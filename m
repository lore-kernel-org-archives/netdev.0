From: Jeff Garzik <jeff@garzik.org>
Subject: Re: the future of ethtool
Date: Mon, 15 Nov 2010 19:07:19 -0500
Message-ID: <4CE1CB37.1020101@garzik.org>
References: <4CE18CEA.5080502@garzik.org> <1289852326.2586.32.camel@bwh-desktop> <20101115124428.7b857ccb@nehalam> <1289855642.2586.38.camel@bwh-desktop> <20101115131453.16958d68@nehalam> <1289857936.2586.51.camel@bwh-desktop> <4CE1B8FD.3000007@garzik.org> <20101115233335.GB24292@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52102 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab0KPAHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 19:07:23 -0500
Received: by vws13 with SMTP id 13so42892vws.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 16:07:23 -0800 (PST)
In-Reply-To: <20101115233335.GB24292@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2010 06:33 PM, Thomas Graf wrote:
> On Mon, Nov 15, 2010 at 05:49:33PM -0500, Jeff Garzik wrote:
>> s/only//   I don't think Stephen is suggesting sending _some_ ops
>> through netlink and others through old-ioctl.  That's just silly.
>> Any new netlink interface should transit all existing ETHTOOL_xxx
>> commands/structures.
>>
>> But presumably, one would have the ability to send multiple
>> ETHTOOL_xxx bundled together into a single netlink transaction,
>> facilitating the kernel's calling of struct ethtool_ops'
>> 	->begin()
>> 	... first operation specified by userspace via netlink ...
>> 	... second operation specified by userspace via netlink ...
>> 	... etc.
>> 	->end()
>>
>> The underlying struct ethtool_ops remains unchanged; you're only
>> changing the transit method.
>>
>> Thus, the ethtool userspace utility would switch entirely to
>> netlink, while the ioctl processing code remains for binary
>> compatibility.
>>
>> Or... ethtool userspace utility could remain unchanged, and a new
>> 'nictool' utility provides the same features but with (a) a new CLI
>> and (b) exclusively uses netlink rather than ioctl.
>
> I actually have code for this including userspace. I never submitted
> it because I wasn't confident it is the way to go since it literally
> duplicates all ethtool code in the kernel.
>
> There is one major problem with bundling multiple requests though. If
> one change request fails but other changes have been committed already
> we can't really undo them without causing lots of races. We have to
> leave the device in a somewhat inconsistent state. It's even difficult
> to tell what has been comitted and what hasn't. It also makes error
> reporting more difficult as a -ERANGE error code could apply to any
> of the values to be changed.

Well, what are the range of possibilities for the _hardware_, given the 
current struct ethtool_ops software interface?

We can either reset+restart RXTX after such events, or not.

That's a binary decision, one easily be passed in from userspace before 
any ethtool ops are executed.

Further down the road, if one wanted to travel that far, we could save 
the hardware state at the beginning, and restore hardware state if 
anything fails.  Depends on peoples' motivation over this rare issue.

We already save/restore hardware state for suspend/resume, so this does 
not seem overly onerous.

	Jeff


