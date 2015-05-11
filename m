From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v6 14/23] bridge: restore br_setlink back to original
Date: Sun, 10 May 2015 19:46:49 -0700
Message-ID: <CAE4R7bAhOzJT-bE-o8K83h6EwwNF5ceAfnH4_poGYa2qv9rLdw@mail.gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
	<1431193225-807-15-git-send-email-sfeldma@gmail.com>
	<20150509190031.GG2290@nanopsycho>
	<554F8300.5070709@cumulusnetworks.com>
	<CAE4R7bBQw+GJ0APt57tf+JBnbE7vyCRmbTozcVxRV3QP8ZNe+w@mail.gmail.com>
	<554FFDF6.4040105@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Joe Perches <joe@perches.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:33017 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378AbbEKCqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 22:46:50 -0400
Received: by qcvo8 with SMTP id o8so39058044qcv.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 19:46:49 -0700 (PDT)
In-Reply-To: <554FFDF6.4040105@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2015 at 5:55 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 5/10/15, 4:55 PM, Scott Feldman wrote:
>>
>> On Sun, May 10, 2015 at 9:10 AM, roopa <roopa@cumulusnetworks.com> wrote:
>>>
>>> On 5/9/15, 12:00 PM, Jiri Pirko wrote:
>>>>
>>>> Sat, May 09, 2015 at 07:40:16PM CEST, sfeldma@gmail.com wrote:
>>>>>
>>>>> From: Scott Feldman <sfeldma@gmail.com>
>>>>>
>>>>> Restore br_setlink back to original and don't call into SELF port
>>>>> driver.
>>>>> rtnetlink.c:bridge_setlink() already does a call into port driver for
>>>>> SELF.
>>>>>
>>>>> bridge set link cmd defaults to MASTER.  From man page for bridge link
>>>>> set
>>>>> cmd:
>>>>>
>>>>>         self   link setting is configured on specified physical device
>>>>>
>>>>>         master link setting is configured on the software bridge
>>>>> (default)
>>>>>
>>>>> The link setting has two values: the device-side value and the software
>>>>> bridge-side value.  These are independent and settable using the bridge
>>>>> link set cmd by specifying some combination of [master] | [self].
>>>>> Futhermore, the device-side and bridge-side settings have their own
>>>>> initial
>>>>> value, viewable from bridge -d link show cmd.
>>>>>
>>>>> Restoring br_setlink back to original makes rocker (the only in-kernel
>>>>> user
>>>>> of SELF link settings) work as first implement: two-sided values.
>>>>>
>>>>> It's true that when both MASTER and SELF are specified from the
>>>>> command,
>>>>> two netlink notifications are generated, one for each side of the
>>>>> settings.
>>>>> The user-space app can distiquish between the two notifications by
>>>>> observing the MASTER or SELF flag.
>>>>
>>>> This is revert of:
>>>>
>>>> commit 68e331c785b85b78f4155e2ab6f90e976b609dc1
>>>> Author: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>> Date:   Thu Jan 29 22:40:14 2015 -0800
>>>>
>>>>       bridge: offload bridge port attributes to switch asic if feature
>>>> flag
>>>> set
>>>>
>>>> Noting that because I want to make sure everybody is ok with new
>>>> behaviour. I tend to like it more.
>>>>
>>> I am not ok with it. I have raised this earlier. same argument as the fib
>>> code, app now has to remember to call with both master and self. I do
>>> however feel that this code needs some rework..,.add to hardware first
>>> and
>>> then software
>>> just like fib and rollback hardware on failure. In which case, i am ok
>>> with
>>> submitting a new patch to do it differently.
>>
>> The problem with your patch to br_setlink/br_dellink is it hard-coded
>> a default in the kernel bridge driver, inconsistent with the default
>> of the application (iproute2/bridge).  Reverting it keeps the kernel
>> out of the default decision and lets the application define a default
>> that suits it.
>
> sorry, I am not understanding how this is different from how we do offload
> for fib and stp.
> just like stp offload from the bridge driver, i am hoping we can also
> offload vlans (current patch under discussion)
> and fdb entries. The switch driver can decide if it is only interested in
> calls with flags set to 'self' (rocker for example).
>
> another example: mstp daemon running in userspace will use bridge setlink to
> propagate stp states to the in-kernel bridge driver. If the current patch is
> removed, mstp daemon will now have to make sure it calls bridge setlink with
> self and master flags to hit both the bridge driver and hardware.

You're making my point with this example: let the application set the
flags it wants, and let the kernel provide the mechanism.

The kernel mechanism for both FDB (rtnl_fdb_add) and bridge settings
(rtnl_bridge_setlink) are the same: they both have this basic logic to
handle MASTER and SELF flags:

if (!flags || flags & MASTER)
    if (master->ops->ndo_xxx)
        master->ops->ndo_xxx(...);
if (flags & SELF)
    if (port->ops->ndo_xxx)
        port->ops->ndo_xxx(...);

That's all the kernel should do.  What is the default flags when
explicit flags aren't specified by the user is up to the application.
Current example apps:

iproute2/bridge/fbd app passes SELF when no flags are given by user.
iproute2/bridge/vlan app passes no flags when no flags are given by user.
iproute2/bridge/link set app passes SELF if setting hwmode, otherwise
passes no flags when no flags are given by user.
mstp app passes no flags (I assume, based on what you wrote above).

So if you want different app defaults than above, we need to change
the app, not the kernel.

(FIB isn't part of this discussion because there is (currently) no
MASTER|SELF flags for FIB entries, so I'm not sure why you're bringing
up FIB).

-scott
