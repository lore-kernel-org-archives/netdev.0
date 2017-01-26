From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Thu, 26 Jan 2017 08:37:30 -0800
Message-ID: <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <87efzq8jbi.fsf@xmission.com> <588995DE.9040707@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:35104 "EHLO
        mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753629AbdAZQp1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 11:45:27 -0500
Received: by mail-vk0-f49.google.com with SMTP id x75so158281225vke.2
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 08:45:13 -0800 (PST)
In-Reply-To: <588995DE.9040707@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus-

Can you weigh in here before we get stuck in a potentially unfortunate place?

On Wed, Jan 25, 2017 at 10:23 PM, Alexei Starovoitov <ast@fb.com> wrote:
> On 1/25/17 9:46 PM, Eric W. Biederman wrote:
>>
>> Alexei Starovoitov <ast@fb.com> writes:
>>

[...]

>>> Similarly TC cls_bpf/act_bpf and socket filters can do
>>> if (skb->netns_inum == expected_inode)
>>
>>
>> Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
>
> I very much value your opinion, but your ack or nack doesn't apply here.

I'm confused.  Eric, the namespace maintainer, says nack.  This is
namespace code regardless of what file it lives in.

>> The only sane thing is to interpret whatever your bpf program in the
>> context of the program which installs it.
>
>
> that's impossible. The programs are operating in the context that
> is disjoined from the app that installs it.
>
>> If you can't do that you have a very broken piece of userspace
>> interface.  Which appears to be the case here.
>
>
> Call it rubbish, but this is how it is.
> cls_bpf is operating on packets. xdp_bpf is operating on raw dma buffers
> and there we might need eventually lookup sockets and net namespaces.
> Think of bpf programs as safe kernel modules. They don't have
> confined boundaries and program authors, if not careful, can shoot
> themselves in the foot. We're not trying to prevent that because
> it's impossible to check that the program is sane. Just like
> it's impossible to check that kernel module is sane.
> But in case of bpf we check that bpf program is _safe_ from the kernel
> point of view. If it's doing some garbage, it's program's business.
> Does it make more sense now?
>

With all due respect, I think this is not an acceptable way to think
about BPF at all.  If you think of BPF this way, I think there needs
to be a real discussion at KS or similar as to whether this is okay.
The reason is simple: the kernel promises a stable ABI to userspace
but not to kernel modules.  By thinking of BPF as more like a module,
you're taking a big shortcut that will either result in ABI breakage
down the road or in committing to a problematic stable ABI.

In fact, this was discussed a bit at KS in the context of tracepoints.
The general consensus seemed to be that tracepoints should not be
considered fully stable in large part because they're a debugging
feature.  But these BPF hooks are very much not a debugging feature.

Concretely, iproute2 git contains an eBPF program.  If that program
were just a "safe kernel module", then it would be totally fine
(expected, even) for future kernel versions to break it outright.  I
don't think this is how it works.

--Andy
