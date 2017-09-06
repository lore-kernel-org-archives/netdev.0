From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Wed, 6 Sep 2017 16:14:22 -0700
Message-ID: <a4b70bf9-ec48-314d-b63d-e44f7cbb4bab@gmail.com>
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
 <6890a27f-e87e-62c1-a676-e5ddf968adb6@caviumnetworks.com>
 <4a65e53c-f13b-9cc3-bffa-f2f2aae423b9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
To: David Daney <ddaney.cavm@gmail.com>,
        David Daney <ddaney@caviumnetworks.com>,
        Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38001 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752666AbdIFXOd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 19:14:33 -0400
Received: by mail-wr0-f194.google.com with SMTP id p37so1545418wrb.5
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 16:14:32 -0700 (PDT)
In-Reply-To: <4a65e53c-f13b-9cc3-bffa-f2f2aae423b9@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2017 03:51 PM, David Daney wrote:
> On 09/06/2017 01:49 PM, David Daney wrote:
>> On 09/06/2017 11:59 AM, Florian Fainelli wrote:
>>> On 09/06/2017 11:00 AM, David Daney wrote:
>>>> On 08/31/2017 11:29 AM, Florian Fainelli wrote:
>>>>> On 08/31/2017 11:12 AM, Mason wrote:
>>>>>> On 31/08/2017 19:53, Florian Fainelli wrote:
>>>>>>> On 08/31/2017 10:49 AM, Mason wrote:
>>>>>>>> On 31/08/2017 18:57, Florian Fainelli wrote:
>>>>>>>>> And the race is between phy_detach() setting phydev->attached_dev
>>>>>>>>> = NULL
>>>>>>>>> and phy_state_machine() running in PHY_HALTED state and calling
>>>>>>>>> netif_carrier_off().
>>>>>>>>
>>>>>>>> I must be missing something.
>>>>>>>> (Since a thread cannot race against itself.)
>>>>>>>>
>>>>>>>> phy_disconnect calls phy_stop_machine which
>>>>>>>> 1) stops the work queue from running in a separate thread
>>>>>>>> 2) calls phy_state_machine *synchronously*
>>>>>>>>        which runs the PHY_HALTED case with everything well-defined
>>>>>>>> end of phy_stop_machine
>>>>>>>>
>>>>>>>> phy_disconnect only then calls phy_detach()
>>>>>>>> which makes future calls of phy_state_machine perilous.
>>>>>>>>
>>>>>>>> This all happens in the same thread, so I'm not yet
>>>>>>>> seeing where the race happens?
>>>>>>>
>>>>>>> The race is as described in David's earlier email, so let's recap:
>>>>>>>
>>>>>>> Thread 1            Thread 2
>>>>>>> phy_disconnect()
>>>>>>> phy_stop_interrupts()
>>>>>>> phy_stop_machine()
>>>>>>> phy_state_machine()
>>>>>>>    -> queue_delayed_work()
>>>>>>> phy_detach()
>>>>>>>                  phy_state_machine()
>>>>>>>                  -> netif_carrier_off()
>>>>>>>
>>>>>>> If phy_detach() finishes earlier than the workqueue had a chance
>>>>>>> to be
>>>>>>> scheduled and process PHY_HALTED again, then we trigger the NULL
>>>>>>> pointer
>>>>>>> de-reference.
>>>>>>>
>>>>>>> workqueues are not tasklets, the CPU scheduling them gets no
>>>>>>> guarantee
>>>>>>> they will run on the same CPU.
>>>>>>
>>>>>> Something does not add up.
>>>>>>
>>>>>> The synchronous call to phy_state_machine() does:
>>>>>>
>>>>>>      case PHY_HALTED:
>>>>>>          if (phydev->link) {
>>>>>>              phydev->link = 0;
>>>>>>              netif_carrier_off(phydev->attached_dev);
>>>>>>              phy_adjust_link(phydev);
>>>>>>              do_suspend = true;
>>>>>>          }
>>>>>>
>>>>>> then sets phydev->link = 0; therefore subsequent calls to
>>>>>> phy_state_machin() will be no-op.
>>>>>
>>>>> Actually you are right, once phydev->link is set to 0 these would
>>>>> become
>>>>> no-ops. Still scratching my head as to what happens for David then...
>>>>>
>>>>>>
>>>>>> Also, queue_delayed_work() is only called in polling mode.
>>>>>> David stated that he's using interrupt mode.
>>>>
>>>> Did you see what I wrote?
>>>
>>> Still not following, see below.
>>>
>>>>
>>>> phy_disconnect() calls phy_stop_interrupts() which puts it into polling
>>>> mode.  So the polling work gets queued unconditionally.
>>>
>>> What part of phy_stop_interrupts() is responsible for changing
>>> phydev->irq to PHY_POLL? free_irq() cannot touch phydev->irq otherwise
>>> subsequent request_irq() calls won't work anymore.
>>> phy_disable_interrupts() only calls back into the PHY driver to
>>> acknowledge and clear interrupts.
>>>
>>> If we were using a PHY with PHY_POLL, as Marc said, the first
>>> synchronous call to phy_state_machine() would have acted on PHY_HALTED
>>> and even if we incorrectly keep re-scheduling the state machine from
>>> PHY_HALTED to PHY_HALTED the second time around nothing can happen.
>>>
>>> What are we missing here?
>>>
>>
>> OK, I am now as confused as you guys are.  I will go back and get an
>> ftrace log out of the failure.
>>
> OK, let's forget about the PHY_HALTED discussion.
> 
> 
> Consider instead the case of a Marvell phy with no interrupts connected
> on a v4.9.43 kernel, single CPU:
> 
> 
>   0)               |                 phy_disconnect() {
>   0)               |                   phy_stop_machine() {
>   0)               |                     cancel_delayed_work_sync() {
>   0) + 23.986 us   |                     } /* cancel_delayed_work_sync */
>   0)               |                     phy_state_machine() {
>   0)               |                       phy_start_aneg_priv() {

Thanks for providing the trace, I think I have an idea of what's going
on, see below.

>   0)               |                         marvell_config_aneg() {
>   0) ! 240.538 us  |                         } /* marvell_config_aneg */
>   0) ! 244.971 us  |                       } /* phy_start_aneg_priv */
>   0)               |                       queue_delayed_work_on() {
>   0) + 18.016 us   |                       } /* queue_delayed_work_on */
>   0) ! 268.184 us  |                     } /* phy_state_machine */
>   0) ! 297.394 us  |                   } /* phy_stop_machine */
>   0)               |                   phy_detach() {
>   0)               |                     phy_suspend() {
>   0)               |                       phy_ethtool_get_wol() {
>   0)   0.677 us    |                       } /* phy_ethtool_get_wol */
>   0)               |                       genphy_suspend() {
>   0) + 71.250 us   |                       } /* genphy_suspend */
>   0) + 74.197 us   |                     } /* phy_suspend */
>   0) + 80.302 us   |                   } /* phy_detach */
>   0) ! 380.072 us  |                 } /* phy_disconnect */
> .
> .
> .
>   0)               |  process_one_work() {
>   0)               |    find_worker_executing_work() {
>   0)   0.688 us    |    } /* find_worker_executing_work */
>   0)               |    set_work_pool_and_clear_pending() {
>   0)   0.734 us    |    } /* set_work_pool_and_clear_pending */
>   0)               |    phy_state_machine() {
>   0)               |      genphy_read_status() {
>   0) ! 205.721 us  |      } /* genphy_read_status */
>   0)               |      netif_carrier_off() {
>   0)               |        do_page_fault() {
> 
> 
> The do_page_fault() at the end indicates the NULL pointer dereference.
> 
> That added call to phy_state_machine() turns the polling back on
> unconditionally for a phy that should be disconnected.  How is that
> correct?

It is not fundamentally correct and I don't think there was any
objection to that to begin with. In fact there is a bug/inefficiency
here in that if we have entered the PHY state machine with PHY_HALTED we
should not re-schedule it period, only applicable to PHY_POLL cases
*and* properly calling phy_stop() followed by phy_disconnect().

What I now think is happening in your case is the following:

phy_stop() was not called, so nothing does set phydev->state to
PHY_HALTED in the first place so we have:

phy_disconnect()
-> phy_stop_machine()
	-> cancel_delayed_work_sync() OK
		phydev->state is probably RUNNING so we have:
		-> phydev->state = PHY_UP
	phy_state_machine() is called synchronously
	-> PHY_UP -> needs_aneg = true
	-> phy_restart_aneg()
	-> queue_delayed_work_sync()
-> phydev->adjust_link = NULL
-> phy_deatch() -> boom

Can you confirm whether the driver you are using does call phy_stop()
prior to phy_disconnect()? If that is the case then this whole theory
falls apart, if not, then this needs fixing in both the driver and PHYLIB.

Thanks
-- 
Florian
