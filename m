From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Sun, 8 Mar 2015 16:17:40 -0700
Message-ID: <CAE4R7bDrhnK_a9dvyMqSJkGgod6AM=HDE6CAKkG_RnjuDxB2-Q@mail.gmail.com>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com>
	<54F6C788.2010201@cumulusnetworks.com>
	<20150305080218.GB2033@nanopsycho.orion>
	<54F86E4B.9040403@cumulusnetworks.com>
	<CAE4R7bCQHcR4Ne-ssCRRvw0czKxRJfykcBFY6c_9haRF3pRJYA@mail.gmail.com>
	<54F8C00C.2010303@cumulusnetworks.com>
	<CAE4R7bAaLxCebc7cuYB9NQ_Duo8a6LvxWDwWOD9Wn8ROWjvDGw@mail.gmail.com>
	<54FC5A60.7000800@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:46501 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbbCHXRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 19:17:41 -0400
Received: by qcyl6 with SMTP id l6so4696589qcy.13
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 16:17:40 -0700 (PDT)
In-Reply-To: <54FC5A60.7000800@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 8, 2015 at 7:19 AM, roopa <roopa@cumulusnetworks.com> wrote:
> On 3/6/15, 1:52 AM, Scott Feldman wrote:

[cut]

>> I'm saying port driver's ndo_bridge_setlink shouldn't be called unless
>> SELF is set.  The port driver shouldn't have to check if it's SELF,
>> that's my main beef with this patch.  If the app (iproute2) wants to
>> mirror an attribute, then it can set both MASTER and SELF.  This is
>> consistent with ndo_fdb ops, where MASTER targets the bridge's FDB and
>> SELF targets the device's FDB.
>
>
> bridge setlink/dellink ndo sets/clears bridge port flags, vlans.
>
> 4 ways to the ndo op gets called (value in brackets is the bridge flags):
>
> 1. ndo_bridge_setlink ()
> 2. ndo_bridge_setlink (master)
> 3. ndo_bridge_setlink (self)
> 4. ndo_bridge_setlink (master | self)
>
>
> in case of 1) and 2) today, bridge driver also calls into the port driver
> (as part of NETIF_F_HW_SWITCH_OFFLOAD) because vlans and other port flags
> need to be offloaded if they are set on master (I understand that rocker
> does not use bridge setlink ndo op for vlans. But it is completely valid for
> a switch driver to use the ndo setlink op for offloading vlan config)
>
> One thing i can do is the NETIF_F_HW_SWITCH_OFFLOAD case only applies in
> case 1 above. ie when bridge flags is zero.
>
> which leads to the following commands to disable learning in the bridge
> driver and enable it in hw,
>
> 1. bridge link learning on - enable learning in both rocker and bridge
> driver due to the NETIF_F_HW_SWITCH_OFFLOAD flag
> 2. bridge link learning off master - learning disable only in the bridge
> driver
>
> With this i think we hit a compromise, rocker setlink can be called when
> flags is zero, but we still get a valid sequence of commands to
> enable/disable certain port flags only in the bridge driver or port driver
> without having an explicit self check in rocker.
>
> (my work laptop is broken..., I will re-post the patch tomorrow if you are
> ok with the plan)

I'm not OK with the plan; it doesn't address the issue.  I'm saying
port driver's ndo_bridge_setlink shouldn't be called unless SELF is
set.

We have this currently, looking from the user's cmd:

bridge link set                               calls into bridge and port driver
bridge link set master                    calls into bridge and port driver
bridge link set self                         calls into port driver
bridge link set self master              calls into bridge and port driver

Your proposal above changes it to:

bridge link set                               calls into bridge and port driver
bridge link set master                    calls into bridge
bridge link set self                         calls into port driver
bridge link set self master              calls into bridge and port driver

Which is still no good because the default case (neither self or
master explicitly set) calls into the port driver.  Before all of
these changes, we had:

bridge link set                               calls into bridge
bridge link set master                    calls into bridge
bridge link set hwmode veb|vepa     calls into port driver

hwmode was a way to set SELF.  We wanted to add "self" flag to command
to be more like bridge fdb cmd.  I assumed the default case (bridge
set link) would continue to work as before.  So we'd have:

bridge link set                               calls into bridge
bridge link set master                    calls into bridge
bridge link set self                         calls into port driver
bridge link set self master              calls into bridge and port driver

But that's not what we got.  Your changes changed the default case
(and the bridge link set master case) to call into both bridge and
port driver even though user didn't specify self.

How hard would it be to get back to original default behavior?
