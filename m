From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Fri, 03 Feb 2017 22:56:43 +0100
Message-ID: <5894FC9B.8000108@iogearbox.net>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>, Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45050 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752441AbdBCV5P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:57:15 -0500
In-Reply-To: <1485401274-2836524-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2017 04:27 AM, Alexei Starovoitov wrote:
> in cases where bpf programs are looking at sockets and packets
> that belong to different netns, it could be useful to read netns inode,
> so that programs can make intelligent decisions.
> For example to disallow raw sockets in all non-init netns the program can do:
> if (sk->type == SOCK_RAW && sk->netns_inum != 0xf0000075)
>    return 0;
> where 0xf0000075 inode comes from /proc/pid/ns/net
>
> Similarly TC cls_bpf/act_bpf and socket filters can do
> if (skb->netns_inum == expected_inode)
>
> The lack of netns awareness was a concern even for socket filters,
> since the application can attach the same bpf program to sockets
> in a different netns. Just like tc cls_bpf program can work in
> different netns as well, so it has to be addressed uniformly
> across all types of bpf programs.

Sorry for jumping in late, but my question is, isn't this helper
really only relevant for BPF_PROG_TYPE_CGROUP_* typed programs?
Thus other prog types making use of bpf_convert_ctx_access()
should probably reject that in .is_valid_access() callback?

Reason why I'm asking is that for sockets or tc progs, you
already have a netns context where you're attached to, and f.e.
skbs leaving that netns context will be orphaned. Thus, why
would tc or sock filter tailor a program with such a check,
if it can only match/mismatch its own netns inum eventually?
When making this effort to lookup and hardcode the dev/inode
num into the prog, wouldn't it be easier for these types if
the managing app that loads these progs tailors the progs for
a given netns directly, so also such runtime check can generally
be avoided? Am I missing something wrt 'concerns'? The cgroup
ones are global, so there I can see that it could be used in
some way f.e. to restrict access, account, etc.

Thanks,
Daniel
