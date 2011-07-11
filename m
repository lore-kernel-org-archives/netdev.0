From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH v2 46/46] net: mark drivers that drop packets from
 rx queue head under memory pressure
Date: Mon, 11 Jul 2011 13:16:30 +0300
Message-ID: <1310379390.22731.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <c84a04a957128ae664f4a80da23fad4b9f71a85f.1310339689.git.mirq-linux@rere.qmqm.pl>
 <1310366828.22731.1.camel@lb-tlvb-eilong.il.broadcom.com>
 <20110711100447.GA7532@rere.qmqm.pl>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hartley Sweeten" <hsweeten@visionengravers.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Guo-Fu Tseng" <cooldavid@cooldavid.org>,
	"Realtek linux nic maintainers" <nic_swsd@realtek.com>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Jon Mason" <jdmason@kudzu.us>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4403 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752211Ab1GKKgA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 06:36:00 -0400
In-Reply-To: <20110711100447.GA7532@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-07-11 at 03:04 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> On Mon, Jul 11, 2011 at 09:47:08AM +0300, Eilon Greenstein wrote:
> > On Sun, 2011-07-10 at 17:52 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl=
>
> > > ---
> >=20
> > > diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bn=
x2x_cmn.c
> > > index 4f9164c..a6da01a 100644
> > > --- a/drivers/net/bnx2x/bnx2x_cmn.c
> > > +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> > > @@ -673,6 +673,9 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, i=
nt budget)
> > >  				goto reuse_rx;
> > >  			}
> > > =20
> > > +#warning drops packets from rx queue head on memory pressure
> > > +#warning (like dev_skb_finish_rx_dma_refill() users)
> > > +
> >=20
> > We have the dropless_fc module parameter that can be configured if =
the
> > user prefers pausing on host memory pressure - the problem with tha=
t
> > feature is that it is enough that one of the ring runs out of memor=
y and
> > the entire port is stopped. When running with 16 rings, this can le=
ad to
> > serious throughput degradation - this is why it is kept as a user
> > configurable option.
>=20
> From the code it look like dropless_fc just enables sending of pause
> frames.  If that's disabled, then what happens when one queue runs ou=
t
> of free rx buffers?
>=20

Actually, I was too fast before and did not read it all through. After =
I
did, I saw that Dave already replied...

The dropless_fc is not really related to this case. It is about the
driver not keeping up with the FW/HW and not about the driver failing t=
o
allocate a buffer (well, not directly - if that will happen with the
suggested patch we will run out of space on the ring). If the ring is
full, the FW will drop the packet. But if the FW is not fast enough and
the internal chip buffer is getting full - the HW will send pause. So
when pause is enabled, without dropless_fc packets will still be droppe=
d
if the host is too slow but not if the chip is too slow (when exceeding
the chip max PPS with small packets). When dropless_fc is set, packet
will not be dropped but in multi-ring scenario we are likely to be unde=
r
utilizing the link in case some (possibly only one) ring on one CPU is
not keeping up while the other rings (on other CPUs) still have room an=
d
possibly idling.=20

Regards,
Eilon


