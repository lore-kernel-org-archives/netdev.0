From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] tcp: make H-TCP the default congestion control
Date: Fri, 31 Oct 2008 12:16:25 -0700
Message-ID: <20081031121625.3c1a463e@extreme>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
	<20081030083641.55e936b0@extreme>
	<20081031.005033.172610018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rhee@eos.ncsu.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35445 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbYJaTQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 15:16:33 -0400
In-Reply-To: <20081031.005033.172610018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new version of CUBIC is not as tested as H-TCP. Therefore it is
prudent to make H-TCP the default congestion control for one (or more)
releases until the new HyStart code has been real world tested.

This is likely to generate interesting discussion and testing.
Both H-TCP and CUBIC are robust.  For most users, there will be no
perceivable difference, but for users with excessively large queues (DSL ISPs)
H-TCP is more fair. One CUBIC flow fills the queue, and the second
flow never pushes hard enough to cause fairness.

For researchers with very high speed networks
with switches with minuscule queues, CUBIC works better.
H-TCP sees the packet loss from the small queue and reduces
sending rate.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/Kconfig	2008-10-30 08:18:10.000000000 -0700
+++ b/net/ipv4/Kconfig	2008-10-30 08:31:32.000000000 -0700
@@ -429,7 +429,7 @@ menuconfig TCP_CONG_ADVANCED
 	  modules.
 
 	  Nearly all users can safely say no here, and a safe default
-	  selection will be made (CUBIC with new Reno as a fallback).
+	  selection will be made (H-TCP with new Reno as a fallback).
 
 	  If unsure, say N.
 
@@ -457,7 +457,7 @@ config TCP_CONG_BIC
 
 config TCP_CONG_CUBIC
 	tristate "CUBIC TCP"
-	default y
+	default m
 	---help---
 	CUBIC TCP is an sender-side only modification to the congestion control
 	algothrim improved versions on the growth function of BIC and has an
@@ -483,7 +483,7 @@ config TCP_CONG_WESTWOOD
 
 config TCP_CONG_HTCP
         tristate "H-TCP"
-        default m
+        default y
 	---help---
 	H-TCP is a send-side only modifications of the TCP Reno
 	protocol stack that optimizes the performance of TCP
@@ -586,17 +586,17 @@ config TCP_CONG_ILLINOIS
 
 choice
 	prompt "Default TCP congestion control"
-	default DEFAULT_CUBIC
+	default DEFAULT_HTCP
 	help
 	  Select the TCP congestion control that will be used by default
 	  for all connections.
 
-	config DEFAULT_CUBIC
-		bool "Cubic" if TCP_CONG_CUBIC=y
-
 	config DEFAULT_HTCP
 		bool "Htcp" if TCP_CONG_HTCP=y
 
+	config DEFAULT_CUBIC
+		bool "Cubic" if TCP_CONG_CUBIC=y
+
 	config DEFAULT_VEGAS
 		bool "Vegas" if TCP_CONG_VEGAS=y
 
@@ -610,7 +610,7 @@ endchoice
 
 endif
 
-config TCP_CONG_CUBIC
+config TCP_CONG_HTCP
 	tristate
 	depends on !TCP_CONG_ADVANCED
 	default y
@@ -622,7 +622,7 @@ config DEFAULT_TCP_CONG
 	default "vegas" if DEFAULT_VEGAS
 	default "westwood" if DEFAULT_WESTWOOD
 	default "reno" if DEFAULT_RENO
-	default "cubic"
+	default "htcp"
 
 config TCP_MD5SIG
 	bool "TCP: MD5 Signature Option support (RFC2385) (EXPERIMENTAL)"
--- a/arch/arm/configs/afeb9260_defconfig	2008-10-30 08:21:23.000000000 -0700
+++ b/arch/arm/configs/afeb9260_defconfig	2008-10-30 08:21:23.000000000 -0700
@@ -351,7 +351,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/am200epdkit_defconfig	2008-10-30 08:21:23.000000000 -0700
+++ b/arch/arm/configs/am200epdkit_defconfig	2008-10-30 08:21:23.000000000 -0700
@@ -318,7 +318,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/ams_delta_defconfig	2008-10-30 08:21:23.000000000 -0700
+++ b/arch/arm/configs/ams_delta_defconfig	2008-10-30 08:21:23.000000000 -0700
@@ -339,7 +339,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/at91cap9adk_defconfig	2008-10-30 08:21:23.000000000 -0700
+++ b/arch/arm/configs/at91cap9adk_defconfig	2008-10-30 08:21:23.000000000 -0700
@@ -305,7 +305,7 @@ CONFIG_IP_PNP_RARP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/at91sam9260ek_defconfig	2008-10-30 08:21:23.000000000 -0700
+++ b/arch/arm/configs/at91sam9260ek_defconfig	2008-10-30 08:21:23.000000000 -0700
@@ -311,7 +311,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/at91sam9261ek_defconfig	2008-10-30 08:21:23.000000000 -0700
+++ b/arch/arm/configs/at91sam9261ek_defconfig	2008-10-30 08:21:23.000000000 -0700
@@ -308,7 +308,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/at91sam9263ek_defconfig	2008-10-30 08:21:23.000000000 -0700
+++ b/arch/arm/configs/at91sam9263ek_defconfig	2008-10-30 08:21:23.000000000 -0700
@@ -303,7 +303,7 @@ CONFIG_IP_PNP_RARP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/at91sam9g20ek_defconfig	2008-10-30 08:21:23.000000000 -0700
+++ b/arch/arm/configs/at91sam9g20ek_defconfig	2008-10-30 08:21:23.000000000 -0700
@@ -319,7 +319,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/cam60_defconfig	2008-10-30 08:21:23.000000000 -0700
+++ b/arch/arm/configs/cam60_defconfig	2008-10-30 08:21:23.000000000 -0700
@@ -323,7 +323,7 @@ CONFIG_IP_PNP_DHCP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/cm_x300_defconfig	2008-10-30 08:21:23.000000000 -0700
+++ b/arch/arm/configs/cm_x300_defconfig	2008-10-30 08:21:23.000000000 -0700
@@ -366,7 +366,7 @@ CONFIG_IP_PNP_RARP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/colibri_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/colibri_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -302,7 +302,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/arm/configs/corgi_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/corgi_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -366,7 +366,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/csb337_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/csb337_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -332,7 +332,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/csb637_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/csb637_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -355,7 +355,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/ecbat91_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/ecbat91_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -321,7 +321,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/ep93xx_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/ep93xx_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -271,7 +271,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/eseries_pxa_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/eseries_pxa_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -348,7 +348,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/ezx_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/ezx_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -340,7 +340,7 @@ CONFIG_INET_TUNNEL=m
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/arm/configs/imx27ads_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/imx27ads_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -307,7 +307,7 @@ CONFIG_IP_PNP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/iop13xx_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/iop13xx_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -292,7 +292,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/iop32x_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/iop32x_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -295,7 +295,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/iop33x_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/iop33x_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -291,7 +291,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/ixp2000_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/ixp2000_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -271,7 +271,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/ixp23xx_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/ixp23xx_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -267,7 +267,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/ixp4xx_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/ixp4xx_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -328,7 +328,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IP_VS=m
 CONFIG_IP_VS_DEBUG=y
--- a/arch/arm/configs/jornada720_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/jornada720_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -352,7 +352,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/arm/configs/kirkwood_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/kirkwood_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -312,7 +312,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/littleton_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/littleton_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -308,7 +308,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/loki_defconfig	2008-10-30 08:21:24.000000000 -0700
+++ b/arch/arm/configs/loki_defconfig	2008-10-30 08:21:24.000000000 -0700
@@ -305,7 +305,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/lpd270_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/lpd270_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -259,7 +259,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/magician_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/magician_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -314,7 +314,7 @@ CONFIG_IP_PNP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/arm/configs/msm_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/msm_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -275,7 +275,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/mv78xx0_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/mv78xx0_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -314,7 +314,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/mx31ads_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/mx31ads_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -314,7 +314,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/mx31litekit_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/mx31litekit_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -317,7 +317,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/n770_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/n770_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -351,7 +351,7 @@ CONFIG_INET_XFRM_MODE_BEET=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/arm/configs/omap3_beagle_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap3_beagle_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -359,7 +359,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/omap_2430sdp_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_2430sdp_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -342,7 +342,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/omap_apollon_2420_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_apollon_2420_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -334,7 +334,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/omap_generic_1510_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_generic_1510_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -347,7 +347,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/omap_generic_1610_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_generic_1610_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -350,7 +350,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/omap_generic_1710_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_generic_1710_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -344,7 +344,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/omap_h2_1610_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_h2_1610_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -376,7 +376,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/omap_h4_2420_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_h4_2420_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -341,7 +341,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/omap_innovator_1510_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_innovator_1510_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -347,7 +347,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/omap_innovator_1610_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_innovator_1610_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -344,7 +344,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/omap_osk_5912_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_osk_5912_defconfig	2008-10-30 08:21:25.000000000 -0700
@@ -363,7 +363,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/omap_perseus2_730_defconfig	2008-10-30 08:21:25.000000000 -0700
+++ b/arch/arm/configs/omap_perseus2_730_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -343,7 +343,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/onearm_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/onearm_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -292,7 +292,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/orion5x_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/orion5x_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -333,7 +333,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/overo_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/overo_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -376,7 +376,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/palmtt_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/palmtt_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -298,7 +298,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
 # CONFIG_INET6_TUNNEL is not set
--- a/arch/arm/configs/palmz71_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/palmz71_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -328,7 +328,7 @@ CONFIG_INET_XFRM_MODE_BEET=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/palmz72_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/palmz72_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -339,7 +339,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/pcm027_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/pcm027_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -286,7 +286,7 @@ CONFIG_IP_PNP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/pcm037_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/pcm037_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -307,7 +307,7 @@ CONFIG_IP_PNP_DHCP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/pcm038_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/pcm038_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -313,7 +313,7 @@ CONFIG_IP_PNP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/picotux200_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/picotux200_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -291,7 +291,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 CONFIG_IPV6_PRIVACY=y
--- a/arch/arm/configs/qil-a9260_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/qil-a9260_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -333,7 +333,7 @@ CONFIG_IP_PIMSM_V2=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/realview-smp_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/realview-smp_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -262,7 +262,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
 # CONFIG_INET6_TUNNEL is not set
--- a/arch/arm/configs/rpc_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/rpc_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -273,7 +273,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/s3c2410_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/s3c2410_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -390,7 +390,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 CONFIG_IPV6_PRIVACY=y
--- a/arch/arm/configs/sam9_l9260_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/sam9_l9260_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -304,7 +304,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/spitz_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/spitz_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -363,7 +363,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/arm/configs/sx1_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/sx1_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -336,7 +336,7 @@ CONFIG_IP_PNP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/trizeps4_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/trizeps4_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -292,7 +292,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 
 #
--- a/arch/arm/configs/usb-a9260_defconfig	2008-10-30 08:21:26.000000000 -0700
+++ b/arch/arm/configs/usb-a9260_defconfig	2008-10-30 08:21:26.000000000 -0700
@@ -333,7 +333,7 @@ CONFIG_IP_PIMSM_V2=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/usb-a9263_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/arm/configs/usb-a9263_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -325,7 +325,7 @@ CONFIG_IP_PIMSM_V2=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/arm/configs/viper_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/arm/configs/viper_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -366,7 +366,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/xm_x2xx_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/arm/configs/xm_x2xx_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -379,7 +379,7 @@ CONFIG_INET_XFRM_MODE_BEET=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/arm/configs/yl9200_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/arm/configs/yl9200_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -299,7 +299,7 @@ CONFIG_IP_PNP_DHCP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
 # CONFIG_INET6_TUNNEL is not set
--- a/arch/arm/configs/zylonite_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/arm/configs/zylonite_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -292,7 +292,7 @@ CONFIG_IP_PNP_RARP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/avr32/configs/atngw100_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/avr32/configs/atngw100_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -269,7 +269,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
--- a/arch/avr32/configs/atngw100_evklcd100_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/avr32/configs/atngw100_evklcd100_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -267,7 +267,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
--- a/arch/avr32/configs/atngw100_evklcd101_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/avr32/configs/atngw100_evklcd101_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -267,7 +267,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
--- a/arch/avr32/configs/atstk1002_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/avr32/configs/atstk1002_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -270,7 +270,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/avr32/configs/atstk1003_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/avr32/configs/atstk1003_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -261,7 +261,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/avr32/configs/atstk1004_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/avr32/configs/atstk1004_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -205,7 +205,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/avr32/configs/atstk1006_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/avr32/configs/atstk1006_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -270,7 +270,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/avr32/configs/favr-32_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/avr32/configs/favr-32_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -263,7 +263,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/avr32/configs/mimc200_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/avr32/configs/mimc200_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -263,7 +263,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/blackfin/configs/BF526-EZBRD_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/blackfin/configs/BF526-EZBRD_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -421,7 +421,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETLABEL is not set
--- a/arch/blackfin/configs/BF527-EZKIT_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/blackfin/configs/BF527-EZKIT_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -400,7 +400,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/BF533-EZKIT_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/blackfin/configs/BF533-EZKIT_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -369,7 +369,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/BF533-STAMP_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/blackfin/configs/BF533-STAMP_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -369,7 +369,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/BF537-STAMP_defconfig	2008-10-30 08:21:27.000000000 -0700
+++ b/arch/blackfin/configs/BF537-STAMP_defconfig	2008-10-30 08:21:27.000000000 -0700
@@ -376,7 +376,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/BF548-EZKIT_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/BF548-EZKIT_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -439,7 +439,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/BF561-EZKIT_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/BF561-EZKIT_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -410,7 +410,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/BlackStamp_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/BlackStamp_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -396,7 +396,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETLABEL is not set
--- a/arch/blackfin/configs/CM-BF527_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/CM-BF527_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -403,7 +403,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/CM-BF533_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/CM-BF533_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -361,7 +361,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/CM-BF537E_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/CM-BF537E_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -372,7 +372,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/CM-BF537U_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/CM-BF537U_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -369,7 +369,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/CM-BF548_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/CM-BF548_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -437,7 +437,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/CM-BF561_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/CM-BF561_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -404,7 +404,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/H8606_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/H8606_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -361,7 +361,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/IP0X_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/IP0X_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -369,7 +369,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/blackfin/configs/PNAV-10_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/PNAV-10_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -366,7 +366,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/blackfin/configs/SRV1_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/blackfin/configs/SRV1_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -387,7 +387,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/cris/configs/artpec_3_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/cris/configs/artpec_3_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -205,7 +205,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/cris/configs/etrax-100lx_v2_defconfig	2008-10-30 08:21:28.000000000 -0700
+++ b/arch/cris/configs/etrax-100lx_v2_defconfig	2008-10-30 08:21:28.000000000 -0700
@@ -204,7 +204,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/cris/configs/etraxfs_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/cris/configs/etraxfs_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -208,7 +208,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/ia64/configs/generic_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/ia64/configs/generic_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -323,7 +323,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/ia64/configs/tiger_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/ia64/configs/tiger_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -264,7 +264,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/ia64/configs/zx1_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/ia64/configs/zx1_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -261,7 +261,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 
 #
--- a/arch/m32r/configs/m32104ut_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/m32104ut_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -191,7 +191,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/m32r/configs/m32700ut.smp_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/m32700ut.smp_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -203,7 +203,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m32r/configs/m32700ut.up_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/m32700ut.up_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -200,7 +200,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m32r/configs/mappi.nommu_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/mappi.nommu_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -208,7 +208,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m32r/configs/mappi.smp_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/mappi.smp_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -212,7 +212,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m32r/configs/mappi.up_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/mappi.up_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -209,7 +209,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m32r/configs/mappi2.opsp_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/mappi2.opsp_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -209,7 +209,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m32r/configs/mappi2.vdec2_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/mappi2.vdec2_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -207,7 +207,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m32r/configs/mappi3.smp_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/mappi3.smp_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -212,7 +212,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m32r/configs/oaks32r_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/oaks32r_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -193,7 +193,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m32r/configs/opsput_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/opsput_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -210,7 +210,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m32r/configs/usrv_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m32r/configs/usrv_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -215,7 +215,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/m68k/configs/amiga_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m68k/configs/amiga_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -210,7 +210,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/apollo_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m68k/configs/apollo_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -208,7 +208,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/atari_defconfig	2008-10-30 08:21:29.000000000 -0700
+++ b/arch/m68k/configs/atari_defconfig	2008-10-30 08:21:29.000000000 -0700
@@ -206,7 +206,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/bvme6000_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68k/configs/bvme6000_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -210,7 +210,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/hp300_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68k/configs/hp300_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -209,7 +209,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/mac_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68k/configs/mac_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -207,7 +207,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/multi_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68k/configs/multi_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -220,7 +220,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/mvme147_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68k/configs/mvme147_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -210,7 +210,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/mvme16x_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68k/configs/mvme16x_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -210,7 +210,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/q40_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68k/configs/q40_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -207,7 +207,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/sun3_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68k/configs/sun3_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -196,7 +196,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68k/configs/sun3x_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68k/configs/sun3x_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -207,7 +207,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/m68knommu/configs/m5208evb_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68knommu/configs/m5208evb_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -213,7 +213,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/m68knommu/configs/m5275evb_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68knommu/configs/m5275evb_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -216,7 +216,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/m68knommu/configs/m5307c3_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68knommu/configs/m5307c3_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -222,7 +222,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/m68knommu/configs/m5407c3_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68knommu/configs/m5407c3_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -218,7 +218,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/m68knommu/defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/m68knommu/defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -220,7 +220,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/bcm47xx_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/mips/configs/bcm47xx_defconfig	2008-10-30 08:26:00.000000000 -0700
@@ -320,26 +320,10 @@ CONFIG_INET_XFRM_MODE_BEET=m
 CONFIG_INET_LRO=m
 CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
-CONFIG_TCP_CONG_ADVANCED=y
-CONFIG_TCP_CONG_BIC=y
-CONFIG_TCP_CONG_CUBIC=m
-CONFIG_TCP_CONG_WESTWOOD=m
-CONFIG_TCP_CONG_HTCP=m
-CONFIG_TCP_CONG_HSTCP=m
-CONFIG_TCP_CONG_HYBLA=m
-CONFIG_TCP_CONG_VEGAS=m
-CONFIG_TCP_CONG_SCALABLE=m
-CONFIG_TCP_CONG_LP=m
-CONFIG_TCP_CONG_VENO=m
-CONFIG_TCP_CONG_YEAH=m
-CONFIG_TCP_CONG_ILLINOIS=m
-CONFIG_DEFAULT_BIC=y
-# CONFIG_DEFAULT_CUBIC is not set
-# CONFIG_DEFAULT_HTCP is not set
-# CONFIG_DEFAULT_VEGAS is not set
-# CONFIG_DEFAULT_WESTWOOD is not set
-# CONFIG_DEFAULT_RENO is not set
-CONFIG_DEFAULT_TCP_CONG="bic"
+# CONFIG_TCP_CONG_ADVANCED is not set
+CONFIG_TCP_CONG_HTCP=y
+CONFIG_DEFAULT_HTCP=y
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IP_VS=m
 # CONFIG_IP_VS_DEBUG is not set
--- a/arch/mips/configs/bigsur_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/mips/configs/bigsur_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -353,7 +353,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 CONFIG_IP_VS=m
 # CONFIG_IP_VS_DEBUG is not set
--- a/arch/mips/configs/capcella_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/mips/configs/capcella_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -276,7 +276,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/cobalt_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/mips/configs/cobalt_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -310,7 +310,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/mips/configs/db1000_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/mips/configs/db1000_defconfig	2008-10-30 08:21:30.000000000 -0700
@@ -303,7 +303,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/db1100_defconfig	2008-10-30 08:21:30.000000000 -0700
+++ b/arch/mips/configs/db1100_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -292,7 +292,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/db1200_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/db1200_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -299,7 +299,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/db1500_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/db1500_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -310,7 +310,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/db1550_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/db1550_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -309,7 +309,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/decstation_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/decstation_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -293,7 +293,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 CONFIG_IPV6=m
 CONFIG_IPV6_PRIVACY=y
--- a/arch/mips/configs/emma2rh_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/emma2rh_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -305,7 +305,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/excite_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/excite_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -302,7 +302,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/fulong_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/fulong_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -297,7 +297,7 @@ CONFIG_INET_XFRM_MODE_BEET=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/mips/configs/ip22_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/ip22_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -286,7 +286,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 CONFIG_IP_VS=m
 # CONFIG_IP_VS_DEBUG is not set
--- a/arch/mips/configs/ip27_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/ip27_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -302,7 +302,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/ip28_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/ip28_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -327,7 +327,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/ip32_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/ip32_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -299,7 +299,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/jazz_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/jazz_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -303,7 +303,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/jmr3927_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/jmr3927_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -281,7 +281,7 @@ CONFIG_IP_PNP_BOOTP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
 # CONFIG_NETFILTER is not set
--- a/arch/mips/configs/lasat_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/lasat_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -262,7 +262,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/malta_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/malta_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -327,7 +327,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 CONFIG_IP_VS=m
 # CONFIG_IP_VS_DEBUG is not set
--- a/arch/mips/configs/mipssim_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/mipssim_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -287,7 +287,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/mpc30x_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/mpc30x_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -273,7 +273,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/msp71xx_defconfig	2008-10-30 08:21:31.000000000 -0700
+++ b/arch/mips/configs/msp71xx_defconfig	2008-10-30 08:21:31.000000000 -0700
@@ -314,7 +314,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 
 #
--- a/arch/mips/configs/mtx1_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/mtx1_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -321,7 +321,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IP_VS=m
 # CONFIG_IP_VS_DEBUG is not set
--- a/arch/mips/configs/pb1100_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/pb1100_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -304,7 +304,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/pb1500_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/pb1500_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -309,7 +309,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/pb1550_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/pb1550_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -310,7 +310,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/pnx8550-jbs_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/pnx8550-jbs_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -297,7 +297,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/pnx8550-stb810_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/pnx8550-stb810_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -295,7 +295,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/rb532_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/rb532_defconfig	2008-10-30 08:26:46.000000000 -0700
@@ -306,26 +306,10 @@ CONFIG_SYN_COOKIES=y
 # CONFIG_INET_LRO is not set
 CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
-CONFIG_TCP_CONG_ADVANCED=y
-CONFIG_TCP_CONG_BIC=m
-CONFIG_TCP_CONG_CUBIC=m
-CONFIG_TCP_CONG_WESTWOOD=m
-CONFIG_TCP_CONG_HTCP=m
-CONFIG_TCP_CONG_HSTCP=m
-CONFIG_TCP_CONG_HYBLA=m
-CONFIG_TCP_CONG_VEGAS=y
-CONFIG_TCP_CONG_SCALABLE=m
-CONFIG_TCP_CONG_LP=m
-CONFIG_TCP_CONG_VENO=m
-CONFIG_TCP_CONG_YEAH=m
-CONFIG_TCP_CONG_ILLINOIS=m
-# CONFIG_DEFAULT_BIC is not set
-# CONFIG_DEFAULT_CUBIC is not set
-# CONFIG_DEFAULT_HTCP is not set
-CONFIG_DEFAULT_VEGAS=y
-# CONFIG_DEFAULT_WESTWOOD is not set
-# CONFIG_DEFAULT_RENO is not set
-CONFIG_DEFAULT_TCP_CONG="vegas"
+# CONFIG_TCP_CONG_ADVANCED is not set
+CONFIG_TCP_CONG_HTCP=y
+CONFIG_DEFAULT_HTCP=y
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/mips/configs/rbtx49xx_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/rbtx49xx_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -306,7 +306,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
 # CONFIG_NETFILTER is not set
--- a/arch/mips/configs/rm200_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/rm200_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -314,7 +314,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 
 #
--- a/arch/mips/configs/sb1250-swarm_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/sb1250-swarm_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -352,7 +352,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IPV6 is not set
 CONFIG_NETWORK_SECMARK=y
--- a/arch/mips/configs/tb0219_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/tb0219_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -311,7 +311,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 CONFIG_NETWORK_SECMARK=y
--- a/arch/mips/configs/tb0226_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/tb0226_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -310,7 +310,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 CONFIG_NETWORK_SECMARK=y
--- a/arch/mips/configs/tb0287_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/tb0287_defconfig	2008-10-30 08:27:08.000000000 -0700
@@ -308,26 +308,10 @@ CONFIG_INET_TUNNEL=m
 # CONFIG_INET_LRO is not set
 CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
-CONFIG_TCP_CONG_ADVANCED=y
-CONFIG_TCP_CONG_BIC=y
-CONFIG_TCP_CONG_CUBIC=m
-CONFIG_TCP_CONG_WESTWOOD=m
-CONFIG_TCP_CONG_HTCP=m
-# CONFIG_TCP_CONG_HSTCP is not set
-# CONFIG_TCP_CONG_HYBLA is not set
-# CONFIG_TCP_CONG_VEGAS is not set
-# CONFIG_TCP_CONG_SCALABLE is not set
-# CONFIG_TCP_CONG_LP is not set
-# CONFIG_TCP_CONG_VENO is not set
-# CONFIG_TCP_CONG_YEAH is not set
-# CONFIG_TCP_CONG_ILLINOIS is not set
-CONFIG_DEFAULT_BIC=y
-# CONFIG_DEFAULT_CUBIC is not set
-# CONFIG_DEFAULT_HTCP is not set
-# CONFIG_DEFAULT_VEGAS is not set
-# CONFIG_DEFAULT_WESTWOOD is not set
-# CONFIG_DEFAULT_RENO is not set
-CONFIG_DEFAULT_TCP_CONG="bic"
+# CONFIG_TCP_CONG_ADVANCED is not set
+CONFIG_TCP_CONG_HTCP=y
+CONFIG_DEFAULT_HTCP=y
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 CONFIG_NETWORK_SECMARK=y
--- a/arch/mips/configs/workpad_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/workpad_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -282,7 +282,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/wrppmc_defconfig	2008-10-30 08:21:32.000000000 -0700
+++ b/arch/mips/configs/wrppmc_defconfig	2008-10-30 08:21:32.000000000 -0700
@@ -310,7 +310,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/mips/configs/yosemite_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/mips/configs/yosemite_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -297,7 +297,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_IPV6=m
 CONFIG_IPV6_PRIVACY=y
 CONFIG_IPV6_ROUTER_PREF=y
--- a/arch/mn10300/configs/asb2303_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/mn10300/configs/asb2303_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -191,7 +191,7 @@ CONFIG_IP_PNP_BOOTP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/parisc/configs/712_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/parisc/configs/712_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -201,7 +201,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/parisc/configs/a500_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/parisc/configs/a500_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -232,7 +232,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/parisc/configs/b180_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/parisc/configs/b180_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -192,7 +192,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
 # CONFIG_IPV6_ROUTER_PREF is not set
--- a/arch/parisc/configs/c3000_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/parisc/configs/c3000_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -202,7 +202,7 @@ CONFIG_INET_XFRM_MODE_BEET=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/parisc/configs/default_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/parisc/configs/default_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -228,7 +228,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/40x/acadia_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/40x/acadia_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -299,7 +299,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/40x/ep405_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/40x/ep405_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -301,7 +301,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/40x/hcu4_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/40x/hcu4_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -294,7 +294,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/40x/kilauea_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/40x/kilauea_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -299,7 +299,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/40x/makalu_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/40x/makalu_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -299,7 +299,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/40x/walnut_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/40x/walnut_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -302,7 +302,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/44x/arches_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/44x/arches_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -306,7 +306,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/44x/bamboo_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/44x/bamboo_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -310,7 +310,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/44x/canyonlands_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/44x/canyonlands_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -305,7 +305,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/44x/ebony_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/44x/ebony_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -308,7 +308,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/44x/katmai_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/44x/katmai_defconfig	2008-10-30 08:21:33.000000000 -0700
@@ -304,7 +304,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/44x/rainier_defconfig	2008-10-30 08:21:33.000000000 -0700
+++ b/arch/powerpc/configs/44x/rainier_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -308,7 +308,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/44x/sam440ep_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/44x/sam440ep_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -309,7 +309,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/44x/sequoia_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/44x/sequoia_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -309,7 +309,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/44x/taishan_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/44x/taishan_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -308,7 +308,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/44x/virtex5_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/44x/virtex5_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -315,7 +315,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/powerpc/configs/44x/warp_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/44x/warp_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -306,7 +306,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/powerpc/configs/52xx/cm5200_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/52xx/cm5200_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -298,7 +298,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/52xx/lite5200b_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/52xx/lite5200b_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -313,7 +313,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/52xx/motionpro_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/52xx/motionpro_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -298,7 +298,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/52xx/pcm030_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/52xx/pcm030_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -303,7 +303,7 @@ CONFIG_IP_PNP_BOOTP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/52xx/tqm5200_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/52xx/tqm5200_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -303,7 +303,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/asp8347_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/83xx/asp8347_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -330,7 +330,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc8313_rdb_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc8313_rdb_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -330,7 +330,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc8315_rdb_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc8315_rdb_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -330,7 +330,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc832x_mds_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc832x_mds_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -331,7 +331,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -331,7 +331,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc834x_itx_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc834x_itx_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -329,7 +329,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc834x_itxgp_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc834x_itxgp_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -329,7 +329,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc834x_mds_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc834x_mds_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -329,7 +329,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc836x_mds_defconfig	2008-10-30 08:21:34.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc836x_mds_defconfig	2008-10-30 08:21:34.000000000 -0700
@@ -329,7 +329,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc836x_rdk_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc836x_rdk_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -332,7 +332,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc837x_mds_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc837x_mds_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -330,7 +330,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/mpc837x_rdb_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/83xx/mpc837x_rdb_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -325,7 +325,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/83xx/sbc834x_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/83xx/sbc834x_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -328,7 +328,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/ksi8560_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/ksi8560_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -301,7 +301,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/mpc8536_ds_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/mpc8536_ds_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -329,7 +329,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/85xx/mpc8540_ads_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/mpc8540_ads_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -303,7 +303,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/mpc8544_ds_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/mpc8544_ds_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -330,7 +330,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/85xx/mpc8560_ads_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/mpc8560_ads_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -312,7 +312,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/mpc8568mds_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/mpc8568mds_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -315,7 +315,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/mpc8572_ds_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/mpc8572_ds_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -330,7 +330,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -310,7 +310,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/sbc8548_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/sbc8548_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -307,7 +307,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/sbc8560_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/sbc8560_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -302,7 +302,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/stx_gp3_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/stx_gp3_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -317,7 +317,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/powerpc/configs/85xx/tqm8540_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/tqm8540_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -306,7 +306,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/tqm8541_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/tqm8541_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -308,7 +308,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/tqm8548_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/tqm8548_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -320,7 +320,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/tqm8555_defconfig	2008-10-30 08:21:35.000000000 -0700
+++ b/arch/powerpc/configs/85xx/tqm8555_defconfig	2008-10-30 08:21:35.000000000 -0700
@@ -308,7 +308,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/85xx/tqm8560_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/85xx/tqm8560_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -308,7 +308,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/86xx/gef_sbc610_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/86xx/gef_sbc610_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -323,7 +323,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/powerpc/configs/86xx/mpc8610_hpcd_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/86xx/mpc8610_hpcd_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -325,7 +325,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/86xx/mpc8641_hpcn_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/86xx/mpc8641_hpcn_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -337,7 +337,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/86xx/sbc8641d_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/86xx/sbc8641d_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -339,7 +339,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/powerpc/configs/adder875_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/adder875_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -300,7 +300,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/c2k_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/c2k_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -359,7 +359,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IP_VS=m
 # CONFIG_IP_VS_DEBUG is not set
--- a/arch/powerpc/configs/cell_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/cell_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -370,7 +370,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
--- a/arch/powerpc/configs/celleb_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/celleb_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -320,7 +320,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
--- a/arch/powerpc/configs/chrp32_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/chrp32_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -308,7 +308,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/powerpc/configs/ep8248e_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/ep8248e_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -302,7 +302,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/ep88xc_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/ep88xc_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -299,7 +299,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/g5_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/g5_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -334,7 +334,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/powerpc/configs/holly_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/holly_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -283,7 +283,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/powerpc/configs/iseries_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/iseries_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -317,7 +317,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/powerpc/configs/linkstation_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/linkstation_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -322,7 +322,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/powerpc/configs/maple_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/maple_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -313,7 +313,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/mgcoge_defconfig	2008-10-30 08:21:36.000000000 -0700
+++ b/arch/powerpc/configs/mgcoge_defconfig	2008-10-30 08:21:36.000000000 -0700
@@ -275,7 +275,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/mgsuvd_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/mgsuvd_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -299,7 +299,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/mpc5200_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/mpc5200_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -294,7 +294,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/powerpc/configs/mpc7448_hpc2_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/mpc7448_hpc2_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -305,7 +305,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/mpc8272_ads_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/mpc8272_ads_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -304,7 +304,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/mpc83xx_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/mpc83xx_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -339,7 +339,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/mpc85xx_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/mpc85xx_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -334,7 +334,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/mpc866_ads_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/mpc866_ads_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -301,7 +301,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/mpc86xx_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/mpc86xx_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -332,7 +332,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/mpc885_ads_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/mpc885_ads_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -306,7 +306,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/pasemi_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/pasemi_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -349,7 +349,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/pmac32_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/pmac32_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -360,7 +360,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/powerpc/configs/ppc40x_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/ppc40x_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -311,7 +311,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/ppc44x_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/ppc44x_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -323,7 +323,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/ppc64_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/ppc64_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -424,7 +424,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/powerpc/configs/ppc6xx_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/ppc6xx_defconfig	2008-10-30 08:27:28.000000000 -0700
@@ -445,26 +445,10 @@ CONFIG_INET_XFRM_MODE_BEET=m
 CONFIG_INET_LRO=y
 CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
-CONFIG_TCP_CONG_ADVANCED=y
-CONFIG_TCP_CONG_BIC=m
-CONFIG_TCP_CONG_CUBIC=y
-CONFIG_TCP_CONG_WESTWOOD=m
-CONFIG_TCP_CONG_HTCP=m
-CONFIG_TCP_CONG_HSTCP=m
-CONFIG_TCP_CONG_HYBLA=m
-CONFIG_TCP_CONG_VEGAS=m
-CONFIG_TCP_CONG_SCALABLE=m
-CONFIG_TCP_CONG_LP=m
-CONFIG_TCP_CONG_VENO=m
-CONFIG_TCP_CONG_YEAH=m
-CONFIG_TCP_CONG_ILLINOIS=m
-# CONFIG_DEFAULT_BIC is not set
-CONFIG_DEFAULT_CUBIC=y
-# CONFIG_DEFAULT_HTCP is not set
-# CONFIG_DEFAULT_VEGAS is not set
-# CONFIG_DEFAULT_WESTWOOD is not set
-# CONFIG_DEFAULT_RENO is not set
-CONFIG_DEFAULT_TCP_CONG="cubic"
+# CONFIG_TCP_CONG_ADVANCED is not set
+CONFIG_TCP_CONG_HTCP=y
+CONFIG_DEFAULT_HTCP=y
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=m
--- a/arch/powerpc/configs/pq2fads_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/pq2fads_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -305,7 +305,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/prpmc2800_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/prpmc2800_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -313,7 +313,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/powerpc/configs/ps3_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/ps3_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -333,7 +333,7 @@ CONFIG_INET_TUNNEL=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/powerpc/configs/pseries_defconfig	2008-10-30 08:21:37.000000000 -0700
+++ b/arch/powerpc/configs/pseries_defconfig	2008-10-30 08:21:37.000000000 -0700
@@ -349,7 +349,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 # CONFIG_IPV6 is not set
--- a/arch/powerpc/configs/storcenter_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/powerpc/configs/storcenter_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -308,7 +308,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/s390/defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/s390/defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -280,7 +280,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
--- a/arch/sh/configs/ap325rxa_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/ap325rxa_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -332,7 +332,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/cayman_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/cayman_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -324,7 +324,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/dreamcast_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/dreamcast_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -358,7 +358,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/edosk7760_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/edosk7760_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -332,7 +332,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/landisk_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/landisk_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -359,7 +359,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/lboxre2_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/lboxre2_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -359,7 +359,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/magicpanelr2_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/magicpanelr2_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -330,7 +330,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/microdev_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/microdev_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -330,7 +330,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/migor_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/migor_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -339,7 +339,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/r7780mp_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/r7780mp_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -359,7 +359,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/r7785rp_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/r7785rp_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -383,7 +383,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/rsk7203_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/rsk7203_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -328,7 +328,7 @@ CONFIG_IP_PNP_DHCP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/rts7751r2d1_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/rts7751r2d1_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -344,7 +344,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/rts7751r2dplus_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/rts7751r2dplus_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -344,7 +344,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/sdk7780_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/sdk7780_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -379,7 +379,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/sh/configs/se7206_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/se7206_defconfig	2008-10-30 08:21:38.000000000 -0700
@@ -351,7 +351,7 @@ CONFIG_IP_PNP_DHCP=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/se7343_defconfig	2008-10-30 08:21:38.000000000 -0700
+++ b/arch/sh/configs/se7343_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -325,7 +325,7 @@ CONFIG_INET_XFRM_MODE_BEET=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/se7705_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/se7705_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -324,7 +324,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/se7712_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/se7712_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -339,7 +339,7 @@ CONFIG_INET_XFRM_MODE_BEET=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/se7721_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/se7721_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -342,7 +342,7 @@ CONFIG_INET_XFRM_MODE_BEET=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/se7722_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/se7722_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -350,7 +350,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/se7750_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/se7750_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -331,7 +331,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/se7751_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/se7751_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -330,7 +330,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/se7780_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/se7780_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -325,7 +325,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_IPV6=y
 # CONFIG_IPV6_PRIVACY is not set
 # CONFIG_IPV6_ROUTER_PREF is not set
--- a/arch/sh/configs/sh03_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/sh03_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -348,7 +348,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/sh7710voipgw_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/sh7710voipgw_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -322,7 +322,7 @@ CONFIG_INET_XFRM_MODE_BEET=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/sh7763rdp_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/sh7763rdp_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -336,7 +336,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/sh7785lcr_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/sh7785lcr_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -359,7 +359,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/shmin_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/shmin_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -306,7 +306,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/shx3_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/shx3_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -385,7 +385,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
--- a/arch/sh/configs/snapgear_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/snapgear_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -321,7 +321,7 @@ CONFIG_IP_FIB_HASH=y
 # CONFIG_INET_DIAG is not set
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
--- a/arch/sh/configs/titan_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sh/configs/titan_defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -359,7 +359,7 @@ CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=y
 CONFIG_IPV6_PRIVACY=y
--- a/arch/sparc/defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sparc/defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -193,7 +193,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 CONFIG_IPV6_PRIVACY=y
--- a/arch/sparc64/defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/sparc64/defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -252,7 +252,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 CONFIG_IPV6_PRIVACY=y
--- a/arch/um/defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/um/defconfig	2008-10-30 08:21:39.000000000 -0700
@@ -277,7 +277,7 @@ CONFIG_INET_DIAG=y
 CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
-CONFIG_DEFAULT_TCP_CONG="cubic"
+CONFIG_DEFAULT_TCP_CONG="htcp"
 # CONFIG_TCP_MD5SIG is not set
 # CONFIG_IPV6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
--- a/arch/x86/configs/i386_defconfig	2008-10-30 08:21:39.000000000 -0700
+++ b/arch/x86/configs/i386_defconfig	2008-10-30 08:27:47.000000000 -0700
@@ -498,26 +498,10 @@ CONFIG_INET_TUNNEL=y
 # CONFIG_INET_XFRM_MODE_BEET is not set
 CONFIG_INET_LRO=y
 # CONFIG_INET_DIAG is not set
-CONFIG_TCP_CONG_ADVANCED=y
-# CONFIG_TCP_CONG_BIC is not set
-CONFIG_TCP_CONG_CUBIC=y
-# CONFIG_TCP_CONG_WESTWOOD is not set
-# CONFIG_TCP_CONG_HTCP is not set
-# CONFIG_TCP_CONG_HSTCP is not set
-# CONFIG_TCP_CONG_HYBLA is not set
-# CONFIG_TCP_CONG_VEGAS is not set
-# CONFIG_TCP_CONG_SCALABLE is not set
-# CONFIG_TCP_CONG_LP is not set
-# CONFIG_TCP_CONG_VENO is not set
-# CONFIG_TCP_CONG_YEAH is not set
-# CONFIG_TCP_CONG_ILLINOIS is not set
-# CONFIG_DEFAULT_BIC is not set
-CONFIG_DEFAULT_CUBIC=y
-# CONFIG_DEFAULT_HTCP is not set
-# CONFIG_DEFAULT_VEGAS is not set
-# CONFIG_DEFAULT_WESTWOOD is not set
-# CONFIG_DEFAULT_RENO is not set
-CONFIG_DEFAULT_TCP_CONG="cubic"
+# CONFIG_TCP_CONG_ADVANCED is not set
+CONFIG_TCP_CONG_HTCP=y
+CONFIG_DEFAULT_HTCP=y
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
--- a/arch/x86/configs/x86_64_defconfig	2008-10-30 08:21:40.000000000 -0700
+++ b/arch/x86/configs/x86_64_defconfig	2008-10-30 08:28:00.000000000 -0700
@@ -488,26 +488,11 @@ CONFIG_INET_TUNNEL=y
 # CONFIG_INET_XFRM_MODE_BEET is not set
 CONFIG_INET_LRO=y
 # CONFIG_INET_DIAG is not set
+# CONFIG_TCP_CONG_ADVANCED is not set
+CONFIG_TCP_CONG_HTCP=y
+CONFIG_DEFAULT_HTCP=y
+CONFIG_DEFAULT_TCP_CONG="htcp"
 CONFIG_TCP_CONG_ADVANCED=y
-# CONFIG_TCP_CONG_BIC is not set
-CONFIG_TCP_CONG_CUBIC=y
-# CONFIG_TCP_CONG_WESTWOOD is not set
-# CONFIG_TCP_CONG_HTCP is not set
-# CONFIG_TCP_CONG_HSTCP is not set
-# CONFIG_TCP_CONG_HYBLA is not set
-# CONFIG_TCP_CONG_VEGAS is not set
-# CONFIG_TCP_CONG_SCALABLE is not set
-# CONFIG_TCP_CONG_LP is not set
-# CONFIG_TCP_CONG_VENO is not set
-# CONFIG_TCP_CONG_YEAH is not set
-# CONFIG_TCP_CONG_ILLINOIS is not set
-# CONFIG_DEFAULT_BIC is not set
-CONFIG_DEFAULT_CUBIC=y
-# CONFIG_DEFAULT_HTCP is not set
-# CONFIG_DEFAULT_VEGAS is not set
-# CONFIG_DEFAULT_WESTWOOD is not set
-# CONFIG_DEFAULT_RENO is not set
-CONFIG_DEFAULT_TCP_CONG="cubic"
 CONFIG_TCP_MD5SIG=y
 # CONFIG_IP_VS is not set
 CONFIG_IPV6=y
