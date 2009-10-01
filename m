From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: [PATCH] make TLLAO option for NA packets configurable
Date: Thu, 1 Oct 2009 19:16:40 +0300
Message-ID: <200910011916.40908.cratiu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:16496 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751910AbZJAQQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 12:16:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is a patch that adds a sysctl to control the sending of the Target Link 
Layer Address Option (TLLAO) with Neighbor Advertisements responding to 
unicast NS. The patch was made for kernel 2.6.7 (yes it is ancient), but the 
code is similar with the current kernel and I can rework it if you want it in.

RFC 2461, page 24 suggests that this option should be included with NAs to 
avoid a race with the sender clearing its cache after sending an unicast NS, 
but before receiving a NA.

It seems there are some Juniper routers (MX series) that expect this option to 
be included with all NAs.

Another solution is to always send this option, as it has little overhead.

Please let me know what you think,
Cosmin.

Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
--- //packages/linux_2.6.7/main/src/include/linux/sysctl.h
+++ /home/z/w1/packages/linux_2.6.7/main/src/include/linux/sysctl.h
@@ -444,6 +444,7 @@                                                
        NET_IPV6_IP6FRAG_TIME=23,                                  
        NET_IPV6_IP6FRAG_SECRET_INTERVAL=24,                       
        NET_IPV6_MLD_MAX_MSF=25,                                   
+       NET_IPV6_NDISC_FORCE_TLLAO=26,                             
 };                                                                
                                                                   
 enum {                                                            
--- //packages/linux_2.6.7/main/src/include/net/ipv6.h             
+++ /home/z/w1/packages/linux_2.6.7/main/src/include/net/ipv6.h
@@ -479,6 +479,7 @@
 extern int sysctl_ip6frag_low_thresh;
 extern int sysctl_ip6frag_time;
 extern int sysctl_ip6frag_secret_interval;
+extern int sysctl_ndisc_force_tllao;

 #endif /* __KERNEL__ */
 #endif /* _NET_IPV6_H */
--- //packages/linux_2.6.7/main/src/net/ipv6/ndisc.c
+++ /home/z/w1/packages/linux_2.6.7/main/src/net/ipv6/ndisc.c
@@ -169,6 +169,8 @@

 #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)

+int sysctl_ndisc_force_tllao;
+
 static u8 *ndisc_fill_option(u8 *opt, int type, void *data, int data_len)
 {
        int space = NDISC_OPT_SPACE(data_len);
@@ -399,6 +401,9 @@
                return;
        }

+       if (sysctl_ndisc_force_tllao)
+               inc_opt = 1;
+
        if (inc_opt) {
                if (dev->addr_len)
                        len += NDISC_OPT_SPACE(dev->addr_len);
--- //packages/linux_2.6.7/main/src/net/ipv6/sysctl_net_ipv6.c
+++ /home/z/w1/packages/linux_2.6.7/main/src/net/ipv6/sysctl_net_ipv6.c
@@ -84,6 +84,14 @@
                .mode           = 0644,
                .proc_handler   = &proc_dointvec
        },
+       {
+               .ctl_name       = NET_IPV6_NDISC_FORCE_TLLAO,
+               .procname       = "ndisc_force_tllao",
+               .data           = &sysctl_ndisc_force_tllao,
+               .maxlen         = sizeof(int),
+               .mode           = 0644,
+               .proc_handler   = &proc_dointvec,
+       },
        { .ctl_name = 0 }
 };

