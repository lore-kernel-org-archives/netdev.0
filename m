From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Mon, 7 Jan 2008 21:02:01 +1100
Message-ID: <20080107100201.GC24258@gondor.apana.org.au>
References: <E1JBJOR-0000jO-00@gondolin.me.apana.org.au> <Pine.LNX.4.64.0801071000390.17676@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	paul.moore@hp.com, latten@us.ibm.com
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4073 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754373AbYAGKCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 05:02:15 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801071000390.17676@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2008 at 10:21:47AM +0200, Ilpo J=E4rvinen wrote:
>
> Unexpected enough, even this logic seems to fail in a way with my gcc=
, I'm=20
> yet to study it closer but it seems to me that e.g., uninlining only =
once=20
> called tcp_fastretrans_alert is worth of at least 100 bytes (note tha=
t=20
> it's not inlined by us, gcc did it all by itself)! Otherwise I'd fail=
 to=20
> understand why I got -270 bytes from uninlining tcp_moderate_cwnd whi=
ch is=20
> only 57 bytes as unlined with three call sites.

Yeah I've studied this effect over the years in my maintainence of
the dash shell where size is paramount :)=20

On x86-32 due to the scarcity of registers local variables often end
up on the stack.  In that case gcc will usually refer to them via %ebp
or %esp.  It just so happens that if the offset is within 128 bytes
of the base register then the instruction can encode the offset with
just a single byte.  However, if it exceeds 128 bytes the instruction
will take 4 bytes to encode the offset.

Since bigger functions are more likely to go over that threshold,
this explains some instances where uninlining ends up being bigger.

There are other similar issues, such as the branch offset which also
goes from 1 byte to 4 when you go over 128 bytes.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
