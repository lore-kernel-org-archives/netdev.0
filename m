From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 6/7] vxlan: simplify vxlan xmit
Date: Wed, 9 Nov 2016 17:59:02 +0100
Message-ID: <20161109175902.01e096ad@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-7-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44198 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754475AbcKIQ7F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 11:59:05 -0500
In-Reply-To: <1478371557-71888-7-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  5 Nov 2016 11:45:56 -0700, Pravin B Shelar wrote:
> @@ -2006,11 +2004,34 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  	info = skb_tunnel_info(skb);
>  
>  	if (rdst) {
> +		dst = &rdst->remote_ip;
> +		if (vxlan_addr_any(dst)) {
> +			if (did_rsc) {
> +				/* short-circuited back to local bridge */
> +				vxlan_encap_bypass(skb, vxlan, vxlan);
> +				return;
> +			}
> +			goto drop;
> +		}
> +
>  		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
>  		vni = rdst->remote_vni;
> -		dst = &rdst->remote_ip;
>  		src = &vxlan->cfg.saddr;
>  		dst_cache = &rdst->dst_cache;
> +		md->gbp = skb->mark;
> +		ttl = vxlan->cfg.ttl;
> +		if (!ttl && vxlan_addr_multicast(dst))
> +			ttl = 1;
> +
> +		tos = vxlan->cfg.tos;
> +		if (tos == 1)
> +			tos = ip_tunnel_get_dsfield(old_iph, skb);

Uninitialized old_iph.

Besides, you can't do this, having TOS, TTL, etc. specified is
perfectly legal for lwtunnel interfaces, too.

 Jiri
