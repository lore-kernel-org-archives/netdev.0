From: Avleen Vig <avleen@gmail.com>
Subject: Re: Crash in __netif_receive_skb
Date: Thu, 29 Mar 2012 16:42:29 -0500
Message-ID: <CAMjP1KmkS9aBXJm1GEavhcNx75ib7G4m+xYBe3_PcGSo6t5FsQ@mail.gmail.com>
References: <CAMjP1Kka6MmT2zLc95ZQ=vigS6w9diS9-tawzdUdhbzzfzMh3w@mail.gmail.com>
	<CAMjP1KmDxhOKOGtgKt=OWbcXoJgrbA_rAxdkV4j7Y8XC8yjnuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:35573 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933141Ab2C2Vmb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 17:42:31 -0400
In-Reply-To: <CAMjP1KmDxhOKOGtgKt=OWbcXoJgrbA_rAxdkV4j7Y8XC8yjnuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 28, 2012 at 10:01 PM, Avleen Vig <avleen@gmail.com> wrote:
> On Wed, Mar 28, 2012 at 8:31 PM, Avleen Vig <avleen@gmail.com> wrote:
>> Hi folks, someone in #kernel recommended I email these two lists. Ho=
pe
>> they're the right place.
>>
>> We're running 2.6.32-220.4.1.el6.x86_64 on Centos 6.2, and getting a
>> repeated crash:
>> =A0 =A0https://gist.github.com/2231998
>>
>> We can make this happen pretty easily just by passing some network
>> traffic and waiting a while.
>> I couldn't find any references to this particular issue.
>> I have vmcore files and am happy to dig into it if it would help (as
>> long as someone can tell me what to do :))
>
> I hope this debugging is legit, I'm really new to this level of insig=
ht.
>
> I think the problem is in include/linux/netpoll.h, at the "if"
> statement at line 86:
> =A0 =A0static inline int netpoll_receive_skb(struct sk_buff *skb)
> =A0 =A0{
> =A0 =A0 =A0 =A0if (!list_empty(&skb->dev->napi_list))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return netpoll_rx(skb);
> =A0 =A0 =A0 =A0return 0;
> =A0 =A0}
>
>
> This is based on poking around in the crash dump:
> =A0 =A0BUG: unable to handle kernel NULL pointer dereference at 00000=
00000000060
> =A0 =A0IP: [<ffffffff8142bb40>] __netif_receive_skb+0x60/0x6e0
> =A0 =A0crash> dis -rl ffffffff8142bb40
> =A0 =A0....
> =A0 =A0/usr/src/debug/kernel-2.6.32-220.7.1.el6/linux-2.6.32-220.7.1.=
el6.x86_64/include/linux/netpoll.h:
> 86
> =A0 =A00xffffffff8142bb33 <__netif_receive_skb+83>: =A0 =A0mov =A0 =A0=
0x20(%rbx),%r12
> =A0 =A00xffffffff8142bb37 <__netif_receive_skb+87>: =A0 =A0mov =A0 =A0=
%r12,-0x38(%rbp)
> =A0 =A00xffffffff8142bb3b <__netif_receive_skb+91>: =A0 =A0lea =A0 =A0=
0x60(%r12),%rax
> =A0 =A00xffffffff8142bb40 <__netif_receive_skb+96>: =A0 =A0cmp =A0 =A0=
%rax,0x60(%r12)
>
>
>
> I *think* this means that "&skb->dev->napi_list" is null when we're
> trying to compare it, rather than being a list.
>
> If it matters, this is inside LXC containers.

We've traced this to a problem with machines that have multiple hard
drives AND have NAPI enabled for the NIC driver.

We recompiled the e1000e driver with NAPI disabled, with:
    make CFLAGS_EXTRA=3D-DE1000E_NO_NAPI

and everything works great now.
