From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: bcmgenet: add support for new GENET
 PHY revision scheme
Date: Wed, 03 Dec 2014 09:54:22 -0800
Message-ID: <547F4E4E.5030906@gmail.com>
References: <1417562882-2511-1-git-send-email-f.fainelli@gmail.com> <1417562882-2511-2-git-send-email-f.fainelli@gmail.com> <547EF2BC.60504@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:59069 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaLCRyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:54:31 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so16073237pac.25
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:54:30 -0800 (PST)
In-Reply-To: <547EF2BC.60504@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/14 03:23, Sergei Shtylyov wrote:
> Hello.
> 
> On 12/3/2014 2:28 AM, Florian Fainelli wrote:
> 
>> Starting with GPHY revision G0, the GENET register layout has changed to
>> use the same numbering scheme as the Starfighter 2 switch. This means
>> that GPHY major revision is in bits 15:12, minor in bits 11:8 and patch
>> level is in bits 7:4.
> 
>> Introduce a small heuristic which checks for the old scheme first, tests
>> for the new scheme and finally attempts to catch reserved values and
>> aborts.
> 
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>   drivers/net/ethernet/broadcom/genet/bcmgenet.c | 24
>> +++++++++++++++++++++++-
>>   1 file changed, 23 insertions(+), 1 deletion(-)
> 
>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> index f2fadb053d52..23e283174c4e 100644
>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> [...]
>> @@ -2551,8 +2552,29 @@ static void bcmgenet_set_hw_params(struct
>> bcmgenet_priv *priv)
>>        * to pass this information to the PHY driver. The PHY driver
>> expects
>>        * to find the PHY major revision in bits 15:8 while the GENET
>> register
>>        * stores that information in bits 7:0, account for that.
>> +     *
>> +     * On newer chips, starting with PHY revision G0, a new scheme is
>> +     * deployed similar to the Starfighter 2 switch with GPHY major
>> +     * revision in bits 15:8 and patch level in bits 7:0. Major
>> revision 0
>> +     * is reserved as well as special value 0x01ff, we have a small
>> +     * heuristic to check for the new GPHY revision and re-arrange
>> things
>> +     * so the GPHY driver is happy.
>>        */
>> -    priv->gphy_rev = (reg & 0xffff) << 8;
>> +    gphy_rev = (reg & 0xffff);
> 
>    Parens not needed anymore.
> 
>> +
>> +    /* This the good old scheme, just GPHY major, no minor nor patch */
> 
>    Missing "is" after "This"?

Alright, I will resubmit...

> 
>> +    if ((gphy_rev & 0xf0) != 0)
>> +        priv->gphy_rev = gphy_rev << 8;
>> +
>> +    /* This is the new scheme, GPHY major rolls over with 0x10 = rev
>> G0 */
>> +    else if ((gphy_rev & 0xff00) != 0)
>> +        priv->gphy_rev = gphy_rev;
>> +
>> +    /* This is reserved so should require special treatment */
>> +    else if (gphy_rev == 0 || gphy_rev == 0x01ff) {
>> +        pr_warn("Invalid GPHY revision detected: 0x%04x\n", gphy_rev);
>> +        return;
>> +    }
> 
>    Hm, {} are needed on all *if* branches.

checkpatch.pl did not complain about that.

> 
> [...]
> 
> WBR, Sergei
> 
