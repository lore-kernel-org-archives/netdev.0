From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next-2.6 PATCH] ixgbe: fix for link failure on SFP+ DA
 cables
Date: Thu, 2 Dec 2010 09:28:18 -0800
Message-ID: <29F4ED941D916B48B88B4D2A4F3D1B9C01CC187446@orsmsx509.amr.corp.intel.com>
References: <20101202065921.13413.91380.stgit@localhost.localdomain>
 <1291275701.1761.40.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23818 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752830Ab0LBR2b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 12:28:31 -0500
In-Reply-To: <1291275701.1761.40.camel@Joe-Laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>-----Original Message-----
>From: Joe Perches [mailto:joe@perches.com]
>Sent: Wednesday, December 01, 2010 11:42 PM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
>bphilips@novell.com; Skidmore, Donald C
>Subject: Re: [net-next-2.6 PATCH] ixgbe: fix for link failure on SFP+ DA
>cables
>
>On Wed, 2010-12-01 at 22:59 -0800, Jeff Kirsher wrote:
>> This patch helps prevent FW/SW semaphore collision from leading
>> to link establishment failure.  The collision might mess up the
>> PHY registers so we reset the PHY.  However there are SFI/KR areas
>> in the PHY that are not reset with a Reset_AN so we need to change
>> LMS to reset it.  Also wait until AN state machine is AN_GOOD
>[]
>>  drivers/net/ixgbe/ixgbe_82599.c |   28 +++++++++++++++++++++++++---
>> diff --git a/drivers/net/ixgbe/ixgbe_82599.c
>b/drivers/net/ixgbe/ixgbe_82599.c
>[]
>> @@ -116,14 +118,34 @@ static s32 ixgbe_setup_sfp_modules_82599(struct
>ixgbe_hw *hw)
>>  			IXGBE_WRITE_FLUSH(hw);
>>  			hw->eeprom.ops.read(hw, ++data_offset, &data_value);
>>  		}
>> -		/* Now restart DSP by setting Restart_AN */
>> -		IXGBE_WRITE_REG(hw, IXGBE_AUTOC,
>> -		    (IXGBE_READ_REG(hw, IXGBE_AUTOC) |
>IXGBE_AUTOC_AN_RESTART));
>>
>>  		/* Release the semaphore */
>>  		ixgbe_release_swfw_sync(hw, IXGBE_GSSR_MAC_CSR_SM);
>>  		/* Delay obtaining semaphore again to allow FW access */
>>  		msleep(hw->eeprom.semaphore_delay);
>
>might these msleeps be usleep_range?
>
>[]
>
>> +		/* Wait for AN to leave state 0 */
>> +		for (i = 0; i < 10; i++) {
>> +			msleep(4);
>
>Perhaps usleep_range?
>
>Maybe all the msleep uses < 20ms in the intel drivers?
>
>$ grep -nPr --include=*.[ch] "msleep\s*\(\s*1?\d\s*\)" drivers/net/ig*
>drivers/net/ixg* drivers/net/e100* | wc -l
>123
>
>Maybe something like doubling the sleep value
>for the upper bound range?
>
>Here's a little script that does that.
>
>$ grep -nPrl --include=*.[ch] "msleep\s*\(\s*1?\d\s*\)" \
>	drivers/net/ig* drivers/net/ixg* drivers/net/e100* | \
>xargs perl -p -i -e 's/msleep\s*\(\s*(1?\d)\s*\)/"usleep_range\(${1}000, "
>. scalar($1) * 2 . "000\)"/ge'
>

Good point about the msleeps.  We do have a plan to change all the <20 ones to usleep_range I just haven't gotten around to make the patch yet.  I just wasn't positive on what our upper range would need to be for each case and wanted to look at each individually to make sure.  Your suggestion may well end up being what we end up trying (doubling the upper bound). :)

I kept msleeps in this patch as I wanted to be consistent when doing the usleep_range changeover and the longer delay really doesn't hurt here as the sleep value is really only the minimum needed.  I do promises that the other patch is coming soon. :)

Thanks,
-Don
