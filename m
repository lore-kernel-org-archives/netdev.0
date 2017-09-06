From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Wed, 6 Sep 2017 16:33:54 +0200
Message-ID: <6721135d-8c3f-57a0-f423-9d18cd6e0947@free.fr>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
 <931bf454-81ff-94dc-82e6-bc2b889bd43a@gmail.com>
 <d6a6b552-95a7-8353-54c8-fa804f9366a1@free.fr>
 <f74f1aad-3990-ae54-316f-751c3b15de41@gmail.com>
 <ebee6e5d-5bc1-1c5b-b31d-6d50618d6074@free.fr>
 <4ea8b432-4968-1616-eff9-48a2689dd3ce@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:8613 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932345AbdIFOeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 10:34:16 -0400
In-Reply-To: <4ea8b432-4968-1616-eff9-48a2689dd3ce@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/08/2017 20:29, Florian Fainelli wrote:
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
> 
> Right that's confusing too now. David can you check if you tree has:
> 
> 49d52e8108a21749dc2114b924c907db43358984 ("net: phy: handle state
> correctly in phy_stop_machine")

Hello David,

A week ago, you wrote about my patch:
"This is broken.  Please revert."

I assume you tested the revert locally, and that reverting did make
the crash disappear. Is that correct?

The reason I ask is because the analysis you provided contains some
flaws, as noted above. But, if reverting my patch did fix your issue,
then perhaps understanding *why* is unimportant.

I'm a bit baffled that it took less than 90 minutes for your request
to be approved, and the patch reverted in all branches, before I even
had a chance to comment.

Regards.
