From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 2/2] mv88e6131: bonding: implement single device
 trunking
Date: Sat, 07 Mar 2015 09:31:59 -0800
Message-ID: <54FB360F.9060901@gmail.com>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com> <1424429473-4601-3-git-send-email-jonasj76@gmail.com> <20150220152644.GD13797@lunn.ch> <54F9DEAA.50606@gmail.com> <20150306192359.GA582@lunn.ch> <54FA125E.6050605@gmail.com> <20150306214723.GB582@lunn.ch> <CAE4R7bBXbNNJ8VyCJ_01Ht4gWhCaYOGv3f_pUS_2grcU3i3OJw@mail.gmail.com> <20150307143838.GD2017@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jonas Johansson <jonasj76@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Jonas Johansson <jonas.johansson@westermo.se>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:32831 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbCGRcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 12:32:20 -0500
Received: by oifz81 with SMTP id z81so22815995oif.0
        for <netdev@vger.kernel.org>; Sat, 07 Mar 2015 09:32:19 -0800 (PST)
In-Reply-To: <20150307143838.GD2017@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2015 06:38 AM, Jiri Pirko wrote:
> Fri, Mar 06, 2015 at 11:43:55PM CET, sfeldma@gmail.com wrote:
>> On Fri, Mar 6, 2015 at 1:47 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>>> Hi Florian
>>>
>>>> Most Broadcom switches, either SF2 or roboswitch (b53) have a limit of 2
>>>> trunking groups, without limitations on the number of ports included in
>>>> any of these two groups.
>>>
>>> O.K, so maybe we want the basic resource management in the DSA layer,
>>> not the switch drivers.
>>>
>>>> The larger question is once we start advertising capabilities, where
>>>> does that stop, right? It would probably be simpler for now to e.g:
>>>> allow 2 trunking groups to be configured, and when trying to configure a
>>>> 3rd one, return -ENOSPC and act upon that to either take the software
>>>> slow path (which is probably not possible) or just return a hard error
>>>> condition.
>>>
>>> This is more than a DSA question. It applies to all the hardware
>>> acceleration being discussed at the moment. As you hinted to above, i
>>> suppose we have two different situations:
>>>
>>> 1) We can fall back to a software slow path.
>>>
>>> 2) There is no software fallback, we have to error out, and it would
>>>     be nice to have a well defined error code for out of hardware
>>>     resources.
>>>

I have a (3) case where we don't ever want to fall back to slow path
even if it is possible and (4) we don't ever want to offload the
operation even when it is possible. Having to program the device then
unwind it from user space seems a bit error prone and ugly. At some
point I think we will have to handle these cases its probably fine to
get the transparent offload working as a start though. Specifically,
talking about LAG I'm not sure of the use case for (4) but in
general it is useful.

>>> We also should think about how we tell user space we have fallen back
>>> to a slow path. I'm sure users want to know why it works, but works
>>> much slower.
>>
>> For the general hardware acceleration of bonds, my thoughts for switchdev are:
>>
>> (Assume 802.3ad LAG setup for discussion sake, other bonding modes are similar).
>>
>> 1. The driver has access to port membership notification via netevent,
>> so driver knows which ports are in which bonds.  This notification is
>> passive; there is no way to signal to user that when port was put in a
>> bond if it was programmed into a device LAG group or not.  It's
>> totally up to the driver and device resources to make that decision.
>
> Exactly. The fact if another group can be added or not should be decided
> and handled by driver. The driver then notifies higher layers using
> switchdev notifier event.

hmm same point I need to be able to know ahead of time if it is going to
succeed or fail. I think we can extend this in two ways one add an
explicit flag to say 'add this to hardware or fail' or 'never offload
this' although for LAG setup this might be challenging because the
notification is passive as noted. The other way to do this is to
sufficient exposure of the hardware model and resources so software
can predict a priori that the LAG setup will be accelerated. I think we
need both...

My only point here is eventually management of the system is challenging
if its entirely a driver decision at least in many cases where we have
intelligent agents managing the network. But sure get the simple case
working as a start.

>
>>
>> 2. The driver can know port active status via netevent as well.  If
>> device has the port in a LAG group, then reflect the active status
>> down to device port.  Again, a passive notification.
>>
>> 3. CPU-originating egress traffic would be LAGed by bonding (or team)
>> driver.  (This is true regardless if the device LAG group was setup or
>> not).
>>
>> 4a. If device LAG group setup, forwarded traffic would be LAG egressed
>> by device (fast path).
>>
>> 4b. If no device LAG group, ingress traffic is sent to CPU (slow path)
>> for bonding (or team) to LAG egress.
>>
>> So software fall-back (4b) is the default case if driver/device can't
>> setup LAG group for forwarding.
>>
>> So the question is: how does user know which bonds are accelerated?
>> So far, we've used the label "external" to mark L2 bridge FDB which
>> are offloaded to the device and "external" to mark L3 routes offloaded
>> to the device.  Do we mark bonds as "external" if the LAG path is
>> offloaded to the device?
>
> I believe that this is the way to go. Introduce this flag for bond and
> team to signal user if LAG is offloaded or not.
>
>
>>
>> -scott
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
