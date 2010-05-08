From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] net: deliver skbs on inactive slaves to exact matches
Date: Fri, 07 May 2010 17:15:21 -0700
Message-ID: <4BE4AD19.8050208@intel.com>
References: <20100506172438.26339.93520.stgit@jf-dev2-dcblab> <25360.1273168864@death.nxdomain.ibm.com> <4BE30C67.4030104@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"kaber@trash.net" <kaber@trash.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24503 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750850Ab0EHAPW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 May 2010 20:15:22 -0400
In-Reply-To: <4BE30C67.4030104@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Fastabend wrote:
> Jay Vosburgh wrote:
>> John Fastabend <john.r.fastabend@intel.com> wrote:
>>
>>> Currently, the accelerated receive path for VLAN's will
>>> drop packets if the real device is an inactive slave and
>>> is not one of the special pkts tested for in
>>> skb_bond_should_drop().  This behavior is different then
>>> the non-accelerated path and for pkts over a bonded vlan.
>>>
>>> For example,
>>>
>>> vlanx -> bond0 -> ethx
>>>
>>> will be dropped in the vlan path and not delivered to any
>>> packet handlers.  However,
>>>
>>> bond0 -> vlanx -> ethx
>>>
>>> will be delivered to handlers that match the exact dev,
>>> because the VLAN path checks the real_dev which is not a
>>> slave and netif_recv_skb() doesn't drop frames but only
>>> delivers them to exact matches.
>>>
>>> This patch adds a pkt_type PACKET_DROP which is now used
>>> to identify skbs that would previously been dropped and
>>> allows the skb to continue to skb_netif_recv().  Here we
>>> add logic to check for PACKET_DROP and if so only deliver
>>> to handlers that match exactly.  IMHO this is more
>>> consistent and gives pkt handlers a way to identify skbs
>>> that come from inactive slaves.
>> 	I was looking at this some yesterday and this morning, trying to
>> figure out if a packet going up the IP protocol stack with pkt_type ==
>> PACKET_DROP would break anything.  For example:
>>
>> net/ipv4/ip_options.c:
>> int ip_options_rcv_srr(struct sk_buff *skb)
>> {
>> [...]
>>         if (!opt->srr)
>>                 return 0;
>>
>>         if (skb->pkt_type != PACKET_HOST)
>>                 return -EINVAL;
>>
>> 	or:
>>
>> net/ipv4/tcp_ipv4.c:
>> int tcp_v4_rcv(struct sk_buff *skb)
>> {
>>         const struct iphdr *iph;
>>         struct tcphdr *th;
>>         struct sock *sk;
>>         int ret;
>>         struct net *net = dev_net(skb->dev);
>>
>>         if (skb->pkt_type != PACKET_HOST)
>>                 goto discard_it;
>>
>> 	Is pkt_type == PACKET_DROP instead going to break things for
>> these, or the other similar cases?
>>
>> 	I think what you're looking for is really the usual PACKET_HOST,
>> PACKET_OTHERHOST, et al, upper protocol behavior, with the exception
>> that at the __netif_receive_skb level, wildcard matches in the ptypes
>> are not done.  Setting the pkt_type to PACKET_DROP loses the _HOST,
>> _OTHERHOST, etc, information, but sends the packet up the stack anyway,
>> and I'm not sure that's really the right thing to do.
> 
> Because we wouldn't be doing wildcard matches the skb shouldn't be 
> passed to the IP protocol stack.  Really what we want is the ip_rcv() to 
> drop the skb in this case,
> 
> net/ipv4/ip_input.c
> int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct 
> packet_type *pt, struct net_device *orig_dev)
> {
> [...]
> 
> if (skb->pkt_type == PACKET_OTHERHOST ||
>      skb->pkt_type == PACKET_DROP)
> 	goto drop;
> 
> 
> We do lose some information about the packet _HOST, _OTHERHOST, etc, but 
> we also gain something namely that the packet was received on an 
> inactive slave.  Currently, we pass these frames up the stack (for non 
> wildcard matches) without any indication that they were received on an 
> inactive slave.
> 
> What we need is a way for the VLAN path to flag skbs so that wildcard 
> matches in the ptyes are not done.  Also I think it may be valuable for 
> the packet handler to be able to determine if the skb is coming from an 
> inactive slave.  I think using the pkt_type field might be OK any ideas 
> for a better field?
> 
> Thanks,
> John
> 

Another possibility which would keep the pkt_type info would be to add a 
  flag to the flags2 field in the sk_buff struct.  Seeing as there is 
already a u8 there for ndisc_nodetype this should work.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 82f5116..bb1bc22 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -374,8 +374,13 @@ struct sk_buff {

         kmemcheck_bitfield_begin(flags2);
         __u16                   queue_mapping:16;
-#ifdef CONFIG_IPV6_NDISC_NODETYPE
+#if defined(CONTIF_IPV6_NDISC_NODETYPE) && defined(CONFIG_BONDING)
+       __u8                    ndisc_nodetype:2,
+                               bond_should_drop:1;
+#elif defined(CONFIG_IPV6_NDISC_NODETYPE)
         __u8                    ndisc_nodetype:2;
+#elif defined(CONFIG_BONDING)
+       __u8                    bond_should_drop:1;
  #endif
         kmemcheck_bitfield_end(flags2);



Thanks,
John
