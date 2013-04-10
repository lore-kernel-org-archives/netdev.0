From: Takashi Yoshii <takashi.yoshii.zj@renesas.com>
Subject: [PATCH] ipconfig: stop ip-config if disabled method directed
Date: Wed, 10 Apr 2013 16:23:54 +0900
Message-ID: <5165138A.7070006@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:44207 "EHLO
	relmlor3.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936388Ab3DJHX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 03:23:57 -0400
Received: from relmlir1.idc.renesas.com ([10.200.68.151])
 by relmlor3.idc.renesas.com ( SJSMS)
 with ESMTP id <0ML10049C37VGT80@relmlor3.idc.renesas.com> for
 netdev@vger.kernel.org; Wed, 10 Apr 2013 16:23:55 +0900 (JST)
Received: from relmlac1.idc.renesas.com ([10.200.69.21])
 by relmlir1.idc.renesas.com (SJSMS)
 with ESMTP id <0ML100A9Q37V5U10@relmlir1.idc.renesas.com> for
 netdev@vger.kernel.org; Wed, 10 Apr 2013 16:23:55 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Looks insignificant, but a misusage of kernel level auto configuration
results in an invalid ipv4 address set.
That is a kind of corner case, but I think it is be better sanitizing
 the input a bit more for our simple in_aton().
--

CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=n
Command line: ip=dhcp
result in false ip address 62.0.0.0 set.

If directed autoconf method is not compiled into the kernel,
ip-config should be terminated.

Signed-off-by: Takashi Yoshii <takashi.yoshii.zj@renesas.com>
---
 net/ipv4/ipconfig.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index bf6c5cf..6401aac 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1586,6 +1586,16 @@ static int __init ip_auto_config_setup(char *addrs)
 	if (ic_proto_name(addrs))
 		return 1;
 
+	/* This mean the kernel is not configured to have the method. */
+	if (strcmp(addrs, "dhcp") == 0 ||
+	    strcmp(addrs, "bootp") == 0 ||
+	    strcmp(addrs, "rarp") == 0 ||
+	    strcmp(addrs, "both") == 0) {
+		pr_warn("IP-Config: autoconf [%s] not compiled in\n", addrs);
+		ic_enable = 0;
+		return 1;
+	}
+
 	/* If no static IP is given, turn off autoconfig and bail.  */
 	if (*addrs == 0 ||
 	    strcmp(addrs, "off") == 0 ||
-- 
1.8.1.5
