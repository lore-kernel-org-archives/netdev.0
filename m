From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Thu, 31 Aug 2017 11:29:12 -0700
Message-ID: <4ea8b432-4968-1616-eff9-48a2689dd3ce@gmail.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
 <931bf454-81ff-94dc-82e6-bc2b889bd43a@gmail.com>
 <d6a6b552-95a7-8353-54c8-fa804f9366a1@free.fr>
 <f74f1aad-3990-ae54-316f-751c3b15de41@gmail.com>
 <ebee6e5d-5bc1-1c5b-b31d-6d50618d6074@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
To: Mason <slash.tmp@free.fr>, David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35888 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750895AbdHaS3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 14:29:19 -0400
Received: by mail-qt0-f196.google.com with SMTP id e2so329924qta.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 11:29:19 -0700 (PDT)
In-Reply-To: <ebee6e5d-5bc1-1c5b-b31d-6d50618d6074@free.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2017 11:12 AM, Mason wrote:
> On 31/08/2017 19:53, Florian Fainelli wrote:
>> On 08/31/2017 10:49 AM, Mason wrote:
>>> On 31/08/2017 18:57, Florian Fainelli wrote:
>>>> And the race is between phy_detach() setting phydev->attached_dev = NULL
>>>> and phy_state_machine() running in PHY_HALTED state and calling
>>>> netif_carrier_off().
>>>
>>> I must be missing something.
>>> (Since a thread cannot race against itself.)
>>>
>>> phy_disconnect calls phy_stop_machine which
>>> 1) stops the work queue from running in a separate thread
>>> 2) calls phy_state_machine *synchronously*
>>>      which runs the PHY_HALTED case with everything well-defined
>>> end of phy_stop_machine
>>>
>>> phy_disconnect only then calls phy_detach()
>>> which makes future calls of phy_state_machine perilous.
>>>
>>> This all happens in the same thread, so I'm not yet
>>> seeing where the race happens?
>>
>> The race is as described in David's earlier email, so let's recap:
>>
>> Thread 1			Thread 2
>> phy_disconnect()
>> phy_stop_interrupts()
>> phy_stop_machine()
>> phy_state_machine()
>>  -> queue_delayed_work()
>> phy_detach()
>> 				phy_state_machine()
>> 				-> netif_carrier_off()
>>
>> If phy_detach() finishes earlier than the workqueue had a chance to be
>> scheduled and process PHY_HALTED again, then we trigger the NULL pointer
>> de-reference.
>>
>> workqueues are not tasklets, the CPU scheduling them gets no guarantee
>> they will run on the same CPU.
> 
> Something does not add up.
> 
> The synchronous call to phy_state_machine() does:
> 
> 	case PHY_HALTED:
> 		if (phydev->link) {
> 			phydev->link = 0;
> 			netif_carrier_off(phydev->attached_dev);
> 			phy_adjust_link(phydev);
> 			do_suspend = true;
> 		}
> 
> then sets phydev->link = 0; therefore subsequent calls to
> phy_state_machin() will be no-op.

Actually you are right, once phydev->link is set to 0 these would become
no-ops. Still scratching my head as to what happens for David then...

> 
> Also, queue_delayed_work() is only called in polling mode.
> David stated that he's using interrupt mode.

Right that's confusing too now. David can you check if you tree has:

49d52e8108a21749dc2114b924c907db43358984 ("net: phy: handle state
correctly in phy_stop_machine")
-- 
Florian
