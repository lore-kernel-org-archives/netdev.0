From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-2.6.25 uncompilable] [TCP]: Avoid breaking
 GSOed skbs when SACKed one-by-one
Date: Tue, 11 Dec 2007 04:32:39 -0800 (PST)
Message-ID: <20071211.043239.224938181.davem@davemloft.net>
References: <Pine.LNX.4.64.0712071442530.18529@kivilampi-30.cs.helsinki.fi>
	<20071207.173201.95379610.davem@davemloft.net>
	<Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48715
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751518AbXLKMck convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 07:32:40 -0500
In-Reply-To: <Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 11 Dec 2007 13:59:16 +0200 (EET)

> How about this...
>=20
> ...I've left couple of FIXMEs there still, should be quite simple &=20
> straightforward to handle them if this seems viable solution at all.
>=20
> Beware, this doesn't even compile yet because not all parameters are=20
> transferred currently (first_sack_index was killed earlier, I need to=
=20
> summon it back for this). Also, I'd need to do the dirty work of kill=
=20
> recv_sack_cache first to make this to not produce, well, interesting=20
> effects due to missed SACK blocks... :-)

Interesting approach, but I think there is limited value to this
(arguably) complex form.

The core issue is that the data and the SACK state are maintained in
the same datastructure.  The complexity in all the state management
and fixups in your patch is purely because of this.

If we maintain SACK scoreboard information seperately, outside of
the SKB, then there are only two changes to make:

1) Every access to TCP_SKB_CB() SACK scoreboard is adjusted to
   new data structure.

2) Retransmit is adjusted so that it can retransmit an SKB
   constructed as a portion of an existing SKB.  Since TSO
   implies SG, this can be handled with simple offset and
   length arguments and suitable creation of a clone referencing
   the pages in the SG vector that contain the desired data.

I would envision this SACK state thing to reference into the
retransmit queue SKB's somehow.  Each SACK block could perhaps
look something like:

	struct sack_ref {
		struct sk_buff *start_skb;
		struct sk_buff *end_skb;
		unsigned int start_off;
		unsigned int len;
	};

Traditionally we've prioritized the design of the SKB and other
infrastructure to suit TCP optimally and I still think we should
operate that way.

Therefore, long term, it is time to make a formal data blob to assist
with all of the repetitive work we do in cases like this and horribly
inefficient places like clean_rtx_queue().

So I'm basically advocating a two-pronged approach to this, the
seperate SACK scoreboard datastructure and the data blob.  I
think we can work on the former right now, and take our time with
the data blob because it requires lots of thinking and we should
get it right as it might have network driver interface implications.
