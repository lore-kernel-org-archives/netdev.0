From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH 2/5] ipvs: Use ERR_PTR for returning errors from make_receive_sock() and make_send_sock()
Date: Sun, 29 Jun 2008 19:32:43 +0200
Message-ID: <1214760766-1526-3-git-send-email-sven.wegener@stealer.net>
References: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:55418 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755140AbYF2SEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 14:04:40 -0400
In-Reply-To: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The additional information we now return to the caller is currently not used,
but will be used to return errors to user space.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_sync.c |   46 +++++++++++++++++++++++++------------------
 1 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 6a84c41..035ddf5 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -29,6 +29,7 @@
 #include <linux/in.h>
 #include <linux/igmp.h>                 /* for ip_mc_join_group */
 #include <linux/udp.h>
+#include <linux/err.h>
 
 #include <net/ip.h>
 #include <net/sock.h>
@@ -578,14 +579,17 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
 static struct socket * make_send_sock(void)
 {
 	struct socket *sock;
+	int result;
 
 	/* First create a socket */
-	if (sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock) < 0) {
+	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	if (result < 0) {
 		IP_VS_ERR("Error during creation of socket; terminating\n");
-		return NULL;
+		return ERR_PTR(result);
 	}
 
-	if (set_mcast_if(sock->sk, ip_vs_master_mcast_ifn) < 0) {
+	result = set_mcast_if(sock->sk, ip_vs_master_mcast_ifn);
+	if (result < 0) {
 		IP_VS_ERR("Error setting outbound mcast interface\n");
 		goto error;
 	}
@@ -593,14 +597,15 @@ static struct socket * make_send_sock(void)
 	set_mcast_loop(sock->sk, 0);
 	set_mcast_ttl(sock->sk, 1);
 
-	if (bind_mcastif_addr(sock, ip_vs_master_mcast_ifn) < 0) {
+	result = bind_mcastif_addr(sock, ip_vs_master_mcast_ifn);
+	if (result < 0) {
 		IP_VS_ERR("Error binding address of the mcast interface\n");
 		goto error;
 	}
 
-	if (sock->ops->connect(sock,
-			       (struct sockaddr*)&mcast_addr,
-			       sizeof(struct sockaddr), 0) < 0) {
+	result = sock->ops->connect(sock, (struct sockaddr *) &mcast_addr,
+			sizeof(struct sockaddr), 0);
+	if (result < 0) {
 		IP_VS_ERR("Error connecting to the multicast addr\n");
 		goto error;
 	}
@@ -609,7 +614,7 @@ static struct socket * make_send_sock(void)
 
   error:
 	sock_release(sock);
-	return NULL;
+	return ERR_PTR(result);
 }
 
 
@@ -619,27 +624,30 @@ static struct socket * make_send_sock(void)
 static struct socket * make_receive_sock(void)
 {
 	struct socket *sock;
+	int result;
 
 	/* First create a socket */
-	if (sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock) < 0) {
+	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	if (result < 0) {
 		IP_VS_ERR("Error during creation of socket; terminating\n");
-		return NULL;
+		return ERR_PTR(result);
 	}
 
 	/* it is equivalent to the REUSEADDR option in user-space */
 	sock->sk->sk_reuse = 1;
 
-	if (sock->ops->bind(sock,
-			    (struct sockaddr*)&mcast_addr,
-			    sizeof(struct sockaddr)) < 0) {
+	result = sock->ops->bind(sock, (struct sockaddr *) &mcast_addr,
+			sizeof(struct sockaddr));
+	if (result < 0) {
 		IP_VS_ERR("Error binding to the multicast addr\n");
 		goto error;
 	}
 
 	/* join the multicast group */
-	if (join_mcast_group(sock->sk,
-			     (struct in_addr*)&mcast_addr.sin_addr,
-			     ip_vs_backup_mcast_ifn) < 0) {
+	result = join_mcast_group(sock->sk,
+			(struct in_addr *) &mcast_addr.sin_addr,
+			ip_vs_backup_mcast_ifn);
+	if (result < 0) {
 		IP_VS_ERR("Error joining to the multicast group\n");
 		goto error;
 	}
@@ -648,7 +656,7 @@ static struct socket * make_receive_sock(void)
 
   error:
 	sock_release(sock);
-	return NULL;
+	return ERR_PTR(result);
 }
 
 
@@ -721,7 +729,7 @@ static void sync_master_loop(void)
 
 	/* create the sending multicast socket */
 	sock = make_send_sock();
-	if (!sock)
+	if (IS_ERR(sock))
 		return;
 
 	IP_VS_INFO("sync thread started: state = MASTER, mcast_ifn = %s, "
@@ -774,7 +782,7 @@ static void sync_backup_loop(void)
 
 	/* create the receiving multicast socket */
 	sock = make_receive_sock();
-	if (!sock)
+	if (IS_ERR(sock))
 		goto out;
 
 	IP_VS_INFO("sync thread started: state = BACKUP, mcast_ifn = %s, "
-- 
1.5.6.1

