From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][PACKET] Remove unneeded packet_socks_nr variable
Date: Wed, 07 Nov 2007 18:32:51 +0300
Message-ID: <4731DAA3.7060306@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59586 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274AbXKGPdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 10:33:01 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This one is used only under ifdef PACKET_REFCNT_DEBUG in
printk and is not needed otherwise. So hide all this stuff
under the PACKET_REFCNT_DEBUG.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4cb2dfb..e6a96ee 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -139,8 +139,30 @@ dev->hard_header == NULL (ll header is added by device, we cannot control it)
 static HLIST_HEAD(packet_sklist);
 static DEFINE_RWLOCK(packet_sklist_lock);
 
+#ifdef PACKET_REFCNT_DEBUG
 static atomic_t packet_socks_nr;
 
+static void packet_sock_inc(void)
+{
+	atomic_inc(&packet_socks_nr);
+}
+
+static void packet_sock_dec(void)
+{
+	atomic_dec(&packet_socks_nr);
+	printk(KERN_DEBUG "PACKET socket %p is free, %d are alive\n",
+			sk, atomic_read(&packet_socks_nr));
+}
+#else
+static inline void packet_sock_inc(void)
+{
+}
+
+static inline void packet_sock_dec(void)
+{
+}
+#endif
+
 
 /* Private packet socket structures. */
 
@@ -236,10 +258,7 @@ static void packet_sock_destruct(struct sock *sk)
 		return;
 	}
 
-	atomic_dec(&packet_socks_nr);
-#ifdef PACKET_REFCNT_DEBUG
-	printk(KERN_DEBUG "PACKET socket %p is free, %d are alive\n", sk, atomic_read(&packet_socks_nr));
-#endif
+	packet_sock_dec();
 }
 
 
@@ -1010,7 +1029,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
 	po->num = proto;
 
 	sk->sk_destruct = packet_sock_destruct;
-	atomic_inc(&packet_socks_nr);
+	packet_sock_inc();
 
 	/*
 	 *	Attach a protocol block
-- 
1.5.3.4

