From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Thu, 26 Jan 2017 10:32:55 -0800
Message-ID: <588A40D7.9070603@fb.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <87efzq8jbi.fsf@xmission.com> <588995DE.9040707@fb.com>
 <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
 <588A35F8.6050909@fb.com>
 <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:52193 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752817AbdAZSdY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:33:24 -0500
In-Reply-To: <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/26/17 10:12 AM, Andy Lutomirski wrote:
> On Thu, Jan 26, 2017 at 9:46 AM, Alexei Starovoitov <ast@fb.com> wrote:
>> On 1/26/17 8:37 AM, Andy Lutomirski wrote:
>>>>
>>>> Think of bpf programs as safe kernel modules. They don't have
>>>> confined boundaries and program authors, if not careful, can shoot
>>>> themselves in the foot. We're not trying to prevent that because
>>>> it's impossible to check that the program is sane. Just like
>>>> it's impossible to check that kernel module is sane.
>>>> But in case of bpf we check that bpf program is _safe_ from the kernel
>>>> point of view. If it's doing some garbage, it's program's business.
>>>> Does it make more sense now?
>>>>
>>>
>>> With all due respect, I think this is not an acceptable way to think
>>> about BPF at all.  If you think of BPF this way, I think there needs
>>> to be a real discussion at KS or similar as to whether this is okay.
>>> The reason is simple: the kernel promises a stable ABI to userspace
>>> but not to kernel modules.  By thinking of BPF as more like a module,
>>> you're taking a big shortcut that will either result in ABI breakage
>>> down the road or in committing to a problematic stable ABI.
>>
>>
>> you misunderstood the analogy.
>> bpf abi is certainly stable. that's why we were careful of not
>> exposing anything to it that is not already stable.
>>
>
> In that case I don't understand what you're trying to say.  Eric
> thinks your patch exposes a bad interface.  A bad interface for
> userspace is a very different thing from a bad interface available to
> kernel modules.  Are you saying that BPF is kernel-module-like in that
> the ABI exposed to BPF programs doesn't need to meet the same quality
> standards as userspace ABIs?

of course not.
ns.inum is already exposed to user space as a value.
This patch exposes it to bpf program in a convenient and stable way,
therefore I don't see why it's a big deal to you and Eric and why it
has anything to do with namespaces in general. It doesn't change
any existing behavior and doesn't impose any new restrictions.
Like ns.inum can be moved around. User space visible field
'netns_inum' is a shadow of kernel field. Only 'netns_inum'
has to be stable and that is my headache.

The kernel module analogy is an attempt to explain that programs
can do insane things.
Like the user can create a socket attach a program to it, change
netns, create another socket and attach the same program.
Inside the program it can do 'if (skb->ifindex == xxx)'.
This would be nonsensical program, since ifindex is obviously scoped
by netns and comparing ifindex without regard to netns is bogus.
But kernel cannot prevent users to write such programs.
Hence the kernel module analogy: the kernel cannot prevent
nonsensical modules.

With this patch the user will be able to do
if (skb->netns_inum == ... && skb->ifindex == ...)
which would be more sane thing to do, but without appropriate
control plane, it's also nonsensical, since netns inode and
dev ifindex can disappear while the program is running.
We obviously don't want to pin net_devices and netns-es for the program.
It would be debugging nightmare. Therefore the user has to write
the program understanding all this.
