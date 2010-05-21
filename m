From: sjur.brandeland@stericsson.com
Subject: [PATCH net-2.6 5/6] caif: Bugfix - missing spin_unlock
Date: Fri, 21 May 2010 14:16:11 +0200
Message-ID: <1274444172-31969-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1274444172-31969-1-git-send-email-sjur.brandeland@stericsson.com>
 <1274444172-31969-2-git-send-email-sjur.brandeland@stericsson.com>
 <1274444172-31969-3-git-send-email-sjur.brandeland@stericsson.com>
 <1274444172-31969-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: sjurbr@gmail.com, linus.walleij@stericsson.com,
	marcel@holtmann.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:44152 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996Ab0EUMQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 08:16:48 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2R003TSRFBK140@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Fri, 21 May 2010 14:16:23 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2R006WURF8S590@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Fri, 21 May 2010 14:16:23 +0200 (CEST)
In-reply-to: <1274444172-31969-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Splint found missing spin_unlock.
Corrected this an some other trivial split warnings.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   10 +++++-----
 net/caif/cfmuxl.c      |    3 ++-
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 732897d..691a571 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -60,7 +60,7 @@ struct debug_fs_counter {
 	atomic_t num_rx_flow_off;
 	atomic_t num_rx_flow_on;
 };
-struct debug_fs_counter cnt;
+static struct debug_fs_counter cnt;
 #define	dbfs_atomic_inc(v) atomic_inc(v)
 #define	dbfs_atomic_dec(v) atomic_dec(v)
 #else
@@ -128,13 +128,13 @@ static void caif_read_unlock(struct sock *sk)
 	mutex_unlock(&cf_sk->readlock);
 }
 
-int sk_rcvbuf_lowwater(struct caifsock *cf_sk)
+static int sk_rcvbuf_lowwater(struct caifsock *cf_sk)
 {
 	/* A quarter of full buffer is used a low water mark */
 	return cf_sk->sk.sk_rcvbuf / 4;
 }
 
-void caif_flow_ctrl(struct sock *sk, int mode)
+static void caif_flow_ctrl(struct sock *sk, int mode)
 {
 	struct caifsock *cf_sk;
 	cf_sk = container_of(sk, struct caifsock, sk);
@@ -146,7 +146,7 @@ void caif_flow_ctrl(struct sock *sk, int mode)
  * Copied from sock.c:sock_queue_rcv_skb(), but changed so packets are
  * not dropped, but CAIF is sending flow off instead.
  */
-int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
 	int skb_len;
@@ -1184,7 +1184,7 @@ static struct net_proto_family caif_family_ops = {
 	.owner = THIS_MODULE,
 };
 
-int af_caif_init(void)
+static int af_caif_init(void)
 {
 	int err = sock_register(&caif_family_ops);
 	if (!err)
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 7372f27..80c8d33 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -174,10 +174,11 @@ struct cflayer *cfmuxl_remove_uplayer(struct cflayer *layr, u8 id)
 	spin_lock(&muxl->receive_lock);
 	up = get_up(muxl, id);
 	if (up == NULL)
-		return NULL;
+		goto out;
 	memset(muxl->up_cache, 0, sizeof(muxl->up_cache));
 	list_del(&up->node);
 	cfsrvl_put(up);
+out:
 	spin_unlock(&muxl->receive_lock);
 	return up;
 }
-- 
1.6.3.3

