From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next] ipv6: stop sending PTB packets for MTU <
 1280
Date: Tue, 26 Aug 2014 00:47:22 +0200
Message-ID: <1409006842.6274.69.camel@localhost>
References: <53F39E50.1020209@gont.com.ar>
	 <1409005545-24910-2-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Fernando Gont <fgont@si6networks.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:42235 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754983AbaHYWrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:47:24 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id 2D33E20C9A
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 18:47:24 -0400 (EDT)
In-Reply-To: <1409005545-24910-2-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hagen,

On Di, 2014-08-26 at 00:25 +0200, Hagen Paul Pfeifer wrote:
> Reduce the attack vector and stop generating ICMPv6 packet to big for
> packets smaller then the minimal required IPv6 MTU.
> 
> See
> http://tools.ietf.org/html/draft-gont-6man-deprecate-atomfrag-generation-00

I wonder if we should wait until this gets RFC status?

I very much welcome this decision! I already raised this problem some
time ago:
http://lists.openwall.net/netdev/2013/12/31/17

I wonder if we should add a mode alike ipv4 ip_no_pmtu_disc mode for
ipv6:

ip_no_pmtu_disc - INTEGER
        Disable Path MTU Discovery. If enabled in mode 1 and a
        fragmentation-required ICMP is received, the PMTU to this
        destination will be set to min_pmtu (see below). You will need
        to raise min_pmtu to the smallest interface MTU on your system
        manually if you want to avoid locally generated fragments.

        In mode 2 incoming Path MTU Discovery messages will be
        discarded. Outgoing frames are handled the same as in mode 1,
        implicitly setting IP_PMTUDISC_DONT on every created socket.

        Mode 3 is a hardend pmtu discover mode. The kernel will only
        accept fragmentation-needed errors if the underlying protocol
        can verify them besides a plain socket lookup. Current
        protocols for which pmtu events will be honored are TCP, SCTP
        and DCCP as they verify e.g. the sequence number or the
        association. This mode should not be enabled globally but is
        only intended to secure e.g. name servers in namespaces where
        TCP path mtu must still work but path MTU information of other
        protocols should be discarded. If enabled globally this mode
        could break other protocols.

        Possible values: 0-3
        Default: FALSE

Not sure yet...

> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---
>  net/ipv6/route.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f74b041..84ebacd 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1154,12 +1154,9 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
>  		struct net *net = dev_net(dst->dev);
>  
>  		rt6->rt6i_flags |= RTF_MODIFIED;
> -		if (mtu < IPV6_MIN_MTU) {
> -			u32 features = dst_metric(dst, RTAX_FEATURES);
> +		if (mtu < IPV6_MIN_MTU)
>  			mtu = IPV6_MIN_MTU;
> -			features |= RTAX_FEATURE_ALLFRAG;
> -			dst_metric_set(dst, RTAX_FEATURES, features);
> -		}
> +
>  		dst_metric_set(dst, RTAX_MTU, mtu);
>  		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
>  	}

This patch is a starter, yes. We can now get rid of the dst_allfrag
function altogether.

Thanks,
Hannes
