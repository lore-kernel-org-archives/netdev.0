From: "Sangtae Ha" <sangtae.ha@gmail.com>
Subject: Re: [RFC] tcp: make H-TCP the default congestion control
Date: Fri, 28 Nov 2008 18:28:54 -0500
Message-ID: <649aecc70811281528v70876fdo787ee8a707e7e12b@mail.gmail.com>
References: <0EC70CEA-0C16-411E-9A50-6A0F23EA273F@nuim.ie>
	 <2860327B-6E7F-435F-AB4A-36E66A49F7DE@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Stephen Hemminger" <shemminger@vyatta.com>
To: "Douglas Leith" <Doug.Leith@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f11.google.com ([209.85.221.11]:46986 "EHLO
	mail-qy0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbYK1X3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 18:29:00 -0500
Received: by qyk4 with SMTP id 4so1829544qyk.13
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2008 15:28:54 -0800 (PST)
In-Reply-To: <2860327B-6E7F-435F-AB4A-36E66A49F7DE@nuim.ie>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I misunderstood the testing scenarios you had, and had a couple of
single flow testings with CUBIC and HTCP under normal links (DSL and
Internet2) and couldn't find out significant difference in completion
times. - HTCP was faster than CUBICv2.1, but not faster than the other
two versions (CUBICv2.2 and 2.3). This might be because I didn't
saturate the link first.

The slow convergence of CUBIC had been addressed through CUBIC v2.1
and CUBIC v2.2 by removing the clamping of CUBIC growth function and
making CUBIC more aggressive for fast convergence.
So, I expect you talk about the latest update (CUBICv2.3) which
integrates a new slow start, called HyStart.

The second parameter of HyStart, which is a delay parameter, is
designed to respect the existing flows.
Which means that the later joining flow starts from the congestion
window where it is believed to be safe not incurring packet losses to
the existing flows.
After that, it tries to share the link progressively (not depriving
all of others bandwidth at once during slow start).

Based on this, the worst scenario I can think of is something like the
testing you had: "Let some flows dominate the link and run a short
flow and measure the completion time of this later-joined flow".
Now I can understand the difference of completion times between CUBIC and H-TCP.
This major performance difference seems like not because of H-TCP
algorithm, but because of HyStart.
This scenario always triggers the second delay parameter on and makes
the second flow exit the slow-start from a very small window.
As the link is already saturated by the first flow, from that small
window, the second flow tries to converge the rate with CUBIC growth
function rather than exponential growth function of slow-start.
Actually, CUBIC growth from this small window is not too slow.

Turning off this delay parameter will give us good convergence time by
sacrificing the stability in a sense that we neglect the possibility
that the later joining flow might incur many packet losses of its own
and other flows and some flows might experience timeouts in some
cases.
I agree that most of cases with small link bandwidth, the current TCP
stack is very efficient for recovering from multiple losses with SACK.
But, in case either one of machine doesn't support SACK, (many)
multiple losses significantly affect their performance.
Also, we have seen that Windows XP clients had some issues with many
packet losses.

As I mentioned in some of previous mails, we always have a choice to
turn off this delay parameter selectively and keep using CUBICv2.2 as
before.

Could you try your testings with the following changes? We definitely
will have testings like you mentioned and post the results.

# the following will only use packet-train detection (not delay detection)
echo "1" > /sys/module/tcp_cubic/parameters/hystart_detect


Regards,
Sangtae

On Fri, Nov 28, 2008 at 6:09 AM, Douglas Leith <Doug.Leith@nuim.ie> wrote:
> A bit of delayed input to this thread on netdev ...
>
>> I'm not so sure about this logic, regardless of the algorithms
>> involved.
>>
>> H-TCP was never the default in any distribution or release that
>> I know of.  So it's real world exposure is effectively zero,
>> which is the same as the new CUBIC stuff.
>
>> They are effectively, therefore, equivalent choices.
>
> Not really.  At this stage HTCP has undergone quite extensive independent
> testing by a good few groups (Caltech, Swinburne, North Carolina etc).  Its
> also been independently implemented in FreeBSD by the Swinburne folks.  Its
> true it hasn't been default in linux, but it HTCP  been subject to *far*
> more testing than the new cubic algorithm which has had no independent
> testing at all to my knowledge.
>
> I'd also like to add some new input to the discussion on choice of
> congestion control algorithm in linux - and why it might be useful to
> evaluate alternatives like htcp.   Almost all of the proposals for changes
> to tcp (including cubic) have really slow convergence to fairness when new
> flows start up.   The question is then whether it matters e.g. whether it
> negatively impacts users.
>
> To try to get a handle on this, we took one set of measurements from a home
> DSL line over a live link (so hopefully representative of common user
> experience), the other from a the production link out of the hamilton
> institute (so maybe more like the experience of enterprise users).   Plots
> of our measurements are at
>
> http://www.hamilton.ie/doug/tina2.eps  (DSL link)
> http://www.hamilton.ie/doug/caltech.eps  (hamilton link)
>
> and also attached.
>
> We started one long-ish flow (mimicking incumbent flows) and then started a
> second shorter flow.  The plots show the completion time of the second flow
> vs its connection size.  If the incumbent flow is slow to release bandwidth
> (as we expect with cubic), we expect the completion time of the second flow
> to increase, and indeed this is what we see.
>
> What's particularly interesting is (i) the magnitude of the difference -
> completion times are consistently x2 with cubic vs htcp over many tests and
> (ii) that this effect is apparent not only on higher speed links
> (caltech.eps) but also on regular DSL links (tina2.eps - we took
> measurements from a home DSL line, so its not a sanitised lab setup or
> anything like that).
>
> As might be expected, the difference in completion times eventually washes
> out for long transfers, e.g for the DSL link the most pronounced difference
> is for 1MB connections (where there is about a x2 difference in times
> between cubic and htcp) but becomes less for longer flows.  The point is
> that most real flows are short however, so the performance with a 1MB size
> flow seems like it should be more important than the 10MB size performance.
>  For me the DSL performance is the more important one here since it affects
> so many people, and was quite surprising, although I can also reproduce
> similar results on our testbed so its not a weird corner case or anything
> like that.
>
> Wouldn't it be interesting to give h-tcp a go in linux to get wider feedback
> ?
>
> Doug
>
>
>
>
>
>
>
>
>
>
>
>
>
>
