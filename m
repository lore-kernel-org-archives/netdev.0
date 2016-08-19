From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for gre tunneled skbs
Date: Fri, 19 Aug 2016 10:26:04 +0300
Message-ID: <20160819102604.271c89d9@halley>
References: <1470726261-16371-1-git-send-email-wenxu@ucloud.cn>
        <20160810.173511.968926810628735179.davem@davemloft.net>
        <20160811224132.7a17f0c3@halley>
        <dfa12e1b-54dc-4e20-8819-cb2400a693d1@stressinduktion.org>
        <20160815141639.35e940b4@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, wenxu@ucloud.cn,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
        wenx05124561@163.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38524 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755470AbcHSH0T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 03:26:19 -0400
Received: by mail-wm0-f44.google.com with SMTP id o80so27367863wme.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 00:26:19 -0700 (PDT)
In-Reply-To: <20160815141639.35e940b4@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Aug 2016 14:16:39 +0300 Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
> On Fri, 12 Aug 2016 13:11:50 +0200, hannes@stressinduktion.org wrote:
> > I really would not like to see this expanded to gre and other protocols.
> > All switches drop packets where the packets are exceeding the MTU,
> > bridges and also openvswitch should behave the same.
> > 
> > Unfortunately we already had this loophole in the kernel that vxlan udp
> > output path could fragment the packet again, even in case of switches.
> > But this stopped working for GSO packets, which violates another rule in
> > the kernel, GSO should always be transparent and user space should never
> > have to care if a packet is GSO or not.
> > 
> > Because we couldn't a) roll back the change that we fragment packets in
> > UDP output paths and b) should not violate GSO transparency rule, I
> > strongly believed it would be better too only change the kernel in a way
> > that it transparently works with GSO, too. If we argue that a VTEP is
> > its own UDP endpoint which is set up after the bridge, I still can sleep
> > well. :)
> > 
> > My understanding was that GRE failed consistently, GSO as well as
> > non-GSO packets are dropped, which would be the correct behavior for me.
> > I don't want to change this. A good argument against this would be if we
> > violate the GSO transparency rule again. But when I looked into the code
> > I couldn't see that.  
> 
> I completely agree with your arguments.
> 
> I think we may run into the same GSO vs Non-GSO anomaly if one uses
> a "nopmtudisc" tunnel, or a gre tunnel in "collect_md" mode, where the
> encapsulating iphdr 'df' is derived from 'tun_flags&TUNNEL_DONT_FRAGMENT'
> (e.g. in case DF is not set).
> 
> I suspect OvS's vport-gre does exactly that, so I assume this is the
> reason why the change was suggested.
> 
> Maybe we can change our criteria in the following manner:
>  
> -	if (skb_iif && proto == IPPROTO_UDP) {
> +	if (skb_iif && !(df & htons(IP_DF))) {
> 		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
> 
> This way, any tunnel explicitly providing DF is NOT allowed to
> further fragment the resulting segments (leading to tx segments being
> dropped).
> Others tunnels, that do not care (e.g. vxlan and geneve, and probably
> ovs vport-gre, or other ovs encap vports, in df_default=false mode),
> will behave same for gso and non-gso.
> 
> WDYT? Am I missing something here?
> 

ping..
