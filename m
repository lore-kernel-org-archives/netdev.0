From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next PATCH 3/5] net: introduce XDP driver features interface
Date: Mon, 22 May 2017 19:07:44 +0200
Message-ID: <59231AE0.8080409@iogearbox.net>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>        <149512210317.14733.15039298820296846614.stgit@firesoul>        <591F27B9.9070003@iogearbox.net>        <20170520095331.18c6be36@redhat.com>        <5920E62B.3040201@iogearbox.net> <20170522164958.52fb3b3d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38875 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933840AbdEVRHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 13:07:47 -0400
In-Reply-To: <20170522164958.52fb3b3d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 04:49 PM, Jesper Dangaard Brouer wrote:
> On Sun, 21 May 2017 02:58:19 +0200
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 05/20/2017 09:53 AM, Jesper Dangaard Brouer wrote:
>>> On Fri, 19 May 2017 19:13:29 +0200
>>> Daniel Borkmann <daniel@iogearbox.net> wrote:
>>>> On 05/18/2017 05:41 PM, Jesper Dangaard Brouer wrote:
>>>>> There is a fundamental difference between normal eBPF programs
>>>>> and (XDP) eBPF programs getting attached in a driver. For normal
>>>>> eBPF programs it is easy to add a new bpf feature, like a bpf
>>>>> helper, because is it strongly tied to the feature being
>>>>> available in the current core kernel code.  When drivers invoke a
>>>>> bpf_prog, then it is not sufficient to simply relying on whether
>>>>> a bpf_helper exists or not.  When a driver haven't implemented a
>>>>> given feature yet, then it is possible to expose uninitialized
>>>>> parts of xdp_buff.  The driver pass in a pointer to xdp_buff,
>>>>> usually "allocated" on the stack, which must not be exposed.
>>>>
>>>> When xdp_buff is being extended, then we should at least zero
>>>> initialize all in-tree users that don't support or populate this
>>>> field, thus that it's not uninitialized memory. Better would be
>>>> to have a way to reject the prog in the first place until it's
>>>> implemented (but further comments on feature bits below).
>>>
>>> Going down a path where we need to zero out the xdp_buff looks a lot
>>> like the sk_buff zeroing, which is the top perf cost associated with
>>> SKBs see[1].  XDP is is about not repeating the same issue we had with
>>> the SKB...
>>
>> But if we agree on implementing a certain feature that requires to
>> add a new member, then basic requirement should be that it needs to
>> be implementable by all XDP enabled drivers, so that users eventually
>> don't need to worry which driver they run to access a XDP feature.
>> In that case, zeroing that member until it gets properly implemented
>> is just temporary (and could be an incentive perhaps).
>>
>>> [1] https://prototype-kernel.readthedocs.io/en/latest/blogposts/xdp25_eval_generic_xdp_tx.html#analyzing-build-skb-and-memset
>>>
>>>>> Only two user visible NETIF_F_XDP_* net_device feature flags are
>>>>> exposed via ethtool (-k) seen as "xdp" and "xdp-partial".
>>>>> The "xdp-partial" is detected when there is not feature equality
>>>>> between kernel and driver, and a netdev_warn is given.
>>>>
>>>> I think having something like a NETIF_F_XDP_BIT for ethtool to
>>>> indicate support as "xdp" is quite useful. Avoids having to grep
>>>> the kernel tree for ndo_xdp callback. ;) A "xdp-partial" would
>>>> still be unclear/confusing to the user whether his program loads
>>>> or doesn't which is the only thing a user (or some loading infra)
>>>> cares about eventually, so one still needs to go trying to load
>>>> the XDP code to see whether that fails for the native case.
>>>
>>> Good that we agree on usefulness of the NETIF_F_XDP_BIT.  The
>>> "xdp-partial" or "xdp-challenged" is an early indication to the user
>>> that they should complain to the vendor.  I tried to keep it simple
>>> towards the user. Do you think every feature bit should be exposed to
>>> userspace?
>>
>> That would potentially require us to go down that path and expose
>> feature bits for everything, even something as silly as new flags
>> for a specific helper that requires some sort of additional support.
>> We probably rather want to keep such thing in the kernel for now
>> and potentially reject loads instead.
>>
>>>>> The idea is that XDP_DRV_* feature bits define a contract between
>>>>> the driver and the kernel, giving a reliable way to know that XDP
>>>>> features a driver promised to implement. Thus, knowing what bpf
>>>>> side features are safe to allow.
>>>>>
>>>>> There are 3 levels of features: "required", "devel" and "optional".
>>>>>
>>>>> The motivation is pushing driver vendors forward to support all
>>>>> the new XDP features.  Once a given feature bit is moved into
>>>>> the "required" features, the kernel will reject loading XDP
>>>>> program if feature isn't implemented by driver.  Features under
>>>>> developement, require help from the bpf infrastrucure to detect
>>>>> when a given helper or direct-access is used, using a bpf_prog
>>>>> bit to mark a need for the feature, and pulling in this bit in
>>>>> the xdp_features_check().  When all drivers have implemented
>>>>> a "devel" feature, it can be moved to the "required" feature and
>>>>
>>>> The problem is that once you add bits markers to bpf_prog like we
>>>> used to do in the past, then as you do in patch 4/5 with the
>>>> xdp_rxhash_needed bit, they will need to be turned /on/ unconditionally
>>>> when a prog has tail calls.
>>>
>>> Yes, with tail calls, we have to enable all features.  But that is a
>>> good thing, as it forces vendors to quickly implement all features.
>>> And it is no different from moving a feature into the "required" bits,
>>> once all drivers implement it.  It is only a limitation for tail calls,
>>> and something we can fix later (for handling this for tail calls).
>>
>> But the issue I pointed out with this approach is that XDP programs
>> using tail calls will suddenly break and get rejected from one
>> version to another.
>>
>> That's basically breaking the contract we have today where it must
>> be guaranteed that older programs keep working on newer kernels,
>> exactly the same with uapi. Breaking user programs is a no-go,
>> not a good thing at all (it will hurt users and they move on with
>> something else). So it's not something we can 'fix' at some later
>> point in time; such feature detection would need to consider this
>> from day 1.
>
> This is a very good point Daniel, that older program should be able to
> run. But this will only happen when tail calls are in-use, and NIC
> vendors don't keep their drivers up-to-date.  Creating a strong
> incentive for drivers implementing all XDP features (which you have
> argue for). Still I see your point.

The issue is that such chaining model as presented in [1] might be
quite typical in deployments.

Another strong argument for using tail calls is that when drivers
still don't support atomic updates of BPF programs. Usually a config
reload is needed when transitioning from no XDP -> XDP and XDP -> no XDP
mode, respectively, but not from XDP -> XDP. Last time I checked however,
there are drivers like qede, that would always do a reconfig. So for
that case having an init prog that then just tail calls into a main
prog would help as well as a work-around until driver finally supports
this.

All in all, I'm trying to say that tail calls are not a niche function
and we shouldn't have such window that when a feature update doesn't
make it in time, things not using the feature break.

   [1] slide 11, http://netdevconf.org/2.1/slides/apr6/zhou-netdev-xdp-2017.pdf

>>> BPF have some nice features of evaluating the input program
>>> "load-time", which is what I'm taking advantage of as an optimization
>>> here (let use this nice bpf property).   It is only tail calls that
>>> cannot evaluate this "load-time".  Thus, if you care about tail calls,
>>> supporting intermediate features, we could later fix that by adding a
>>> runtime feature check in the case of tail calls.
>
> How do we move forward from here?

If we introduce such feature bits one day, one possibility I see
that more or less could work is to propagate this into tail call
maps in a similar way like we do today with bpf_prog_array_compatible().
Latter checks the prog type and whether a prog was jited, as both
really cannot be mixed among each other.

So, once you load the program, either we somehow need to tell the
verifier upfront about our requirements, or the verifier detects
them based on the programs that are loaded (not sure about this
one though), and besides prog, it needs to mark the tail call map
with the same mask, such that any programs added later on to this
tail call map are guaranteed to use the same set of features or
just a subset of them. This also means that later updates cannot
use features outside of this set anymore (even if the driver could
support it). Then, the 'root' program which is to be attached to
the device can check against the driver's capabilities eventually,
since any program reachable from the root program would be guaranteed
to not use features outside of this set.

Still big question-mark wrt exposing these feature bits, and how
the set would be determined eventually, e.g. the loader would somehow
need to transparently calc the superset of features based on all
progs residing in the object file, and then pass them into the kernel
on prog load, where verifier checks them against the prog and if the
prog makes use of the same set or a subset, then we mark it and related
maps with the superset.

Just a quick thought, probably we can come up with something better.
The ugly bit is that we would expose bits for each silly thing and
need to determine them in the loader, which gets messy very quickly,
we should try hard to avoid that in the first place.

I guess would we add something similar like xdp_adjust_head() in
the future we might just add a uapi hidden dev pointer along which
we then access from the kernel's struct xdp_buff representation
inside the helper and bail out with an error should the device not
support it. And once we have all devices supporting it, we'd remove
it again, so that we wouldn't need such huge complexity with feature
bits.

> Let me try to restate the problem: There is a general disconnect
> between bpf and what XDP drivers support.
>
> The bpf model (AFAIK) is that your bpf program will get rejected when
> loading your bpf_prog.  This happens if you are using a bpf_helper or
> direct-ctx-access which is not supported/avail in the kernel. Right??
> (This also happens for tail-call programs, right?)  (I do like this
> model of failing the program when the feature is not avail).
>
> I guess, new bpf features are discovered by looking at uapi/bpf.h and
> then try to use the feature, and see if your program loads.
>
> The disconnect is that when writing XDP-bpf programs, then you will
> not get any feedback when you are calling a bpf-helper that the XDP
> driver doesn't support.  The XDP bpf-program loads and can happily run
> calling core-kernel XDP helpers.  Now, how will the XDP program author
> know that his call to the helper is valid?
>
> For rxhash, we could init the fields to zero (in drivers not
> supporting it), but how will the XDP bpf_prog author know whether or
> not a NIC driver supports XDP-rxhash?  (I guess, he could write a XDP
> program, that sets the XDP software hash, and then add a match via TC
> meta match or another cls_bpf program that read the skb->hash value,
> to see if changing the rxhash works... it seem clumpsy)
>
> For xdp_adjust_head, it was even-worse, as a boundry check against
> data_end with e.g. zero is no boundry, and would allow unbounded
> memory access from the xdp.data_end pointer.  We actually have
> released kernels with this bug, which can be triggered with a bpf
> tail-call.
>
> I just did a quick check on linux-stable.git for v4.10.17 and it looks
> like commit c2002f983767 ("bpf: fix checking xdp_adjust_head on tail
> calls") is missing, meaning drivers nfp, mlx5, nfp and virtio_net is
> likely subject to the adjust_head unbounded memory access bug via tail
> calls. I really wish we had a reliable way of avoiding these kind of
> bpf vs. XDP-driver mismatches.

Yeah :/, I think we might need to pass these to 4.10 stable:

   c2002f983767 ("bpf: fix checking xdp_adjust_head on tail calls")
   6b1bb01bcc5b ("bpf: fix cb access in socket filter programs on tail calls")
