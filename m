From: "Herton R. Krzesinski" <herton@redhat.com>
Subject: [PATCH 3/3] net/rds: fix possible double free on sock tear down
Date: Wed,  1 Oct 2014 18:49:54 -0300
Message-ID: <1412200194-28902-4-git-send-email-herton@redhat.com>
References: <1412200194-28902-1-git-send-email-herton@redhat.com>
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, rmanes@redhat.com,
	dledford@redhat.com
To: Chien Yen <chien.yen@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412200194-28902-1-git-send-email-herton@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I got a report of a double free happening at RDS slab cache. One
suspicion was that may be somewhere we were doing a sock_hold/sock_put
on an already freed sock. Thus after providing a kernel with the
following change:

 static inline void sock_hold(struct sock *sk)
 {
-       atomic_inc(&sk->sk_refcnt);
+       if (!atomic_inc_not_zero(&sk->sk_refcnt))
+               WARN(1, "Trying to hold sock already gone: %p (family: %hd)\n",
+                       sk, sk->sk_family);
 }

The warning successfuly triggered:

Trying to hold sock already gone: ffff81f6dda61280 (family: 21)
WARNING: at include/net/sock.h:350 sock_hold()
Call Trace:
<IRQ>  [<ffffffff8adac135>] :rds:rds_send_remove_from_sock+0xf0/0x21b
[<ffffffff8adad35c>] :rds:rds_send_drop_acked+0xbf/0xcf
[<ffffffff8addf546>] :rds_rdma:rds_ib_recv_tasklet_fn+0x256/0x2dc
[<ffffffff8009899a>] tasklet_action+0x8f/0x12b
[<ffffffff800125a2>] __do_softirq+0x89/0x133
[<ffffffff8005f30c>] call_softirq+0x1c/0x28
[<ffffffff8006e644>] do_softirq+0x2c/0x7d
[<ffffffff8006e4d4>] do_IRQ+0xee/0xf7
[<ffffffff8005e625>] ret_from_intr+0x0/0xa
<EOI>

Looking at the call chain above, the only way I think this would be
possible is if somewhere we already released the same socket->sock which
is assigned to the rds_message at rds_send_remove_from_sock. Which seems
only possible to happen after the tear down done on rds_release.

rds_release properly calls rds_send_drop_to to drop the socket from any
rds_message, and some proper synchronization is in place to avoid race
with rds_send_drop_acked/rds_send_remove_from_sock. However, I still see
a very narrow window where it may be possible we touch a sock already
released: when rds_release races with rds_send_drop_acked, we check
RDS_MSG_ON_CONN to avoid cleanup on the same rds_message, but in this
specific case we don't clear rm->m_rs. In this case, it seems we could
then go on at rds_send_drop_to and after it returns, the sock is freed
by last sock_put on rds_release, with concurrently we being at
rds_send_remove_from_sock; then at some point in the loop at
rds_send_remove_from_sock we process an rds_message which didn't have
rm->m_rs unset for a freed sock, and a possible sock_hold on an sock
already gone at rds_release happens.

This hopefully address the described condition above and avoids a double
free on "second last" sock_put. In addition, I removed the comment about
socket destruction on top of rds_send_drop_acked: we call rds_send_drop_to
in rds_release and we should have things properly serialized there, thus
I can't see the comment being accurate there.

Signed-off-by: Herton R. Krzesinski <herton@redhat.com>
---
 net/rds/send.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 2371816..0a64541 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -593,8 +593,11 @@ static void rds_send_remove_from_sock(struct list_head *messages, int status)
 				sock_put(rds_rs_to_sk(rs));
 			}
 			rs = rm->m_rs;
-			sock_hold(rds_rs_to_sk(rs));
+			if (rs)
+				sock_hold(rds_rs_to_sk(rs));
 		}
+		if (!rs)
+			goto unlock_and_drop;
 		spin_lock(&rs->rs_lock);
 
 		if (test_and_clear_bit(RDS_MSG_ON_SOCK, &rm->m_flags)) {
@@ -638,9 +641,6 @@ unlock_and_drop:
  * queue. This means that in the TCP case, the message may not have been
  * assigned the m_ack_seq yet - but that's fine as long as tcp_is_acked
  * checks the RDS_MSG_HAS_ACK_SEQ bit.
- *
- * XXX It's not clear to me how this is safely serialized with socket
- * destruction.  Maybe it should bail if it sees SOCK_DEAD.
  */
 void rds_send_drop_acked(struct rds_connection *conn, u64 ack,
 			 is_acked_func is_acked)
@@ -711,6 +711,9 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 		 */
 		if (!test_and_clear_bit(RDS_MSG_ON_CONN, &rm->m_flags)) {
 			spin_unlock_irqrestore(&conn->c_lock, flags);
+			spin_lock_irqsave(&rm->m_rs_lock, flags);
+			rm->m_rs = NULL;
+			spin_unlock_irqrestore(&rm->m_rs_lock, flags);
 			continue;
 		}
 		list_del_init(&rm->m_conn_item);
-- 
1.9.3
