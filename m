From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH 1/2] bridge: Check if vlan filtering is enabled only once.
Date: Sun, 14 Sep 2014 23:43:56 +0900
Message-ID: <5415A9AC.1020400@gmail.com>
References: <1410553577-17519-1-git-send-email-vyasevic@redhat.com> <1410553577-17519-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:39923 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbaINOoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 10:44:02 -0400
Received: by mail-pa0-f54.google.com with SMTP id lj1so4756804pab.41
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 07:44:02 -0700 (PDT)
In-Reply-To: <1410553577-17519-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(14/09/13 (土) 5:26), Vladislav Yasevich wrote:
> The bridge code checks if vlan filtering is enabled on both
> ingress and egress.   When the state flip happens, it
> is possible for the bridge to currently be forwarding packets
> and forwarding behavior becomes non-deterministic.  Bridge
> may drop packets on some interfaces, but not others.
> 
> This patch solves this by caching the filtered state of the
> packet into skb_cb on ingress.  The skb_cb is guaranteed to
> not be over-written between the time packet entres bridge
> forwarding path and the time it leaves it.  On egress, we
> can then check the cached state to see if we need to
> apply filtering information.
...
> @@ -270,7 +275,8 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
>   	struct net_bridge *br = p->br;
>   	struct net_port_vlans *v;
>   
> -	if (!br->vlan_enabled)
> +	/* If filtering was disabled at input, let it pass. */
> +	if (!BR_INPUT_SKB_CB(skb)->vlan_filtered)
>   		return true;
>   
>   	v = rcu_dereference(p->vlan_info);
> 
I'm afraid br_should_learn() is not called after calling
br_allowed_ingress(), so vlan_filtered doesn't seem to be initialized at
this point.

Thanks,
Toshiaki Makita
