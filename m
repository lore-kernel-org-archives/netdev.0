From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v3 net] bpf: add bpf_sk_netns_id() helper
Date: Sun, 5 Feb 2017 12:19:16 -0800
Message-ID: <CALCETrWS4_NOL_MZFX=hK+RDaYaVyq-danMU3DY6BZ98SN_5dQ@mail.gmail.com>
References: <1486179240-3574802-1-git-send-email-ast@fb.com> <92c34d0c-ec60-a44d-6542-00fde5aad082@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tejun Heo <tj@kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Network Development <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:34900 "EHLO
        mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753181AbdBEUTn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 15:19:43 -0500
Received: by mail-vk0-f43.google.com with SMTP id x75so44429911vke.2
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 12:19:38 -0800 (PST)
In-Reply-To: <92c34d0c-ec60-a44d-6542-00fde5aad082@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 5, 2017 at 11:24 AM, David Ahern <dsa@cumulusnetworks.com> wrot=
e:
> On 2/3/17 8:34 PM, Alexei Starovoitov wrote:
>> Therefore introduce 'u64 bpf_sk_netns_id(sk);' helper. It returns
>> unique value that identifies netns of given socket or dev_net(skb->dev)
>> The upper 32-bits of the return value contain device id where namespace
>> filesystem resides and lower 32-bits contain inode number within that fi=
lesystem.
>> It's the same as
>>  struct stat st;
>>  stat("/proc/pid/ns/net", &st);
>>  return (st->st_dev << 32)  | st->st_ino;
>>
> ...
>
>> can be considered a new feature, whereas for cgroup_sock
>> programs that modify sk->bound_dev_if (like 'ip vrf' does)
>> it's a bug fix, since 'ip vrf' needs to be netns aware.
>>
>
>
> LGTM.
>
> Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
> Tested-by: David Ahern <dsa@cumulusnetworks.com>
>
> Updated patches for vrf in network namespaces are here:
>     https://github.com/dsahern/iproute2 vrf/ip-vrf
>
>
> root@kenny-jessie2:~# ip vrf exec red bash
>
> root@kenny-jessie2:red:~# ping -c1 -w1 10.100.1.254
> PING 10.100.1.254 (10.100.1.254) 56(84) bytes of data.
> 64 bytes from 10.100.1.254: icmp_seq=3D1 ttl=3D64 time=3D0.230 ms
>
> --- 10.100.1.254 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev =3D 0.230/0.230/0.230/0.000 ms
>
> root@kenny-jessie2:red:~# unshare -n
>
> root@kenny-jessie2:red:~# ping -c1 -w1 10.100.1.254
> connect: Network is unreachable
>
>
> Andy: thank you for the feedback on the 'ip vrf' use case. I believe this=
 kernel patch + my iproute2 patches address the issues mentioned so far. Sp=
ecifically, the transcript above shows your concern about 'unshare -n' case=
 is handled. In one of the many responses last night, you mentioned I have =
'a somewhat kludgey fix that gets the "ip netns" case'. If you can elaborat=
e on 'somewhat kludgey', I can fix those this week as well.

What I meant was: fixing it in iproute2 without kernel changes would
be kludgey and incomplete.  You seem to have fixed it by depending on
this kernel patch.

--Andy
