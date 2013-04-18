From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] bridge: fix IP DNAT handling when packet is sent back
 via same bport
Date: Thu, 18 Apr 2013 23:02:20 +0200
Message-ID: <20130418210220.GI1408@breakpoint.cc>
References: <1366277833-1405-1-git-send-email-fw@strlen.de>
 <51705267.3070909@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54243 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751823Ab3DRVCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 17:02:24 -0400
Content-Disposition: inline
In-Reply-To: <51705267.3070909@pandora.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bart De Schuymer <bdschuym@pandora.be> wrote:
> Op 18/04/2013 11:37, Florian Westphal schreef:
> >commit e179e6322ac334e21a3c6d669d95bc967e5d0a80
> >(netfilter: bridge-netfilter: Fix MAC header handling with IP DNAT)
> >breaks DNAT when the destination address sits on the same bridgeport
> >the packet originally arrived on.  Example:
> >
> >( Network1 ) -- [ eth1-Bridge-eth0 ] -- ( Network2 )
> >
> >Lets assume bridge has ip 192.168.10.8, and following netfilter rules
> >are active:
> >
> >-A PREROUTING  -s 192.168.10.1 -d 192.168.10.8 -p tcp --dport 21 -j DNAT --to-destination 192.168.10.1
> >-A POSTROUTING -s 192.168.10.1 -d 192.168.10.1 -p tcp --dport 21 -j SNAT --to-source 192.168.10.8
> 
> >With kernels before 2.6.35, this makes host 192.168.10.1 connecting to
> >the bridge on port 21 connect-to-self.
> 
> I don't get why you didn't need the hairpin mode back then.

because afaics before packets were just sent from the bridge, i.e. no
forward path and no should_deliver() check.

[..]

> In my opinion this is just a special kind of MAC SNAT and you can
> already achieve this with hairpin mode, ebtables and iptables now:
>
> 1. make sure to mark the packets with iptables before you perform the DNAT
> 2. in ebtables POSTROUTING, SNAT those marked packets with the MAC
> address of the bridge.
> 3. enable hairpin mode
> Even if it turns out not yet to be fully possible with the current
> kernel, I think such a feature should be implemented as an ebtables
> target instead of increasing the complexity of the generic code.

Well, I am all for doing this with existing tools, problem is
userspace didn't change but newer kernels don't work as they used to.

If consensus is 'too bad, fix configuration' I can accept that.
The fact that noone seems to have reported this until now
pretty much proves that virtually noone has such configurations.

> Your patch also introduces potential unexpected behavior in
> different scenarios. Consider the following rule:
> -A PREROUTING -s 192.168.10.1 -d 192.168.10.8 -p tcp --dport 21 -j
> DNAT --to-destination 192.168.10.2
> Note that the DNAT is to a different IP address. Suppose
> 192.168.10.2 is on a different machine located on the same side of
> the bridge. Your patch would change the MAC source address here too
> without any need.

Not sure if this is even possible, as 10.1 would discard the syn/ack
from 10.2 (expects reply from 10.8 address).

But I think understand what you're saying.

> >diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
> >index dfb4d9e..eacd206 100644
> >--- a/include/linux/netfilter_bridge.h
> >+++ b/include/linux/netfilter_bridge.h
> >@@ -23,6 +23,8 @@ enum nf_br_hook_priorities {
> >  #define BRNF_NF_BRIDGE_PREROUTING	0x08
> >  #define BRNF_8021Q			0x10
> >  #define BRNF_PPPoE			0x20
> >+/* DNAT'd packet is to be sent back on same bridge port: */
> >+#define BRNF_BRIDGED_DNAT_DODGY		0x40
> 
> Obviously, a more descriptive name would be nice :)

I failed to come up with something that isn't more explicit ;)
But I'll try.

> >+static int forward_should_deliver(const struct net_bridge_port *to,
> >+				  struct sk_buff *skb)
> >+{
> >+#ifdef CONFIG_BRIDGE_NETFILTER
> >+	if (skb->dev == to->dev &&
> >+	    skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
> >+		skb->nf_bridge->mask |= BRNF_BRIDGED_DNAT_DODGY;
> 
> You should unset the BRNF_BRIDGED_DNAT mask here (no longer needed
> and might confuse other code yet to be executed):
> skb->nf_bridge->mask ^= BRNF_BRIDGED_DNAT;

Sounds reasonable.

> >+		return to->state == BR_STATE_FORWARDING &&
> >+			br_allowed_egress(to->br, nbp_get_vlan_info(to), skb);
> 
> I don't like this change. It's basically a hack to prevent having to
> enable the hairpin mode.

Yes. It wasn't necessary before.  If the consensus is that it should be
used in this case, I am ok with that.

> Putting the new code in should_deliver() would have prevented you
> from having to come up with a new and not very descriptive function
> name.

I wanted to make sure that this extra DNAT crud is not e.g. called in
the multi/broadcast flood case, but only for plain br_forward().

> >+		/* tell br_dev_xmit to continue with forwarding, make
> >+		 * fwd path handle inport == outport case
> >+		 */
> >+		nf_bridge->mask |= BRNF_BRIDGED_DNAT;
> 
> I think you'll be ok here, as long as you unset the mask later (as
> mentioned above).

Noted, thanks for reviewing.

Regards,
Florian
