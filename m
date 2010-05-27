From: Brian Haley <brian.haley@hp.com>
Subject: Re: [REGRESSION,BISECTED] MIPv6 support broken by f4f914b58019f0
Date: Wed, 26 May 2010 20:48:15 -0400
Message-ID: <4BFDC14F.6050407@hp.com>
References: <87zkzmppfg.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kg?=
	 =?UTF-8?B?LyDlkInol6Toi7HmmI4=?= <yoshfuji@linux-ipv6.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Scott Otto <scott.otto@alcatel-lucent.com>,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:42127 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851Ab0E0AsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 20:48:20 -0400
In-Reply-To: <87zkzmppfg.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2010 01:01 PM, Arnaud Ebalard wrote:
> Hi,
> 
> I just updated my laptop's kernel to 2.6.34 (previously running .33 and
> configured to act as an IPsec/IKE-protected MIPv6 Mobile Node using
> racoon and umip): after rebooting on the new kernel, the transport mode
> SA protecting MIPv6 signaling traffic are missing.
> 
> I bisected the issue down to f4f914b58019f0e50d521bbbadfaee260d766f95
> (net: ipv6 bind to device issue) which was added after 2.6.34-rc5: 
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index c2438e8..05ebd78 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -815,7 +815,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
>  {
>         int flags = 0;
>  
> -       if (rt6_need_strict(&fl->fl6_dst))
> +       if (fl->oif || rt6_need_strict(&fl->fl6_dst))
>                 flags |= RT6_LOOKUP_F_IFACE;

Can you see if fl->oif is at least a sane value here?  Maybe there's some
partially un-initialized flowi getting passed-in, a quick source code check
didn't find anything obvious.

The other thought is that it's the tunnel code calling it, as it's going
to set 'oif' (actually it caches a whole flowi) from the tunnel parms ifindex/link
value.  It could have been setting it forever, but ip6_route_output() just
never enforced it until now.

My $.02.

-Brian
