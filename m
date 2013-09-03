From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BQL support in gianfar causes network hiccup
Date: Tue, 03 Sep 2013 08:42:20 -0700
Message-ID: <1378222940.7360.34.camel@edumazet-glaptop>
References: <522490CB.60008@appeartv.com> <52249859.2040605@freescale.com>
	 <5224A2A8.6000306@appeartv.com> <5224B026.8090803@freescale.com>
	 <5224C1EB.3030307@appeartv.com> <52258A60.8040305@freescale.com>
	 <522595DD.1030600@appeartv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	netdev@vger.kernel.org
To: Per =?ISO-8859-1?Q?Dal=E9n?= <per.dalen@appeartv.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:51610 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298Ab3ICPn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 11:43:29 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so6176317pbc.15
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 08:43:28 -0700 (PDT)
In-Reply-To: <522595DD.1030600@appeartv.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 09:55 +0200, Per Dal=C3=A9n wrote:

> Yes, it's weird. The only reason I removed the BQL commit=20
> (d8a0f1b0af67679bba886784de10d8c21acc4e0e) was because the error Tino=
=20
> Keitel had was the similar as mine.


I suspect a genuine race in this driver. BQL only makes this race happe=
n
more often.

gfar_poll_sq() has the following :

/* run Tx cleanup to completion */
if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx])
        gfar_clean_tx_ring(tx_queue);

While gfar_poll() has a different method :

if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx]) {=20
    gfar_clean_tx_ring(tx_queue);
    has_tx_work =3D 1;
}

Note the has_tx_work use in gfar_poll() only.

Note that memory barriers seems to be missing.

1) In your cases, is it gfar_poll_sq() or gfar_poll() that is used ?

2) Is the bug happening if only one CPU is used ?
