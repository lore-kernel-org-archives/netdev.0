From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Mon, 21 Apr 2008 17:30:39 +0200
Message-ID: <m3ve2b9qe8.fsf@maximus.localdomain>
References: <20080412115950.1cbb9cfa@core>
	<m33apqomgf.fsf@maximus.localdomain>
	<m33apjp32f.fsf@maximus.localdomain>
	<20080418.153256.253949503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759635AbYDUPay@vger.kernel.org>
In-Reply-To: <20080418.153256.253949503.davem@davemloft.net> (David Miller's message of "Fri\, 18 Apr 2008 15\:32\:56 -0700 \(PDT\)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> I'll fix it properly because I know you won't do the work.

Great to read that.

Just few friendly after all notes so that you don't waste your time
learning that yourself:
- my patch didn't give us a third PPP implementation, we already have
  three: generic PPP, syncppp and PPP for ISDN :-)
- of those, both generic PPP and (I think) ISDN PPP are in a good
  shape
- generic PPP is specialized for dial-up async devices and has the
  required features (in kernel and in userspace pppd) - auth,
  multi-line, compression etc. It's a "lets give /dev/ttyS* a network
  device" implementation.
- ISDN PPP does for ISDN cards basically the same as generic PPP does
  for terminals. They are completely different from syncppp as the
  needs are completely different. Fixed-line PPP must be small and
  fast, and self-contained.


Now syncppp.c and sync serial (HDLC) cards. We basically have three
categories of hardware:
- mostly old ISA cards (cosa, cyclom-2x, z85230, s502/s508, personally
  I have c101 and n2 for tests, and PCI wanxl400). I think Alan
  maintains Zilog drivers, other "old" drivers are not maintained at
  all. They use syncppp.c directly (except c101, n2 and wanxl using
  generic HDLC).
  The list was longer but few drivers have been removed recently.

- cards with in-kernel obsolete drivers and users encouraged to use
  manufacturers' driver - lmc.

- a bit more modern PCI cards such as pc300, pci200syn, synclinks,
  dscc4, farsync, some off-tree ones. They use generic HDLC.

- I have offered to port any remaining old driver to generic HDLC if
  I'm sent a hardware sample. Synclink, dscc4 and farsync have been
  ported by other people.

I would be surprised to find that the "old" drivers are still
functional. Nevertheless syncppp.c is functional (though marginally)
and I think there are no bugs related to dev->priv and netdev_priv()
for those drivers.

The real problem with old drivers is the lack of hardware. Personally
I suspect they may have 0 users worldwide.


Syncppp.c is the problem for newer cards:
- the support has been broken recently due to netdev_priv() changes
  (could be band-aided).
- it's missing IPv6 and adding it is not trivial
- it's not RFC/STD-compliant at all, i.e. breaks many "MUST" rules and
  doesn't work with some other compliant implementations, and fixing
  that would be a real PITA,
- the code is really hard to parse/understand/maintain, it looks a bit
  like it was written in some other language and then "compiled" into
  C machine code :-)
- the lack of hardware makes doing significant changes to the drivers
  and syncppp almost impossible, without breaking them (if they aren't
  already broken).


That's why I came to an idea that leaving syncppp and the old drivers
in their current bit-rotting state which nobody can really fix, and
using another (fourth, and third when syncppp eventually dies) PPP
implementation is the only way out of this situation.

HTH.
-- 
Krzysztof Halasa
