From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH net 3/4] Revert "sh_eth: Enable Rx descriptor word 0
 shift for r8a7790"
Date: Thu, 26 Feb 2015 20:13:43 +0000
Message-ID: <1424981623.4444.65.camel@xylophone.i.decadent.org.uk>
References: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
	 <1424960474.4444.21.camel@xylophone.i.decadent.org.uk>
	 <54EF7163.80900@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:46306 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689AbbBZUNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 15:13:49 -0500
In-Reply-To: <54EF7163.80900@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 22:17 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 02/26/2015 05:21 PM, Ben Hutchings wrote:
> 
> > This reverts commit fd9af07c3404ac9ecbd0d859563360f51ce1ffde.
> 
> > The hardware manual states that the frame error and multicast bits are
> > copied to bits 9:0 of RD0, not bits 25:16.  I've tested that this is
> > true for RFS1 (CRC error), RFS3 (frame too short), RFS4 (frame too
> > long) and RFS8 (multicast).
> 
>     Well, if your testing does match the manual, the reverted patch was most 
> probably just wrong in the first place.
> 
> > Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> > ---
> >   drivers/net/ethernet/renesas/sh_eth.c |    5 ++---
> >   1 file changed, 2 insertions(+), 3 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> > index ed67951f5271..317722e16043 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
> > @@ -1459,8 +1458,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
> >
> >   		/* In case of almost all GETHER/ETHERs, the Receive Frame State
> >   		 * (RFS) bits in the Receive Descriptor 0 are from bit 9 to
> > -		 * bit 0. However, in case of the R8A7740, R8A779x, and
> > -		 * R7S72100 the RFS bits are from bit 25 to bit 16. So, the
> > +		 * bit 0. However, in case of the R8A7740 and R7S72100
> > +		 * the RFS bits are from bit 25 to bit 16. So, the
> 
>     And that seems more logical to me, as we have the RFS bits starting with 
> bit 16 only on the SoCs with the GEther compatible register layout (though the 
> latter SoC doesn't support Gigabit speed).
>     Having the RFS bits start at bit 16 is most probably connected to a SoC 
> having support for hardware checksumming (bit 0-15 store the received frame 
> checksum for at least R7S72100), so merging the 'shift_rd0' and 'hw_crc' flags 
> seemed the reasonable next step to me (not taken due to the lack of 
> documentation)...

After this patch there will still be:

/* SH7757(GETHERC) */ .register_type = SH_ETH_REG_GIGABIT, .hw_crc = 0, .shift_rd0 = 0
/* SH7734 */          .register_type = SH_ETH_REG_GIGABIT, .hw_crc = 1, .shift_rd0 = 0
/* SH7763 */          .register_type = SH_ETH_REG_GIGABIT, .hw_crc = 0, .shift_rd0 = 0
/* R8A7740 */         .register_type = SH_ETH_REG_GIGABIT, .hw_crc = 0, .shift_rd0 = 1
/* R7S72100 */        .register_type = SH_ETH_REG_FAST_RZ, .hw_crc = 1, .shift_rd0 = 1

Do you really think R7S72100 is the only one of these with the flags set
correctly?

Also, the frame CRC is 32 bits and is surely checked by all versions of
the MAC.  Is the 16-bit 'CRC' actually a full-frame IP-style checksum?
Someone should make the driver actually use that where available.  (Not
me, I don't have one of those fancy checksumming chips.)

> >   		 * driver needs right shifting by 16.
> >   		 */
> >   		if (mdp->cd->shift_rd0)
> 
>     This hunk (inverted) was not a part of the commit you're reverting. 
> Perhaps you shouldn't call this patch revert? Or make a remark about this hunk 
> in the change-log?

Well, it's logically a revert.  I could mention that I'm also fixing a
comment to match.

Ben.
