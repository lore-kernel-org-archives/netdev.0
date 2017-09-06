From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Wed, 6 Sep 2017 21:14:27 +0200
Message-ID: <89164218-82a8-ae12-4b1a-c2d0d8a04624@free.fr>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
 <931bf454-81ff-94dc-82e6-bc2b889bd43a@gmail.com>
 <d6a6b552-95a7-8353-54c8-fa804f9366a1@free.fr>
 <f74f1aad-3990-ae54-316f-751c3b15de41@gmail.com>
 <ebee6e5d-5bc1-1c5b-b31d-6d50618d6074@free.fr>
 <4ea8b432-4968-1616-eff9-48a2689dd3ce@gmail.com>
 <ff070239-28b7-d41b-8abe-c9f810561372@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
To: David Daney <ddaney@caviumnetworks.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:19994 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751941AbdIFTOd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 15:14:33 -0400
In-Reply-To: <ff070239-28b7-d41b-8abe-c9f810561372@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2017 20:00, David Daney wrote:
> On 08/31/2017 11:29 AM, Florian Fainelli wrote:
>> On 08/31/2017 11:12 AM, Mason wrote:
>>> On 31/08/2017 19:53, Florian Fainelli wrote:
>>>> On 08/31/2017 10:49 AM, Mason wrote:
>>>>> On 31/08/2017 18:57, Florian Fainelli wrote:
>>>>>> And the race is between phy_detach() setting phydev->attached_dev = NULL
>>>>>> and phy_state_machine() running in PHY_HALTED state and calling
>>>>>> netif_carrier_off().
>>>>>
>>>>> I must be missing something.
>>>>> (Since a thread cannot race against itself.)
>>>>>
>>>>> phy_disconnect calls phy_stop_machine which
>>>>> 1) stops the work queue from running in a separate thread
>>>>> 2) calls phy_state_machine *synchronously*
>>>>>       which runs the PHY_HALTED case with everything well-defined
>>>>> end of phy_stop_machine
>>>>>
>>>>> phy_disconnect only then calls phy_detach()
>>>>> which makes future calls of phy_state_machine perilous.
>>>>>
>>>>> This all happens in the same thread, so I'm not yet
>>>>> seeing where the race happens?
>>>>
>>>> The race is as described in David's earlier email, so let's recap:
>>>>
>>>> Thread 1			Thread 2
>>>> phy_disconnect()
>>>> phy_stop_interrupts()
>>>> phy_stop_machine()
>>>> phy_state_machine()
>>>>   -> queue_delayed_work()
>>>> phy_detach()
>>>> 				phy_state_machine()
>>>> 				-> netif_carrier_off()
>>>>
>>>> If phy_detach() finishes earlier than the workqueue had a chance to be
>>>> scheduled and process PHY_HALTED again, then we trigger the NULL pointer
>>>> de-reference.
>>>>
>>>> workqueues are not tasklets, the CPU scheduling them gets no guarantee
>>>> they will run on the same CPU.
>>>
>>> Something does not add up.
>>>
>>> The synchronous call to phy_state_machine() does:
>>>
>>> 	case PHY_HALTED:
>>> 		if (phydev->link) {
>>> 			phydev->link = 0;
>>> 			netif_carrier_off(phydev->attached_dev);
>>> 			phy_adjust_link(phydev);
>>> 			do_suspend = true;
>>> 		}
>>>
>>> then sets phydev->link = 0; therefore subsequent calls to
>>> phy_state_machin() will be no-op.
>>
>> Actually you are right, once phydev->link is set to 0 these would become
>> no-ops. Still scratching my head as to what happens for David then...
>>
>>>
>>> Also, queue_delayed_work() is only called in polling mode.
>>> David stated that he's using interrupt mode.
> 
> Did you see what I wrote?
> 
> phy_disconnect() calls phy_stop_interrupts() which puts it into polling 
> mode.  So the polling work gets queued unconditionally.

I did address that remark in
https://www.mail-archive.com/netdev@vger.kernel.org/msg186336.html

int phy_stop_interrupts(struct phy_device *phydev)
{
	int err = phy_disable_interrupts(phydev);

	if (err)
		phy_error(phydev);

	free_irq(phydev->irq, phydev);

	/* If work indeed has been cancelled, disable_irq() will have
	 * been left unbalanced from phy_interrupt() and enable_irq()
	 * has to be called so that other devices on the line work.
	 */
	while (atomic_dec_return(&phydev->irq_disable) >= 0)
		enable_irq(phydev->irq);

	return err;
}

Which part of this function changes phydev->irq to PHY_POLL?

Perhaps phydev->drv->config_intr?

What PHY are you using?

Regards.
