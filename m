From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 05/10] bnxt_en: Add get_eee() and set_eee()
 ethtool support.
Date: Tue, 5 Apr 2016 03:36:23 -0700
Message-ID: <CACKFLinJMDC52Bbc_OFQLFAJuoC-DC5kdawkRo1J75Q5v3XOpA@mail.gmail.com>
References: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
	<1459844562-24576-6-git-send-email-michael.chan@broadcom.com>
	<1459850858.23351.45.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34206 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757797AbcDEKgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 06:36:25 -0400
Received: by mail-oi0-f54.google.com with SMTP id s79so11978089oie.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 03:36:24 -0700 (PDT)
In-Reply-To: <1459850858.23351.45.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 5, 2016 at 3:07 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Tue, 2016-04-05 at 04:22 -0400, Michael Chan wrote:
>
>> Allow users to get|set EEE parameters.
>>
>> Signed-off-by: Michael Chan <michael.chan@broadcom.com>
>> ---
>>  drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 73 +++++++++++++++++++++++
>>  1 file changed, 73 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
>> index 14f0520..3d5c64f 100644
>> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
>> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
>> @@ -1379,6 +1379,77 @@ static int bnxt_set_eeprom(struct net_device *dev,
>>                               eeprom->len);
>>  }
>>
>> +static int bnxt_set_eee(struct net_device *dev, struct ethtool_eee *edata)
>> +{
>> +     struct bnxt *bp = netdev_priv(dev);
>> +     struct ethtool_eee *eee = &bp->eee;
>> +     struct bnxt_link_info *link_info = &bp->link_info;
>> +     u32 advertising =
>> +              _bnxt_fw_to_ethtool_adv_spds(link_info->advertising, 0);
>> +     int rc = 0;
>> +
>> +     if (BNXT_VF(bp))
>> +             return 0;
>> +
>> +     if (!(bp->flags & BNXT_FLAG_EEE_CAP))
>> +             return -EOPNOTSUPP;
>> +
>> +     if (!edata->eee_enabled)
>> +             goto eee_ok;
> [...]
>> +     eee->advertised = edata->advertised;
>> +     eee->tx_lpi_enabled = edata->tx_lpi_enabled;
>> +     eee->tx_lpi_timer = edata->tx_lpi_timer;
>> +eee_ok:
>> +     eee->eee_enabled = edata->eee_enabled;
>> +
>> +     if (netif_running(dev))
>> +             rc = bnxt_hwrm_set_link_setting(bp, false, true);
>> +
>> +     return rc;
>> +}
>> +
>> +static int bnxt_get_eee(struct net_device *dev, struct ethtool_eee *edata)
>> +{
>> +     struct bnxt *bp = netdev_priv(dev);
>> +
>> +     if (!(bp->flags & BNXT_FLAG_EEE_CAP))
>> +             return -EOPNOTSUPP;
>> +
>> +     *edata = bp->eee;
>> +     if (!bp->eee.eee_enabled) {
>> +             edata->advertised = 0;
>> +             edata->tx_lpi_enabled = 0;
>
> What about tx_lpi_timer?

We want to keep the tx_lpi_timer value so that it can be used again
when it is turned on again.

The user doesn't have to figure out what value to use if he just wants
to use the default or the last value.

>
> And, wouldn't it make more sense to do these fixups to the internal
> state in bnxt_set_eee()?

I don't understand.  If the user is enabling EEE, we take all the
parameters.  If he is disabling, we don't take any of the parameters.

>
> Ben.
>
>> +     }
>> +
>> +     if (!bp->eee.eee_active)
>> +             edata->lp_advertised = 0;
>> +
>> +     return 0;
>> +}
> [...]
>
> --
> Ben Hutchings
> No political challenge can be met by shopping. - George Monbiot
