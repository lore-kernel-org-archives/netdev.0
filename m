From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e100: Wait for PHY reset to complete?
Date: Mon, 30 Oct 2006 11:05:49 -0800
Message-ID: <45464D0D.50802@intel.com>
References: <453F9D4A.8090306@users.sourceforge.net>    <20061025185656.GA19037@electric-eye.fr.zoreil.com>    <453FC693.10705@intel.com> <453FD677.7060405@intel.com> <3699.82.182.159.28.1161819386.squirrel@webmail.sys.kth.se> <45400A6D.4020704@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31829 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1161435AbWJ3TGD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 14:06:03 -0500
To: =?ISO-8859-1?Q?Anders_Grafstr=F6m?= <grfstrm@users.sourceforge.net>
In-Reply-To: <45400A6D.4020704@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Anders Grafstr=F6m wrote:
>> Auke Kok wrote:
>>> Allthough the spec itself didn't talk about phy reset times, I've r=
an=20
>>> this
>>> patch with
>>> some debugging output on a few boxes and did some speed/duplex sett=
ings,
>>> and the PHY
>>> reset returned succesfull after the very first mdio_read, which is=20
>>> before
>>> any msleep(10)
>>> is executed. That is also expected behaviour.
>>>
>>> I think you might be confusing this with a MAC reset, which has a
>>> documented 10usec
>>> timeout (see 8255x developers manual). The driver already adheres t=
o=20
>>> this
>>> by doing a
>>> 20usec delay after software/selective resets.
>>>
>>> which gets us back to the original problem: how did your driver end=
=20
>>> up in
>>> loopback mode?
>>> (and, how did you figure out that it did??).
>>
>>
>> This is what the 2.4.33.3 driver does:
>>
>> void
>> e100_phy_reset(struct e100_private *bdp)
>> {
>>         u16 ctrl_reg;
>>         ctrl_reg =3D BMCR_RESET;
>>         e100_mdi_write(bdp, MII_BMCR, bdp->phy_addr, ctrl_reg);
>>         /* ieee 802.3 : The reset process shall be completed       *=
/
>>         /* within 0.5 seconds from the settting of PHY reset bit.  *=
/
>>         set_current_state(TASK_UNINTERRUPTIBLE);
>>         schedule_timeout(HZ / 2);
>> }
>>
>> And here
>> http://www.cs.helsinki.fi/linux/linux-kernel/2003-23/1245.html
>> I found this entry:
>>
>> <scott.feldman@intel.com> (03/06/08 1.1218)
>> [e100] misc
>> <...>
>> * Add 1/2 second delay after PHY reset to allow link partner to
>> see and respond to reset, per IEEE 802.3.
>>
>>
>> I ran mii-diag when the LEDs went out and the register dump
>> said it was in loopback. It is somewhat difficult reproduce.
>> It seems to be timing dependent, something else has to occur
>> at the same time.
>> I must confess I have only seen it with the 2.6.13 kernel.
>> I have not been able to reproduce it with 2.6.18.
>> But I have found no change in the driver that would fix it so
>> I suspect the problem is still there.
>>
>> I have tried adding debug output to see if I can read back the
>> RESET bit in set state, but then the problem refuses to show
>> so I don't think I can rule out an unfinished PHY reset.
>=20
> theoretically, yes, the ieee spec PHY reset timeout is kind of silly:=
 in=20
> no way do we assume that we have re-negotiated link after 1/2 a secon=
d!=20
> Other code in the driver should take care of that, and since it works=
=20
> I'll assume it does ;)
>=20
> the mdio_read probably acts as a flush to the hardware too -=20
> masquerading problems, more goodness. Perhaps we should do a single r=
ead=20
> in all cases and forget about the timeout (is there an mdio_write_flu=
sh?)

Anders,

It appears that there isn't such a thing as an mdio_write_flush in e100=
 but we can force=20
a flush by reading the status register. Not sure if it works 100% so pl=
ease give this a=20
try and let me know if this fixes the problem for you.

Basically, we're preventing mdio writes that might happen after our res=
et write from=20
being reordered. This might have caused an undefined state.

Auke


---

e100: force mdio write flush after PHY reset

Make sure the PHY reset happens without delay by flushing the reset wri=
te.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>


diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 815eb29..04a52cd 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2197,6 +2197,8 @@ static int e100_set_settings(struct net_
  	int err;

  	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, BMCR_RESET);
+	/* flush MDIO write */
+	mdio_read(netdev, nic->mii.phy_id, MII_BMSR);
  	err =3D mii_ethtool_sset(&nic->mii, cmd);
  	e100_exec_cb(nic, NULL, e100_configure);

