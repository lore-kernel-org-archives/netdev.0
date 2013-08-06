From: Phil Sutter <phil@nwl.cc>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Tue, 6 Aug 2013 23:29:59 +0200
Message-ID: <20130806213006.078C72210F@mail.nwl.cc>
References: <1375804998.8219.27.camel@jlt4.sipsolutions.net>
 <CA+icZUVRgVfXUdJ1xoaN=nciqZDhV-f6EbH+6DS7HAh+My65oQ@mail.gmail.com>
 <CA+icZUUmQbovkwXcdEp6eu=WJkiuiyO8nDVwCHFUuPDbJqU7Kg@mail.gmail.com>
 <CA+icZUV++2+OG=P1SVbNrpHPLyzrfFX0eu8NHrd0nPjkPDUOtQ@mail.gmail.com>
 <CA+icZUXpZaHu-FjR6FGnbkG0XEkiukEgYYbDmrSjdqNz4rWCNg@mail.gmail.com>
 <1375816128.8219.28.camel@jlt4.sipsolutions.net>
 <CA+icZUXaTYVc_iv3hny6Je9mVdX8KCVpFSNBeukS+Fh-347Wvw@mail.gmail.com>
 <1375816715.8219.29.camel@jlt4.sipsolutions.net>
 <CA+icZUXdAjEDgu2XrA4Dg2hsLDJYdFTCpJwiW6=ZUgULe2noyw@mail.gmail.com>
 <CA+icZUVmokQ1fKmtbuPyp7f5Z2wdFYfjG5HCAm4Kue7efyKV8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	wireless <linux-wireless@vger.kernel.org>, netdev@vger.kernel.org
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:35711 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756609Ab3HFVad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 17:30:33 -0400
Content-Disposition: inline
In-Reply-To: <CA+icZUVmokQ1fKmtbuPyp7f5Z2wdFYfjG5HCAm4Kue7efyKV8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 09:47:01PM +0200, Sedat Dilek wrote:
> On Tue, Aug 6, 2013 at 9:32 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> > On Tue, Aug 6, 2013 at 9:18 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> >> On Tue, 2013-08-06 at 21:14 +0200, Sedat Dilek wrote:
> >>> On Tue, Aug 6, 2013 at 9:08 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> >>> > On Tue, 2013-08-06 at 20:35 +0200, Sedat Dilek wrote:
> >>> >
> >>> >> Attached is a diff comparing all new commits in next-20130805.
> >>> >> If one of the commits smells bad to you, please let me know.
> >>> >
> >>> > Out of that list, only the af_packet changes would seem to have any
> >>> > impact on wireless at all.
> >>> >
> >>>
> >>> git-bisecting... 2 steps to go...
> >>>
> >>> This one is bad... "af_packet: simplify VLAN frame check in packet_snd"
> >>>
> >>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=c483e02614551e44ced3fe6eedda8e36d3277ccc
> >>
> >> That seems weird, does reverting it fix it?
> >>
> >
> > [ TO Phil Sutter ]
> >
> > This was 3/3 of af_packet patches :-).
> >
> > So, the culprit commit is...
> >
> > 0f75b09c798ed00c30d7d5551b896be883bc2aeb is the first bad commit
> > commit 0f75b09c798ed00c30d7d5551b896be883bc2aeb
> > Author: Phil Sutter <phil@nwl.cc>
> > Date:   Fri Aug 2 11:37:39 2013 +0200
> >
> >     af_packet: when sending ethernet frames, parse header for skb->protocol
> >
> >     This may be necessary when the SKB is passed to other layers on the go,
> >     which check the protocol field on their own. An example is a VLAN packet
> >     sent out using AF_PACKET on a bridge interface. The bridging code checks
> >     the SKB size, accounting for any VLAN header only if the protocol field
> >     is set accordingly.
> >
> >     Note that eth_type_trans() sets skb->dev to the passed argument, so this
> >     can be skipped in packet_snd() for ethernet frames, as well.
> >
> >     Signed-off-by: Phil Sutter <phil@nwl.cc>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > :040000 040000 af403a20a321517f6cfb51d2e22c17ca5a60e947
> > 1f302ebd62a87b9e874a3e61203499e17d6fce3c M      net
> >
> > - Sedat -
> 
> [ net/packet/af_packet.c ]
> ...
> #include <linux/if_arp.h>
> 
> $ find include/ -name if_arp.h
> include/uapi/linux/if_arp.h
> include/linux/if_arp.h
> 
> $ LC_ALL=C ll include/uapi/linux/if_arp.h include/linux/if_arp.h
> -rw-r--r-- 1 wearefam wearefam 1560 Jul 11 19:42 include/linux/if_arp.h
> -rw-r--r-- 1 wearefam wearefam 6344 Jul 26 12:36 include/uapi/linux/if_arp.h
> 
> $ grep ARPHRD_ETHER include/linux/if_arp.h include/uapi/linux/if_arp.h
> include/uapi/linux/if_arp.h:#define ARPHRD_ETHER        1
>  /* Ethernet 10Mbps              */
> 
> Wrong include?

Nope, <linux/if_arp.h> includes <uapi/linux/if_arp.h>. I suppose there
is a semantical problem here.

Did you verify your bisect by reverting just the three patches?

Does the problem occur on client or server side? AFAICT, hostapd as well
as wpa_supplicant use AF_PACKET.

The tricky thing is, these patches are meant to *loosen* the
restrictions in af_packet.c, so *should* not be harmful. So either my
patches create a side effect I did not foresee, or it's something nasty
(too much delay introduced by calling eth_type_trans() or so).

Could you please provide steps on how to reproduce the faulty behaviour?

Best wishes, Phil
