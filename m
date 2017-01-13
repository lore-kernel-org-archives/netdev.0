From: Mason <slash.tmp@free.fr>
Subject: Re: Setting link down or up in software
Date: Fri, 13 Jan 2017 16:17:05 +0100
Message-ID: <9be9b48d-1bef-b48f-866f-8651d9b9c245@free.fr>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
 <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
 <0273a4ad-46f7-d7b9-a206-6bd713e6165e@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:47697 "EHLO
        smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751771AbdAMPSv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 10:18:51 -0500
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr [212.27.42.2])
        by smtpfb1-g21.free.fr (Postfix) with ESMTP id 58CFA3C622
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 16:18:23 +0100 (CET)
In-Reply-To: <0273a4ad-46f7-d7b9-a206-6bd713e6165e@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/2017 10:20, Zefir Kurtisi wrote:
> On 01/12/2017 04:16 PM, Mason wrote:
>> On 12/01/2017 14:05, Mason wrote:
>>
>>> I'm wondering what are the semantics of calling
>>>
>>> 	ip link set dev eth0 down
>>>
>>> I was expecting that to somehow instruct the device's ethernet driver
>>> to shut everything down, have the PHY tell the peer that it's going
>>> away, maybe even put the PHY in some low-power mode, etc.
>>>
>>> But it doesn't seem to be doing any of that on my HW.
>>>
>>> So what exactly is it supposed to do?
>>>
>>>
>>> And on top of that, I am seeing random occurrences of
>>>
>>> 	nb8800 26000.ethernet eth0: Link is Down
>>>
>>> Sometimes it is printed immediately.
>>> Sometimes it is printed as soon as I run "ip link set dev eth0 up" (?!)
>>> Sometimes it is not printed at all.
>>>
>>> I find this erratic behavior very confusing.
>>>
>>> Is it the symptom of some deeper bug?
>>
>> Here's an example of "Link is Down" printed when I set link up:
>>
>> At [   62.750220] I run ip link set dev eth0 down
>> Then leave the system idle for 10 minutes.
>> At [  646.263041] I run ip link set dev eth0 up
>> At [  647.364079] it prints "Link is Down"
>> At [  649.417434] it prints "Link is Up - 1Gbps/Full - flow control rx/tx"
>>
>> I think whether I set up the PHY to use interrupts or polling
>> does have an influence on the weirdness I observe.
>>
>> AFAICT, changing the interface flags is done in dev_change_flags
>> which calls __dev_change_flags and __dev_notify_flags
>>
>> Is one of these supposed to call the device driver through a
>> callback at some point?
>>
>> How/when is the phy_state_machine notified of the change in
>> interface flags?
>>
>> Regards.
>>
> Hm, reminds me of something at my side that I recently fixed with [1]. For me it
> was pulling the cable got randomly unnoticed at PHY layer - but might be related.
> 
> Do you by chance have some component that polls the link states over the ethtool
> interface very often (like once per second)? At my side it was a snmpd agent that
> pro-actively updated the interface states every second and with that 'stole' the
> link change information from the phy link state machine. What you need to have to
> run in such a failing situation is:
> 1) an ETH driver that updates link status in ethtool GSET path (e.g. dsa does)
> 2) some component that continuously polls states via ethtool GSET
> 
> 
> Cheers,
> Zefir
> 
> 
> [1] https://patchwork.ozlabs.org/patch/711839/

Hello Zefir,

Thanks for the insightful comment.

This is a minimal buildroot system, with no frills, and not much running.
There definitely is no SNMP daemon running, but I can't be 100% sure that
busybox isn't polling the link state once in a while. (It's unlikely.)

I'm surprised that there are still bugs lurking in the phy state machine,
I expected this to be a "solved problem", but I suppose power management
has broken many assumptions that were once safe...

By the way, I did come across code paths where phy->state was read or
written without taking the lock. Isn't that never supposed to happen?

Regards.
