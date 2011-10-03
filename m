From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next 11/11 v2] ixgbe: allow eeprom writes via ethtool
Date: Mon, 3 Oct 2011 11:00:10 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A136605A8FCB18@rrsmsx501.amr.corp.intel.com>
References: <1317444771-13962-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1317444771-13962-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <20111001093105.GA9885@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47112 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756935Ab1JCRAM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 13:00:12 -0400
In-Reply-To: <20111001093105.GA9885@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Francois Romieu [mailto:romieu@fr.zoreil.com]
>Sent: Saturday, October 01, 2011 2:31 AM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; Tantilov, Emil S; netdev@vger.kernel.org;
>gospo@redhat.com
>Subject: Re: [net-next 11/11 v2] ixgbe: allow eeprom writes via ethtool
>
>Jeff Kirsher <jeffrey.t.kirsher@intel.com> :
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>> index 10ea29f..fb47abb 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>> @@ -812,6 +812,66 @@ static int ixgbe_get_eeprom(struct net_device
>*netdev,
>[...]
>> +	ptr = (void *)eeprom_buff;
>
>(nit) useless cast to void *.
>
>> +
>> +	if (eeprom->offset & 1) {
>[...]
>> +		ret_val = hw->eeprom.ops.read(hw, first_word, &eeprom_buff[0]);
>> +		ptr++;
>> +	}
>> +	if (((eeprom->offset + eeprom->len) & 1) && (ret_val == 0)) {
>[...]
>> +		ret_val = hw->eeprom.ops.read(hw, last_word,
>> +					  &eeprom_buff[last_word - first_word]);
>> +	}
>
>I guess that the code tries to do its best to write something even when the
>reads or writes partially fail but this one should imho be :

Actually we shouldn't be writing if any of the eeprom read operations fail. I will revisit the error checking logic.

>
>	if ((eeprom->offset + eeprom->len) & 1) {
>[...]
>		ret_val |= hw->eeprom.ops.read(hw, last_word,
>
>> +
>> +	/* Device's eeprom is always little-endian, word addressable */
>> +	for (i = 0; i < last_word - first_word + 1; i++)
>> +		le16_to_cpus(&eeprom_buff[i]);
>
>Shouldn't there be (drivers/net/ethernet/intel/ixgbe/ixgbe_type.h):
>
>struct ixgbe_eeprom_operations {
>[...]
>        s32 (*read)(struct ixgbe_hw *, u16, __le16 *);
>
>instead of :
>
>struct ixgbe_eeprom_operations {
>[...]
>        s32 (*read)(struct ixgbe_hw *, u16, u16 *);
>
>[...]

That's a good idea.

>> +	/* Update the checksum */
>> +	hw->eeprom.ops.update_checksum(hw);
>
>The returned status code is ignored.

Thanks for the review. I already asked Jeff to drop this patch, we'll address the issues pointed out and submit a new version.

Thanks,
Emil

>
>--
>Ueimor
