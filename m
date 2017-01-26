From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Wed, 25 Jan 2017 22:23:26 -0800
Message-ID: <588995DE.9040707@fb.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <87efzq8jbi.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48346 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751605AbdAZGYD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 01:24:03 -0500
In-Reply-To: <87efzq8jbi.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/25/17 9:46 PM, Eric W. Biederman wrote:
> Alexei Starovoitov <ast@fb.com> writes:
>
>> in cases where bpf programs are looking at sockets and packets
>> that belong to different netns, it could be useful to read netns inode,
>> so that programs can make intelligent decisions.
>> For example to disallow raw sockets in all non-init netns the program can do:
>> if (sk->type == SOCK_RAW && sk->netns_inum != 0xf0000075)
>>    return 0;
>> where 0xf0000075 inode comes from /proc/pid/ns/net
>>
>> Similarly TC cls_bpf/act_bpf and socket filters can do
>> if (skb->netns_inum == expected_inode)
>
> Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

I very much value your opinion, but your ack or nack doesn't apply here.
Exposing existing inode has nothing to do with what you maintain.
It's a bpf feature that is exposing already visible to user space id.
Period.
If I was proposing to expose some internal namespace id, then yes,
we'd need to have a discussion. ns.inum is already visible.

> Particularly you need to compare more than the inode number.
> Further I have never guaranteed there will be exactly one inode
> per network namespace, just that if the device number and the inode
> number pair match they are the same.

people already rely on inodes for _all_ namespaces.
The current implementation of
net_ns_net_init->..>ida_get_new is stuck the way it is.
We can change ids, generation algorithm, but uniqueness is
already assumed by user space.

> Beyond that the entire concept is complete rubbish.

care to explain what you think the 'entire concept' is?

> The only sane thing is to interpret whatever your bpf program in the
> context of the program which installs it.

that's impossible. The programs are operating in the context that
is disjoined from the app that installs it.

> If you can't do that you have a very broken piece of userspace
> interface.  Which appears to be the case here.

Call it rubbish, but this is how it is.
cls_bpf is operating on packets. xdp_bpf is operating on raw dma buffers
and there we might need eventually lookup sockets and net namespaces.
Think of bpf programs as safe kernel modules. They don't have
confined boundaries and program authors, if not careful, can shoot
themselves in the foot. We're not trying to prevent that because
it's impossible to check that the program is sane. Just like
it's impossible to check that kernel module is sane.
But in case of bpf we check that bpf program is _safe_ from the kernel
point of view. If it's doing some garbage, it's program's business.
Does it make more sense now?
