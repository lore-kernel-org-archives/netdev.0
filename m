From: Tommi Rantala <tt.rantala@gmail.com>
Subject: Re: ipv6 && kernel BUG at net/core/skbuff.c:126!
Date: Sun, 9 Jun 2013 09:36:10 +0300
Message-ID: <CA+ydwtp2w3OS+NotDaTfFSvJ+39_2pii0V3BqWwTeZT4tKdJjg@mail.gmail.com>
References: <CA+ydwtpiZ7Z3bEWZxnM4BVxo_fvX5JXO=0zqqpobsCgm4jdwRQ@mail.gmail.com>
	<51B25559.20404@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B25559.20404@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/6/8 Brian Haley <brian.haley@hp.com>:
> On 06/07/2013 02:33 PM, Tommi Rantala wrote:
>> Hello,
>>
>> Hit this while fuzzing v3.10-rc4-214-g1612e11 (plus a one-liner
>> af_netlink patch from Patrick McHardy, that I hope is not related to
>> this bug).
>>
>> Tommi
>
>> [19491.615447] Call Trace:
>> [19491.616273]  [<ffffffff81eb6243>] skb_push+0x33/0x40
>> [19491.617840]  [<ffffffff81fc402c>] ip6_push_pending_frames+0x20c/0x4b0
>> [19491.619768]  [<ffffffff81119c55>] ? local_bh_enable+0xc5/0xf0
>> [19491.621476]  [<ffffffff81fdf650>] udp_v6_push_pending_frames+0x390/0x3a0
>> [19491.623475]  [<ffffffff81119c55>] ? local_bh_enable+0xc5/0xf0
>> [19491.625236]  [<ffffffff81fdf2c0>] ? compat_udpv6_setsockopt+0x30/0x30
>> [19491.627153]  [<ffffffff81f60812>] udp_lib_setsockopt+0xc2/0x1d0
>> [19491.628965]  [<ffffffff81fdf67d>] udpv6_setsockopt+0x1d/0x30
>> [19491.630674]  [<ffffffff81eb33bf>] sock_common_setsockopt+0xf/0x20
>> [19491.632577]  [<ffffffff81ead7e6>] SyS_setsockopt+0x96/0xe0
>> [19491.634376]  [<ffffffff822a47a9>] system_call_fastpath+0x16/0x1b
>
> Does something as simple below crash?  It at least tickles the code path from
> what I can tell.

Nope, no visible effect.

# strace ./i
execve("./i", ["./i"], [/* 14 vars */]) = 0
[...]
socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 3
setsockopt(3, SOL_UDP, 1, [1], 4)       = 0
sendto(3, "1234546789", 10, 0, {sa_family=AF_INET6,
sin6_port=htons(1234), inet_pton(AF_INET6, "::", &sin6_addr),
sin6_flowinfo=0, sin6_scope_id=0}, 28) = 10
setsockopt(3, SOL_UDP, 1, [0], 4)       = 0
close(3)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++


> -Brian
>
>
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <errno.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <netinet/udp.h>
>
> main()
> {
>         int s, cork, err, flags = 0;
>         struct sockaddr_in6 sin6 = {0};
>         char *buf = "1234546789";
>
>         s = socket(AF_INET6, SOCK_DGRAM, 0);
>         if (s < 0) {
>                 perror("socket");
>                 exit(1);
>         }
>
>         cork = 1;
>         err = setsockopt(s, SOL_UDP, UDP_CORK, &cork, sizeof(cork));
>         if (err < 0) {
>                 perror("setsockopt");
>                 goto out;
>         }
>
>         sin6.sin6_family = AF_INET6;
>         sin6.sin6_port = htons(1234);
>         err = sendto(s, buf, strlen(buf), flags,
>                         (const struct sockaddr *)&sin6,
>                         sizeof(sin6));
>         if (err < 0) {
>                 perror("sendto");
>                 goto out;
>         }
>
>         cork = 0;
>         err = setsockopt(s, SOL_UDP, UDP_CORK, &cork, sizeof(cork));
>         if (err < 0)
>                 perror("setsockopt");
>
> out:
>         close(s);
>         exit(0);
> }
