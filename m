From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Sun, 16 May 2010 22:15:28 +0200
Message-ID: <1274040928.2299.17.camel@edumazet-laptop>
References: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Krzysztof Oledzki' <ole@ans.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:34964 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623Ab0EPUPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 16:15:33 -0400
Received: by wwi17 with SMTP id 17so89504wwi.19
        for <netdev@vger.kernel.org>; Sun, 16 May 2010 13:15:31 -0700 (PDT)
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 16 mai 2010 =C3=A0 13:00 -0700, Michael Chan a =C3=A9crit :
> Krzysztof Oledzki wrote:
>=20
> > On 2010-05-16 20:51, Michael Chan wrote:
> > > Krzysztof Oledzki wrote:
> > >
> > >>
> > >> Why the driver registers 5 interrupts instead of 4? How to
> > >> limit it to 4?
> > >>
> > >
> > > The first vector (eth0-0) handles link interrupt and other slow
> > > path events.  It also has an RX ring for non-IP packets that are
> > > not hashed by the RSS hash.  The majority of the rx packets shoul=
d
> > > be hashed to the rx rings eth0-1 - eth0-4, so I would assign thes=
e
> > > vectors to different CPUs.
> >
> > Thank you for your prompt response.
> >
> > In my case the first vector must be handling something more:
> >  - "ping -f 192.168.0.1" increases interrupts on both eth1-0
> > and eth1-4
> >  - "ping -f 192.168.0.2" increases interrupts on both eth1-0
> > and eth1-3
> >  - "ping -f 192.168.0.3" increases interrupts on both eth1-0
> > and eth1-1
> >  - "ping -f 192.168.0.7" increases interrupts on both eth1-0
> > and eth1-2
> >
> >             CPU0       CPU1       CPU2       CPU3
> >   67:    1563979          0          0          0
> > PCI-MSI-edge      eth1-0
> >   68:    1072869          0          0          0
> > PCI-MSI-edge      eth1-1
> >   69:     137905          0          0          0
> > PCI-MSI-edge      eth1-2
> >   70:     259246          0          0          0
> > PCI-MSI-edge      eth1-3
> >   71:     760252          0          0          0
> > PCI-MSI-edge      eth1-4
> >
> > As you can see, eth1-1 + eth1-2 + eth1-3 + eth1-4 ~=3D eth1-0.
>=20
> I think that ICMP ping packets will always go to ring 0 (eth1-0)
> because they are non-IP packets.  I need to double check tomorrow
> on how exactly the hashing works on RX.  Can you try running IP
> traffic?  IP packets should theoretically go to rings 1 - 4.
>=20

ICMP packets are IP packets (Protocol=3D1)

> >
> > So, it seems that TX or RX is always handled by the first vector.
> > I'll try to find if it is TX or RX.
> >
> > BTW: I'm using .1Q vlans over bonding, does it change anything?
>=20
> That should not matter, as the VLAN tag is stripped before hashing.

warning, bonding currently is not multiqueue aware.

All tx packets through bonding will use txqueue 0, since bnx2 doesnt
provide a ndo_select_queue() function.





