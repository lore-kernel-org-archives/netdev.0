From: Avleen Vig <avleen@gmail.com>
Subject: Re: Crash in __netif_receive_skb
Date: Wed, 4 Apr 2012 14:35:41 -0500
Message-ID: <CAMjP1KkwMuQY4eBxmQeK_8xa11fDWHu_401Tg3iiXtqnHGV0jw@mail.gmail.com>
References: <CAMjP1Kka6MmT2zLc95ZQ=vigS6w9diS9-tawzdUdhbzzfzMh3w@mail.gmail.com>
	<CAMjP1KmDxhOKOGtgKt=OWbcXoJgrbA_rAxdkV4j7Y8XC8yjnuA@mail.gmail.com>
	<CAMjP1KmkS9aBXJm1GEavhcNx75ib7G4m+xYBe3_PcGSo6t5FsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMjP1KmkS9aBXJm1GEavhcNx75ib7G4m+xYBe3_PcGSo6t5FsQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 29, 2012 at 4:42 PM, Avleen Vig <avleen@gmail.com> wrote:
> On Wed, Mar 28, 2012 at 10:01 PM, Avleen Vig <avleen@gmail.com> wrote=
:
>> On Wed, Mar 28, 2012 at 8:31 PM, Avleen Vig <avleen@gmail.com> wrote=
:
>>> Hi folks, someone in #kernel recommended I email these two lists. H=
ope
>>> they're the right place.
>>>
>>> We're running 2.6.32-220.4.1.el6.x86_64 on Centos 6.2, and getting =
a
>>> repeated crash:
>>> =A0 =A0https://gist.github.com/2231998
>>>
>>> We can make this happen pretty easily just by passing some network
>>> traffic and waiting a while.
>>> I couldn't find any references to this particular issue.
>>> I have vmcore files and am happy to dig into it if it would help (a=
s
>>> long as someone can tell me what to do :))
>>
>> I hope this debugging is legit, I'm really new to this level of insi=
ght.
>>
>> I think the problem is in include/linux/netpoll.h, at the "if"
>> statement at line 86:
>> =A0 =A0static inline int netpoll_receive_skb(struct sk_buff *skb)
>> =A0 =A0{
>> =A0 =A0 =A0 =A0if (!list_empty(&skb->dev->napi_list))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return netpoll_rx(skb);
>> =A0 =A0 =A0 =A0return 0;
>> =A0 =A0}
>>
>>
>> This is based on poking around in the crash dump:
>> =A0 =A0BUG: unable to handle kernel NULL pointer dereference at 0000=
000000000060
>> =A0 =A0IP: [<ffffffff8142bb40>] __netif_receive_skb+0x60/0x6e0
>> =A0 =A0crash> dis -rl ffffffff8142bb40
>> =A0 =A0....
>> =A0 =A0/usr/src/debug/kernel-2.6.32-220.7.1.el6/linux-2.6.32-220.7.1=
=2Eel6.x86_64/include/linux/netpoll.h:
>> 86
>> =A0 =A00xffffffff8142bb33 <__netif_receive_skb+83>: =A0 =A0mov =A0 =A0=
0x20(%rbx),%r12
>> =A0 =A00xffffffff8142bb37 <__netif_receive_skb+87>: =A0 =A0mov =A0 =A0=
%r12,-0x38(%rbp)
>> =A0 =A00xffffffff8142bb3b <__netif_receive_skb+91>: =A0 =A0lea =A0 =A0=
0x60(%r12),%rax
>> =A0 =A00xffffffff8142bb40 <__netif_receive_skb+96>: =A0 =A0cmp =A0 =A0=
%rax,0x60(%r12)
>>
>>
>>
>> I *think* this means that "&skb->dev->napi_list" is null when we're
>> trying to compare it, rather than being a list.
>>
>> If it matters, this is inside LXC containers.
>
> We've traced this to a problem with machines that have multiple hard
> drives AND have NAPI enabled for the NIC driver.
>
> We recompiled the e1000e driver with NAPI disabled, with:
> =A0 =A0make CFLAGS_EXTRA=3D-DE1000E_NO_NAPI
>
> and everything works great now.

Untrue! This eventually failed too, but after a lot more debugging, we
think we've nailed it:
    Multicast

We use ganglia on all of our nodes (and we were setting it up inside
the LXC containers), and ganglia listens / sends on multicast.

When gmond was starting inside the containers, it was giving an error:
    Apr  4 17:00:42 hostname /usr/sbin/gmond[551]: Error creating
multicast server mcast_join=3D239.2.11.110 port=3D8649 mcast_if=3DNULL
family=3D'inet4'. Exiting.

It occurred to me that if the kernel is trying to read a multicast
packet from a socket buffer, but the container can't handle multicast
(mcast_if=3DNULL), that would explain why we got a NULL pointer
dereference in &skb->dev->napi_list.
(at least, this makes sense in my head.)

We disabled gmond in the containers, so nothing should be listening
for multicast packets, and everything is stable again.
Note that this ONLY seems to happen for us when we're using the
onboard 82574L Intel NIC with the e1000e driver.
We have other servers with the 82575 NIC which uses the igb driver and
doesn't exhibit this problem.

Is anyone from Intel here who could look in to this?
