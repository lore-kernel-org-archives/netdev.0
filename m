From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/4] Cleanup the xfrm4_tunnel_(un)register
Date: Fri, 09 Nov 2007 16:16:23 +0300
Message-ID: <47345DA7.2030107@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:45444 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754171AbXKINQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 08:16:43 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both check for the family to select an appropriate tunnel list.
Consolidate this check and make the for() loop more readable.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 7938430..b662a9e 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -18,6 +18,11 @@ static struct xfrm_tunnel *tunnel4_handlers;
 static struct xfrm_tunnel *tunnel64_handlers;
 static DEFINE_MUTEX(tunnel4_mutex);
 
+static inline struct xfrm_tunnel **fam_handlers(unsigned short family)
+{
+	return (family == AF_INET) ? &tunnel4_handlers : &tunnel64_handlers;
+}
+
 int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family)
 {
 	struct xfrm_tunnel **pprev;
@@ -26,8 +31,7 @@ int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family)
 
 	mutex_lock(&tunnel4_mutex);
 
-	for (pprev = (family == AF_INET) ? &tunnel4_handlers : &tunnel64_handlers;
-	     *pprev; pprev = &(*pprev)->next) {
+	for (pprev = fam_handlers(family); *pprev; pprev = &(*pprev)->next) {
 		if ((*pprev)->priority > priority)
 			break;
 		if ((*pprev)->priority == priority)
@@ -54,8 +58,7 @@ int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family)
 
 	mutex_lock(&tunnel4_mutex);
 
-	for (pprev = (family == AF_INET) ? &tunnel4_handlers : &tunnel64_handlers;
-	     *pprev; pprev = &(*pprev)->next) {
+	for (pprev = fam_handlers(family); *pprev; pprev = &(*pprev)->next) {
 		if (*pprev == handler) {
 			*pprev = handler->next;
 			ret = 0;
-- 
1.5.3.4

