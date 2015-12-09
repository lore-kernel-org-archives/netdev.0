From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] ipv6: sctp: clone options to avoid use after free
Date: Wed, 9 Dec 2015 15:11:24 -0200
Message-ID: <566860BC.4040604@gmail.com>
References: <CACT4Y+YjXJoh3uGDp=FJkYVnjaMxFSPY252ptbDGZ-LQ9JAEWw@mail.gmail.com>
 <CANn89i+V-GeD3zCzGPAo4jY8Z6iTjFN3U1ixG44WyKKLOZ9Txw@mail.gmail.com>
 <20151209145917.GA3884@mrl.redhat.com>
 <CANn89iLhetNbtO6h99zZOrCiMYON50vzVsk7j_AtosXejvvm4Q@mail.gmail.com>
 <1449674706.9768.5.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE9A61@AcuExch.aculab.com>
 <1449676782.9768.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE9B1C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: David Laight <David.Laight@ACULAB.COM>,
	'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:33322 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbbLIRLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 12:11:31 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBE9B1C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 09-12-2015 14:31, David Laight escreveu:
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>> Sent: 09 December 2015 16:00
>> On Wed, 2015-12-09 at 15:49 +0000, David Laight wrote:
>>>> SCTP is lacking proper np->opt cloning at accept() time.
>>>>
>>>> TCP and DCCP use ipv6_dup_options() helper, do the same in SCTP.
>>>>
>>>> We might later factorize this code in a common helper to avoid
>>>> future mistakes.
>>>
>>> I'm wondering what the real impact of this and the other recent
>>> SCTP bugs/patches is on real workloads?
>>> We have enough trouble getting our customers to use kernels
>>> later that the 2.6.18 based RHEL5 - without having to persuade
>>> them to use kernels that contain very recent fixes.
>>
>> It all depends if your customers let (hostile ?) people run programs on
>> the boxes.
>
> If they require hostile programs I'm not worried.

Not really "require", but "allow", as in: allowing third-party 
applications to run on it.

> But it isn't entirely clear from these oops reports what the
> test program is actually doing.
> Some of them might be valid scenarios.
> Not that our code does anything clever.

This one patched by Eric is a rather common scenario and can lead to 
memory corruption and even double-frees because it will call txopt_put() 
on a buffer that is long gone due to the blind pointer copy. Note that 
Vlad is checking peeloff operation yet regarding this.
You just have to use the right SOL_IPV6 options and accept a socket to 
trigger it.

The timestamps I patched are also not an unusual scenario and allow one 
to be able to disable packet stamping for the entire system. Another 
effect would be to one enable stamping on listening socket and not gett 
it automatically on accepted ones, but that's probably a minor compared 
to the others because developers probably would have caught this already.

And this last one I'm still fixing, is mostly harmless so far. The 
use-after-free happens only in a debug statement (read: not propagated 
anywhere else) and it's just a read.

HTH!

   Marcelo
