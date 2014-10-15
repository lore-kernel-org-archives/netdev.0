From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] nf_conntrack_proto_tcp: allow server to become a client
 in TW handling
Date: Wed, 15 Oct 2014 09:27:43 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1410150854460.19251@blackhole.kfki.hu>
References: <5419B546.40702@redhat.com> <a9618c5db692413c2970201b5206bcd357438399.1413216136.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp0.kfki.hu ([148.6.0.25]:52086 "EHLO smtp0.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603AbaJOH1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 03:27:14 -0400
In-Reply-To: <a9618c5db692413c2970201b5206bcd357438399.1413216136.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Oct 2014, Marcelo Ricardo Leitner wrote:

> When a port that was used to listen for inbound connections gets closed
> and reused for outgoing connections (like rsh ends up doing for stderr
> flow), current we may reject the SYN/ACK packet for the new connection
> because tcp_conntracks states forbirds a port to become a client while
> there is still a TIME_WAIT entry in there for it.
> 
> As TCP may expire the TIME_WAIT socket in 60s and conntrack's timeout
> for it is 120s, there is a ~60s window that the application can end up
> opening a port that conntrack will end up blocking.
> 
> This patch fixes this by simply allowing such state transition: if we
> see a SYN, in TIME_WAIT state, on REPLY direction, move it to sSS. Note
> that the rest of the code already handles this situation, more
> specificly in tcp_packet(), first switch clause.

In those code branch if there was a valid FIN in either direction, we 
destroy the old connection and a new will be created. That way the rules 
about NEW connections will be applied, so the policies are not bypassed. 
Otherwise we just ignore the SYN packet, so if it's invalid, we'll catch 
the RST from the other side and destroy the conntrack entry. The event 
flow looks OK to me.

> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Best regards,
Jozsef

> ---
>  net/netfilter/nf_conntrack_proto_tcp.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
> index 44d1ea32570a07338dc39f34624bd823b6f76916..d87b6423ffb21e0f8f9b6ef25ef51c1cb5f54ad6 100644
> --- a/net/netfilter/nf_conntrack_proto_tcp.c
> +++ b/net/netfilter/nf_conntrack_proto_tcp.c
> @@ -213,7 +213,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
>  	{
>  /* REPLY */
>  /* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
> -/*syn*/	   { sIV, sS2, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sS2 },
> +/*syn*/	   { sIV, sS2, sIV, sIV, sIV, sIV, sIV, sSS, sIV, sS2 },
>  /*
>   *	sNO -> sIV	Never reached.
>   *	sSS -> sS2	Simultaneous open
> @@ -223,7 +223,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
>   *	sFW -> sIV
>   *	sCW -> sIV
>   *	sLA -> sIV
> - *	sTW -> sIV	Reopened connection, but server may not do it.
> + *	sTW -> sSS	Reopened connection, but server may have switched role
>   *	sCL -> sIV
>   */
>  /* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
