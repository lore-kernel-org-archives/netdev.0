From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v2 3/9] llc: add support for SO_BINDTODEVICE
Date: Thu, 24 Dec 2009 01:45:28 +0200
Message-ID: <1261611934-24348-4-git-send-email-opurdila@ixiacom.com>
References: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23684 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757526AbZLWXs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:48:58 -0500
In-Reply-To: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using bind(MAC address) with LLC sockets has O(n) complexity, where n
is the number of interfaces. To overcome this, we add support for
SO_BINDTODEVICE which drops the complexity to O(1).

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/llc/af_llc.c |   29 +++++++++++++++++++++++++++--
 1 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index ac691fe..c4d1a1d 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -259,7 +259,14 @@ static int llc_ui_autobind(struct socket *sock, struct sockaddr_llc *addr)
 	if (!sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 	rc = -ENODEV;
-	llc->dev = dev_getfirstbyhwtype(&init_net, addr->sllc_arphrd);
+	if (sk->sk_bound_dev_if) {
+		llc->dev = dev_get_by_index(&init_net, sk->sk_bound_dev_if);
+		if (llc->dev && addr->sllc_arphrd != llc->dev->type) {
+			dev_put(llc->dev);
+			llc->dev = NULL;
+		}
+	} else
+		llc->dev = dev_getfirstbyhwtype(&init_net, addr->sllc_arphrd);
 	if (!llc->dev)
 		goto out;
 	rc = -EUSERS;
@@ -310,7 +317,25 @@ static int llc_ui_bind(struct socket *sock, struct sockaddr *uaddr, int addrlen)
 		goto out;
 	rc = -ENODEV;
 	rtnl_lock();
-	llc->dev = dev_getbyhwaddr(&init_net, addr->sllc_arphrd, addr->sllc_mac);
+	if (sk->sk_bound_dev_if) {
+		llc->dev = dev_get_by_index(&init_net, sk->sk_bound_dev_if);
+		if (llc->dev) {
+			if (!addr->sllc_arphrd)
+				addr->sllc_arphrd = llc->dev->type;
+			if (llc_mac_null(addr->sllc_mac))
+				memcpy(addr->sllc_mac, llc->dev->dev_addr,
+				       IFHWADDRLEN);
+			if (addr->sllc_arphrd != llc->dev->type ||
+			    !llc_mac_match(addr->sllc_mac,
+					   llc->dev->dev_addr)) {
+				rc = -EINVAL;
+				dev_put(llc->dev);
+				llc->dev = NULL;
+			}
+		}
+	} else
+		llc->dev = dev_getbyhwaddr(&init_net, addr->sllc_arphrd,
+					   addr->sllc_mac);
 	rtnl_unlock();
 	if (!llc->dev)
 		goto out;
-- 
1.5.6.5

