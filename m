From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Fri, 3 Feb 2017 15:06:28 -0800
Message-ID: <20170203230627.GB26227@ast-mbp.thefacebook.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <5894FC9B.8000108@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33226 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752268AbdBCXGi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:06:38 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so3078728pgd.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 15:06:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5894FC9B.8000108@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2017 at 10:56:43PM +0100, Daniel Borkmann wrote:
> On 01/26/2017 04:27 AM, Alexei Starovoitov wrote:
> >in cases where bpf programs are looking at sockets and packets
> >that belong to different netns, it could be useful to read netns inode,
> >so that programs can make intelligent decisions.
> >For example to disallow raw sockets in all non-init netns the program can do:
> >if (sk->type == SOCK_RAW && sk->netns_inum != 0xf0000075)
> >   return 0;
> >where 0xf0000075 inode comes from /proc/pid/ns/net
> >
> >Similarly TC cls_bpf/act_bpf and socket filters can do
> >if (skb->netns_inum == expected_inode)
> >
> >The lack of netns awareness was a concern even for socket filters,
> >since the application can attach the same bpf program to sockets
> >in a different netns. Just like tc cls_bpf program can work in
> >different netns as well, so it has to be addressed uniformly
> >across all types of bpf programs.
> 
> Sorry for jumping in late, but my question is, isn't this helper
> really only relevant for BPF_PROG_TYPE_CGROUP_* typed programs?
> Thus other prog types making use of bpf_convert_ctx_access()
> should probably reject that in .is_valid_access() callback?
> 
> Reason why I'm asking is that for sockets or tc progs, you
> already have a netns context where you're attached to, and f.e.
> skbs leaving that netns context will be orphaned. Thus, why
> would tc or sock filter tailor a program with such a check,
> if it can only match/mismatch its own netns inum eventually?

Please see the example I provided earlier.
We can have the same cls_bpf attached to all netns-es.
Same for socket filters and everything else.
All bpf programs are global.
They can all share info via maps and so on.

> When making this effort to lookup and hardcode the dev/inode
> num into the prog, wouldn't it be easier for these types if

we cannot hardcode dev/inode. They are dynamic and depends
where program runs.
I'll send a patch shortly that exposes both.
