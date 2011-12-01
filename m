From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Thu, 1 Dec 2011 09:29:50 -0800
Message-ID: <20111201092950.00006ce8@unknown>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	<1322710962.2577.3.camel@edumazet-laptop>
	<CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
	<1322713032.2577.7.camel@edumazet-laptop>
	<CA+mtBx9fE0qQc-LndM03ykhVMV5n9Z4KHcD6PpTiy=M79GOnKw@mail.gmail.com>
	<1322730937.2335.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15867 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755648Ab1LAR3y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 12:29:54 -0500
In-Reply-To: <1322730937.2335.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Dec 2011 01:15:37 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 30 novembre 2011 =E0 21:09 -0800, Tom Herbert a =E9crit :
> > > We recently added commit f07d960df33c5aef
> > > (tcp: avoid frag allocation for small frames)
> >=20
> > Yes, reverting that patch seems to fix the problem.  Eric, do you h=
ave
> > an idea what should be used to determine length of headers in an sk=
b
> > now (mac through transport).

Tom, thanks very much for finding this subtle bug!  I bet that this
commit (which I had missed) broke a lot of other drivers in
very subtle ways due to changing a long standing behavior.  Auditing
every driver's tx path is going to be a lot of work unless a way can be
discovered to automate finding incorrect assumptions in drivers.

> I dont know why its even necessary :
>=20
> TSO enabled NIC all provide hardware counters, so why even bother
> computing tx_bytes ourself ?

because we have runtime logic for adjusting interrupt rate that depends
on knowing how many bytes and packets were cleaned up in an interrupt
and reading MMIO to get latest stats causes CPU stall in hot path.
Counting the bytes sent on the wire via a segmented SKB was hard to get
right to begin with, I think we took a different approach in ixgbe
(recent versions) and compute the math in hard_start_xmit instead of tx
cleanup.

> skb->len is appropriate for BQL, as long as producers/consumer use th=
e
> same skb->len. 1 or 2% error is not a problem if not cumulative ?

if skb->len access doesn't cause a cache miss in hot path (or at
least doesn't increase misses) then I say sure.
