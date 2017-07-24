From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Problem with PHY state machine when using interrupts
Date: Mon, 24 Jul 2017 15:39:07 -0700
Message-ID: <eb09bda5-c972-0c2c-2693-982c02c8c87c@gmail.com>
References: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr>
 <849513d9-c981-ec20-5a10-08c663d0aa37@free.fr>
 <02e9e171-ec22-e491-5bc8-ef4b3ad7fec2@gmail.com>
 <e6a7a5df-b735-6f9c-6a2b-cded86ec6525@free.fr>
 <b0410a73-ff2d-ca06-93fa-17af2040c41c@gmail.com>
 <0f56083f-d43e-a141-1470-b76546af6d58@gmail.com>
 <c81e12bc-0f89-5eab-547e-f0c1ec389ad8@free.fr>
 <62085f48-df18-f987-f521-dcdfbd7f574b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>, Andrew Lunn <andrew@lunn.ch>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34850 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752864AbdGXWjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 18:39:10 -0400
Received: by mail-qk0-f196.google.com with SMTP id k2so3777670qkf.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 15:39:10 -0700 (PDT)
In-Reply-To: <62085f48-df18-f987-f521-dcdfbd7f574b@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2017 03:36 PM, Florian Fainelli wrote:
> On 07/24/2017 02:20 PM, Mason wrote:
>> On 24/07/2017 21:53, Florian Fainelli wrote:
>>
>>> Well now that I see the possible interrupts generated, I indeed don't
>>> see how you can get a link down notification unless you somehow force
>>> the link down yourself, which would certainly happen in phy_suspend()
>>> when we set BMCR.pwrdwn, but that may be too late.
>>>
>>> You should still expect the adjust_link() function to be called though
>>> with PHY_HALTED being set and that takes care of doing phydev->link = 0
>>> and netif_carrier_off(). If that still does not work, then see whether
>>> removing the call to phy_stop() does help (it really should).
>>
>> The only functions setting phydev->state to PHY_HALTED
>> are phy_error() and phy_stop() AFAICT.
>>
>> I am aware that when phy_state_machine() handles the
>> PHY_HALTED state, it will set phydev->link = 0;
>> and call netif_carrier_off() -- because that's where
>> I copied that code from.
>>
>> My issue is that phy_state_machine() does not run when
>> I run 'ip set link dev eth0 down' from the command line.
> 
> Yes, that much is clear, which is why I suggested earlier you try the
> patch at the end now.

This sentence was referring to this patch that I changed mid way through
this email:

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d0626bf5c540..652e24b53f3f 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -968,6 +968,8 @@ void phy_stop(struct phy_device *phydev)
         * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
         * will not reenable interrupts.
         */
+       if (phy_interrupt_is_valid(phydev))
+               phy_change(phydev);
 }
 EXPORT_SYMBOL(phy_stop);
-- 
Florian
