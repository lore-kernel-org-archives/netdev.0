From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel >= 4.0: crashes when using traceroute6 with isatap
Date: Tue, 12 May 2015 13:36:31 -0700
Message-ID: <1431462991.566.97.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1770409.aMESoOv08f@h2o.as.studentenwerk.mhn.de>
	 <1958390.Ugr57PpLDS@h2o.as.studentenwerk.mhn.de>
	 <CAM_iQpWei83_pEoiDWKvHHaj02_D6WGEUHYfEJWM05-RuN3CEw@mail.gmail.com>
	 <1489362.AtetvSCXN1@h2o.as.studentenwerk.mhn.de>
	 <5552602E.3060300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Walter <linux@stwm.de>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35367 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927AbbELUge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 16:36:34 -0400
In-Reply-To: <5552602E.3060300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-12 at 16:18 -0400, Vlad Yasevich wrote:
> On 05/06/2015 06:11 PM, Wolfgang Walter wrote:
> > Am Mittwoch, 6. Mai 2015, 11:15:18 schrieben Sie:
> >> (Cc'ing netdev.)
> >>
> >> On Sat, May 2, 2015 at 5:29 AM, Wolfgang Walter <linux@stwm.de> wrote:
> >>> Am Samstag, 2. Mai 2015, 02:16:36 schrieb Wolfgang Walter:
> >>>> Hello,
> >>>>
> >>>> kernel 4.0 (and 4.0.1) crashes immediately when I use traceroute6 with an
> >>>> isatap-tunnel.
> >>>
> >>> I did some further tests. To trigger the crash you need
> >>>
> >>> * isatap-tunnel (probably any sit-tunnel will do it)
> >>> * raw-socket
> >>> * udp
> >>>
> >>> Using icmpv6 or tcp i.e. does not trigger it.
> >>
> >> Do you have a script to reproduce it?
> >>
> >>
> >> Thanks for the bug report!
> >
> > You need a isatap-server with say ipv4-address $X
> >
> > Then, on host with 4.0, start isatapd: isatapd --mtu 1280 $X
> >
> > then do
> >
> > 	traceroute6 www.google.de
> >
> > Regards,
> >
> 
> Hi Walter
> 
> Could you try this patch.  Looks like raw passes transhdrlen
> of 0 on the first packet and that makes IPv4 behave correctly,
> but not IPv6.
> 
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 7fde1f2..fd9c079 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1278,7 +1278,7 @@ emsgsize:
>  	/* If this is the first and only packet and device
>  	 * supports checksum offloading, let's use it.
>  	 */
> -	if (!skb && sk->sk_protocol == IPPROTO_UDP &&
> +	if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
>  	    length + fragheaderlen < mtu &&
>  	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
>  	    !exthdrlen)

And make sure the checksum is correct ;)

Vlad, can you tell where skb->cum_start and skb->csum_offset are set ?
