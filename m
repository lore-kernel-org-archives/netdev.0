From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 11/21] netlink: Make the sending netlink socket availabe in
	NETLINK_CB
Date: Mon, 13 Aug 2012 13:18:25 -0700
Message-ID: <1344889115-21610-11-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1344889115-21610-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

The sending socket of an skb is already available by it's port id
in the NETLINK_CB.  If you want to know more like to examine the
credentials on the sending socket you have to look up the sending
socket by it's port id and all of the needed functions and data
structures are static inside of af_netlink.c.  So do the simple
thing and pass the sending socket to the receivers in the NETLINK_CB.

I intend to use this to get the user namespace of the sending socket
in inet_diag so that I can report uids in the context of the process
who opened the socket, the same way I report uids in the contect
of the process who opens files.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f74dd13..c9fdde2 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -165,6 +165,7 @@ struct netlink_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	__u32			pid;
 	__u32			dst_group;
+	struct sock		*ssk;
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5463969..7cb7867 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -912,7 +912,8 @@ static void netlink_rcv_wake(struct sock *sk)
 		wake_up_interruptible(&nlk->wait);
 }
 
-static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb)
+static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
+				  struct sock *ssk)
 {
 	int ret;
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -921,6 +922,7 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb)
 	if (nlk->netlink_rcv != NULL) {
 		ret = skb->len;
 		skb_set_owner_r(skb, sk);
+		NETLINK_CB(skb).ssk = ssk;
 		nlk->netlink_rcv(skb);
 		consume_skb(skb);
 	} else {
@@ -947,7 +949,7 @@ retry:
 		return PTR_ERR(sk);
 	}
 	if (netlink_is_kernel(sk))
-		return netlink_unicast_kernel(sk, skb);
+		return netlink_unicast_kernel(sk, skb, ssk);
 
 	if (sk_filter(sk, skb)) {
 		err = skb->len;
-- 
1.7.5.4
