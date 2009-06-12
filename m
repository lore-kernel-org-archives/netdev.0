From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] cnic: fix build for INET=n or IPV6=m
Date: Fri, 12 Jun 2009 10:44:09 -0700
Message-ID: <4A3293E9.7020204@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:25601 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbZFLRrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 13:47:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix cnic build for case of CONFIG_INET=n.
Fix cnic build for case of CONFIG_IPV6=m and CONFIG_CNIC=y.

Fixes these build errors (from different builds):

cnic.c:(.text+0x236a1d): undefined reference to `ip_route_output_key'
cnic.c:(.text+0x15a8e8): undefined reference to `ip6_route_output'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/cnic.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

--- linux-next-20090612.orig/drivers/net/cnic.c
+++ linux-next-20090612/drivers/net/cnic.c
@@ -1454,6 +1454,7 @@ static inline u16 cnic_get_vlan(struct n
 static int cnic_get_v4_route(struct sockaddr_in *dst_addr,
 			     struct dst_entry **dst)
 {
+#if defined(CONFIG_INET)
 	struct flowi fl;
 	int err;
 	struct rtable *rt;
@@ -1465,12 +1466,15 @@ static int cnic_get_v4_route(struct sock
 	if (!err)
 		*dst = &rt->u.dst;
 	return err;
+#else
+	return -ENETUNREACH;
+#endif
 }
 
 static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
 			     struct dst_entry **dst)
 {
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
 	struct flowi fl;
 
 	memset(&fl, 0, sizeof(fl));
@@ -1550,7 +1554,7 @@ static int cnic_get_route(struct cnic_so
 	clear_bit(SK_F_IPV6, &csk->flags);
 
 	if (is_v6) {
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
 		set_bit(SK_F_IPV6, &csk->flags);
 		err = cnic_get_v6_route(&saddr->remote.v6, &dst);
 		if (err)

-- 
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
