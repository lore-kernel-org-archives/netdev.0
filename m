From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Fri, 14 Nov 2014 11:52:00 -0800
Message-ID: <CA+mtBx_DyUCxE6BqL_xXcqKPUDu7b3jLShV+AL6L+gCzJLriPg@mail.gmail.com>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHO5Pa0OGtgbUp4R287jbK2SFSpVUoXWCJybvHTFsGyCLynqLg@mail.gmail.com>
	<CALCETrXmCWSoeQLC3WCqMf_sehGVE9KTbTGmsA77ZN84B-V24Q@mail.gmail.com>
	<1415993614.17262.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Linux API <linux-api@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:42719 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219AbaKNTwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 14:52:02 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so308604iga.15
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 11:52:00 -0800 (PST)
In-Reply-To: <1415993614.17262.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2014 at 11:33 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-11-14 at 09:17 -0800, Andy Lutomirski wrote:
>
>> As a heavy user of RFS (and finder of bugs in it, too), here's my
>> question about this API:
>>
>> How does an application tell whether the socket represents a
>> non-actively-steered flow?  If the flow is subject to RFS, then moving
>> the application handling to the socket's CPU seems problematic, as the
>> socket's CPU might move as well.  The current implementation in this
>> patch seems to tell me which CPU the most recent packet came in on,
>> which is not necessarily very useful.
>
> Its the cpu that hit the TCP stack, bringing dozens of cache lines in
> its cache. This is all that matters,
>
>>
>> Some possibilities:
>>
>> 1. Let SO_INCOMING_CPU fail if RFS or RPS are in play.
>
> Well, idea is to not use RFS at all. Otherwise, it is useless.
>
Bear in mind this is only an interface to report RX CPU and in itself
doesn't provide any functionality for changing scheduling, there is
obviously logic needed in user space that would need to do something.

If we track the interrupting CPU in skb, the interface could be easily
extended to provide the interrupting CPU, the RPS CPU (calculated at
reported time), and the CPU processing transport (post steering which
is what is currently returned). That would provide the complete
picture to control scheduling a flow from userspace, and an interface
to selectively turn off RFS for a socket would make sense then.

> RFS is the other way around : You want the flow to follow your thread.
>
> RPS wont be a problem if you have sensible RPS settings.
>
>>
>> 2. Change the interface a bit to report the socket's preferred CPU
>> (where it would go without RFS, for example) and then let the
>> application use setsockopt to tell the socket to stay put (i.e. turn
>> off RFS and RPS for that flow).
>>
>> 3. Report the preferred CPU as in (2) but let the application ask for
>> something different.
>>
>> For example, I have flows for which I know which CPU I want.  A nice
>> API to put the flow there would be quite useful.
>>
>>
>> Also, it may be worth changing the naming to indicate that these are
>> about the rx cpu (they are, right?).  For some applications (sparse,
>> low-latency flows, for example), it can be useful to keep the tx
>> completion handling on a different CPU.
>
> SO_INCOMING_CPU is rx, like incoming ;)
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
