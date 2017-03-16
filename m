From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH] net: ethernet: bgmac: Allow MAC address to be specified
 in DTB
Date: Thu, 16 Mar 2017 13:13:38 -0400
Message-ID: <CAC3K-4rRmSAPiyJQku0uuaHwRerUD3BMkhLEBiGKEz5tRRBOJg@mail.gmail.com>
References: <1489679338-39705-1-git-send-email-steven.lin1@broadcom.com> <d6bf9f70-6857-440c-bd1c-40c2fa472b41@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steve Lin <steven.lin1@broadcom.com>,
        David Miller <davem@davemloft.net>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        Tobias Klauser <tklauser@distanz.ch>,
        Network Development <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6bf9f70-6857-440c-bd1c-40c2fa472b41@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 16, 2017 at 12:39 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 03/16/2017 08:48 AM, Steve Lin wrote:
>> Allows the BCMA version of the bgmac driver to obtain MAC address
>> from the device tree.  If no MAC address is specified there, then
>> the previous behavior (obtaining MAC address from SPROM) is
>> used.
>>
>> Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>
> PS: you might want to specify which tree this applies to by using [PATCH
> net-next] or [PATCH net] in the subject, see the netdev-FAQ.txt for
> details:
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/netdev-FAQ.txt

I believe he wants this in net-next

Acked-by: Jon Mason <jon.mason@broadcom.com>

>> ---
>>  drivers/net/ethernet/broadcom/bgmac-bcma.c | 39 ++++++++++++++++++------------
>>  1 file changed, 23 insertions(+), 16 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net/ethernet/broadcom/bgmac-bcma.c
>> index cf15b7e..6322594 100644
>> --- a/drivers/net/ethernet/broadcom/bgmac-bcma.c
>> +++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
>> @@ -11,6 +11,7 @@
>>  #include <linux/bcma/bcma.h>
>>  #include <linux/brcmphy.h>
>>  #include <linux/etherdevice.h>
>> +#include <linux/of_net.h>
>>  #include "bgmac.h"
>>
>>  static inline bool bgmac_is_bcm4707_family(struct bcma_device *core)
>> @@ -114,7 +115,7 @@ static int bgmac_probe(struct bcma_device *core)
>>       struct ssb_sprom *sprom = &core->bus->sprom;
>>       struct mii_bus *mii_bus;
>>       struct bgmac *bgmac;
>> -     u8 *mac;
>> +     const u8 *mac = NULL;
>>       int err;
>>
>>       bgmac = bgmac_alloc(&core->dev);
>> @@ -127,21 +128,27 @@ static int bgmac_probe(struct bcma_device *core)
>>
>>       bcma_set_drvdata(core, bgmac);
>>
>> -     switch (core->core_unit) {
>> -     case 0:
>> -             mac = sprom->et0mac;
>> -             break;
>> -     case 1:
>> -             mac = sprom->et1mac;
>> -             break;
>> -     case 2:
>> -             mac = sprom->et2mac;
>> -             break;
>> -     default:
>> -             dev_err(bgmac->dev, "Unsupported core_unit %d\n",
>> -                     core->core_unit);
>> -             err = -ENOTSUPP;
>> -             goto err;
>> +     if (bgmac->dev->of_node)
>> +             mac = of_get_mac_address(bgmac->dev->of_node);
>> +
>> +     /* If no MAC address assigned via device tree, check SPROM */
>> +     if (!mac) {
>> +             switch (core->core_unit) {
>> +             case 0:
>> +                     mac = sprom->et0mac;
>> +                     break;
>> +             case 1:
>> +                     mac = sprom->et1mac;
>> +                     break;
>> +             case 2:
>> +                     mac = sprom->et2mac;
>> +                     break;
>> +             default:
>> +                     dev_err(bgmac->dev, "Unsupported core_unit %d\n",
>> +                             core->core_unit);
>> +                     err = -ENOTSUPP;
>> +                     goto err;
>> +             }
>>       }
>>
>>       ether_addr_copy(bgmac->net_dev->dev_addr, mac);
>>
>
>
> --
> Florian
