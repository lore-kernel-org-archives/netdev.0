From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC] act_cpu: redirect skb receiving to a special CPU.
Date: Sat, 5 Jun 2010 22:15:01 +0800
Message-ID: <AANLkTim83nfQDuLNmYAvk6RBqxot0t6cGq-lbic4-DSs@mail.gmail.com>
References: <AANLkTikskTWJrULj2IKYhebxh9O_XTOMBy3i0wPY8thq@mail.gmail.com>
	<1275743224.3490.44.camel@bigi> <AANLkTiltF2APEnqHyHTtHA7JMNp3HX3aCu9UL3nUJ5_u@mail.gmail.com>
	<1275746045.3490.60.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:47131 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933470Ab0FEOPW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 10:15:22 -0400
Received: by pvg16 with SMTP id 16so928924pvg.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 07:15:21 -0700 (PDT)
In-Reply-To: <1275746045.3490.60.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 5, 2010 at 9:54 PM, jamal <hadi@cyberus.ca> wrote:
> On Sat, 2010-06-05 at 21:26 +0800, Changli Gao wrote:
>
>> ingress doesn't have any qdisc, but a class tree. The ingress_queue
>> will be sth. like this:
> [..]
>
>> Then we can classify skbs in tree =A0manner.
> [..]
>> > The cpuid should be sufficient to map to a remote cpu queue, no?
>>
>> It should be sufficient, but it isn't efficient. With map option, we
>> can use cls_flow to map traffic to classid, and use act_cpu map to m=
ap
>> classid to cpuid.
>
> I am missing something, I would see the flow as:
> -->ethx/lo/etc->ingressqdisc->classify-->action(redirect to cpuidX)
> Why/when do you need the tree variant? If you are thinking of maybe
> rate limiting to a specific CPU, then would passing it to a policer
> first not be sufficient? =A0IOW, classid is not very useful.

=46or instance: there are 4 CPUs. I want redirect traffic to CPU 1-3
evenly. If the qdisc is linear the rules as

flow classify(flow classid ffff:2-4) | tc_index 2 action cpu 1 |
tc_index 3 action cpu 2 | tc_index 4 action cpu3

a tree variant:

class ffff:1 : flow classify(flow classid ffff:2-4)
class ffff:2 parent ffff:1 : action cpu 1
class ffff:3 parent ffff:1 : action cpu 2
class ffff:4 parent ffff:1 : action cpu 3

ingress_classify: use flow classify to get the subclass ID, then find
the corresponding class and exec action.

When there are lots of CPUs, tree is more efficient.

>
>> I won't implement a new netdevice, but reuse the softnet. Even, I'll
>> reuse the enqueue_to_backlog() introduced by RPS, and of course, use
>> IPIs as RPS. Is there another way to trigger an IRQ of the remote CP=
U?
>
> I would look at it as "messaging of remote CPU" which may not result
> in an IRQ. I am pretty sure if you tried hard you could use HT in AMD
> hardware - the remote cpu may have an IRQ triggered but it wont be as
> expensive as IPI.
>

It seems AMD specific. Why do the AMD guys use this to implement async
smp_call_function() if it is useful as you said?

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
