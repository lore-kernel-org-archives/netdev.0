From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH next] bonding: speed/duplex update at NETDEV_UP event
Date: Fri, 29 Sep 2017 15:02:16 -0700
Message-ID: <CAF2d9jiy0bGQ8cOKMA6jc5Z5d_cOLYkWi1poMuiwSxVwsv1=+g@mail.gmail.com>
References: <20170928010349.8988-1-mahesh@bandewar.net> <20170929130819.74879e99@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:44848 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbdI2WCj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 18:02:39 -0400
Received: by mail-wm0-f45.google.com with SMTP id m127so1390441wmm.1
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 15:02:38 -0700 (PDT)
In-Reply-To: <20170929130819.74879e99@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 1:08 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 27 Sep 2017 18:03:49 -0700
> Mahesh Bandewar <mahesh@bandewar.net> wrote:
>
>> From: Mahesh Bandewar <maheshb@google.com>
>>
>> Some NIC drivers don't have correct speed/duplex settings at the
>> time they send NETDEV_UP notification and that messes up the
>> bonding state. Especially 802.3ad mode which is very sensitive
>> to these settings. In the current implementation we invoke
>> bond_update_speed_duplex() when we receive NETDEV_UP, however,
>> ignore the return value. If the values we get are invalid
>> (UNKNOWN), then slave gets removed from the aggregator with
>> speed and duplex set to UNKNOWN while link is still marked as UP.
>>
>> This patch fixes this scenario. Also 802.3ad mode is sensitive to
>> these conditions while other modes are not, so making sure that it
>> doesn't change the behavior for other modes.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 11 ++++++++++-
>>  1 file changed, 10 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index b7313c1d9dcd..177be373966b 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -3076,7 +3076,16 @@ static int bond_slave_netdev_event(unsigned long event,
>>               break;
>>       case NETDEV_UP:
>>       case NETDEV_CHANGE:
>> -             bond_update_speed_duplex(slave);
>> +             /* For 802.3ad mode only:
>> +              * Getting invalid Speed/Duplex values here will put slave
>> +              * in weird state. So mark it as link-down for the time
>> +              * being and let link-monitoring (miimon) set it right when
>> +              * correct speeds/duplex are available.
>> +              */
>> +             if (bond_update_speed_duplex(slave) &&
>> +                 BOND_MODE(bond) == BOND_MODE_8023AD)
>> +                     slave->link = BOND_LINK_DOWN;
>> +
>>               if (BOND_MODE(bond) == BOND_MODE_8023AD)
>>                       bond_3ad_adapter_speed_duplex_changed(slave);
>>               /* Fallthrough */
>
> Then fix the drivers. Trying to workaround it here isn't helping.
>
This is not a workaround. It avoids bonding state being weird.

> The problem is that miimon is not required.  Bonding can be purely
> event driven.
>
really? Here is a code-snippet from bonding itself -

        /* reset values for 802.3ad/TLB/ALB */
        if (!bond_mode_uses_arp(bond_mode)) {
                if (!miimon) {
                        pr_warn("Warning: miimon must be specified,
otherwise bonding will not detect link failure, speed and duplex which
are essential for 802.3ad operation\n");
                        pr_warn("Forcing miimon to 100msec\n");
                        miimon = BOND_DEFAULT_MIIMON;
                }
        }
