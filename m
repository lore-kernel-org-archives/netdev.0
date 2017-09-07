From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Wed, 6 Sep 2017 18:41:06 -0700
Message-ID: <167efcdf-51bb-e460-caaf-6819d9026053@gmail.com>
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
 <a4b70bf9-ec48-314d-b63d-e44f7cbb4bab@gmail.com>
 <64800ff2-201b-eb26-304e-1c4c6e0a6d5e@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
To: David Daney <ddaney@caviumnetworks.com>,
        David Daney <ddaney.cavm@gmail.com>, Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:38819 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751287AbdIGBlK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 21:41:10 -0400
Received: by mail-oi0-f65.google.com with SMTP id d10so4131577oih.5
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 18:41:10 -0700 (PDT)
In-Reply-To: <64800ff2-201b-eb26-304e-1c4c6e0a6d5e@caviumnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/06/2017 05:10 PM, David Daney wrote:
> On 09/06/2017 04:14 PM, Florian Fainelli wrote:
>> On 09/06/2017 03:51 PM, David Daney wrote:
> [...]
>>>
>>> Consider instead the case of a Marvell phy with no interrupts connected
>>> on a v4.9.43 kernel, single CPU:
>>>
>>>
>>>    0)               |                 phy_disconnect() {
>>>    0)               |                   phy_stop_machine() {
>>>    0)               |                     cancel_delayed_work_sync() {
>>>    0) + 23.986 us   |                     } /*
>>> cancel_delayed_work_sync */
>>>    0)               |                     phy_state_machine() {
>>>    0)               |                       phy_start_aneg_priv() {
>>
>> Thanks for providing the trace, I think I have an idea of what's going
>> on, see below.
>>
>>>    0)               |                         marvell_config_aneg() {
>>>    0) ! 240.538 us  |                         } /*
>>> marvell_config_aneg */
>>>    0) ! 244.971 us  |                       } /* phy_start_aneg_priv */
>>>    0)               |                       queue_delayed_work_on() {
>>>    0) + 18.016 us   |                       } /*
>>> queue_delayed_work_on */
>>>    0) ! 268.184 us  |                     } /* phy_state_machine */
>>>    0) ! 297.394 us  |                   } /* phy_stop_machine */
>>>    0)               |                   phy_detach() {
>>>    0)               |                     phy_suspend() {
>>>    0)               |                       phy_ethtool_get_wol() {
>>>    0)   0.677 us    |                       } /* phy_ethtool_get_wol */
>>>    0)               |                       genphy_suspend() {
>>>    0) + 71.250 us   |                       } /* genphy_suspend */
>>>    0) + 74.197 us   |                     } /* phy_suspend */
>>>    0) + 80.302 us   |                   } /* phy_detach */
>>>    0) ! 380.072 us  |                 } /* phy_disconnect */
>>> .
>>> .
>>> .
>>>    0)               |  process_one_work() {
>>>    0)               |    find_worker_executing_work() {
>>>    0)   0.688 us    |    } /* find_worker_executing_work */
>>>    0)               |    set_work_pool_and_clear_pending() {
>>>    0)   0.734 us    |    } /* set_work_pool_and_clear_pending */
>>>    0)               |    phy_state_machine() {
>>>    0)               |      genphy_read_status() {
>>>    0) ! 205.721 us  |      } /* genphy_read_status */
>>>    0)               |      netif_carrier_off() {
>>>    0)               |        do_page_fault() {
>>>
>>>
>>> The do_page_fault() at the end indicates the NULL pointer dereference.
>>>
>>> That added call to phy_state_machine() turns the polling back on
>>> unconditionally for a phy that should be disconnected.  How is that
>>> correct?
>>
>> It is not fundamentally correct and I don't think there was any
>> objection to that to begin with. In fact there is a bug/inefficiency
>> here in that if we have entered the PHY state machine with PHY_HALTED we
>> should not re-schedule it period, only applicable to PHY_POLL cases
>> *and* properly calling phy_stop() followed by phy_disconnect().
>>
>> What I now think is happening in your case is the following:
>>
>> phy_stop() was not called, so nothing does set phydev->state to
>> PHY_HALTED in the first place so we have:
>>
>> phy_disconnect()
>> -> phy_stop_machine()
>>     -> cancel_delayed_work_sync() OK
>>         phydev->state is probably RUNNING so we have:
>>         -> phydev->state = PHY_UP
>>     phy_state_machine() is called synchronously
>>     -> PHY_UP -> needs_aneg = true
>>     -> phy_restart_aneg()
>>     -> queue_delayed_work_sync()
>> -> phydev->adjust_link = NULL
>> -> phy_deatch() -> boom
>>
>> Can you confirm whether the driver you are using does call phy_stop()
>> prior to phy_disconnect()? 
> 
> There is no call to phy_stop().

OK this all makes sense now.

> 
> I can add this to the ethernet drivers, but I wonder if it should be
> called by the code code when doing phy_disconnect(), if it was not
> already stopped.

Fixing the driver should be reasonably quick and easy and can be done
independently from fixing PHYLIB, but I agree that PHYLIB should be
safeguarded against such a case.

Of course, now that I looked again at the code, there is really a ton of
unnecessary workqueue scheduling going on, similarly to phy_stop()
making us go from PHY_HALTED to PHY_HALTED, phy_start_machine() does the
same thing with PHY_READY -> PHY_READY, I suppose back when this was
done the assumption was that there is not going to be a tremendous
amount of time being spent between a call to
phy_connect()/phy_start_machine() and phy_start() and respectively
phy_stop() followed by a phy_disconnect(), oh well.

Now that the revert is in 4.13 we can work on a solution that satisfies
everybody on this thread.

Thanks!
-- 
Florian
