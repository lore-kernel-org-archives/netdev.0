From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Thu, 26 Jan 2017 11:25:48 -0800
Message-ID: <588A4D3C.9070601@fb.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <87efzq8jbi.fsf@xmission.com> <588995DE.9040707@fb.com>
 <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
 <588A35F8.6050909@fb.com>
 <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
 <588A40D7.9070603@fb.com>
 <CALCETrXgdY_Kt8wn4uiATUnNJ3YXttCUREgEeQReG7u29Lc44g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Daniel Borkmann" <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        "Tejun Heo" <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50641 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753115AbdAZUOe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 15:14:34 -0500
In-Reply-To: <CALCETrXgdY_Kt8wn4uiATUnNJ3YXttCUREgEeQReG7u29Lc44g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/26/17 11:07 AM, Andy Lutomirski wrote:
> On Thu, Jan 26, 2017 at 10:32 AM, Alexei Starovoitov <ast@fb.com> wrote:
>> On 1/26/17 10:12 AM, Andy Lutomirski wrote:
>>>
>>> On Thu, Jan 26, 2017 at 9:46 AM, Alexei Starovoitov <ast@fb.com> wrote:
>>>>
>>>> On 1/26/17 8:37 AM, Andy Lutomirski wrote:
>>>>>>
>>>>>>
>>>>>> Think of bpf programs as safe kernel modules. They don't have
>>>>>> confined boundaries and program authors, if not careful, can shoot
>>>>>> themselves in the foot. We're not trying to prevent that because
>>>>>> it's impossible to check that the program is sane. Just like
>>>>>> it's impossible to check that kernel module is sane.
>>>>>> But in case of bpf we check that bpf program is _safe_ from the kernel
>>>>>> point of view. If it's doing some garbage, it's program's business.
>>>>>> Does it make more sense now?
>>>>>>
>>>>>
>>>>> With all due respect, I think this is not an acceptable way to think
>>>>> about BPF at all.  If you think of BPF this way, I think there needs
>>>>> to be a real discussion at KS or similar as to whether this is okay.
>>>>> The reason is simple: the kernel promises a stable ABI to userspace
>>>>> but not to kernel modules.  By thinking of BPF as more like a module,
>>>>> you're taking a big shortcut that will either result in ABI breakage
>>>>> down the road or in committing to a problematic stable ABI.
>>>>
>>>>
>>>>
>>>> you misunderstood the analogy.
>>>> bpf abi is certainly stable. that's why we were careful of not
>>>> exposing anything to it that is not already stable.
>>>>
>>>
>>> In that case I don't understand what you're trying to say.  Eric
>>> thinks your patch exposes a bad interface.  A bad interface for
>>> userspace is a very different thing from a bad interface available to
>>> kernel modules.  Are you saying that BPF is kernel-module-like in that
>>> the ABI exposed to BPF programs doesn't need to meet the same quality
>>> standards as userspace ABIs?
>>
>>
>> of course not.
>> ns.inum is already exposed to user space as a value.
>> This patch exposes it to bpf program in a convenient and stable way,
>
> Here's what I'm imaging Eric is thinking:
>
> ns.inum is currently exposed to userspace via procfs.  In principle,
> the value could be local to a namespace, though, which would enable
> CRIU to be able to preserve namespace inode numbers across a
> checkpoint+restore operation.  If this happened, the contained and
> restored procfs would see a different inode number than the outermost
> procfs.

sure. there are many different ways for the program to see inode
that either was already reused or disappeared.
What I'm saying that it is expected. We cannot prevent that from
bpf side. Just like ifindex value read by the program can be bogus
as in the example I just provided.

> If you start exposing the raw ns.inum field to BPF programs and those
> programs are not themselves scoped to a namespace, then this could
> create a problem for CRIU.

criu doesn't support ebpf because maps are not snapshot-able and
programs are detached from the control plane. I cannot see how one can
criu of xdp or cls program. The ssh connection to the box might die in
the middle while criu is messing with unknown. Hence the analogy to
the kernel modules. Imagine a set of mini-kernel modules and a set
of apps that depend on them. What kind of criu can we even talk about?

> But you told Eric that his nack doesn't matter, and maybe it would be
> nice to ask him to clarify instead.

Fair enough. Eric, thoughts?
