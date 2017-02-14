From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v4 net] bpf: add bpf_sk_netns_id() helper
Date: Tue, 14 Feb 2017 20:21:09 +1300
Message-ID: <87h93xqlui.fsf@xmission.com>
References: <1486432968-3255218-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48036 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751937AbdBNHZp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 02:25:45 -0500
In-Reply-To: <1486432968-3255218-1-git-send-email-ast@fb.com> (Alexei
        Starovoitov's message of "Mon, 6 Feb 2017 18:02:48 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <ast@fb.com> writes:

> in cases where bpf programs are looking at sockets and packets
> that belong to different netns, it could be useful to get an id
> that uniquely identify a netns within the whole system.

It could be useful but there is no unique namespace id.

> Therefore introduce 'u64 bpf_sk_netns_id(sk);' helper. It returns
> unique value that identifies netns of given socket or dev_net(skb->dev)
> The upper 32-bits of the return value contain device id where namespace
> filesystem resides and lower 32-bits contain inode number within that filesystem.
> It's the same as
>  struct stat st;
>  stat("/proc/pid/ns/net", &st);
>  return (st->st_dev << 32)  | st->st_ino;

The function is fundamentally buggy.  Inode numbers are 64bit and need
to be 64bit whenever we expose them to userspace.  Otherwise we are
painting ourselves into a corner with respect to future expansion.

> For example to disallow raw sockets in all non-init netns
> the bpf_type_cgroup_sock program can do:
> if (sk->type == SOCK_RAW && bpf_sk_netns_id(sk) != 0x3f0000075)
>   return 0;
> where 0x3f0000075 comes from combination of st_dev and st_ino
> of /proc/pid/ns/net

Which is generally a reasonable type of thing to do.

However if we make the logic look like:

if (sk->type == SOCK_RAW && bpf_sk_net(sk, 0x3f, 0x75))
	return 0;

With the comparison in the function call itself.  That will solve the
32 vs 64bit inode number issue as well putting the burden on matching
what userspace sees to what the kernel sees to the kernel.  Which
is much more future proof.

I suspect the bpf verifier can even be enhanced to check that the last
two arguments are constants.  Limiting the device number and inode
number to constants will make further optimizations/simplifcations
possible.   But that is just a nice to have.

But the key thing here is that if we pass the device number and the
inode to the kernel and ask it to compare, the kernel can lookup up the
namespace by device+inode and see if it matches what is on the socket
without any need for that to be a unique name of the network namespace
which is 1000 times more maintainable then returning a magic string.

Which means even if all we do in kernel churn is go back to the
implementation that existed a little while ago where the device number
depended upon which mount of proc you looked at, the bpf filters written
today can all be made to work with any challenge.

Does that make sense?

Eric
