From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 0/2] act_bpf, cls_bpf: send eBPF bytecode through
Date: Wed, 20 Apr 2016 11:55:22 +0200
Message-ID: <5717520A.5060800@iogearbox.net>
References: <1460714856-7221-1-git-send-email-quentin.monnet@6wind.com> <5710C541.7070609@iogearbox.net> <20160415184445.GA58007@ast-mbp.thefacebook.com> <57172ED3.30101@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev@vger.kernel.org
To: Quentin Monnet <quentin.monnet@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44512 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933236AbcDTJza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 05:55:30 -0400
In-Reply-To: <57172ED3.30101@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Quentin,

On 04/20/2016 09:25 AM, Quentin Monnet wrote:
> 2016-04-15 (11:44 UTC-0700) ~ Alexei Starovoitov:
>> On Fri, Apr 15, 2016 at 12:41:05PM +0200, Daniel Borkmann wrote:
>>> On 04/15/2016 12:07 PM, Quentin Monnet wrote:
>>>> When a new BPF traffic control filter or action is set up with tc,=
 the
>>>> bytecode is sent back to userspace through a netlink socket for cB=
PF, but
>>>> not for eBPF (the file descriptor pointing to the object file cont=
aining
>>>> the bytecode is sent instead).
>>>>
>>>> This patch makes cls_bpf and act_bpf modules send the bytecode for=
 eBPF as
>>>> well (in addition to the file descriptor).
>>>>
> [=85]
>>>
>>> Thanks for working on this, but it's unfortunately not that easy. L=
et
>>> me ask, what would be the intended use-case to dump the insns?
>>
>> +1
>>
>>> I'm asking because if you dump them as-is, then a reinject at a lat=
er
>>> time of that bytecode back into the kernel will most likely be reje=
cted
>>> by the verifier.
>>>
>>> This is because on load time, verifier does rewrites/expansion on s=
ome
>>> of the insns (f.e. map pointers, helper functions, ctx access etc, =
see
>>> also appendix in [1]), so the code as seen in the kernel would need=
 to
>>> be sanitized first.
>>
>> +1
>> we had similar discussion about this in seccomp context and decided =
that
>> the only sensible way is to keep original instructions, but it's was=
teful
>> to do unconditionally and snapshotting of maps is not possible,
>> so there was no use for such dumping facility other than debugging.
>> Is it what the patch after?
>> We need to discuss it in the proper context.
>
> I am experimenting with BPF, and so far I was just trying to dump the
> bytecode sent from tc to the kernel. I had not realized that the
> verifier would bring some changes to the instructions. And I agree th=
at
> a more comprehensive debugging solution could be obtained if I can fi=
nd
> some way to get a snapshot of the maps.
>
>>> Also, how would you make sense/transform maps into a meaningful
>>> representation (probably possible to find a scheme when they are pi=
nned)?
>>>
>>> Another possibility is that such programs need to be pinned (can be=
 done
>>> easily by tc in the background) and then implement a CRIU facility =
into
>>> the bpf(2) syscall to retrieve them. tc could make use of this w/o =
too
>>> much effort, and at the same time it would help CRIU folks, too. It
>>> also seems cleaner to have only one central api (bpf(2)) to dump th=
em,
>>> but needs a bit of thought.
>>
>> +1
>> any debugging or criu needs to be done in a centralized way via sysc=
all
>> and/or bpffs.
>
> Maintaining a central API around bpf() makes sense to me. I have been
> looking at the BPF filesystem to see what information I can obtain fr=
om
> it, but I did not understand it well. I read the logs of Daniel's com=
mit
> b2197755b263 (=93bpf: add support for persistent maps/progs=94), but =
I am
> unsure how I could use it in order to gather data about the maps and
> programs (if this is possible at all). I tried to set up some BPF

Currently, there's not yet much information to extract. F.e. if you loo=
k at
the tc source code, we do bpf_map_selfcheck_pinned() from fdinfo to che=
ck if
the map fd that we got from the pinned one fits to the one from the obj=
ect
file. But obviously more work is needed for extraction of bytecode as i=
n your
case.

Haven't thought much about it yet, but one idea could be that tc also p=
ins
programs, then sends some kind of annotation down to cls_bpf where on f=
ilter
dump tc could retrieve the path to the pinned program again, then uses =
bpf(2)
with BPF_OBJ_GET to get the fd, and a new command e.g. BPF_PROG_DUMP to=
 extract
bytecode/map info from the running program and dumps it to the user in =
a way
where some sense can be made out of it from admin/user perspective (in =
other
words, not just raw opcodes I mean).

BPF_PROG_DUMP could have auxiliary information with map specs, kind of =
in a
similar way like we retrieve them as relo entries from the object file =
in
the loader, and in addition some information where to retrieve the maps=
 in
case they were pinned. This still doesn't give you a entire snapshot of=
 the
map, but would at least allow you for the pinned ones to iterate over t=
hem
via bpf(2) with BPF_MAP_GET_NEXT_KEY, plus in general it would allow yo=
u to
reload the program.

There's still the issue with the additional memory overhead to keep ori=
ginal
insns around as Alexei mentioned. Two things that come to mind, one bei=
ng
that when JITing was successful, we could actually try to shrink struct=
 bpf_prog
again since we work on a different image, but it doesn't address the ca=
se
where JIT is not used. Other one being to perhaps only keep a 'diff' ar=
ound
in orig_prog where we can patch insns back to original, probably possib=
le,
but needs a bit of work though.

> filters working with maps, but I could not find any file under
> /sys/fs/bpf/tc.

There are some getting started examples under examples/bpf/ in the ipro=
ute2
repo, f.e. bpf_shared.c is one.

> Would you have a pointer to some documentation about this filesystem?=
 Or
> is there only the kernel code?

Yeah, b2197755b263 and 42984d7c1e56, and in my netdev1.1 paper I tried =
to put
more extensive information, but seems the proceedings haven't been publ=
ished
yet. I can send you a private copy until they are officially released I=
 guess.

Thanks,
Daniel
