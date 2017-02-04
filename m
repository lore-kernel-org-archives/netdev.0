From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Sat, 4 Feb 2017 09:08:38 -0800
Message-ID: <CALCETrVnGP3DBAWQGFDXyXsN+tq+sSF+zirp4yPgiBo42qzV-g@mail.gmail.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <5894FC9B.8000108@iogearbox.net> <20170203230627.GB26227@ast-mbp.thefacebook.com>
 <58951567.1030401@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:35908 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdBDRJA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 12:09:00 -0500
Received: by mail-vk0-f45.google.com with SMTP id t8so32478408vke.3
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 09:09:00 -0800 (PST)
In-Reply-To: <58951567.1030401@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 3:42 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 02/04/2017 12:06 AM, Alexei Starovoitov wrote:
>>
>> On Fri, Feb 03, 2017 at 10:56:43PM +0100, Daniel Borkmann wrote:
>>>
>>> On 01/26/2017 04:27 AM, Alexei Starovoitov wrote:
>>>>
>>>> in cases where bpf programs are looking at sockets and packets
>>>> that belong to different netns, it could be useful to read netns inode,
>>>> so that programs can make intelligent decisions.
>>>> For example to disallow raw sockets in all non-init netns the program
>>>> can do:
>>>> if (sk->type == SOCK_RAW && sk->netns_inum != 0xf0000075)
>>>>    return 0;
>>>> where 0xf0000075 inode comes from /proc/pid/ns/net
>>>>
>>>> Similarly TC cls_bpf/act_bpf and socket filters can do
>>>> if (skb->netns_inum == expected_inode)
>>>>
>>>> The lack of netns awareness was a concern even for socket filters,
>>>> since the application can attach the same bpf program to sockets
>>>> in a different netns. Just like tc cls_bpf program can work in
>>>> different netns as well, so it has to be addressed uniformly
>>>> across all types of bpf programs.
>>>
>>>
>>> Sorry for jumping in late, but my question is, isn't this helper
>>> really only relevant for BPF_PROG_TYPE_CGROUP_* typed programs?
>>> Thus other prog types making use of bpf_convert_ctx_access()
>>> should probably reject that in .is_valid_access() callback?
>>>
>>> Reason why I'm asking is that for sockets or tc progs, you
>>> already have a netns context where you're attached to, and f.e.
>>> skbs leaving that netns context will be orphaned. Thus, why
>>> would tc or sock filter tailor a program with such a check,
>>> if it can only match/mismatch its own netns inum eventually?
>>
>>
>> Please see the example I provided earlier.
>
>
> That example for both socket filter and tc progs specifically
> wasn't quite clear to me, hence my question wrt why it's right
> now a "concern" for these ones. (Again, clear to me for cgroups
> progs.)
>
>> We can have the same cls_bpf attached to all netns-es.
>> Same for socket filters and everything else.
>
>
> So use-case would be that someone wants to attach the very same
> prog via tc to various netdevs sitting in different netns, and
> that prog looks up a map, controlled by initns, with skb->netns_inum
> as key and the resulting value could contain allowed feature bits
> for that specific netns prog the skbs goes through? That would be
> a feature, not "concern", no? At the same time, it's up to the
> user or mgmt app what gets loaded so f.e. it might just as well
> tailor/optimize the progs individually for the devs sitting in
> netns-es to avoid such map lookup.

Agreed.  I don't see why you would install the exact same program on
two sockets in different netnses if the program contains, say, an
ifindex.  Why not just install a variant with the right ifindex into
each socket?
