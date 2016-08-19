From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for gre tunneled skbs
Date: Fri, 19 Aug 2016 16:40:07 +0300
Message-ID: <20160819164007.527fe984@halley>
References: <1470726261-16371-1-git-send-email-wenxu@ucloud.cn>
        <20160810.173511.968926810628735179.davem@davemloft.net>
        <20160811224132.7a17f0c3@halley>
        <dfa12e1b-54dc-4e20-8819-cb2400a693d1@stressinduktion.org>
        <20160815141639.35e940b4@pixies>
        <20160819102604.271c89d9@halley>
        <d9fcc388-4722-02c6-e3dc-b68893c6cc15@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, wenxu@ucloud.cn,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
        wenx05124561@163.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34363 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751442AbcHSNkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 09:40:14 -0400
Received: by mail-wm0-f53.google.com with SMTP id q128so8987331wma.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 06:40:13 -0700 (PDT)
In-Reply-To: <d9fcc388-4722-02c6-e3dc-b68893c6cc15@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 19 Aug 2016 11:20:40 +0200 Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> >> Maybe we can change our criteria in the following manner:
> >>  
> >> -	if (skb_iif && proto == IPPROTO_UDP) {
> >> +	if (skb_iif && !(df & htons(IP_DF))) {
> >> 		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
> >>
> >> This way, any tunnel explicitly providing DF is NOT allowed to
> >> further fragment the resulting segments (leading to tx segments being
> >> dropped).
> >> Others tunnels, that do not care (e.g. vxlan and geneve, and probably
> >> ovs vport-gre, or other ovs encap vports, in df_default=false mode),
> >> will behave same for gso and non-gso.
> >>
> 
> I am really not sure...
> 
> Probably we have no other choice.

Further diving into this, seems the !IP_DF approach is more correct 
then the IPPROTO_UDP approach (WRT packets/segments arriving from other
interface, that exceed egress mtu):

vxlan/geneve:
  Both set df to zero.
  !IP_DF approach acts same as IPPROTO_UDP approach

vxlan/geneve in collect_md (e.g. OvS):
  They set df according to tun_flags & TUNNEL_DONT_FRAGMENT.
  IPPROTO_UDP approach:
    IPSKB_FRAG_SEGS gets set unconditionally.
    In case TUNNEL_DONT_FRAGMENT requested, non-gso get dropped
    due to IPSTATS_MIB_FRAGFAILS, whereas gso gets segmented+fragmented (!)
  !IP_DF approach:
    Aligned, both non-gso and gso gets dropped for TUNNEL_DONT_FRAGMENT.

ip_gre in collect_md (e.g. OvS):
  Sets df according to tun_flags & TUNNEL_DONT_FRAGMENT.
  IPPROTO_UDP approach:
    IPSKB_FRAG_SEGS is never set.
    Therefore in the case were df is NOT set, non-gso are fragged and
    passed, whereas gso gets dropped (!)
  !IP_DF approach:
    Non-gso vs gso aligned.

ip_gre in nopmtudisc:
  Will pass tnl_update_pmtu checks; Then, df inherrited from inner_iph
  (or stays unset if IFLA_GRE_IGNORE_DF specified).
  IPPROTO_UDP approach:
    IPSKB_FRAG_SEGS never set.
    Therefore in the case were df is NOT set, non-gso are fragged and
    passed, whereas gso gets dropped (!)
  !IP_DF approach:
    Aligned.
    
ip_gre in fou/gue mode in nopmtudisc:
  Assuming they pass tnl_update_pmtu checks; Then, df inherrited from
  inner_iph (or stays unset if IFLA_GRE_IGNORE_DF specified).
  IPPROTO_UDP approach:
    IPSKB_FRAG_SEGS gets always set (since proto==IPPROTO_UDP).
    In the case df is set, non-gso dropped by IPSTATS_MIB_FRAGFAILS,
    whereas gso gets segmented+fragmented (!)
  !IP_DF approach: 
    Aligned.

ip_gre in pmtudisc:
  Sets df to IP_DF.
  Non-gso will fail tnl_update_pmtu checks (gso should pass).
  IPPROTO_UDP approach:
    IPSKB_FRAG_SEGS never set. This leads the gso skbs to be eventually
    dropped. okay.
  !IP_DF approach:
    IPSKB_FRAG_SEGS not set, since IP_DF is true.
    This leads to gso skbs to be eventually dropped. okay.

(truely appreciate if you can review my above analysis)

Therefore using !(df & htons(IP_DF)) actually fixes some oversights of
our former proto==IPPROTO_UDP approach.

I'll send a patch.

Thanks
Shmulik
