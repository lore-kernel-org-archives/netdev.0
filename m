From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: [bisected regression] e1000e: "Detected Hardware Unit
 Hang"
Date: Thu, 15 Jan 2015 08:00:58 -0800
Message-ID: <1421337658.11734.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1719052.SGOfRAJhfQ@storm> <8088599.PZmG8U31O2@storm>
	 <1421335532.11734.73.camel@edumazet-glaptop2.roam.corp.google.com>
	 <3089325.gjrPpo2XX1@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:63728 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737AbbAOQBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 11:01:00 -0500
Received: by mail-ie0-f181.google.com with SMTP id rl12so15575118iec.12
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 08:00:59 -0800 (PST)
In-Reply-To: <3089325.gjrPpo2XX1@storm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 16:48 +0100, Thomas Jarosch wrote:
> On Thursday, 15. January 2015 07:25:32 Eric Dumazet wrote:
> > On Thu, 2015-01-15 at 15:58 +0100, Thomas Jarosch wrote:
> > > A colleague mentioned to me he saw the "Hardware Unit Hang" message
> > > every
> > > few days even running on kernel 3.4 (without your patch). Basically I'm
> > > testing now if that's still the case with 3.19-rc4+ or not.
> > > 
> > > I'm all for fixing the root cause. I'm just interested if the e1000e
> > > hang can even be triggered when using a max frag page size of 4096.
> > > So far it transferred 751.6 GiB without a hiccup.
> > 
> > You told it was forwarding setup.
> > 
> > 1) What is the NIC receiving traffic.
> > 2) What happens if you disable GRO on it ?
> 
> The setup is like this:
> 
> Win7 notebook (client)
>     -> "private LAN" eth0 (e1000e)
>         -> "external traffic" eth1 (r8169)
> 
>             -> local HTTP server in the intranet
>                (2x e1000e using bonding)
> 
> 
> Disabling gro on eth1 (r8169) seems to make eth0 (e1000e) stable.
> As it usually hangs within seconds, it already transferred 28 GiB right now.
> 
> When I switch gro back on, it takes around three seconds until the hang.
> 
> Does that point into the right / any direction?

Sure. 

Please apply this patch, and try to lower
/proc/sys/net/core/gro_max_frags and see if this makes a difference
(leaving GRO enabled)

(start with 7 and increase it, limit being 17)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 642d426a668f8ac94daf334c00117f96789f3990..817aee05a1b0623e5752beb0952a6fe6d66e583f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3400,6 +3400,7 @@ extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
 extern int		bpf_jit_enable;
+extern int		sysctl_gro_max_frags;
 
 bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
 struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 56db472e9b864e805e0ab36dd73a0404d2fc66d5..c2c2e7e53014617c5da574f2eb8a2889ed743719 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3197,6 +3197,8 @@ err:
 }
 EXPORT_SYMBOL_GPL(skb_segment);
 
+int sysctl_gro_max_frags = MAX_SKB_FRAGS;
+
 int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
 	struct skb_shared_info *pinfo, *skbinfo = skb_shinfo(skb);
@@ -3219,8 +3221,8 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		int i = skbinfo->nr_frags;
 		int nr_frags = pinfo->nr_frags + i;
 
-		if (nr_frags > MAX_SKB_FRAGS)
-			goto merge;
+		if (nr_frags > sysctl_gro_max_frags)
+			return -E2BIG;
 
 		offset -= headlen;
 		pinfo->nr_frags = nr_frags;
@@ -3252,8 +3254,8 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		unsigned int first_size = headlen - offset;
 		unsigned int first_offset;
 
-		if (nr_frags + 1 + skbinfo->nr_frags > MAX_SKB_FRAGS)
-			goto merge;
+		if (nr_frags + 1 + skbinfo->nr_frags > sysctl_gro_max_frags)
+			return -E2BIG;
 
 		first_offset = skb->data -
 			       (unsigned char *)page_address(page) +
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 31baba2a71ce15e49450f69dae81e7d3be1ff3f2..de73d51381bf8acd0aedeb859ed961468441014a 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -278,6 +278,13 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "gro_max_frags",
+		.data		= &sysctl_gro_max_frags,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "netdev_rss_key",
 		.data		= &netdev_rss_key,
 		.maxlen		= sizeof(int),
