From: Andrew Grover <andrew.grover@intel.com>
Subject: [PATCH 9/10] [IOAT] Add sysctl to tuning IOAT offloaded IO threshold
Date: Thu, 20 Apr 2006 13:50:40 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0604201341530.22544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:1681 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751276AbWDTUul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 16:50:41 -0400
Received: from orsfmr100.jf.intel.com (orsfmr100.jf.intel.com [10.7.209.16])
	by orsfmr003.jf.intel.com (8.12.10/8.12.10/d: major-outer.mc,v 1.1 2004/09/17 17:50:56 root Exp $) with ESMTP id k3KKoeS4000312
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:50:40 GMT
Received: from nwlxmail01.jf.intel.com (nwlxmail01.jf.intel.com [10.7.171.40])
	by orsfmr100.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k3KKoe2u016215
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:50:40 GMT
Received: from isotope.jf.intel.com (isotope.jf.intel.com [10.23.35.8])
	by nwlxmail01.jf.intel.com (8.12.10/8.12.9/MailSET/Hub) with ESMTP id k3KKoehF021555
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 13:50:40 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Any socket recv of less than this ammount will not be offloaded

Signed-off-by: Chris Leech <christopher.leech@intel.com>

---

 include/linux/sysctl.h     |    1 +
 include/net/tcp.h          |    1 +
 net/core/user_dma.c        |    4 ++++
 net/ipv4/sysctl_net_ipv4.c |   10 ++++++++++

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 76eaeff..cd9e7c0 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -403,6 +403,7 @@ enum
  	NET_TCP_MTU_PROBING=113,
 	NET_TCP_BASE_MSS=114,
 	NET_IPV4_TCP_WORKAROUND_SIGNED_WINDOWS=115,
+	NET_TCP_DMA_COPYBREAK=116,
 };
 
 enum {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index ca5bdaf..2e6fdef 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -219,6 +219,7 @@ extern int sysctl_tcp_adv_win_scale;
 extern int sysctl_tcp_tw_reuse;
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_low_latency;
+extern int sysctl_tcp_dma_copybreak;
 extern int sysctl_tcp_nometrics_save;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index ec177ef..642a3f3 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -33,6 +33,10 @@
 
 #ifdef CONFIG_NET_DMA
 
+#define NET_DMA_DEFAULT_COPYBREAK 1024
+
+int sysctl_tcp_dma_copybreak = NET_DMA_DEFAULT_COPYBREAK;
+
 /**
  *	dma_skb_copy_datagram_iovec - Copy a datagram to an iovec.
  *	@skb - buffer to copy
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 6b6c3ad..6a6aa53 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -688,6 +688,16 @@ ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+#ifdef CONFIG_NET_DMA
+	{
+		.ctl_name	= NET_TCP_DMA_COPYBREAK,
+		.procname	= "tcp_dma_copybreak",
+		.data		= &sysctl_tcp_dma_copybreak,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+#endif
 	{ .ctl_name = 0 }
 };
 
-- 
1.2.6



