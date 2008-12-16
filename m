From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] net: Remove a noisy printk
Date: Tue, 16 Dec 2008 21:00:12 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0812162058030.21696@fbirervta.pbzchgretzou.qr>
References: <1229033625-30825-1-git-send-email-ajax@redhat.com> <20081211.203243.124017657.davem@davemloft.net> <alpine.LNX.1.10.0812132310080.27276@fbirervta.pbzchgretzou.qr> <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu>
 <20081214200353.GA2994@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>, ajax@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:57077 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbYLPUAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 15:00:14 -0500
In-Reply-To: <20081214200353.GA2994@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sunday 2008-12-14 21:03, Dave Jones wrote:
> > > >> @@ -147,8 +147,6 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
> > > >>  	/* root is playing with raw sockets. */
> > > >>  	if (skb->len < sizeof(struct iphdr) ||
> > > >>  	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
> > > >> -		if (net_ratelimit())
> > > >> -			printk("ipt_hook: happy cracking.\n");
> > > >>  		return NF_ACCEPT;
> > > >>  	}
> > > >>  	return nf_conntrack_in(dev_net(out), PF_INET, hooknum, skb);
> > > 
> > > I think this change is ok.
> > 
> > In a >normal< system one usually does not use raw sockets. So if
> > a root process do use raw socket, at least netfilter sends a
> > notification and there's a chance that someone take notice it by
> > checking the kernel logs.
>
>'normal' systems are irrelevant here. This message is triggerable remotely.
>Even though it's ratelimited, anyone can flood another boxes logs by
>sending enough packets.
>
>The message is also utterly useless. What kind of action would you take
>to a few gigabytes of "ipt_hook: happy cracking.\n" ?
>There's no IP address logged, or any other useful information.


Here is a patch that attempts silence both the fraction
that wants to keep the printk and those to get rid of it.
It trips up on the bloatmeters, though.

(No, this patch is not serious, but should give you some
thinking as to why the printk is in there at all.)


diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 4a7c352..ac72770 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -27,6 +27,9 @@
 #include <net/netfilter/nf_nat_helper.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 
+static unsigned int happy_cracking;
+module_param(happy_cracking, bool, S_IRUGO | S_IWUSR);
+
 int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
 			      struct nf_conn *ct,
 			      enum ip_conntrack_info ctinfo);
@@ -147,7 +150,7 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
-		if (net_ratelimit())
+		if (happy_cracking && net_ratelimit())
 			printk("ipt_hook: happy cracking.\n");
 		return NF_ACCEPT;
 	}
