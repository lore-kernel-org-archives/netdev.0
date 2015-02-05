From: B Viswanath <marichika4@gmail.com>
Subject: Re: [PATCH net-next] bridge: Let bridge not age 'externally' learnt
 FDB entries, they are removed when 'external' entity notifies the aging
Date: Fri, 6 Feb 2015 00:01:04 +0530
Message-ID: <CAN+pFwKAWX+En6zK3Q94q9ejdpqz6WBvnkH=Rp3HBEAeOyNbNw@mail.gmail.com>
References: <CA+CtxLSziWmx94_V9S-uW9=6VYg4WXsU4CERx-uovvrFOtO1dA@mail.gmail.com>
	<54D246A7.2020502@cumulusnetworks.com>
	<CAE4R7bCASKHmZD+tiu=ZWM9dzvTrSLsaXxgtOYLpsmOR87kcTQ@mail.gmail.com>
	<20150204.235308.71797582017426266.davem@davemloft.net>
	<CA+CtxLRaJ+p=y1LCgap48vqH3b4VjxKQO55Yy5cyazng4WtxPw@mail.gmail.com>
	<CAN+pFwJQQMFmmm1f7tSPCmaSr2GE_L8Pua+Rz7tvK9CFnr63Tg@mail.gmail.com>
	<CAE4R7bBKXHfbOz-BT1jW2=+hTi=6hZZHRUVpYUvOj1yF+XEtUw@mail.gmail.com>
	<CAE4R7bDRHwUnt7jzPw_CzwsZfou2B2mRgZ_9t4AfRWe2Z_EtYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Siva Mannem <siva.mannem.lnx@gmail.com>,
	David Miller <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:36282 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbBESbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 13:31:12 -0500
Received: by mail-qa0-f48.google.com with SMTP id v8so7073638qal.7
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:31:11 -0800 (PST)
In-Reply-To: <CAE4R7bDRHwUnt7jzPw_CzwsZfou2B2mRgZ_9t4AfRWe2Z_EtYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5 February 2015 at 23:25, Scott Feldman <sfeldma@gmail.com> wrote:
<snip>
>>>> I now see why rocker is broken. Sorry for the churn.
>>>> As Scott/Roopa suggested, a new flag IFLA_BRPORT_AGING_SYNC (similar
>>>> to IFLA_BRPORT_LEARNING_SYNC) can be defined and stored in
>>>> net_bridge_port->flags when user configures it. Some thing like below.
>>>>
>>>> $ sudo bridge link set dev swp1 ageing_sync on self
>>>>
>>>> And bridge ageing logic does not age externally learnt entry *only* if
>>>> IFLA_BRPORT_AGING_SYNC flag on fdb entry's net_bridge_port is set.
>>>> This ensures that existing behavior continues to be default behavior
>>>> and is of no harm to rocker.
>>>>
>>>> Please let me know your comments on above approach.
>>>
>>> I am not sure you really want to pass on this burden of deciding who
>>> should age to the end user.  I think user should  not be forced to be
>>> aware of all the device and driver properties.
>>>
>>> May be a different way would be that -
>>>
>>> 1. driver specifies whether it can supporting ageing by itself (the
>>> chip) during registration.
>>> 2. driver also allows that kernel turn off the driver/device ageing.
>>> 3. when a bridge is created with all ports from same device which
>>> supports ageing (and which is currently enabled), then bridge defers
>>> ageing to driver. Otherwise bridge disables ageing on all
>>> participating devices and takes care of ageing by itself.
>>> 4. When ageing is disabled on a device, all other bridges that use any
>>> ports from that device start ageing themselves.
>>>
>>> I guess this sounds complicated, but it can ensure that user gets the
>>> best default behaviour based on the device. Any alternate suggestions
>>> ?
>
> So let me see if I can summarize the PROs and CONs of using the
> default behavior of the bridge driver for ageing externally learned
> FDB entries:
>
> PROs
>
> 1) No new user knobs; just use existing bridge ageing settings for
> both internal and
> externally learned FDB entries.
> 2) Because we're using SW bridge, all offloaded switches behave the
> same w.r.t. ageing.
> 3) Because we're using SW bridge, bug fixes and enhancements apply to
> all offloaded switches.
> 4) Switch device model w.r.t. FDB ageing is simple to understand.
> 5) User's view of the ageing process is the same for internal and
> external learned FDB entries.
> The last-used stats make sense.
> 6) Leveraging what's already there...bridge ageing function is
> tried-and-true....let's reuse it if we can.
>
> CONs
>
> 1) Scale-ability.  The bridge driver can't keep up with ageing many
> (10^5, for example) entries.
> 2) Scale-ability.  Keeping the entries periodically refreshed requires
> a refresh sync from
> the device to the bridge driver, and the bridge driver/kernel can't keep up.
> 3) With the bridge driver, the ageing settings are per-bridge, not per-port.
>
> Did I miss any points?

There is one more

4. On links with wirespeed traffic, software ageing FDB entries
independently without having the knowledge of the traffic means that
CPU will ageout entries it should not. I don't know if this breaks
some RFC, but it can certainly cause big packet loss.

Such a packet loss is considered bad, and is a primary reason why
hardware supports ageing. Otherwise there is no reason hw needs to
support it. Based on experience, I can say that it is a necessity, now
even more with 10G and 40G links.

>
> I think it boils down to use-ability vs. scale-ability.  My personal
> opinion is I'm skeptical there are real scale-ability issues because
> the on-board switch CPU should easily be able to handle the ageing
> tasks.  After all, the CPU will for the most part be idle, only
> worrying about the occasional ctrl pkt (STP, LLDP, OSPF, etc).  I'm
> most interested in keeping the user's experience simple, so if we can
> extend the existing bridge ageing model to offloaded devices without
> changing the users' experience compared to the non-offloaded case.

I agree with no changes in user experience. I think my design change
suggestion can make sure that no user experience changes for all
regular use cases, and certainly no changes for non-switch-devices.

Thanks
Vissu

>
> So let's draw out the CONs for using the bridge driver's ageing function as-is.
>
> -scott
