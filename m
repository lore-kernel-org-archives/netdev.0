From: Milton Miller <miltonm@bga.com>
Subject: [SPARSE REQUEST] was [PATCH] niu: bitwise or does not imply ordering
Date: Tue, 18 Nov 2008 10:29:10 -0600
Message-ID: <eff33bff566e125171ec813f2ed58015@bga.com>
References: <312268717986b8b45674.846930886.miltonm@bga.com> <1226849525.8189.6.camel@localhost.localdomain> <20081116.124924.146154114.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jdb@comx.dk,
	segher@kernel.crashing.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercury.realtime.net ([205.238.132.86]:39628 "EHLO
	mercury.realtime.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960AbYKRQYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 11:24:34 -0500
In-Reply-To: <20081116.124924.146154114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Nov 16, 2008, at 2:49 PM, David Miller wrote:
> From: Jesper Dangaard Brouer <jdb@comx.dk>
> Date: Sun, 16 Nov 2008 16:32:05 +0100

[restored context]
>> Milton Miller wrote:
>>> commit e23a59e1ca6d177a57a7791b3629db93ff1d9813 (niu: Fix readq
>>> implementation when architecture does not provide one.) reordered the
>>> arguments to a bitwise or to change the emitted code.   However, C 
>>> does
>>> not guarantee the evaluation order.
[end restored context]
>>
>> I have tested it on the actual hardware, it works...
>>
>> I actually agree that we should make it explicit, eventhough DaveM 
>> seems
>> to disagree on the netdev list.
>
> I'm also not applying this patch for another reason.
>
> This is a knee-jerk reaction patch, purely.  This person
> saw the commit and wants to fix only _THIS_ case.

Yes, I saw the commit that said *for this driver* the order of the 
operations matter.  I saw a change that relied on implementation 
behavior that I doubt even the current compiler would make any future 
guarantees.

> Well guess what?  If you really CARED, you'd go change this
> across the whole tree.  This exact construct exists ALL
> OVER the kernel.  In fact there are sequences that match
> this new NIU code exactly.

But does the hardware require the two reads occur in order, or does the 
order not matter to that hardware?

By the same token, I don't care, as I don't use the hardware.   I was 
trying to save you future debug.

But thinking about it further, I think you only changed the size of the 
window, and the underlying problem still exists.  What prevents 
hardware from setting (additional) bits between the read to the lower 
portion and the upper?     You reduced the window to the few cycles 
between the first and second read. but the window is still there.

> Did these people complaining look for those?  No.

You are right, I didn't look.   But I don't think the tool to use to 
look for this is grep.   I think its either sparse or one of the 
semantic parsers.  Gcc has  -Wsequence-point in -Wall, although I am 
told it will only complain when it can prove a multiple reference and 
store.   What the kernel checker should be checking is (1) volatile 
dereference or (2) barrier (volatile asm?) (or any combination) on both 
sides of a sequence point.  Because the reference might be hidden 
out-of-line, it was suggested we annotate things like readl/writel as 
(has_side_effects).   The way to remove such errors is to choose one 
order (preferably the one some version of gcc uses) and create local 
variables with the partial results.   I would expect this option should 
get its own kconfig to enable/disable the warning like the warn 
deprecated stuff while the points are identified.

Since I'm not a toolchain hacker, I'm hoping someone on linux-kernel 
will see this request and act on it.  And I would guess that most of 
the cc list doesn't' care to watch it, so consider your cc list.


thanks
milton

