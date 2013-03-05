From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 0/7] USB: don't recover device if suspend fails in system sleep
Date: Tue, 5 Mar 2013 22:03:06 +0800
Message-ID: <CACVXFVMVqvye1edVmLECdrjip06Xd6YYJTPOU-nYut5qNGybwg@mail.gmail.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<3703451.5FViJ58GpZ@linux-5eaq.site>
	<CACVXFVMkztqc_K+8gvPJhU-rC+c_STDyZLDmJZ2p1hLnADDXvg@mail.gmail.com>
	<2867446.m8zodPstBd@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35837 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754754Ab3CEODJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 09:03:09 -0500
In-Reply-To: <2867446.m8zodPstBd@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 5, 2013 at 9:28 PM, Oliver Neukum <oneukum@suse.de> wrote:
> On Tuesday 05 March 2013 21:08:09 Ming Lei wrote:
>> On Tue, Mar 5, 2013 at 8:50 PM, Oliver Neukum <oneukum@suse.de> wrote:
>
>> > In other words, if we don't handle errors, there must be no errors,
>> > otherwise it doesn't matter what we do in the error case. We'd leave
>> > the problem to generic layers.
>>
>> Generic layers can't handle the driver's specific failure.
>
> We depend on stopping the HC forcing all devices into suspend.
> We know this is problematic. For example some disk enclosures
> need to flush cache. Fortunately for us this is done in the SCSI
> layer.

I mean only the driver can know its specific suspend failure
in its suspend callback, so it is reasonable to deal with it in its
resume() callback, suppose the policy to ignore suspend failure
isn't changed.

>
>> If driver records its suspend failure state in suspend(), resume()
>> should and can deal with it without much difficulty.
>
> Yes, but why bother? Either we can safely suspend in any state or
> we must not ignore errors.

In fact, for many drivers, its suspend() in system sleep just return 0,
for example, cdc_wcm/cdc_acm/hub, etc, so these drivers simply
ignore any failures from suspend() during system sleep.

For other drivers, if suspend() don't return success in system sleep,
it shouldn't try to recover the device, and its resume has to handle
the failure. Or do you have better approach? Suppose we keep
ignoring the suspend failure.

At least, I think URBs can't be submitted to device in its system
suspend failure path, which is generally one part of suspend
recovery for many usb drivers. Doing such recovery may confuse
resume() very much, and it is really wrong.

That is the inconsistency of handling system suspend between
usb drivers and usb core.

>
>> > Furthermore there is a small chance that although the device tree
>> > is walked, teh system suspend fails for another later reason that
>> > is not ignored. In that case the drivers need to do error recovery,
>> > albeit in resume().
>>
>> Yes,  resume() need to handle the USB system suspend failure
>> either in normal resume or error recovery, both are basically same.
>
> In theory yes, in practice usually power is cut.

reset_resume() or rebind() can handle the power cut case, for example,
the suspend failure state can be ignored in reset_resume(), or rebind()
just forget previous suspend failure.  Correct me if it is wrong.

Thanks,
--
Ming Lei
