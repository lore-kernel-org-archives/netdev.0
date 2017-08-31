From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Thu, 31 Aug 2017 12:18:50 -0700
Message-ID: <7b1c1dc9-b6e3-a1bd-2e36-474946741a79@gmail.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <a75691d9-c22a-9b89-2cce-604315062739@gmail.com>
 <d54d0555-c448-741c-eb63-5a773bed5a30@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        David Daney <ddaney.cavm@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36157 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdHaTTB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 15:19:01 -0400
Received: by mail-qk0-f177.google.com with SMTP id o63so2544677qkb.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 12:19:01 -0700 (PDT)
In-Reply-To: <d54d0555-c448-741c-eb63-5a773bed5a30@free.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2017 12:09 PM, Mason wrote:
> On 31/08/2017 19:03, Florian Fainelli wrote:
> 
>> On 08/31/2017 05:29 AM, Marc Gonzalez wrote:
>>
>>> On 31/08/2017 02:49, Florian Fainelli wrote:
>>>
>>>> The original motivation for this change originated from Marc Gonzalez
>>>> indicating that his network driver did not have its adjust_link callback
>>>> executing with phydev->link = 0 while he was expecting it.
>>>
>>> I expect the core to call phy_adjust_link() for link changes.
>>> This used to work back in 3.4 and was broken somewhere along
>>> the way.
>>
>> If that was working correctly in 3.4 surely we can look at the diff and
>> figure out what changed, even maybe find the offending commit, can you
>> do that?
> 
> Bisecting would a be a huge pain because my platform was
> not upstream until v4.4

Then just diff the file and try to pinpoint which commit may have
changed that?

> 
> You mentioned the guarantees made by PHYLIB.
> When is the adjust_link callback guaranteed to be called?

As long as the state machine is running after a call to phy_start()
adjust_link will be called if there a change in link and/or link
settings. Once you call phy_stop() no such guarantees are made.

> 
>>>> PHYLIB has never made any such guarantees ever because phy_stop() merely
>>>> just tells the workqueue to move into PHY_HALTED state which will happen
>>>> asynchronously.
>>>
>>> My original proposal was to fix the issue in the driver.
>>> I'll try locating it in my archives.
>>
>> Yes I remember you telling that, by the way I don't think you ever
>> provided a clear explanation why this is absolutely necessary for your
>> driver though?
> 
> 1) nb8800_link_reconfigure() calls phy_print_status()
> which prints the "Link down" and "Link up" messages
> to the console. With the patch reverted, nothing is
> printed when the link goes down, and the result is
> random when the link comes up. Sometimes, we get
> down + up, sometimes just up.

Nothing printed when you bring down the network interface as a result of
not signaling the link down, there is a small nuance here.

Seeing a random message upon bringing the interface back up suggests you
may not be re-initialization your old vs. new link state book keeping
variables and state transitions are not properly detected and therefore
not printed. In fact, I don't see where priv->link is ever set to say -1
to force the comparison between phydev->link != priv->link to be true,
oversight?

> 
> 2) nb8800_link_reconfigure() does some HW init when
> the link state changes. If we miss some notifications,
> we might not perform some HW init, and stuff breaks.

Care to be more specific? What specific HW init is required during link
notification that if not done breaks the HW? There is both
nb8800_mac_config() and nb8800_pause_config() that are both called in
the adjust_link callback both could presumably be deferred until the
link is detected, so why do you need it during ndo_stop() absolutely?
-- 
Florian
