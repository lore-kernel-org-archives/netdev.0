From: Joe Perches <joe@perches.com>
Subject: Re: am335x: cpsw: phy ignores max-speed setting
Date: Thu, 06 Nov 2014 11:19:49 -0800
Message-ID: <1415301589.6634.63.camel@perches.com>
References: <CAGm1_ktWK5ai85PZJTkq8Q1mAFH6JZ5XM1mDOHO3K_N2iGNLWg@mail.gmail.com>
	 <CAA93jw5=LDirktyC+rvpLi-kywUSosj6QV8-na5p3-f=PxKcWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Yegor Yefremov <yegorslists@googlemail.com>,
	netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, mpa@pengutronix.de,
	lsorense@csclub.uwaterloo.ca, Daniel Mack <zonque@gmail.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0213.hostedemail.com ([216.40.44.213]:49790 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751262AbaKFTTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:19:54 -0500
In-Reply-To: <CAA93jw5=LDirktyC+rvpLi-kywUSosj6QV8-na5p3-f=PxKcWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-06 at 08:51 -0800, Dave Taht wrote:
> ooh! ooh! I have a BQL enablement patch for the cpsw that I have no
> means of testing against multiple phys. Could
> you give the attached very small patch a shot along the way?

One trivial bit and another possible patch below it

this
+       dev_info(priv->dev, "BQL enabled\n");
might be better as:
+	cpsw_info(priv, link, "BQL enabled\n");

Is this the change that matters most?

-#define CPSW_POLL_WEIGHT       64
+#define CPSW_POLL_WEIGHT       16

If so, maybe this could be limited by a sysctl:

Something like:

 Documentation/sysctl/net.txt | 9 +++++++++
 include/linux/netdevice.h    | 1 +
 net/core/dev.c               | 7 +++++++
 net/core/sysctl_net_core.c   | 7 +++++++
 4 files changed, 24 insertions(+)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 04892b8..1fe0ebd 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -50,6 +50,15 @@ The maximum number of packets that kernel can handle on a NAPI interrupt,
 it's a Per-CPU variable.
 Default: 64
 
+napi_add_weight_max
+-------------------
+
+Limit the maximum number of packets that a device can register in a
+call to netif_napi_add.  This is disabled by default so the value in the
+specific device call is used, but it may be useful in throughput and
+latency testing.
+Default: 0 (off)
+
 default_qdisc
 --------------
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 68fe8a0..31857de 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3380,6 +3380,7 @@ void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
+extern int		sysctl_napi_add_weight_max;
 extern int		bpf_jit_enable;
 
 bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index c934680..aa9bd8d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3016,6 +3016,7 @@ EXPORT_SYMBOL(netdev_max_backlog);
 int netdev_tstamp_prequeue __read_mostly = 1;
 int netdev_budget __read_mostly = 300;
 int weight_p __read_mostly = 64;            /* old backlog weight */
+int sysctl_napi_add_weight_max __read_mostly = 0; /* disabled by default */
 
 /* Called with irq disabled */
 static inline void ____napi_schedule(struct softnet_data *sd,
@@ -4506,6 +4507,12 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 	if (weight > NAPI_POLL_WEIGHT)
 		pr_err_once("netif_napi_add() called with weight %d on device %s\n",
 			    weight, dev->name);
+	if (sysctl_napi_add_weight_max > 0 &&
+	    weight > sysctl_napi_add_weight_max) {
+		pr_notice("netif_napi_add() requested weight %d reduced to sysctl napi_add_weight_max limit %d on device %s\n",
+			  weight, sysctl_napi_add_weight_max, dev->name);
+		weight = sysctl_napi_add_weight_max;
+	}
 	napi->weight = weight;
 	list_add(&napi->dev_list, &dev->napi_list);
 	napi->dev = dev;
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cf9cd13..c90e524 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -257,6 +257,13 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "napi_add_weight_max",
+		.data		= &sysctl_napi_add_weight_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "netdev_max_backlog",
 		.data		= &netdev_max_backlog,
 		.maxlen		= sizeof(int),
