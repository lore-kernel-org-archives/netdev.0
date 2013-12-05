From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 6/9] xfrm: Add xfrm_tunnel_skb_cb to the skb common buffer
Date: Thu, 5 Dec 2013 13:03:53 +0100
Message-ID: <20131205120353.GC31491@secunet.com>
References: <20131205120028.GW31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55541 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755656Ab3LEMD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 07:03:56 -0500
Content-Disposition: inline
In-Reply-To: <20131205120028.GW31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPsec vti_rcv needs to remind the tunnel pointer to
check it later at the vti_rcv_cb callback. So add
this pointer to the IPsec common buffer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 7f71462..8295b4c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -600,16 +600,24 @@ struct xfrm_mgr {
 int xfrm_register_km(struct xfrm_mgr *km);
 int xfrm_unregister_km(struct xfrm_mgr *km);
 
+struct xfrm_tunnel_skb_cb {
+	union {
+		struct inet_skb_parm h4;
+		struct inet6_skb_parm h6;
+        } header;
+
+	struct ip_tunnel *tunnel;
+};
+
+#define XFRM_TUNNEL_SKB_CB(__skb) ((struct xfrm_tunnel_skb_cb *)&((__skb)->cb[0]))
+
 /*
  * This structure is used for the duration where packets are being
  * transformed by IPsec.  As soon as the packet leaves IPsec the
  * area beyond the generic IP part may be overwritten.
  */
 struct xfrm_skb_cb {
-	union {
-		struct inet_skb_parm h4;
-		struct inet6_skb_parm h6;
-        } header;
+	struct xfrm_tunnel_skb_cb header;
 
         /* Sequence number for replay protection. */
 	union {
@@ -631,10 +639,7 @@ struct xfrm_skb_cb {
  * to transmit header information to the mode input/output functions.
  */
 struct xfrm_mode_skb_cb {
-	union {
-		struct inet_skb_parm h4;
-		struct inet6_skb_parm h6;
-	} header;
+	struct xfrm_tunnel_skb_cb header;
 
 	/* Copied from header for IPv4, always set to zero and DF for IPv6. */
 	__be16 id;
@@ -666,10 +671,7 @@ struct xfrm_mode_skb_cb {
  * related information.
  */
 struct xfrm_spi_skb_cb {
-	union {
-		struct inet_skb_parm h4;
-		struct inet6_skb_parm h6;
-	} header;
+	struct xfrm_tunnel_skb_cb header;
 
 	unsigned int daddroff;
 	unsigned int family;
-- 
1.7.9.5
