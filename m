From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/4] Documenting eBPF - extended Berkeley Packet
 Filter
Date: Tue, 07 Feb 2017 23:32:22 +0100
Message-ID: <589A4AF6.8010005@iogearbox.net>
References: <148647756092.10567.10947541548678801938.stgit@localhost>   <5899F93A.70708@iogearbox.net> <20170207221924.1583d3d0@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        Jonathan Corbet <corbet@lwn.net>,
        Alexei Starovoitov <ast@fb.com>, alexander@alemayhu.com,
        linux-kernel@vger.kernel.org, quentin.monnet@6wind.com,
        Daniel Borkmann <borkmann@iogearbox.net>, mtk@man7.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170207221924.1583d3d0@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/2017 10:19 PM, Jesper Dangaard Brouer wrote:
> On Tue, 07 Feb 2017 17:43:38 +0100
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> Hi Jesper,
>>
>> On 02/07/2017 03:30 PM, Jesper Dangaard Brouer wrote:
>>> Question: What kernel tree should this go into???
>>>
>>> If going through Jonathan Corbet, will it appear sooner here???
>>>    https://www.kernel.org/doc/html/latest/
>>> If it will not appear sooner that way, then it's likely best to keep
>>> it in sync with the tree that takes eBPF code changes.
>>
>> For initial parts, I don't have a preference (Jonathan has though,
>> so seems fine via docs tree then). If at some /later/ point in time
>> features come in along with doc updates (similar to test case updates),
>> probably best to route them via net-next.
>>
>>> This marks the beginning of user-facing developer documentation for
>>> using eBPF (extended Berkeley Packet Filter) as part of the kernel
>>> Documentation/ tree.
>>>
>>> This documentation is also available here[1], as an intermidiate quick
>>> way of prototyping and releasing the documentation.  The autoriative
>>> and official version of the documentation is what gets included in the
>>> kernel tree.  The docs at [2] will get updated based on what gets
>>> accepted after the standard peer-review kernel process.
>>
>> Thanks for your effort of writing a doc. Some high-level comments on
>> the set from my PoV first.
>>
>> I think it's definitely the right direction to move everything BPF
>> related to Documentation/BPF/. Right now, there are a lot of different
>> places with different kind of documentation, f.e.:
>
> Agree that we need some in-kernel place to centralize bpf related
> documentation, as it is too scattered at the moment.
>
>> * Documentation/networking/filter.txt
>>     Covers some cBPF/eBPF internals, tooling, etc; mostly technical,
>>     historically the central spot for BPF documentation. "filter" in
>>     filter.txt is long obsolete name, but looks like various sites,
>>     talks, blogs, etc still link to it. (At best, we should keep the
>>     file saying that the doc moved to Documentation/BPF/.)
>
> Agree.
>
>> * bpf(2) man page
>>     Has a good start, but right now is heavily behind the current user
>>     facing kernel code.
>
> Yes, the man-page have proven to get out-of-sync.  This is one of the
> reasons I prefer this in-kernel-tree documentation, as documentation
> can follow the patchset submission, instead of being something
> developers need to submit _after_ patches are accepted.
>
>
>> * include/uapi/linux/bpf.h
>>     Mostly relevant for helper function API description.
>>
>> * netdev conference slides/proceedings
>>     Also contain mostly technical details on eBPF.
>>
>> * https://github.com/iovisor/bpf-docs
>>     Non-exhaustive collection of various talks from different confs.
>>
>> * https://qmonnet.github.io/whirl-offload/2016/09/01/dive-into-bpf/
>>     Even bigger and more complete list of documentation material.
>>
>> * Various lwn articles ;), blog posts (f.e. from Brendan), etc.
>>
>> Now, challenge is to bring the relevant parts together and logically
>> separated into Documentation/BPF/ and bpf(2) man page. I think everything
>> user API relevant would help most if it updates bpf(2) man page. That can
>> be explanation of different map types, interaction with maps, quirks, etc.
>
> Sorry, but I disagree.  The man-page bpf(2) should only describe the
> bpf syscall.  Details on map types should be documented in this
> documentation.  Why, because this allow us to enforce documentation
> of a new map type is included together with the code submission (else
> it will never get documented).

But essential part of the syscall is to create new maps, interact with
them, etc so it's definitely relevant for the man page. The man page
has a couple of FIXMEs in its source that Michael Kerrisk added in the
course of reviewing and editing patches that were submitted; to give
one example related to this:

   [...]
   Currently, the following values are supported for
   .IR map_type :

   .in +4n
   .nf
   enum bpf_map_type {
     BPF_MAP_TYPE_UNSPEC,  /* Reserve 0 as invalid map type */
     BPF_MAP_TYPE_HASH,
     BPF_MAP_TYPE_ARRAY,
     BPF_MAP_TYPE_PROG_ARRAY,
   };
   .fi
   .in

   .I map_type
     selects one of the available map implementations in the kernel.
   .\" FIXME We need an explanation of why one might choose each of
   .\" these map implementations
   [...]

Thus, I think it makes sense to address these points there instead of
duplicating as a programmer guide in the kernel tree. Maps are not
added as frequently as helper calls, and neither require writing long
novels to document, so we could require submitters to send a patch there.
When it comes to deeper kernel internals that would not be appropriate
in man pages project, but need to be documented nevertheless (perhaps
a guide on what is necessary to implement new map types), they could
then go to the kernel documentation.

What I'm trying to say is that it makes sense to logically defragment
these bits that are relevant for man-page (since user/prog developer
specific) and for kernel doc tree (rather kernel developer specific),
so there's less duplication of efforts eventually.

>> Eventually also helper functions. Right now they're all documented in
>> include/uapi/linux/bpf.h and that's okay as it ships along with the
>> kernel code, so they're in sync. Eventually, there should be some more
>> elaborate description of them, perhaps with tiny examples, in bpf(2)
>> as well, since it's part of the uapi and stable (helpers themselves at
>> least).
>
> IMHO descriptions for bpf helpers function does not belong in the
> man-page for the bpf(2) syscall.  The bpf helpers are something that
> gets used by the ebpf program code which runs kernel side.  (And again
> the same argument about introducing new will not get updated in the man
> page).

But also here, the program runs in kernel space, sure, but people
writing programs are not necessarily the same that write kernel code
f.e. on netdev/lkml, or have a kernel source tree at hand. For helper
functions, the documentation is in-sync and part of include/uapi/linux/bpf.h
which gets shipped as kernel header anyway from distro side.

Man-pages get shipped as well, so they could contain additional infos
related to helpers, f.e. what helpers are tied to which program type,
etc; again, illustration from bpf.2 source:

   [...]
   .BR BPF_PROG_TYPE_KPROBE " (since Linux 4.1)
   .\" commit 2541517c32be2531e0da59dfd7efc1ce844644f5
   [To be documented]
   .\" FIXME Document this program type
   .\"       Describe allowed helper functions for this program type
   .\"       Describe bpf_context for this program type
   .\"
   .\" FIXME We need text here to describe 'kern_version'
   [...]

>> The Documentation/networking/filter.txt would need to be reworked a
>> bit and split into pieces for Documentation/BPF/, so we keep that as a
>> central place for the technical parts. Documentation/RCU/ is doing a
>> great job at that, and I would like to see Documentation/BPF/ being as
>> helpful for developers here. Part of that would be to add missing
>> pieces from the various available sources mentioned above or
>> elsewhere, so people can get a deeper understanding on internals
>> beyond reading just man page for the user API description; explaining
>> concepts, etc. Part of that can also be on the ELF loader bits, etc,
>> no doubt.
>
> Agree
>
>> On a quick glance on the remaining patches, it seems a mixture of
>> quotes from the bpf(2) man page, filter.txt along with sample code
>> explanation and lots of external links, part of them to
>> https://git.kernel.org/cgit/linux/..., http://lxr.free-electrons.com,
>> http://man7.org, http://www.slideshare.net/,
>> https://github.com/torvalds/linux/..., etc. I would suggest that
>> instead we should make Documentation/BPF/ eventually as
>> self-contained as possible and the central place for the internals
>> where others link to instead. It might take a bit, but I think
>> definitely worth it.
>
> In time it can be more self-contained, but as of this writing, as you
> mention yourself, bpf doc resources are fragmented all over, thus the
> obviously doc reflect that with many links.
>
>> Regarding patches, could you split the parts that should go to bpf(2)
>> off and submit them to man page tree for inclusion? I think that
>> would be incredibly helpful. And the remaining internals to start a
>> Documentation/BPF/ directory, even if initially just small (but will
>> grow over time of course)?
>
> As noted, I don't believe in populating the man page further is right
> direction, sorry, and I've already argued why.
>
>
>>> [1] http://prototype-kernel.readthedocs.io/en/latest/bpf/index.html
>>> [2]
>>> https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/Documentation
>>>
>>> Thanks to the following people, who have already reviewed and fixed
>>> earlier versions of this documentation on the IOvisor mailing-list:
>>>
>>>    Alexander Alemayhu <alexander@alemayhu.com>
>>>    Alexei Starovoitov <ast@fb.com>
>>>    Daniel Borkmann <daniel@iogearbox.net>
>>>    Quentin Monnet <quentin.monnet@6wind.com>
>>>
>>>
>>> ---
>>>
>>> Jesper Dangaard Brouer (4):
>>>         doc/bpf: start eBPF documentation tree bpf/
>>>         doc/bpf: document interacting with eBPF maps
>>>         doc/bpf: describes the different types of eBPF maps available
>>>         doc/bpf: describe BCC the BPF Compiler Collection
>>>
>>>
>>>    Documentation/bpf/bcc_tool_chain.rst  |   37 +++++
>>>    Documentation/bpf/ebpf_maps.rst       |  256
>>> +++++++++++++++++++++++++++++++++
>>> Documentation/bpf/ebpf_maps_types.rst |  119 +++++++++++++++
>>> Documentation/bpf/index.rst           |   68 +++++++++
>>> Documentation/index.rst               |    1 5 files changed, 481
>>> insertions(+) create mode 100644
>>> Documentation/bpf/bcc_tool_chain.rst create mode 100644
>>> Documentation/bpf/ebpf_maps.rst create mode 100644
>>> Documentation/bpf/ebpf_maps_types.rst create mode 100644
>>> Documentation/bpf/index.rst
>>>
>

