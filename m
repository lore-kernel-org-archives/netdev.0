From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting
 skb->dev in receive path
Date: Sat, 16 May 2015 17:13:28 -0400 (EDT)
Message-ID: <20150516.171328.1953881469617376252.davem@davemloft.net>
References: <20150515.123726.1298734930500737780.davem@redhat.com>
	<555645A3.6010509@gmail.com>
	<20150516123457.GB683@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, steffen.klassert@secunet.com, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbbEPVNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 17:13:30 -0400
In-Reply-To: <20150516123457.GB683@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 16 May 2015 20:34:58 +0800

> On Fri, May 15, 2015 at 12:14:43PM -0700, Alexander Duyck wrote:
>>
>> >Yeah, this mark handling via tunnel->parms.o_key looks not so good.
>> 
>> So is there any recommendations for an alternative to make it so
>> that the ipsec endpoint is identified as needing to be encrypted or
>> decrypted?  If needed I could probably take a day or two to try and
>> address it as I still have a few other minor things I want to try
>> and fix such as the MTU configuration for vti/vti6.
> 
> I'd like to hear from Steffen as to whether there is anything
> in userspace that relies on the mark being used in this way by
> vti.  If not it should be easy to get rid of it and use some
> field that's not exposed to user-space.  If there is then this
> would be tricky to resolve.

The mark stuff comes from the commit below, and at the time I remember
pushing back a few times because I was uneasy about applying this
change:

====================
commit 7263a5187f9e9de45fcb51349cf0e031142c19a1
Author: Christophe Gouault <christophe.gouault@6wind.com>
Date:   Tue Oct 8 17:21:22 2013 +0200

    vti: get rid of nf mark rule in prerouting
    
    This patch fixes and improves the use of vti interfaces (while
    lightly changing the way of configuring them).
    
    Currently:
    
    - it is necessary to identify and mark inbound IPsec
      packets destined to each vti interface, via netfilter rules in
      the mangle table at prerouting hook.
    
    - the vti module cannot retrieve the right tunnel in input since
      commit b9959fd3: vti tunnels all have an i_key, but the tunnel lookup
      is done with flag TUNNEL_NO_KEY, so there no chance to retrieve them.
    
    - the i_key is used by the outbound processing as a mark to lookup
      for the right SP and SA bundle.
    
    This patch uses the o_key to store the vti mark (instead of i_key) and
    enables:
    
    - to avoid the need for previously marking the inbound skbuffs via a
      netfilter rule.
    - to properly retrieve the right tunnel in input, only based on the IPsec
      packet outer addresses.
    - to properly perform an inbound policy check (using the tunnel o_key
      as a mark).
    - to properly perform an outbound SPD and SAD lookup (using the tunnel
      o_key as a mark).
    - to keep the current mark of the skbuff. The skbuff mark is neither
      used nor changed by the vti interface. Only the vti interface o_key
      is used.
    
    SAs have a wildcard mark.
    SPs have a mark equal to the vti interface o_key.
    
    The vti interface must be created as follows (i_key = 0, o_key = mark):
    
       ip link add vti1 mode vti local 1.1.1.1 remote 2.2.2.2 okey 1
    
    The SPs attached to vti1 must be created as follows (mark = vti1 o_key):
    
       ip xfrm policy add dir out mark 1 tmpl src 1.1.1.1 dst 2.2.2.2 \
          proto esp mode tunnel
       ip xfrm policy add dir in  mark 1 tmpl src 2.2.2.2 dst 1.1.1.1 \
          proto esp mode tunnel
    
    The SAs are created with the default wildcard mark. There is no
    distinction between global vs. vti SAs. Just their addresses will
    possibly link them to a vti interface:
    
       ip xfrm state add src 1.1.1.1 dst 2.2.2.2 proto esp spi 1000 mode tunnel \
                     enc "cbc(aes)" "azertyuiopqsdfgh"
    
       ip xfrm state add src 2.2.2.2 dst 1.1.1.1 proto esp spi 2000 mode tunnel \
                     enc "cbc(aes)" "sqbdhgqsdjqjsdfh"
    
    To avoid matching "global" (not vti) SPs in vti interfaces, global SPs
    should no use the default wildcard mark, but explicitly match mark 0.
    
    To avoid a double SPD lookup in input and output (in global and vti SPDs),
    the NOPOLICY and NOXFRM options should be set on the vti interfaces:
    
       echo 1 > /proc/sys/net/ipv4/conf/vti1/disable_policy
       echo 1 > /proc/sys/net/ipv4/conf/vti1/disable_xfrm
    
    The outgoing traffic is steered to vti1 by a route via the vti interface:
    
       ip route add 192.168.0.0/16 dev vti1
    
    The incoming IPsec traffic is steered to vti1 because its outer addresses
    match the vti1 tunnel configuration.
    
    Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index e805e7b..6e87f85 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -125,8 +125,17 @@ static int vti_rcv(struct sk_buff *skb)
 				  iph->saddr, iph->daddr, 0);
 	if (tunnel != NULL) {
 		struct pcpu_tstats *tstats;
+		u32 oldmark = skb->mark;
+		int ret;
 
-		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
+
+		/* temporarily mark the skb with the tunnel o_key, to
+		 * only match policies with this mark.
+		 */
+		skb->mark = be32_to_cpu(tunnel->parms.o_key);
+		ret = xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb);
+		skb->mark = oldmark;
+		if (!ret)
 			return -1;
 
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
@@ -135,7 +144,6 @@ static int vti_rcv(struct sk_buff *skb)
 		tstats->rx_bytes += skb->len;
 		u64_stats_update_end(&tstats->syncp);
 
-		skb->mark = 0;
 		secpath_reset(skb);
 		skb->dev = tunnel->dev;
 		return 1;
@@ -167,7 +175,7 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	memset(&fl4, 0, sizeof(fl4));
 	flowi4_init_output(&fl4, tunnel->parms.link,
-			   be32_to_cpu(tunnel->parms.i_key), RT_TOS(tos),
+			   be32_to_cpu(tunnel->parms.o_key), RT_TOS(tos),
 			   RT_SCOPE_UNIVERSE,
 			   IPPROTO_IPIP, 0,
 			   dst, tiph->saddr, 0, 0);
