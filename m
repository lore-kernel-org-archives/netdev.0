From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 net] bpf: add bpf_sk_netns_id() helper
Date: Sun, 5 Feb 2017 12:24:58 -0700
Message-ID: <92c34d0c-ec60-a44d-6542-00fde5aad082@cumulusnetworks.com>
References: <1486179240-3574802-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35852 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753221AbdBETZG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 14:25:06 -0500
Received: by mail-pf0-f179.google.com with SMTP id 189so18030631pfu.3
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 11:25:05 -0800 (PST)
In-Reply-To: <1486179240-3574802-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/3/17 8:34 PM, Alexei Starovoitov wrote:
> Therefore introduce 'u64 bpf_sk_netns_id(sk);' helper. It returns
> unique value that identifies netns of given socket or dev_net(skb->dev)
> The upper 32-bits of the return value contain device id where namespace
> filesystem resides and lower 32-bits contain inode number within that filesystem.
> It's the same as
>  struct stat st;
>  stat("/proc/pid/ns/net", &st);
>  return (st->st_dev << 32)  | st->st_ino;
> 
...

> can be considered a new feature, whereas for cgroup_sock
> programs that modify sk->bound_dev_if (like 'ip vrf' does)
> it's a bug fix, since 'ip vrf' needs to be netns aware.
> 


LGTM.

Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
Tested-by: David Ahern <dsa@cumulusnetworks.com>

Updated patches for vrf in network namespaces are here:
    https://github.com/dsahern/iproute2 vrf/ip-vrf


root@kenny-jessie2:~# ip vrf exec red bash

root@kenny-jessie2:red:~# ping -c1 -w1 10.100.1.254
PING 10.100.1.254 (10.100.1.254) 56(84) bytes of data.
64 bytes from 10.100.1.254: icmp_seq=1 ttl=64 time=0.230 ms

--- 10.100.1.254 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.230/0.230/0.230/0.000 ms

root@kenny-jessie2:red:~# unshare -n

root@kenny-jessie2:red:~# ping -c1 -w1 10.100.1.254
connect: Network is unreachable


Andy: thank you for the feedback on the 'ip vrf' use case. I believe this kernel patch + my iproute2 patches address the issues mentioned so far. Specifically, the transcript above shows your concern about 'unshare -n' case is handled. In one of the many responses last night, you mentioned I have 'a somewhat kludgey fix that gets the "ip netns" case'. If you can elaborate on 'somewhat kludgey', I can fix those this week as well.
