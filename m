From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] 8139too: send NETDEV_CHANGE manually when autoneg is
 disabled
Date: Mon, 11 Mar 2013 18:58:09 +0100
Message-ID: <20130311175809.GA22957@redhat.com>
References: <1362596784-19443-1-git-send-email-vfalico@redhat.com>
 <1362601372.3126.23.camel@bwh-desktop.uk.solarflarecom.com>
 <20130306.155323.344491888348815531.davem@davemloft.net>
 <20130307102740.GB31105@redhat.com>
 <1362671555.2936.10.camel@bwh-desktop.uk.solarflarecom.com>
 <20130307163537.GA21810@redhat.com>
 <1362675261.2936.18.camel@bwh-desktop.uk.solarflarecom.com>
 <20130307183803.GB21810@redhat.com>
 <1362683433.2936.41.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	wfp5p@virginia.edu, jasowang@redhat.com, junchangwang@gmail.com,
	greearb@candelatech.com, ivecera@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9393 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247Ab3CKR6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 13:58:18 -0400
Content-Disposition: inline
In-Reply-To: <1362683433.2936.41.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 07, 2013 at 07:10:33PM +0000, Ben Hutchings wrote:
>On Thu, 2013-03-07 at 19:38 +0100, Veaceslav Falico wrote:
>> On Thu, Mar 07, 2013 at 04:54:21PM +0000, Ben Hutchings wrote:
>> >On Thu, 2013-03-07 at 17:35 +0100, Veaceslav Falico wrote:
>> >> On Thu, Mar 07, 2013 at 03:52:35PM +0000, Ben Hutchings wrote:
>> >> >On Thu, 2013-03-07 at 11:27 +0100, Veaceslav Falico wrote:
>[...]
>> >> >> Silently changing speed can break things a bit - bonding relies on
>> >> >> interface speeds for 802.3ad/alb/tlb/active-backup iirc, bridge relies on
>> >> >> stp port cost etc. and they all get it via NETDEV_ notifications. So
>> >> >> without them, they would end up with outdated data, per example (eth2 being
>> >> >> 8139too):
>> >> >[...]
>> >> >
>> >> >Yes, I get it.  But on real hardware, changing speed/duplex is always
>> >> >going to break the link if it's up.  The link change notification should
>> >> >result in kernel and userland notifications via linkwatch_do_dev().
>> >> >
>> >> >(If you're testing against QEMU rather than real hardware, there could
>> >> >be a bug in the emulation of link interrupts.)
>> >>
>> >> It's real hardware:
>> >>
>> >> [    4.339413] 8139cp 0000:10:09.0: This (id 10ec:8139 rev 10) is not an 8139C+ compatible chip, use 8139too
>> >> [    4.348210] 8139too: 8139too Fast Ethernet driver 0.9.28
>> >> [    4.350017] 8139too 0000:10:09.0 eth2: RealTek RTL8139 at 0xffffc90004574100, 00:14:d1:1f:b9:49, IRQ 21
>> >[...]
>> >
>> >OK.  But it's generally not enough to send a 'something changed'
>> >notification; the driver actually has to update the link state.  MAybe
>> >in your test you reconfigure the other end of the link too, or it's
>> >smart enough to do parallel detect.  But in general, changing the link
>> >speed is going to change the link state, and the TX scheduler needs to
>> >enabled or disabled accordingly.
>>
>> Sorry, I think I didn't explain it clearly. The driver *does* notify
>> about link changes even when it has autonegotiation disabled.
>>
>> The only thing that doesn't work is the notification when someone changes
>> it via ethtool. In the same moment.
>
>The link *should* go down (assuming it was up before) because you likely
>have a speed mismatch and won't be able to pass traffic.  I don't know
>whether this is possible for the hardware to detect immediately; maybe a
>PHY reset will ensure that it is detected.

Sorry for late response - I've had a feeling that I was writing something
utterly dumb. My feeling was correct. I've looked through it and came up
with the next patch, though I have a feeling... :)

Anyway, you were right - the hardware does everything needed, and the
driver also. The normal way (with autoneg on) would be for the driver to
call mii_check_media() when it got the interrupt, which would verify if
state/duplex has changed and report it.

However, with autoneg off, and thus mii->force_duplex == 1,
mii_check_media() just returns 'nothing changed' back, without doing
anything else. This way, any media change while in autoneg off (like
up/down notifications) are completely hidden to the rest of the kernel.

I've modified the mii_check_media() to not verify for ->force_media and to
get all the media settings from mii_ethtool_gset(), which would take care
of whether autoneg is on or off and return the correct values. Tested,
works ok - it sees when the cable is dis/connected, notifies bonding of
speed/duplex changes, when enslaved.

Subject: [PATCH] mii: make mii_check_media() work with ->force_media == 1

mii_check_media() does nothing when ->force_media is set, and thus might
miss media change events reported by the drivers if the autonegotiation is
off.

Make mii_check_media() use mii_ethtool_gset() for getting media settings,
which cleans the code a lot and works with both autoneg off and on. This
allows us to catch link notifications even ->force_media on.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
  drivers/net/mii.c |   45 ++++++++++++---------------------------------
  1 files changed, 12 insertions(+), 33 deletions(-)

diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index 4a99c39..2447487 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -308,19 +308,14 @@ void mii_check_link (struct mii_if_info *mii)
   * @init_media: OK to save duplex mode in @mii
   *
   * Returns 1 if the duplex mode changed, 0 if not.
- * If the media type is forced, always returns 0.
   */
  unsigned int mii_check_media (struct mii_if_info *mii,
  			      unsigned int ok_to_print,
  			      unsigned int init_media)
  {
  	unsigned int old_carrier, new_carrier;
-	int advertise, lpa, media, duplex;
-	int lpa2 = 0;
-
-	/* if forced media, go no further */
-	if (mii->force_media)
-		return 0; /* duplex did not change */
+	int duplex;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
  
  	/* check current and old link status */
  	old_carrier = netif_carrier_ok(mii->dev) ? 1 : 0;
@@ -345,37 +340,21 @@ unsigned int mii_check_media (struct mii_if_info *mii,
  	 */
  	netif_carrier_on(mii->dev);
  
-	/* get MII advertise and LPA values */
-	if ((!init_media) && (mii->advertising))
-		advertise = mii->advertising;
-	else {
-		advertise = mii->mdio_read(mii->dev, mii->phy_id, MII_ADVERTISE);
-		mii->advertising = advertise;
-	}
-	lpa = mii->mdio_read(mii->dev, mii->phy_id, MII_LPA);
-	if (mii->supports_gmii)
-		lpa2 = mii->mdio_read(mii->dev, mii->phy_id, MII_STAT1000);
+	/*
+	 * save the previous state of the duplex, mii_ethtool_gset()
+	 * modifies it
+	 */
+	duplex = mii->full_duplex;
  
-	/* figure out media and duplex from advertise and LPA values */
-	media = mii_nway_result(lpa & advertise);
-	duplex = (media & ADVERTISE_FULL) ? 1 : 0;
-	if (lpa2 & LPA_1000FULL)
-		duplex = 1;
+	mii_ethtool_gset(mii, &ecmd);
  
  	if (ok_to_print)
  		netdev_info(mii->dev, "link up, %uMbps, %s-duplex, lpa 0x%04X\n",
-			    lpa2 & (LPA_1000FULL | LPA_1000HALF) ? 1000 :
-			    media & (ADVERTISE_100FULL | ADVERTISE_100HALF) ?
-			    100 : 10,
-			    duplex ? "full" : "half",
-			    lpa);
-
-	if ((init_media) || (mii->full_duplex != duplex)) {
-		mii->full_duplex = duplex;
-		return 1; /* duplex changed */
-	}
+			    ethtool_cmd_speed(&ecmd), 
+			    ecmd.duplex == DUPLEX_FULL ? "full" : "half",
+			    ecmd.lp_advertising);
  
-	return 0; /* duplex did not change */
+	return (init_media || (mii->full_duplex != duplex)) ? 1 : 0;
  }
  
  /**
-- 
1.7.1


>
>[...]
>> Other drivers, after setting autoneg off, usually ifdown/ifup the interface
>> manually, and thus everything gets updated. That is another way to fix this
>> driver - to issue ->ndo_stop(); ->ndo_open(); (as netxen_nic/qlcnic/etc
>> do), but I think that just issuing a notification that we've changed the
>> state, without flapping, is better.
>
>The link *should* flap, though doing a full stop/start is likely
>unnecessary.
>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
