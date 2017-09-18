From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 6/6] Modify tag_ksz.c to support other KSZ switch
 drivers
Date: Mon, 18 Sep 2017 21:57:08 +0200
Message-ID: <20170918195708.GE15606@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121901@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A22@CHN-SV-EXMX02.mchp-main.com>
 <20170907214834.GT11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D2E@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41124D2E@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 07:38:03PM +0000, Tristram.Ha@microchip.com wrote:
> Sorry for the late response.
> 
> > > diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c index 010ca0a..d5faf14
> > 100644
> > > --- a/net/dsa/tag_ksz.c
> > > +++ b/net/dsa/tag_ksz.c
> > >  static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device
> > *dev)  {
> > >  	struct dsa_slave_priv *p = netdev_priv(dev);
> > > +	struct dsa_switch *ds = p->dp->ds;
> > > +	struct ksz_device *swdev = ds->priv;
> > >  	struct sk_buff *nskb;
> > > +	int len;
> > >  	int padlen;
> > > -	u8 *tag;
> > >
> > >  	padlen = (skb->len >= ETH_ZLEN) ? 0 : ETH_ZLEN - skb->len;
> > >
> > > -	if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
> > > +	len = swdev->dev_ops->get_tx_len(swdev);
> > 
> > This is ugly. We have a clean separation between a switch driver and a
> > tag driver. Here you are mixing them together. Don't. Look at the
> > mailing lists for what Florian and I suggested to Pavel. It will also
> > solve your include file issue above.
> 
> It seems to me all tag_*.c are hard-coded.  They do not have access to
> the switch device and just use the bit definitions defined in the top to
> do the job.
> 
> This creates a problem for all KSZ switch devices as they have different
> tail tag formats and lengths.  There will be potentially 4 additional
> DSA_TAG_PROT_KSZ* just to handle them.  Extra files will be added
> with about the same code.

Hi Tristram

Think about factoring out the common code into a shared functions.

> But the most important thing is how do we support the offload_fwd_mark
> bit in skb when the only place that has access to skb does not have access to
> the switch hardware?

Well, so far, nothing has set offload_fwd_mark. This is about to
change, since i need it for IGMP snooping on the brX interface, for
Marvell at least. Bit i just need to set it to true for all frames.

What use cases do you have in mind where you need information from the
switch driver to decide on its value?

> A little out-of-topic is the MAC driver may have problem receiving the frame if
> the tail tag length is too big.  Most of the MAC drivers have big enough receive
> buffer or require 64-bytes multiple so there are extra room to accommodate
> the big tail tag at the end of the frame.  Still some MAC drivers use exactly 1500
> MTU and some additional length and may run into this problem.  Currently the
> Atmel Cadence MAC driver has this potential problem when certain conditions
> are met.

This is a know problem. I just fixed the FEC driver which also
discarded DSA tagged frames when they were bigger than the MTU.

So far, it has not been too much of an issue, because most boards with
a switch, use an Ethernet interface from the same manufacture. Marvell
Switches with a Marvell Ethernet interface. Broadcom switch with a
Broadcom Interface. Atheros switch with an Atheros interface. And
naturally, these combinations just work. But Freescale FEC and Marvell
had not been combined before, and it was broken.

So i would not be surprised if the Cadence MAC driver had an issue.

   Andrew
