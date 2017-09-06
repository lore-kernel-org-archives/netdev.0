From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Wed, 6 Sep 2017 11:00:53 -0700
Message-ID: <ff070239-28b7-d41b-8abe-c9f810561372@caviumnetworks.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
 <931bf454-81ff-94dc-82e6-bc2b889bd43a@gmail.com>
 <d6a6b552-95a7-8353-54c8-fa804f9366a1@free.fr>
 <f74f1aad-3990-ae54-316f-751c3b15de41@gmail.com>
 <ebee6e5d-5bc1-1c5b-b31d-6d50618d6074@free.fr>
 <4ea8b432-4968-1616-eff9-48a2689dd3ce@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
To: Florian Fainelli <f.fainelli@gmail.com>, Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0080.outbound.protection.outlook.com ([104.47.34.80]:39901
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750836AbdIFSA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 14:00:59 -0400
In-Reply-To: <4ea8b432-4968-1616-eff9-48a2689dd3ce@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2017 11:29 AM, Florian Fainelli wrote:
> On 08/31/2017 11:12 AM, Mason wrote:
>> On 31/08/2017 19:53, Florian Fainelli wrote:
>>> On 08/31/2017 10:49 AM, Mason wrote:
>>>> On 31/08/2017 18:57, Florian Fainelli wrote:
>>>>> And the race is between phy_detach() setting phydev->attached_dev = NULL
>>>>> and phy_state_machine() running in PHY_HALTED state and calling
>>>>> netif_carrier_off().
>>>>
>>>> I must be missing something.
>>>> (Since a thread cannot race against itself.)
>>>>
>>>> phy_disconnect calls phy_stop_machine which
>>>> 1) stops the work queue from running in a separate thread
>>>> 2) calls phy_state_machine *synchronously*
>>>>       which runs the PHY_HALTED case with everything well-defined
>>>> end of phy_stop_machine
>>>>
>>>> phy_disconnect only then calls phy_detach()
>>>> which makes future calls of phy_state_machine perilous.
>>>>
>>>> This all happens in the same thread, so I'm not yet
>>>> seeing where the race happens?
>>>
>>> The race is as described in David's earlier email, so let's recap:
>>>
>>> Thread 1			Thread 2
>>> phy_disconnect()
>>> phy_stop_interrupts()
>>> phy_stop_machine()
>>> phy_state_machine()
>>>   -> queue_delayed_work()
>>> phy_detach()
>>> 				phy_state_machine()
>>> 				-> netif_carrier_off()
>>>
>>> If phy_detach() finishes earlier than the workqueue had a chance to be
>>> scheduled and process PHY_HALTED again, then we trigger the NULL pointer
>>> de-reference.
>>>
>>> workqueues are not tasklets, the CPU scheduling them gets no guarantee
>>> they will run on the same CPU.
>>
>> Something does not add up.
>>
>> The synchronous call to phy_state_machine() does:
>>
>> 	case PHY_HALTED:
>> 		if (phydev->link) {
>> 			phydev->link = 0;
>> 			netif_carrier_off(phydev->attached_dev);
>> 			phy_adjust_link(phydev);
>> 			do_suspend = true;
>> 		}
>>
>> then sets phydev->link = 0; therefore subsequent calls to
>> phy_state_machin() will be no-op.
> 
> Actually you are right, once phydev->link is set to 0 these would become
> no-ops. Still scratching my head as to what happens for David then...
> 
>>
>> Also, queue_delayed_work() is only called in polling mode.
>> David stated that he's using interrupt mode.

Did you see what I wrote?

phy_disconnect() calls phy_stop_interrupts() which puts it into polling 
mode.  So the polling work gets queued unconditionally.



> 
> Right that's confusing too now. David can you check if you tree has:
> 
> 49d52e8108a21749dc2114b924c907db43358984 ("net: phy: handle state
> correctly in phy_stop_machine")
> 

Yes, I am using the 4.9 stable branch, and that commit was also present.

David.
