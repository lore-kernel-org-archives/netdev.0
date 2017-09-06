From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Wed, 6 Sep 2017 13:49:41 -0700
Message-ID: <6890a27f-e87e-62c1-a676-e5ddf968adb6@caviumnetworks.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
 <931bf454-81ff-94dc-82e6-bc2b889bd43a@gmail.com>
 <d6a6b552-95a7-8353-54c8-fa804f9366a1@free.fr>
 <f74f1aad-3990-ae54-316f-751c3b15de41@gmail.com>
 <ebee6e5d-5bc1-1c5b-b31d-6d50618d6074@free.fr>
 <4ea8b432-4968-1616-eff9-48a2689dd3ce@gmail.com>
 <ff070239-28b7-d41b-8abe-c9f810561372@caviumnetworks.com>
 <572f49fd-f623-f064-a551-e243c57cef7f@gmail.com>
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
Received: from mail-by2nam01on0083.outbound.protection.outlook.com ([104.47.34.83]:64736
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752058AbdIFUtt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 16:49:49 -0400
In-Reply-To: <572f49fd-f623-f064-a551-e243c57cef7f@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2017 11:59 AM, Florian Fainelli wrote:
> On 09/06/2017 11:00 AM, David Daney wrote:
>> On 08/31/2017 11:29 AM, Florian Fainelli wrote:
>>> On 08/31/2017 11:12 AM, Mason wrote:
>>>> On 31/08/2017 19:53, Florian Fainelli wrote:
>>>>> On 08/31/2017 10:49 AM, Mason wrote:
>>>>>> On 31/08/2017 18:57, Florian Fainelli wrote:
>>>>>>> And the race is between phy_detach() setting phydev->attached_dev
>>>>>>> = NULL
>>>>>>> and phy_state_machine() running in PHY_HALTED state and calling
>>>>>>> netif_carrier_off().
>>>>>>
>>>>>> I must be missing something.
>>>>>> (Since a thread cannot race against itself.)
>>>>>>
>>>>>> phy_disconnect calls phy_stop_machine which
>>>>>> 1) stops the work queue from running in a separate thread
>>>>>> 2) calls phy_state_machine *synchronously*
>>>>>>        which runs the PHY_HALTED case with everything well-defined
>>>>>> end of phy_stop_machine
>>>>>>
>>>>>> phy_disconnect only then calls phy_detach()
>>>>>> which makes future calls of phy_state_machine perilous.
>>>>>>
>>>>>> This all happens in the same thread, so I'm not yet
>>>>>> seeing where the race happens?
>>>>>
>>>>> The race is as described in David's earlier email, so let's recap:
>>>>>
>>>>> Thread 1            Thread 2
>>>>> phy_disconnect()
>>>>> phy_stop_interrupts()
>>>>> phy_stop_machine()
>>>>> phy_state_machine()
>>>>>    -> queue_delayed_work()
>>>>> phy_detach()
>>>>>                  phy_state_machine()
>>>>>                  -> netif_carrier_off()
>>>>>
>>>>> If phy_detach() finishes earlier than the workqueue had a chance to be
>>>>> scheduled and process PHY_HALTED again, then we trigger the NULL
>>>>> pointer
>>>>> de-reference.
>>>>>
>>>>> workqueues are not tasklets, the CPU scheduling them gets no guarantee
>>>>> they will run on the same CPU.
>>>>
>>>> Something does not add up.
>>>>
>>>> The synchronous call to phy_state_machine() does:
>>>>
>>>>      case PHY_HALTED:
>>>>          if (phydev->link) {
>>>>              phydev->link = 0;
>>>>              netif_carrier_off(phydev->attached_dev);
>>>>              phy_adjust_link(phydev);
>>>>              do_suspend = true;
>>>>          }
>>>>
>>>> then sets phydev->link = 0; therefore subsequent calls to
>>>> phy_state_machin() will be no-op.
>>>
>>> Actually you are right, once phydev->link is set to 0 these would become
>>> no-ops. Still scratching my head as to what happens for David then...
>>>
>>>>
>>>> Also, queue_delayed_work() is only called in polling mode.
>>>> David stated that he's using interrupt mode.
>>
>> Did you see what I wrote?
> 
> Still not following, see below.
> 
>>
>> phy_disconnect() calls phy_stop_interrupts() which puts it into polling
>> mode.  So the polling work gets queued unconditionally.
> 
> What part of phy_stop_interrupts() is responsible for changing
> phydev->irq to PHY_POLL? free_irq() cannot touch phydev->irq otherwise
> subsequent request_irq() calls won't work anymore.
> phy_disable_interrupts() only calls back into the PHY driver to
> acknowledge and clear interrupts.
> 
> If we were using a PHY with PHY_POLL, as Marc said, the first
> synchronous call to phy_state_machine() would have acted on PHY_HALTED
> and even if we incorrectly keep re-scheduling the state machine from
> PHY_HALTED to PHY_HALTED the second time around nothing can happen.
> 
> What are we missing here?
> 

OK, I am now as confused as you guys are.  I will go back and get an 
ftrace log out of the failure.

David.
