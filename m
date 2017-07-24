From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Problem with PHY state machine when using interrupts
Date: Mon, 24 Jul 2017 09:49:35 -0700
Message-ID: <02e9e171-ec22-e491-5bc8-ef4b3ad7fec2@gmail.com>
References: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr>
 <849513d9-c981-ec20-5a10-08c663d0aa37@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>, Andrew Lunn <andrew@lunn.ch>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:37044 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752911AbdGXQtj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:49:39 -0400
Received: by mail-qk0-f182.google.com with SMTP id q130so13918174qka.4
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:49:39 -0700 (PDT)
In-Reply-To: <849513d9-c981-ec20-5a10-08c663d0aa37@free.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2017 08:01 AM, Mason wrote:
> On 24/07/2017 13:07, Mason wrote:
> 
>> When I set the link down via 'ip link set eth0 down'
>> (as opposed to pulling the Ethernet cable) things don't happen as expected:
>>
>> The driver's adjust_link() callback is never called, and doesn't
>> get a chance make some required changes. And when I set the link
>> up again, there is no network connectivity.
>>
>> I get this problem only if I enable interrupts on my PHY.
>> If I use polling, things work as expected.
>>
>>
>> When I set the link down, devinet_ioctl() eventually calls
>> ndo_set_rx_mode() and ndo_stop()
>>
>> In ndo_stop() the driver calls
>> phy_stop(phydev);
>> which disables interrupts and sets the state to HALTED.
>>
>> In phy_state_machine()
>> the PHY_HALTED case does call the adjust_link() callback:
>>
>> 		if (phydev->link) {
>> 			phydev->link = 0;
>> 			netif_carrier_off(phydev->attached_dev);
>> 			phy_adjust_link(phydev);
>> 			do_suspend = true;
>> 		}
>>
>> But it's not called when I use interrupts...
>>
>> Perhaps because there are no interrupts generated?
>> Or even if there were, they have been turned off by phy_stop?
>>
>> Basically, it seems like when I use interrupts,
>> the phy_state_machine() is not called on link down,
>> which breaks the MAC driver's expectations.
>>
>> Am I barking up the wrong tree?
> 
> FWIW, the patch below solves my issue.
> Basically, we reset the MAC in open(), instead of probe().
> 
> I also had to solve the issue of adjust_link() not being
> called by calling it explicitly in stop() instead of
> relying on phy_stop() to do it indirectly.

Which is of course absolutely not how it is intended to be used.
phy_stop() does the following:

- if the PHY was already HALTED do nothing and exit
- if it was not and an interrupt is valid for this PHY:  disable and
clear these interrupts
- set state to PHY_HALTED

somehow an interrupt should be generated from doing this such that
phy_change(), invoked from phy_interrupt() should have a chance to run
and make the PHY state machine transition properly to PHY_HALTED.

So from there can you check a few things:

- is such an interrupt actually generated?
- if you turn on dynamic debug prints for drivers/net/phy/phy.c where do
we leave the PHY state machine and what state is it in when you call
ifconfig up again?

> 
> With this code, I think it is easy to handle suspend/resume:
> on suspend, I will stop() and on resume, I will start(),
> and everything should work as expected.
> 
> I'd like to hear comments on the patch, so I can turn it
> into a formal submission.



-- 
Florian
