From: Quentin Monnet <quentin.monnet@6wind.com>
Subject: Re: [PATCH net-next 0/2] act_bpf, cls_bpf: send eBPF bytecode through
Date: Wed, 20 Apr 2016 09:25:07 +0200
Message-ID: <57172ED3.30101@6wind.com>
References: <1460714856-7221-1-git-send-email-quentin.monnet@6wind.com>
 <5710C541.7070609@iogearbox.net>
 <20160415184445.GA58007@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36042 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbcDTHZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 03:25:23 -0400
Received: by mail-wm0-f43.google.com with SMTP id v188so190911305wme.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 00:25:22 -0700 (PDT)
In-Reply-To: <20160415184445.GA58007@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel, Alexei, and many thanks for your answers,

2016-04-15 (11:44 UTC-0700) ~ Alexei Starovoitov:
> On Fri, Apr 15, 2016 at 12:41:05PM +0200, Daniel Borkmann wrote:
>> Hi Quentin,
>>
>> On 04/15/2016 12:07 PM, Quentin Monnet wrote:
>>> When a new BPF traffic control filter or action is set up with tc, =
the
>>> bytecode is sent back to userspace through a netlink socket for cBP=
=46, but
>>> not for eBPF (the file descriptor pointing to the object file conta=
ining
>>> the bytecode is sent instead).
>>>
>>> This patch makes cls_bpf and act_bpf modules send the bytecode for =
eBPF as
>>> well (in addition to the file descriptor).
>>>
[=85]
>>
>> Thanks for working on this, but it's unfortunately not that easy. Le=
t
>> me ask, what would be the intended use-case to dump the insns?
>=20
> +1
>=20
>> I'm asking because if you dump them as-is, then a reinject at a late=
r
>> time of that bytecode back into the kernel will most likely be rejec=
ted
>> by the verifier.
>>
>> This is because on load time, verifier does rewrites/expansion on so=
me
>> of the insns (f.e. map pointers, helper functions, ctx access etc, s=
ee
>> also appendix in [1]), so the code as seen in the kernel would need =
to
>> be sanitized first.
>=20
> +1
> we had similar discussion about this in seccomp context and decided t=
hat
> the only sensible way is to keep original instructions, but it's wast=
eful
> to do unconditionally and snapshotting of maps is not possible,
> so there was no use for such dumping facility other than debugging.
> Is it what the patch after?
> We need to discuss it in the proper context.

I am experimenting with BPF, and so far I was just trying to dump the
bytecode sent from tc to the kernel. I had not realized that the
verifier would bring some changes to the instructions. And I agree that
a more comprehensive debugging solution could be obtained if I can find
some way to get a snapshot of the maps.

>> Also, how would you make sense/transform maps into a meaningful
>> representation (probably possible to find a scheme when they are pin=
ned)?
>>
>> Another possibility is that such programs need to be pinned (can be =
done
>> easily by tc in the background) and then implement a CRIU facility i=
nto
>> the bpf(2) syscall to retrieve them. tc could make use of this w/o t=
oo
>> much effort, and at the same time it would help CRIU folks, too. It
>> also seems cleaner to have only one central api (bpf(2)) to dump the=
m,
>> but needs a bit of thought.
>=20
> +1
> any debugging or criu needs to be done in a centralized way via sysca=
ll
> and/or bpffs.

Maintaining a central API around bpf() makes sense to me. I have been
looking at the BPF filesystem to see what information I can obtain from
it, but I did not understand it well. I read the logs of Daniel's commi=
t
b2197755b263 (=93bpf: add support for persistent maps/progs=94), but I =
am
unsure how I could use it in order to gather data about the maps and
programs (if this is possible at all). I tried to set up some BPF
filters working with maps, but I could not find any file under
/sys/fs/bpf/tc.

Would you have a pointer to some documentation about this filesystem? O=
r
is there only the kernel code?
