From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 14:48:36 +0100
Message-ID: <20131029134836.GD5278@cpaasch-mac>
References: <20131028115552.GC4408@cpaasch-mac>
 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
 <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029090849.GC5944@cpaasch-mac>
 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:48420 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871Ab3J2Nsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 09:48:46 -0400
Content-Disposition: inline
In-Reply-To: <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/10/13 - 06:06:02, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
> by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> 
> (Jerry is working on adding native GRO support for tunnels)
> 
> skb_segment() only deals with a frag_list chain containing MSS sized
> fragments.
> 
> This patch adds support any kind of frag, and adds a new sysctl,
> as clearly the GRO layer should avoid building frag_list skbs
> on a router, as the segmentation is adding cpu overhead.
> 
> Note that we could try to reuse page fragments instead of doing
> copy to linear skbs, but this requires a fair amount of work,
> and possible truesize nightmares, as we do not track individual
> (per page fragment) truesizes.
> 
> /proc/sys/net/core/gro_frag_list_enable possible values are :
> 
> 0 : GRO layer is not allowed to use frag_list to extend skb capacity
> 1 : GRO layer is allowed to use frag_list, but skb_segment()
>     automatically sets the sysctl to 0.
> 2 : GRO is allowed to use frag_list, and skb_segment() wont
>     clear the sysctl.
> 
> Default value is 1 : automatic discovery
> 
> Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Reported-by: Jerry Chu <hkchu@google.com>
> Cc: Michael Dalton <mwdalton@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  Documentation/sysctl/net.txt |   19 +++++++++++++++++++
>  include/linux/netdevice.h    |    1 +
>  net/core/skbuff.c            |   29 ++++++++++++++++++++---------
>  net/core/sysctl_net_core.c   |   10 ++++++++++
>  4 files changed, 50 insertions(+), 9 deletions(-)
> 
> diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
> index 9a0319a82470..8778568ae64e 100644
> --- a/Documentation/sysctl/net.txt
> +++ b/Documentation/sysctl/net.txt
> @@ -87,6 +87,25 @@ sysctl.net.busy_read globally.
>  Will increase power usage.
>  Default: 0 (off)
>  
> +gro_frag_list_enable
> +--------------------
> +
> +GRO layer can build full size GRO packets (~64K of payload) if it is allowed
> +to extend skb using the frag_list pointer. However, this strategy is a win
> +on hosts, where TCP flows are terminated. For a router, using frag_list
> +skbs is not a win because we have to segment skbs before transmit,
> +as most NIC drivers do not support frag_list.
> +As soon as one frag_list skb has to be segmented, this sysctl is automatically
> +changed from 1 to 0.
> +If the value is set to 2, kernel wont change it.
> +
> +Choices : 0 (off),
> +          1 (on, with automatic change to 0)
> +          2 (on, permanent)
> +
> +Default: 1 (on, with automatic downgrade on a router)
> +
> +
>  rmem_default
>  ------------
>  
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 27f62f746621..b82ff52f301e 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2807,6 +2807,7 @@ extern int		netdev_max_backlog;
>  extern int		netdev_tstamp_prequeue;
>  extern int		weight_p;
>  extern int		bpf_jit_enable;
> +extern int		sysctl_gro_frag_list_enable;

We are missing the definition of sysctl_gro_frag_list_enable :)

net/built-in.o: In function `skb_gro_receive':
(.text+0x8f04): undefined reference to `sysctl_gro_frag_list_enable'
net/built-in.o: In function `skb_segment':
(.text+0xa54e): undefined reference to `sysctl_gro_frag_list_enable'
net/built-in.o: In function `skb_segment':
(.text+0xa557): undefined reference to `sysctl_gro_frag_list_enable'
net/built-in.o:(.data+0x1198): undefined reference to `sysctl_gro_frag_list_enable'


Cheers,
Christoph
