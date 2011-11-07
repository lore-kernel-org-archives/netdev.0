From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH net-next 0/2] 802.1ad S-VLAN support
Date: Mon, 7 Nov 2011 16:48:57 +0100
Message-ID: <20111107154857.GC1833899@jupiter.n2.diac24.net>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
 <1320678704.3020.33.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:57971 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071Ab1KGPtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 10:49:09 -0500
Content-Disposition: inline
In-Reply-To: <1320678704.3020.33.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 07, 2011 at 03:11:44PM +0000, Ben Hutchings wrote:
> On Sat, 2011-11-05 at 17:54 +0100, David Lamparter wrote:
> > this kernel patch, together with the iproute2 userspace support,
> > allows creating 802.1ad S-VLAN devices.
[...]
> We definitely need to think about how MTU/MRU are configured when
> multiple VLAN tags are used, though I don't think it's essential to do
> before this goes in.  To be slightly more blunt than your documentation,
> our current handling of MTU/MRU and VLANs is a botch.

I fully agree, both on the botch and on fixing it separately.

> Do you have any plan to improve that?

Yes, what i'd like to do is introduce a new field into struct netdevice
that tracks the hardware Max Frame Size; it'd be a read-only field
that's initialized once by the driver. (The field would only be used by
ethernet-like devices.) To get things started easier, the field can have
a default value like 0xffff, so if the driver doesn't set it we end up
with the same old nothing-checked behaviour.

MTU change requests from userspace are then validated against the MFS
field for ethernet devices.

Each VLAN device created will inherit its parent's value minus 4 (minus
16 for 802.1ah Mac-in-Mac, I'm working on that currently).

A nice side-effect would be that we can export this value in sysfs so
the admin easily can see the hardware limitations. No more trial & error
to find that r8169 (or was it forcedeth?) has the totally weird value of
7200... ("almost-jumbo-frames-but-not-quite")


Anyway, I'm still in the "design" phase with regards to two points:

 - bridge - is the MFS field allowed to change when we add/remove
   devices? Is there a notification e.g. for VLANs on top of the bridge?

 - "speshul" hardware. I think I saw chips that support "1514 bytes" and
   "1514 bytes + 1 vlan tag" but not "1518 bytes". If this is indeed a
   case we want to support (no idea if it is), we could add a separate
   "extra_vlans" field that is 1 for those devices. (It would only be
   used for protocol-0x8100 802.1Q vlans).

> Or to allow use of offload features for multiple-tagged packets?

Hm. Well... I have yet to do quite a bit of reading to understand all of
the offload mechanisms. What the 802.1Q code currently does is

	dev->hw_features = NETIF_F_ALL_CSUM | NETIF_F_SG |
			   NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |
			   NETIF_F_HIGHDMA | NETIF_F_SCTP_CSUM |
			   NETIF_F_ALL_FCOE;

which is pretty much the "basic" set. I don't see why any of that should
differ for 802.1ad (or even 802.1ah), but my understanding is barely
enough to tell that these flags should work for 802.1ad.


Comments very welcome,


-David
