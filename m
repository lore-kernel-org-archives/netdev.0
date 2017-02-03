From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Fri, 03 Feb 2017 17:33:45 +1300
Message-ID: <87r33fevva.fsf@xmission.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
        <87efzq8jbi.fsf@xmission.com> <588995DE.9040707@fb.com>
        <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
        <588A35F8.6050909@fb.com>
        <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
        <588A40D7.9070603@fb.com>
        <CALCETrXgdY_Kt8wn4uiATUnNJ3YXttCUREgEeQReG7u29Lc44g@mail.gmail.com>
        <588A4D3C.9070601@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Lutomirski <luto@amacapital.net>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        "Daniel Borkmann" <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        "Tejun Heo" <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59422 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752311AbdBCEiT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 23:38:19 -0500
In-Reply-To: <588A4D3C.9070601@fb.com> (Alexei Starovoitov's message of "Thu,
        26 Jan 2017 11:25:48 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <ast@fb.com> writes:

> On 1/26/17 11:07 AM, Andy Lutomirski wrote:
>> On Thu, Jan 26, 2017 at 10:32 AM, Alexei Starovoitov <ast@fb.com> wrote:
>>> On 1/26/17 10:12 AM, Andy Lutomirski wrote:
>>>>
>>>> On Thu, Jan 26, 2017 at 9:46 AM, Alexei Starovoitov <ast@fb.com> wrote:
>>>>>
>>>>> On 1/26/17 8:37 AM, Andy Lutomirski wrote:
>>>>>>>
>>>>>>>
>>>>>>> Think of bpf programs as safe kernel modules. They don't have
>>>>>>> confined boundaries and program authors, if not careful, can shoot
>>>>>>> themselves in the foot. We're not trying to prevent that because
>>>>>>> it's impossible to check that the program is sane. Just like
>>>>>>> it's impossible to check that kernel module is sane.
>>>>>>> But in case of bpf we check that bpf program is _safe_ from the kernel
>>>>>>> point of view. If it's doing some garbage, it's program's business.
>>>>>>> Does it make more sense now?
>>>>>>>
>>>>>>
>>>>>> With all due respect, I think this is not an acceptable way to think
>>>>>> about BPF at all.  If you think of BPF this way, I think there needs
>>>>>> to be a real discussion at KS or similar as to whether this is okay.
>>>>>> The reason is simple: the kernel promises a stable ABI to userspace
>>>>>> but not to kernel modules.  By thinking of BPF as more like a module,
>>>>>> you're taking a big shortcut that will either result in ABI breakage
>>>>>> down the road or in committing to a problematic stable ABI.
>>>>>
>>>>>
>>>>>
>>>>> you misunderstood the analogy.
>>>>> bpf abi is certainly stable. that's why we were careful of not
>>>>> exposing anything to it that is not already stable.
>>>>>
>>>>
>>>> In that case I don't understand what you're trying to say.  Eric
>>>> thinks your patch exposes a bad interface.  A bad interface for
>>>> userspace is a very different thing from a bad interface available to
>>>> kernel modules.  Are you saying that BPF is kernel-module-like in that
>>>> the ABI exposed to BPF programs doesn't need to meet the same quality
>>>> standards as userspace ABIs?
>>>
>>>
>>> of course not.
>>> ns.inum is already exposed to user space as a value.
>>> This patch exposes it to bpf program in a convenient and stable way,
>>
>> Here's what I'm imaging Eric is thinking:
>>
>> ns.inum is currently exposed to userspace via procfs.  In principle,
>> the value could be local to a namespace, though, which would enable
>> CRIU to be able to preserve namespace inode numbers across a
>> checkpoint+restore operation.  If this happened, the contained and
>> restored procfs would see a different inode number than the outermost
>> procfs.
>
> sure. there are many different ways for the program to see inode
> that either was already reused or disappeared.
> What I'm saying that it is expected. We cannot prevent that from
> bpf side. Just like ifindex value read by the program can be bogus
> as in the example I just provided.

The point is that we can make the inode number stable across migration
and the user space API for namespaces has been designed with that
possibility in mind.

What you have proposed is the equivalent of reporting a file name, and
instead of reporting /dir1/file1 /dir2/file1 just reporting file1 for
both cases.

That is problematic.

It doesn't matter that eBPF and CRIU do not mix.  When we implement
migration of the namespace file descriptors and can move them from
one system to another preserving the device number and inode number
so that criu of other parts of userspace can function better there will
be a problem.  There is not one unique inode number per namespace and
the proposed interface in your eBPF programs is broken.

I don't know when inode numbers are going to be the bottleneck we decide
to make migratable to make CRIU work better but things have been
designed and maintained very carefully so that we can do that.

Inode numbers are in the namespace of the filesystem they reside in.

>> But you told Eric that his nack doesn't matter, and maybe it would be
>> nice to ask him to clarify instead.
>
> Fair enough. Eric, thoughts?

In very short terms exporting just the inode number would require
implementing a namespace of namespaces, and that is NOT happening.
We are not going to design our kernel interfaces so badly that we need
to do that.

At a bare minimum you need to export the device number of the filesystem
as well as the inode number.

My expectation would be that now you are starting to look at concepts
that are namespaced the way you would proceed would be to associate a
full set of namespaces with your ebpf program.  Those namespaces would
come from the submitter of your ebpf program.  Namespaced values
would be in the terms of your associated namespaces.

That keeps things working the way userspace would expect.

The easy way to build such an association is to not allow your
contextless ebpf programs from being submitted to kernel in anything
other than the initial set of namespaces.

But please assume all global identifiers are namespaced.  If they aren't
that needs to be fixed because not having them namespaced will break
process migration at some point.

In short the fix here is to export both the inode number the device
number.  That is what it takes to uniquely identify a file.  It would be
good if you went farther and limited your contextless ebpf programs to
only being installed by programs in the initial set of namespaces.

Does that make things clearer?

Eric
