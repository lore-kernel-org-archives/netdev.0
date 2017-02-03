From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Sat, 04 Feb 2017 00:42:31 +0100
Message-ID: <58951567.1030401@iogearbox.net>
References: <1485401274-2836524-1-git-send-email-ast@fb.com> <5894FC9B.8000108@iogearbox.net> <20170203230627.GB26227@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58803 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752825AbdBCXmm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:42:42 -0500
In-Reply-To: <20170203230627.GB26227@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2017 12:06 AM, Alexei Starovoitov wrote:
> On Fri, Feb 03, 2017 at 10:56:43PM +0100, Daniel Borkmann wrote:
>> On 01/26/2017 04:27 AM, Alexei Starovoitov wrote:
>>> in cases where bpf programs are looking at sockets and packets
>>> that belong to different netns, it could be useful to read netns inode,
>>> so that programs can make intelligent decisions.
>>> For example to disallow raw sockets in all non-init netns the program can do:
>>> if (sk->type == SOCK_RAW && sk->netns_inum != 0xf0000075)
>>>    return 0;
>>> where 0xf0000075 inode comes from /proc/pid/ns/net
>>>
>>> Similarly TC cls_bpf/act_bpf and socket filters can do
>>> if (skb->netns_inum == expected_inode)
>>>
>>> The lack of netns awareness was a concern even for socket filters,
>>> since the application can attach the same bpf program to sockets
>>> in a different netns. Just like tc cls_bpf program can work in
>>> different netns as well, so it has to be addressed uniformly
>>> across all types of bpf programs.
>>
>> Sorry for jumping in late, but my question is, isn't this helper
>> really only relevant for BPF_PROG_TYPE_CGROUP_* typed programs?
>> Thus other prog types making use of bpf_convert_ctx_access()
>> should probably reject that in .is_valid_access() callback?
>>
>> Reason why I'm asking is that for sockets or tc progs, you
>> already have a netns context where you're attached to, and f.e.
>> skbs leaving that netns context will be orphaned. Thus, why
>> would tc or sock filter tailor a program with such a check,
>> if it can only match/mismatch its own netns inum eventually?
>
> Please see the example I provided earlier.

That example for both socket filter and tc progs specifically
wasn't quite clear to me, hence my question wrt why it's right
now a "concern" for these ones. (Again, clear to me for cgroups
progs.)

> We can have the same cls_bpf attached to all netns-es.
> Same for socket filters and everything else.

So use-case would be that someone wants to attach the very same
prog via tc to various netdevs sitting in different netns, and
that prog looks up a map, controlled by initns, with skb->netns_inum
as key and the resulting value could contain allowed feature bits
for that specific netns prog the skbs goes through? That would be
a feature, not "concern", no? At the same time, it's up to the
user or mgmt app what gets loaded so f.e. it might just as well
tailor/optimize the progs individually for the devs sitting in
netns-es to avoid such map lookup.

> All bpf programs are global.

True, but for socket filter and tc they are hooked/attached under
a given netns context.

> They can all share info via maps and so on.

>> When making this effort to lookup and hardcode the dev/inode
>> num into the prog, wouldn't it be easier for these types if
>
> we cannot hardcode dev/inode. They are dynamic and depends
> where program runs.

Was referring to the test from above provided example:

 >>> if (skb->netns_inum == expected_inode)

> I'll send a patch shortly that exposes both.

Thanks,
Daniel
