From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Thu, 10 Dec 2015 08:26:57 -0800
Message-ID: <CALx6S34bg-iRMcTpGd+yw+CV1T7MxpWx+i_AdxXjsfTTnOGK4g@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<20151207.143848.2158761076110518741.davem@davemloft.net>
	<5666EC4B.40800@solarflare.com>
	<20151208.120654.2127200076257822677.davem@davemloft.net>
	<56681B18.3030200@solarflare.com>
	<CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
	<566864C0.6020204@solarflare.com>
	<CALx6S34+j0xQk7gfwOa9adBc3fkjhTJG366eDcT81AzKnWCrLA@mail.gmail.com>
	<56699F15.3030202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38779 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbbLJQ06 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 11:26:58 -0500
Received: by igbxm8 with SMTP id xm8so19276355igb.1
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 08:26:58 -0800 (PST)
In-Reply-To: <56699F15.3030202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2015 at 7:49 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 09/12/15 18:00, Tom Herbert wrote:
>> That is not at all true. If the stack has set up VXLAN RCO and the > device decides to set the inner checksum itself then the checksum > will be bad. The checksum interface is very specific please read it > carefully (sk_buff.h), if the driver/device thinks it is smarter > than the stack and tries to do set its own rules on how checksum > offload works then things will eventually break miserably.
>
> Ok, I've passed that on to the guy working on this bit of the driver.
>
> It looks like the best way to support the capabilities of NICs like the
> sfc 8000 series (which can fill in two checksums but uses packet parsing
> to figure out what to do, rather than using csum start/offset) is:
>
> (core / stack)
> * add NETIF_F_HW_2CSUMS (or whatever name)
> * squeeze a second csum start/offset pair into the skb (as you mention,
>  we can do this without size increase)
> * Modify (Tx) CHECKSUM_PARTIAL generation to use both csum pairs.
>  Presumably by creating CHECKSUM_PARTIAL_2CSUMS to indicate that the
>  second csum pair has been filled in as well.
>
> (sfc driver)
> * declare 2CSUMS support
> * on getting an skb for xmit, check whether the csum pairs match what our
>  eeevil packet parsing hardware will do.  If so, send it with appropriate
>  csum offload settings (we can enable/disable inner & outer offload
>  independently, with TX Option descriptors).  Any csum pair that doesn't
>  match, we call skb_checksum_help to do it in software, and tell the
>  hardware not to do that one.
>

> Does that seem reasonable?

It sounds like potentially interesting work. You'll probably want my
patches that provider helper functions that allow a driver to verify
that it can offload a checksum. We'll have to update those also to
allow two checksums.
