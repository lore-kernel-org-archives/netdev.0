From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 1/1] net sched actions: mirred add support for
 setting Dst MAC address
Date: Tue, 5 Jul 2016 07:04:10 -0400
Message-ID: <577B942A.2020602@mojatatu.com>
References: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
 <20160704.151435.624086916441807197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:37281 "EHLO
	mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932792AbcGELEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 07:04:20 -0400
Received: by mail-it0-f51.google.com with SMTP id f6so79685467ith.0
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 04:04:20 -0700 (PDT)
In-Reply-To: <20160704.151435.624086916441807197.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-04 06:14 PM, David Miller wrote:

> I agree with Jiri.
>
> The whole model is to chain together the actions that you need to
> accomplish whatever it is you want to do.
>
> This means actions are as specialized as possible, and do one thing
> as precisely and efficiently as possible.
>
> It seems unnecessary to break this model and start to make swiss army
> knife actions.
>
> Every time we find some "common use case" will we turn yet another
> action into a Frankenstein thing that does more than it was designed
> to do?
>

I agree there is grey line and i too subscribe to the faith of
small-actions granularity. But it is not exact dogma guys.
Even grep ends up adding features over time;->
I am/was on the fence on submitting this patch. Here's the
thought process that convinced my fingers to type the patch:

When you have a switch between you and the destination target (in my
case several that i have no control over) and when said switches
learn the MAC addresses, then there is confusion when they start
seeing the same MAC address showing up in conflicting ports.

Second arguement  usability, from:

sudo $TC filter add dev $ETH parent ffff: pref 11 protocol ip u32 \
match ip protocol 1 0xff flowid 1:2 \
action pedit munge offset -14 u8 set 0x02 \
         munge offset -13 u8 set 0x15 \
         munge offset -12 u8 set 0x15 \
         munge offset -11 u8 set 0x15 \
         munge offset -10 u16 set 0x1515 \
         pipe \
action mirred egress redirect dev $SPANPORT

to:
$TC filter add dev $ETH parent 1: protocol ip prio 10 \
     u32 match ip protocol 1 0xff flowid 1:2 \
     action mirred egress redirect dev $SPANPORT dst 02:15:15:15:15:15

given that I have to do this many many times in scripts and the
second policy is better eye candy.

And last but not least: there is a small performance improvement
because i have to execute less instructions.

Choices are ugly and slow vs fast and nicer;->

Of course what i am doing makes it more complex to offload with
existing ASICs. But it is an optional feature so it could be
worked around; we need to start dealing with capabilities and
reject offloads for certain policies.

Alternative: introduce another action, I'll call it skbmod
(like skbedit) and anytime someone finds something they are
prototyping with pedit is ugly they could migrate the modifier
into skbmod. First user dstmac.
So my policy would be:

$TC filter add dev $ETH parent 1: protocol ip prio 10 \
u32 match ip protocol 1 0xff flowid 1:2 \
action skbmod dstmac 02:15:15:15:15:15 \
action mirred egress redirect dev $SPANPORT

> I don't want to apply this and start us down this road, seriously...

That cat is out of the bag, at least for tc bpf. An opaque blob
of a single action could do whatever it wants.

cheers,
jamal
