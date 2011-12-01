From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Thu, 01 Dec 2011 21:37:55 +0100
Message-ID: <1322771875.2750.9.camel@edumazet-laptop>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	 <1322710962.2577.3.camel@edumazet-laptop>
	 <CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
	 <1322713032.2577.7.camel@edumazet-laptop>
	 <CA+mtBx9fE0qQc-LndM03ykhVMV5n9Z4KHcD6PpTiy=M79GOnKw@mail.gmail.com>
	 <1322730937.2335.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111201092950.00006ce8@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60374 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845Ab1LAUiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 15:38:00 -0500
Received: by bkas6 with SMTP id s6so2891033bka.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 12:37:59 -0800 (PST)
In-Reply-To: <20111201092950.00006ce8@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 09:29 -0800, Jesse Brandeburg a =C3=
=A9crit :
> On Thu, 1 Dec 2011 01:15:37 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Tom, thanks very much for finding this subtle bug!  I bet that this
> commit (which I had missed) broke a lot of other drivers in
> very subtle ways due to changing a long standing behavior.  Auditing
> every driver's tx path is going to be a lot of work unless a way can =
be
> discovered to automate finding incorrect assumptions in drivers.
>=20

I did a quick check an counted 3 intel drivers.

Others are fine. I'll redo a check.

> > I dont know why its even necessary :
> >=20
> > TSO enabled NIC all provide hardware counters, so why even bother
> > computing tx_bytes ourself ?
>=20
> because we have runtime logic for adjusting interrupt rate that depen=
ds
> on knowing how many bytes and packets were cleaned up in an interrupt
> and reading MMIO to get latest stats causes CPU stall in hot path.
> Counting the bytes sent on the wire via a segmented SKB was hard to g=
et
> right to begin with, I think we took a different approach in ixgbe
> (recent versions) and compute the math in hard_start_xmit instead of =
tx
> cleanup.


>=20
> > skb->len is appropriate for BQL, as long as producers/consumer use =
the
> > same skb->len. 1 or 2% error is not a problem if not cumulative ?
>=20
> if skb->len access doesn't cause a cache miss in hot path (or at
> least doesn't increase misses) then I say sure.

You still can cache it like now in your bytecount field in start_xmit()=
,
but since you call skb_free(), I doubt this matters a lot.
