From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: 2.6.25: Weird IPv4 stack behaviour, IPv6 is fine
Date: Mon, 28 Apr 2008 10:31:30 +0100
Message-ID: <20080428093130.GA1011@flint.arm.linux.org.uk>
References: <20080427231411.GA5261@flint.arm.linux.org.uk> <48157685.1040709@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:34287 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760882AbYD1Jbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 05:31:39 -0400
Content-Disposition: inline
In-Reply-To: <48157685.1040709@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2008 at 11:02:29AM +0400, Pavel Emelyanov wrote:
> > Lastly, in /proc/net/snmp on lists, I find:
> > 
> > Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
> > Ip: 2 64 12771 0 0 0 0 0 5159 6262 9 0 2 8172 1363 2 922 0 5520
> 
> Can you please also show the /proc/net/netstat contents - I'm interested
> in IpExt statistics.

IpExt: InNoRoutes InTruncatedPkts InMcastPkts OutMcastPkts InBcastPkts OutBcastPkts
IpExt: 0 0 0 0 0 0

I suspect that you were expecting these to be non-zero.

I've just added some debug printks into ip_input.c, and I don't think the
IP stack itself is at fault (if it were, you'd be flooded with reports.)

int ip_local_deliver(struct sk_buff *skb)
{
...
if (ip_hdr(skb)->saddr == htonl(0xc0a80043) &&
    ip_hdr(skb)->protocol == IPPROTO_ICMP) printk("ping 2\n");
        return NF_HOOK(PF_INET, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
                       ip_local_deliver_finish);
}

static int ip_local_deliver_finish(struct sk_buff *skb)
{
        __skb_pull(skb, ip_hdrlen(skb));

        /* Point into the IP datagram, just past the header. */
        skb_reset_transport_header(skb);

if (ip_hdr(skb)->saddr == htonl(0xc0a80043) &&
    ip_hdr(skb)->protocol == IPPROTO_ICMP) printk("ping 3\n");

When the machine stops responding to pings, I see in the kernel message
log 'ping 2' but no 'ping 3' (whereas I get both when it does respond.)

I don't have the iptables binary installed, so there aren't any rules.
(Also, the iptables_filter module isn't loaded.)

I'll see if I can track the packet's progress through the netfilter code
today.

-- 
Russell King
