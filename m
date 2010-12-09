From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Thu, 09 Dec 2010 18:58:35 +0000
Message-ID: <1291921115.2647.28.camel@bwh-desktop>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
	 <1291906948.19763.16.camel@localhost>
	 <AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Govindarajan, Sriramakrishnan" <srk@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:10718 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756251Ab0LIS6i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 13:58:38 -0500
In-Reply-To: <AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-09 at 19:47 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> 2010/12/9 Ben Hutchings <bhutchings@solarflare.com>:
> > On Thu, 2010-12-09 at 16:03 +0530, Govindarajan, Sriramakrishnan wr=
ote:
> >> Hi
> >> We have a NAPI compliant driver(net/drivers/davinci_emac.c), that =
does
> >> well at 10/100Mbps loads. Now the same controller/driver is used f=
or
> >> 1000Mbps
> >> mode as well, where the CPU gets saturated easily
> >>
> >> Internally the module supports scatter gather DMA(which is current=
ly not
> >> exercised) but there is no HW checksum support.
> >>
> >> To specifically implement GRO, GSO support would it be sufficient =
to add
> >> SG support to the driver? Are there other means of increasing the =
throughput
> >> and decreasing the CPU loading?
> [...]
> > On the TX side, NETIF_F_SG means that the stack may include data in=
 the
> > skb by reference to arbitrary pages *even if their contents are sti=
ll
> > being changed* (think sendfile()), which means it depends on hardwa=
re
> > checksum generation.
>=20
> Isn't that condition too broad? If the data could change after packet
> is submitted to the driver then results would be unpredictable and
> allow sending wrong data with correct (because hw-calculated)
> checksum.

This is not done for a regular send(), only for functions such as
sendfile() which are specified to read the data asynchronously.

> Right now NETIF_F_SG is removed from dev->features by
> netdev_fix_features() if no checksum offloads are enabled.
>=20
> Just an idea: would driver with NETIF_F_SG|NETIF_F_HW_CSUM using
> skb_checksum_help() in xmit path work? This would allow to use DMA
> scatter-gather without hardware checksumming (and avoid copying the
> packet's data before sending).

No, you cannot calculate a checksum for the fragments without also
copying them to ensure the data doesn't change afterward and invalidate
the checksum.  You could in theory make a copy into multiple fragments,
but there's no point in doing that unless the frame size is larger than
a page.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

