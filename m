From: Sathya Perla <sathya.perla@broadcom.com>
Subject: RE: [PATCH net-next 1/2] be2net: set temperature value for all
 adapter's functions
Date: Tue, 26 Jul 2016 13:56:41 +0530
Message-ID: <e9b62029547b138317654f80210d63c4@mail.gmail.com>
References: <1469237395-11501-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
 <a231dccbdf9d054819aca387db6533c4@mail.gmail.com> <57960BAF.20004@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ajit Kumar Khaparde <ajit.khaparde@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>,
	netdev@vger.kernel.org
To: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:34242 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528AbcGZI0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 04:26:43 -0400
Received: by mail-yw0-f172.google.com with SMTP id z8so169222300ywa.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 01:26:43 -0700 (PDT)
In-Reply-To: <57960BAF.20004@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Guilherme G. Piccoli [mailto:gpiccoli@linux.vnet.ibm.com]
>
> On 07/25/2016 07:48 AM, Sathya Perla wrote:
> >> -----Original Message-----
> >> From: Guilherme G. Piccoli [mailto:gpiccoli@linux.vnet.ibm.com]
> >>
> >> Temperature values on be2net driver are made available to userspace
> >> via
> > hwmon abstraction, so tools like lm-
> >> sensors can present them to the user.
> >> The driver provides hwmon structures for each adapter's function.
> >> Nevertheless, the temperature information come from fw queries
> >> performed
> > by
> >> be_worker() with some frequency, and this procedure is called with a
> > single function as argument; this means
> >> that the temperature value is updated only in the specific function
> >> that
> > was passed to be_worker().
> >>
> >> This can lead to incongruency in reported temperature by a function,
> >> or
> > in a worse scenario, some functions
> >> might be unable to provide temperature info to userspace, if they
> > weren't fed with this information from fw in
> >> be_worker() run.
> >
> > Hi, I'm wondering if you are OK with the temperature value being 128s
> > old
> > (2/2 patch), then why is it a problem
> > if two different functions report a temperature value that is queried
> > a few seconds apart?
> > Also, you'll not have a scenario where the FW cmd succeeds for one
> > function and fails for other functions.
> > It's a common FW for the entire adapter.
> >
> >>
> >> This patch changes the way temperature is set in be2net driver. At
> > anytime the fw query is performed, it will set
> >> the temperature value for all functions of the adapter, instead of
> >> only
> > setting the temperature of the function
> >> passed to be_worker().
> > If the possible inconsistency across functions is indeed a problem,
> > then a simpler solution would be to issue the FW cmd synchronously
> > when the sysfs attr is read, i.e., in
> > be_hwmon_show_temp() routine itself.
> >
>
> Hi Sathya, thanks very much for your quick reply. I agree with you that an
> 1 or 2 sec inconsistency wouldn't
> harm, but the main problem we're seeing is that be_worker() is being
> called with a single function as a parameter
> - in our case, the last function is being passed as argument to
> be_worker() multiple times in a row, and then we
> have its temperature updated but the other functions' temperature set as
> invalid.

Hi Guilherme, this doesn't sound right to me and is not expected. The
be_worker() routine must execute for *each* function every second.
Can you pls share the driver/fw version and any debug logs (with prints) you
may have and also lspci output.

>
> Regarding the temperature update run on be_hwmon_show_temp(), it was an
> idea too, but I was afraid in delay
> this output too much - imagine some userspace tool reads hwmon attributes
> for all functions almost at "same
> time", supposing the fw command can't run in parallel, the "last" read
> would need to wait 4 fw commands to
> complete before showing it's output.

I don't see any issue even if the sensors program queries each function one
after another. These calls would only be
a few milli-seconds apart.

> Besides, in a worse scenario, some "not-friendly" tool might issue lots of
> reads to hwmon per second then
> issuing lots of fw commands, which does not seem a good idea. Of course
> this last case we can avoid by
> implementing a counter or timer on be_hwmon_show_temp() to allow maximum
> number of fw cmds in a time
> frame.
Yes, this is not an issue. If the hwmon read is issued with-in a few seconds
of the previous read then you can just return the old temperature value.
We are anyway querying this value only once in 64s now.
But, I'd like to root-cause the issue you are seeing above before we "fix"
anything.

thanks,
-Sathya
