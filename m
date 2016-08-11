From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for gre tunneled skbs
Date: Thu, 11 Aug 2016 22:41:32 +0300
Message-ID: <20160811224132.7a17f0c3@halley>
References: <1470726261-16371-1-git-send-email-wenxu@ucloud.cn>
	<20160810.173511.968926810628735179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wenxu@ucloud.cn, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	wenx05124561@163.com, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33733 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbcHKTlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 15:41:45 -0400
Received: by mail-wm0-f65.google.com with SMTP id o80so1150788wme.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 12:41:45 -0700 (PDT)
In-Reply-To: <20160810.173511.968926810628735179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Aug 2016 17:35:11 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> > commit b8247f095edd ("net: ip_finish_output_gso: If skb_gso_network_seglen
> > exceeds MTU, allow segmentation for local udp tunneled skbs")
> > 
> > Given:
> >      - tap0 and ovs-gre
> >      - ovs-gre stacked on eth0, eth0 having the small mtu
> > 
> > After encapsulation these skbs have skb_gso_network_seglen that exceed
> > eth0's ip_skb_dst_mtu. So the finnal each segment would be larger than
> > eth0 mtu. These packets maybe dropped.
> > 
> > It has the same problem if tap0 bridge with ipgre or gretap device. So
> > the IPSKB_FRAG_SEGS flags should also be set in gre tunneled skbs.
> > 
> > Signed-off-by: wenxu <wenxu@ucloud.cn>  
> 
> I am rather certain that this test is intentionally restricted to
> UDP tunnel endpoints, because GRE and other tunnel types are PMTU safe.
> 
> Hannes and Shmulik?

It was restricted to UDP tun encaps per Hannes' suggestion, in order to
scope the change, as Hannes hinted gre and ipip are pmtu-safe, see [1].

Glancing at ip_tunnel_xmit() --> tnl_update_pmtu(), they do seem to
handle PMTU, but - if I understand correctly - only in the !skb_is_gso
case.
(since 68c3316311 "v4 GRE: Add TCP segmentation offload for GRE")

This is probably due the same hidden assumption that 'gso_size' will be
suitable for the egress mtu even after encapsulation, which does not
hold true in some usecases as described in [2].

Therefore it might be that b8247f095edd needs to be augmented for
non-udp tunnels as well.

Hannes?

[1] http://www.spinics.net/lists/netdev/msg386447.html
[2] http://www.spinics.net/lists/netdev/msg385776.html
