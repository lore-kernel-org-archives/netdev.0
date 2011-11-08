From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH] route: add more relaxed option for secure_redirects
Date: Mon,  7 Nov 2011 22:03:50 -0200
Message-ID: <1320710630-28335-1-git-send-email-fbl@redhat.com>
References: <20111107170517.6acb1f87@asterix.rh>
Cc: David Miller <davem@davemloft.net>, Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894Ab1KHAEF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 19:04:05 -0500
In-Reply-To: <20111107170517.6acb1f87@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the host uses a gateway IP address that is actually an alias
address, the ICMP redirect message source address can be the gateway's
main IP address, so the message is ignored by the host regardless of
the secure_redirects setup.

The new value (2) allows that ICMP message to be processed.
The possible values are:

 0 - Accept ICMP redirect messages only if its source address is the
     previous gateway address.
 1 - The same as above. However, if shared_media is FALSE, it has to
     be for gateways listed in default gateway list as well.
 2 - Accept ICMP redirects messages ignoring the conditions above.
 default value is 1.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 Documentation/networking/ip-sysctl.txt |   17 ++++++++++-------
 include/linux/icmp.h                   |    5 +++++
 include/linux/inetdevice.h             |    2 +-
 net/ipv4/route.c                       |    6 ++++--
 4 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index cb7f314..f17727d 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -805,13 +805,16 @@ shared_media - BOOLEAN
 	it will be disabled otherwise
 	default TRUE
 
-secure_redirects - BOOLEAN
-	Accept ICMP redirect messages only for gateways,
-	listed in default gateway list.
-	secure_redirects for the interface will be enabled if at least one of
-	conf/{all,interface}/secure_redirects is set to TRUE,
-	it will be disabled otherwise
-	default TRUE
+secure_redirects - INTEGER
+	0 - Accept ICMP redirect messages only if its source address is the
+	    previous gateway address.
+	1 - The same as above. However, if shared_media is FALSE, it has to
+	    be for gateways listed in default gateway list as well.
+	2 - Accept ICMP redirects messages ignoring the conditions above.
+	default value is 1.
+
+	The max value from conf/{all,interface}/secure_redirects is used
+	when doing the ICMP redirect message validation on the {interface}.
 
 send_redirects - BOOLEAN
 	Send redirects, if router.
diff --git a/include/linux/icmp.h b/include/linux/icmp.h
index 474f2a5..77f0c2d 100644
--- a/include/linux/icmp.h
+++ b/include/linux/icmp.h
@@ -64,6 +64,11 @@
 #define ICMP_EXC_TTL		0	/* TTL count exceeded		*/
 #define ICMP_EXC_FRAGTIME	1	/* Fragment Reass time exceeded	*/
 
+/* secure_redirects sysctl */
+#define ICMP_SEC_REDIR_OLDGW	0	/* accept only from old gw	*/
+#define ICMP_SEC_REDIR_TOGW	1	/* accept only from old gw and
+					 * to known listed gw */
+#define ICMP_SEC_REDIR_ANY	2	/* accept from any host		*/
 
 struct icmphdr {
   __u8		type;
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 5f81466..eca2cfb 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -124,7 +124,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_PROXY_ARP_PVLAN(in_dev)	IN_DEV_CONF_GET(in_dev, PROXY_ARP_PVLAN)
 #define IN_DEV_SHARED_MEDIA(in_dev)	IN_DEV_ORCONF((in_dev), SHARED_MEDIA)
 #define IN_DEV_TX_REDIRECTS(in_dev)	IN_DEV_ORCONF((in_dev), SEND_REDIRECTS)
-#define IN_DEV_SEC_REDIRECTS(in_dev)	IN_DEV_ORCONF((in_dev), \
+#define IN_DEV_SEC_REDIRECTS(in_dev)	IN_DEV_MAXCONF((in_dev), \
 						      SECURE_REDIRECTS)
 #define IN_DEV_IDTAG(in_dev)		IN_DEV_CONF_GET(in_dev, TAG)
 #define IN_DEV_MEDIUM_ID(in_dev)	IN_DEV_CONF_GET(in_dev, MEDIUM_ID)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 155138d..ec3ce37 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1329,7 +1329,8 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 	if (!IN_DEV_SHARED_MEDIA(in_dev)) {
 		if (!inet_addr_onlink(in_dev, new_gw, old_gw))
 			goto reject_redirect;
-		if (IN_DEV_SEC_REDIRECTS(in_dev) && ip_fib_check_default(new_gw, dev))
+		if (IN_DEV_SEC_REDIRECTS(in_dev) == ICMP_SEC_REDIR_TOGW &&
+		    ip_fib_check_default(new_gw, dev))
 			goto reject_redirect;
 	} else {
 		if (inet_addr_type(net, new_gw) != RTN_UNICAST)
@@ -1347,7 +1348,8 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				continue;
 
 			if (rt->dst.error || rt->dst.dev != dev ||
-			    rt->rt_gateway != old_gw) {
+			    (IN_DEV_SEC_REDIRECTS(in_dev) != ICMP_SEC_REDIR_ANY &&
+			    rt->rt_gateway != old_gw)) {
 				ip_rt_put(rt);
 				continue;
 			}
-- 
1.7.6
