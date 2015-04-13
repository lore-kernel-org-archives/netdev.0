From: Jonathan Davies <jonathan.davies@citrix.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance regression
 on Xen
Date: Mon, 13 Apr 2015 14:38:25 +0100
Message-ID: <552BC6D1.1060907@citrix.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	<1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	netdev <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	<edumazet@google.com>, <linux-arm-kernel@lists.infradead.org>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	David Vrabel <david.vrabel@citrix.com>,
	"Felipe Franciosi" <felipe.franciosi@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>
To: George Dunlap <George.Dunlap@eu.citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27933 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbbDMNia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 09:38:30 -0400
In-Reply-To: <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/04/15 11:56, George Dunlap wrote:
> On Thu, Apr 9, 2015 at 5:36 PM, Stefano Stabellini
> <stefano.stabellini@eu.citrix.com> wrote:
>> On Thu, 9 Apr 2015, Eric Dumazet wrote:
>>> On Thu, 2015-04-09 at 16:46 +0100, Stefano Stabellini wrote:
>>>> Hi all,
>>>>
>>>> I found a performance regression when running netperf -t TCP_MAERTS from
>>>> an external host to a Xen VM on ARM64: v3.19 and v4.0-rc4 running in the
>>>> virtual machine are 30% slower than v3.18.
>>>>
>>>> Through bisection I found that the perf regression is caused by the
>>>> prensence of the following commit in the guest kernel:
>>>>
>>>>
>>>> commit 605ad7f184b60cfaacbc038aa6c55ee68dee3c89
>>>> Author: Eric Dumazet <edumazet@google.com>
>>>> Date:   Sun Dec 7 12:22:18 2014 -0800
>>>>
>>>>      tcp: refine TSO autosizing
>
> [snip]

I recently discussed this issue on netdev in the following thread:

https://www.marc.info/?l=linux-netdev&m=142738853820517

>>> This commit restored original TCP Small Queue behavior, which is the
>>> first step to fight bufferbloat.
>>>
>>> Some network drivers are known to be problematic because of a delayed TX
>>> completion.
>
> [snip]
>
>>> Try to tweak /proc/sys/net/ipv4/tcp_limit_output_bytes to see if it
>>> makes a difference ?
>>
>> A very big difference:
>>
>> echo 262144 > /proc/sys/net/ipv4/tcp_limit_output_bytes
>> brings us much closer to the original performance, the slowdown is just
>> 8%
>>
>> echo 1048576 > /proc/sys/net/ipv4/tcp_limit_output_bytes
>> fills the gap entirely, same performance as before "refine TSO
>> autosizing"
>>
>>
>> What would be the next step for here?  Should I just document this as an
>> important performance tweaking step for Xen, or is there something else
>> we can do?
>
> Is the problem perhaps that netback/netfront delays TX completion?
> Would it be better to see if that can be addressed properly, so that
> the original purpose of the patch (fighting bufferbloat) can be
> achieved while not degrading performance for Xen?  Or at least, so
> that people get decent perfomance out of the box without having to
> tweak TCP parameters?

I agree; reducing the completion latency should be the ultimate goal. 
However, that won't be easy, so we need a work-around in the short term. 
I don't like the idea of relying on documenting the recommendation to 
change tcp_limit_output_bytes; too many people won't read this advice 
and will expect the out-of-the-box defaults to be reasonable.

Following Eric's pointers to where a similar problem had been 
experienced in wifi drivers, I came up with two proof-of-concept patches 
that gave a similar performance gain without any changes to sysctl 
parameters or core tcp/ip code. See 
https://www.marc.info/?l=linux-netdev&m=142746161307283.

I haven't yet received any feedback from the xen-netfront maintainers 
about whether those ideas could be reasonably adopted.

Jonathan
