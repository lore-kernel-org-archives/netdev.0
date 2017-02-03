From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Fri, 3 Feb 2017 13:00:47 -0800
Message-ID: <CALCETrWDxVHc4_hpjLQRj-XbvGX0+tbGZ8o388-xn6rNcQTySQ@mail.gmail.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <87efzq8jbi.fsf@xmission.com> <588995DE.9040707@fb.com> <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
 <588A35F8.6050909@fb.com> <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
 <588A40D7.9070603@fb.com> <CALCETrXgdY_Kt8wn4uiATUnNJ3YXttCUREgEeQReG7u29Lc44g@mail.gmail.com>
 <588A4D3C.9070601@fb.com> <87r33fevva.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@fb.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:35820 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752349AbdBCVBJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:01:09 -0500
Received: by mail-ua0-f180.google.com with SMTP id y9so22857142uae.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 13:01:09 -0800 (PST)
In-Reply-To: <87r33fevva.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 8:33 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Alexei Starovoitov <ast@fb.com> writes:
>
>> On 1/26/17 11:07 AM, Andy Lutomirski wrote:
>>> On Thu, Jan 26, 2017 at 10:32 AM, Alexei Starovoitov <ast@fb.com> wrote:
>>>> On 1/26/17 10:12 AM, Andy Lutomirski wrote:
>>>>>
>>>>> On Thu, Jan 26, 2017 at 9:46 AM, Alexei Starovoitov <ast@fb.com> wrote:
>>>>>>
>>>>>> On 1/26/17 8:37 AM, Andy Lutomirski wrote:
>>>>>>>>
>>>>>>>>
>>>>>>>> Think of bpf programs as safe kernel modules. They don't have
>>>>>>>> confined boundaries and program authors, if not careful, can shoot
>>>>>>>> themselves in the foot. We're not trying to prevent that because
>>>>>>>> it's impossible to check that the program is sane. Just like
>>>>>>>> it's impossible to check that kernel module is sane.
>>>>>>>> But in case of bpf we check that bpf program is _safe_ from the kernel
>>>>>>>> point of view. If it's doing some garbage, it's program's business.
>>>>>>>> Does it make more sense now?
>>>>>>>>
>>>>>>>
>>>>>>> With all due respect, I think this is not an acceptable way to think
>>>>>>> about BPF at all.  If you think of BPF this way, I think there needs
>>>>>>> to be a real discussion at KS or similar as to whether this is okay.
>>>>>>> The reason is simple: the kernel promises a stable ABI to userspace
>>>>>>> but not to kernel modules.  By thinking of BPF as more like a module,
>>>>>>> you're taking a big shortcut that will either result in ABI breakage
>>>>>>> down the road or in committing to a problematic stable ABI.
>>>>>>
>>>>>>
>>>>>>
>>>>>> you misunderstood the analogy.
>>>>>> bpf abi is certainly stable. that's why we were careful of not
>>>>>> exposing anything to it that is not already stable.
>>>>>>
>>>>>
>>>>> In that case I don't understand what you're trying to say.  Eric
>>>>> thinks your patch exposes a bad interface.  A bad interface for
>>>>> userspace is a very different thing from a bad interface available to
>>>>> kernel modules.  Are you saying that BPF is kernel-module-like in that
>>>>> the ABI exposed to BPF programs doesn't need to meet the same quality
>>>>> standards as userspace ABIs?
>>>>
>>>>
>>>> of course not.
>>>> ns.inum is already exposed to user space as a value.
>>>> This patch exposes it to bpf program in a convenient and stable way,
>>>
>>> Here's what I'm imaging Eric is thinking:
>>>
>>> ns.inum is currently exposed to userspace via procfs.  In principle,
>>> the value could be local to a namespace, though, which would enable
>>> CRIU to be able to preserve namespace inode numbers across a
>>> checkpoint+restore operation.  If this happened, the contained and
>>> restored procfs would see a different inode number than the outermost
>>> procfs.
>>
>> sure. there are many different ways for the program to see inode
>> that either was already reused or disappeared.
>> What I'm saying that it is expected. We cannot prevent that from
>> bpf side. Just like ifindex value read by the program can be bogus
>> as in the example I just provided.
>
> The point is that we can make the inode number stable across migration
> and the user space API for namespaces has been designed with that
> possibility in mind.

How does it help if BPF starts exposing both inode number and device number?

ISTM any ability to migrate namespaces and to migrate eBPF programs
that know about namespaces needs to have the eBPF program firmly
rooted in some namespace (or perhaps cgroup in this case) so that it
can see a namespaced view of the world.  For this to work, presumably
we need to make sure that eBPF programs that are installed by programs
that are in a container don't see traffic that isn't in that
container.  This is part of why I think that we should consider
preventing programs that aren't in the root namespace (perhaps *all*
the root namespaces) from installing bpf+cgroup programs in the first
place until there's a clearer understanding of how this all fits
together.
