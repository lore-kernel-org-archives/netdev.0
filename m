From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: Re: [PATCH 2/3] route: set iif and oif information in flowi struct
Date: Wed, 30 Nov 2011 18:21:52 +0100
Message-ID: <4ED66630.8030308@sophos.com>
References: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com> <1322511292-1413-3-git-send-email-ulrich.weber@sophos.com> <alpine.LFD.2.00.1111290051240.2497@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.sophos.com ([216.47.234.212]:53785 "EHLO mx3.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758020Ab1K3RV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 12:21:56 -0500
In-Reply-To: <alpine.LFD.2.00.1111290051240.2497@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.11.2011 00:53, Julian Anastasov wrote:
>
> 	May be setting flowi4_oif unconditionally here is more
> correct because ip_route_output_slow fills flowi4_oif with
> the selected oif, it can even change the provided original
> oif in flowi4_oif. What about this?:
>
> 			flp4->flowi4_oif =3D rth->dst.dev->ifindex;
>
> 	OTOH, rt_iif has some complex semantic: original oif
> or the selected oif. May be you prefer flowi4_oif to hold
> the selected oif, right?
I wasn't aware the ip_route_output_slow() might change the original oif=
=2E
You know why this might happen? Shouldn't fib_lookup only return
a route matching the given oif?

Anyway, if thats the case your code above is more correct. The packet
should always match the xfrm policy where it was originally routed.

> 	I see one dangerous place that must be checked:
> icmp_route_lookup. Before now __ip_route_output_key was
> called after xfrm_decode_session_reverse with 0 in
> flowi4_oif, i.e. no oif binding was used. But now when
> decode_session sets flowi4_oif we will restrict the route
> via this interface?
Thanks for the hint! Yes the current patch will force the ICMP packet
over the received interface.

Will add "fl4_dec.flowi4_oif =3D 0;" in case the saddr is local, so the
behavior will be the same. fl4_dec.flowi4_oif will then be set in
_ip_route_output_key() again.

Cheers
Ulrich

--=20
Ulrich Weber | ulrich.weber@sophos.com | Senior Software Engineer
Astaro - a Sophos company | Amalienbadstr 41 | 76227 Karlsruhe | German=
y
Phone +49-721-25516-0 | Fax =96200 | www.astaro.com
