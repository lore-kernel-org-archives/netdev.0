From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH net] hv_sock: add locking in the open/close/release code paths
Date: Thu, 19 Oct 2017 03:33:14 +0000
Message-ID: <KL1P15301MB0006B746A23A2FCE695D08DEBF420@KL1P15301MB0006.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jork Loeser <Jork.Loeser@microsoft.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Marcelo Cerri <marcelo.cerri@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, Vitaly
 Kuznetsov <vkuznets@redhat.com>
To: "David S. Miller" <davem@davemloft.net>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, "KY
 Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org


Without the patch, when hvs_open_connection() hasn't completely established
a connection (e.g. it has changed sk->sk_state to SS_CONNECTED, but hasn't
inserted the sock into the connected queue), vsock_stream_connect() may see
the sk_state change and return the connection to the userspace, and next
when the userspace closes the connection quickly, hvs_release() may not see
the connection in the connected queue; finally hvs_open_connection()
inserts the connection into the queue, but we won't be able to purge the
connection for ever.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
Cc: K. Y. Srinivasan <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Cathy Avery <cavery@redhat.com>
Cc: Rolf Neugebauer <rolf.neugebauer@docker.com>
Cc: Marcelo Cerri <marcelo.cerri@canonical.com>
---

Please consider this for v4.14.

 net/vmw_vsock/hyperv_transport.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/vmw_vsock/hyperv_transport.c b/net/vmw_vsock/hyperv_transport.c
index 14ed5a3..e21991f 100644
--- a/net/vmw_vsock/hyperv_transport.c
+++ b/net/vmw_vsock/hyperv_transport.c
@@ -310,11 +310,15 @@ static void hvs_close_connection(struct vmbus_channel *chan)
 	struct sock *sk = get_per_channel_state(chan);
 	struct vsock_sock *vsk = vsock_sk(sk);
 
+	lock_sock(sk);
+
 	sk->sk_state = SS_UNCONNECTED;
 	sock_set_flag(sk, SOCK_DONE);
 	vsk->peer_shutdown |= SEND_SHUTDOWN | RCV_SHUTDOWN;
 
 	sk->sk_state_change(sk);
+
+	release_sock(sk);
 }
 
 static void hvs_open_connection(struct vmbus_channel *chan)
@@ -344,6 +348,8 @@ static void hvs_open_connection(struct vmbus_channel *chan)
 	if (!sk)
 		return;
 
+	lock_sock(sk);
+
 	if ((conn_from_host && sk->sk_state != VSOCK_SS_LISTEN) ||
 	    (!conn_from_host && sk->sk_state != SS_CONNECTING))
 		goto out;
@@ -395,9 +401,7 @@ static void hvs_open_connection(struct vmbus_channel *chan)
 
 		vsock_insert_connected(vnew);
 
-		lock_sock(sk);
 		vsock_enqueue_accept(sk, new);
-		release_sock(sk);
 	} else {
 		sk->sk_state = SS_CONNECTED;
 		sk->sk_socket->state = SS_CONNECTED;
@@ -410,6 +414,8 @@ static void hvs_open_connection(struct vmbus_channel *chan)
 out:
 	/* Release refcnt obtained when we called vsock_find_bound_socket() */
 	sock_put(sk);
+
+	release_sock(sk);
 }
 
 static u32 hvs_get_local_cid(void)
@@ -476,13 +482,21 @@ static int hvs_shutdown(struct vsock_sock *vsk, int mode)
 
 static void hvs_release(struct vsock_sock *vsk)
 {
+	struct sock *sk = sk_vsock(vsk);
 	struct hvsock *hvs = vsk->trans;
-	struct vmbus_channel *chan = hvs->chan;
+	struct vmbus_channel *chan;
 
+	lock_sock(sk);
+
+	sk->sk_state = SS_DISCONNECTING;
+	vsock_remove_sock(vsk);
+
+	release_sock(sk);
+
+	chan = hvs->chan;
 	if (chan)
 		hvs_shutdown(vsk, RCV_SHUTDOWN | SEND_SHUTDOWN);
 
-	vsock_remove_sock(vsk);
 }
 
 static void hvs_destruct(struct vsock_sock *vsk)
-- 
2.7.4
