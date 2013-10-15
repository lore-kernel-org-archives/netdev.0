From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: kernel policy routing table src ip not respected since 2.6.37 and
 commit 9fc3bbb4a752
Date: Tue, 15 Oct 2013 09:02:32 -0700
Message-ID: <CAK3+h2w13isZEOurBMv57L0H_pkqMdYmPaNE3Kn5vPxfqErOMw@mail.gmail.com>
References: <CAK3+h2zGFnbC-hpPB8fPX7TC3rKCWbPYVY4WW4HDYbN+LXNXXw@mail.gmail.com>
	<alpine.LFD.2.03.1310151144580.1562@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joel Sing <jsing@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:51554 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759169Ab3JOQCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 12:02:33 -0400
Received: by mail-oa0-f50.google.com with SMTP id j1so6080736oag.9
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 09:02:32 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.03.1310151144580.1562@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks for the clue, the arp indeed is from 10.1.1.2 in my test and i
made 10.1.1.9 ip reachable and tcpdump on 10.1.1.9 indeed show
sourcing from ip 10.1.1.2:

08:48:41.576588 IP 10.1.1.2 > 10.1.1.9: ICMP echo request, id 6972,
seq 1, length 64
08:48:41.576614 IP 10.1.1.9 > 10.1.1.2: ICMP echo reply, id 6972, seq
1, length 64
08:48:42.576909 IP 10.1.1.2 > 10.1.1.9: ICMP echo request, id 6972,
seq 2, length 64
08:48:42.576932 IP 10.1.1.9 > 10.1.1.2: ICMP echo reply, id 6972, seq
2, length 64

it is strange though when 10.1.1.9 is unreachable address and the ping
utility reports error 'Destination Host Unreachable' with source
10.1.1.1.  before 2.6.37, it reports 10.1.1..2

the ping utility is standard ping command from centos6.4 and I am
running centos6.4 on KVM, here is strace

socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
connect(4, {sa_family=AF_INET, sin_port=htons(1025),
sin_addr=inet_addr("10.1.1.9")}, 16) = 0
getsockname(4, {sa_family=AF_INET, sin_port=htons(49991),
sin_addr=inet_addr("10.1.1.2")}, [16]) = 0
close(4)                                = 0
setsockopt(3, SOL_RAW, ICMP_FILTER,
~(ICMP_ECHOREPLY|ICMP_DEST_UNREACH|ICMP_SOURCE_QUENCH|ICMP_REDIRECT|ICMP_TIME_EXCEEDED|ICMP_PARAMETERPROB),
4) = 0
setsockopt(3, SOL_IP, IP_RECVERR, [1], 4) = 0
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [324], 4) = 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [65536], 4) = 0
getsockopt(3, SOL_SOCKET, SO_RCVBUF, [4851439803083915264], [4]) = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 1), ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7f0b4332e000
write(1, "PING 10.1.1.9 (10.1.1.9) 56(84) "..., 47PING 10.1.1.9
(10.1.1.9) 56(84) bytes of data.
) = 47
setsockopt(3, SOL_SOCKET, SO_TIMESTAMP, [1], 4) = 0
setsockopt(3, SOL_SOCKET, SO_SNDTIMEO,
"\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
setsockopt(3, SOL_SOCKET, SO_RCVTIMEO,
"\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
getpid()                                = 15633
rt_sigaction(SIGINT, {0x7f0b43337a40, [], SA_RESTORER|SA_INTERRUPT,
0x7f0b42b7e920}, NULL, 8) = 0
rt_sigaction(SIGALRM, {0x7f0b43337a40, [], SA_RESTORER|SA_INTERRUPT,
0x7f0b42b7e920}, NULL, 8) = 0
rt_sigaction(SIGQUIT, {0x7f0b43337a50, [], SA_RESTORER|SA_INTERRUPT,
0x7f0b42b7e920}, NULL, 8) = 0
gettimeofday({1381852599, 797511}, NULL) = 0
ioctl(1, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}) = 0
ioctl(1, TIOCGWINSZ, {ws_row=71, ws_col=158, ws_xpixel=0, ws_ypixel=0}) = 0
gettimeofday({1381852599, 797672}, NULL) = 0
gettimeofday({1381852599, 797708}, NULL) = 0
sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0),
sin_addr=inet_addr("10.1.1.9")},
msg_iov(1)=[{"\10\0\373\n\21=\0\1\267e]R\0\0\0\0\f,\f\0\0\0\0\0\20\21\22\23\24\25\26\27"...,
64}], msg_controllen=0, msg_flags=0}, 0) = 64
setitimer(ITIMER_REAL, {it_interval={0, 0}, it_value={10, 0}}, NULL) = 0
recvmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0),
sin_addr=inet_addr("127.0.0.1")},
msg_iov(1)=[{"E\300\0D\237\210\0\0@\1\334n\177\0\0\1\177\0\0\1\3\3v9\0\0\0\0E\0\0("...,
192}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_SOCKET,
cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, 0) = 68
setsockopt(3, SOL_SOCKET, SO_ATTACH_FILTER,
"\10\0\0\0\0\0\0\0\300\305SC\v\177\0\0", 16) = 0
recvmsg(3, 0x7fffccde57b0, MSG_DONTWAIT) = -1 EAGAIN (Resource
temporarily unavailable)
recvmsg(3, 0x7fffccde57b0, 0)           = -1 EAGAIN (Resource
temporarily unavailable)
recvmsg(3, 0x7fffccde57b0, 0)           = -1 EAGAIN (Resource
temporarily unavailable)
recvmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0),
sin_addr=inet_addr("10.1.1.1")},
msg_iov(1)=[{"E\300\0pd{\0\0@\1\377M\n\1\1\1\n\1\1\2\3\1\374\376\0\0\0\0E\0\0T"...,
192}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_SOCKET,
cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, 0) = 112
recvmsg(3, 0x7fffccde57b0, 0)           = -1 EHOSTUNREACH (No route to host)
recvmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0),
sin_addr=inet_addr("10.1.1.9")}, msg_iov(1)=[{"\10\0\373\n\21=\0\1",
8}], msg_controllen=80, {cmsg_len=32, cmsg_level=SOL_SOCKET,
cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=MSG_TRUNC|MSG_ERRQUEUE},
MSG_ERRQUEUE|MSG_DONTWAIT) = 8
setsockopt(3, SOL_RAW, ICMP_FILTER,
~(ICMP_ECHOREPLY|ICMP_SOURCE_QUENCH|ICMP_REDIRECT), 4) = 0
write(1, "From 10.1.1.1 icmp_seq=1 Destina"..., 54From 10.1.1.1
icmp_seq=1 Destination Host Unreachable
) = 54
gettimeofday({1381852602, 805123}, NULL) = 0
write(1, "\n", 1
)                       = 1
write(1, "--- 10.1.1.9 ping statistics ---"..., 33--- 10.1.1.9 ping
statistics ---
) = 33
write(1, "1 packets transmitted, 0 receive"..., 761 packets
transmitted, 0 received, +1 errors, 100% packet loss, time 3007ms
) = 76
write(1, "\n", 1
)                       = 1
exit_group(1)                           = ?


I

On Tue, Oct 15, 2013 at 1:51 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Mon, 14 Oct 2013, Vincent Li wrote:
>
>> I had a simple bash script to test if the policy routing table src ip
>> is respected or not, git bisect found the  commit 9fc3bbb4a752 to
>> change the policy routing table source ip behavior.
>>
>> commit 9fc3bbb4a752f108cf096d96640f3b548bbbce6c
>> Author: Joel Sing <jsing@google.com>
>> Date:   Mon Jan 3 20:24:20 2011 +0000
>>
>>     ipv4/route.c: respect prefsrc for local routes
>>
>>     The preferred source address is currently ignored for local routes,
>>     which results in all local connections having a src address that is the
>>     same as the local dst address. Fix this by respecting the preferred source
>>     address when it is provided for local routes.
>>
>> test script:
>>
>> #!/bin/bash
>> ip addr add 10.1.1.1/24 dev eth0
>> ip addr add 10.1.1.2/24 dev eth0
>> ip rule add priority 245 table 245
>> ip route add 10.1.1.0/24 dev eth0  proto kernel  scope link  src
>> 10.1.1.2 table 245 <===source ip 10.1.1.2 to be preferred
>>
>> ip addr show dev eth0
>> ip route list table main
>> ip route list table 245
>>
>>
>> tcpdump -nn -i eth0 host 10.1.1.9 and icmp &
>>
>> ping 10.1.1.9
>>
>>
>>
>> --before commit 9fc3bbb4a752
>>
>> the source is from ip 10.1.1.2 as expected
>>
>> --after commit 9fc3bbb4a752
>>
>> the source is from ip 10.1.1.1 which not expected since I have high
>> priority table 245 with source ip 10.1.1.2
>>
>> is this regression of commit 9fc3bbb4a752 ?
>
>         Hm, it works here on 3.11.3. ARP request uses
> 10.1.1.2 and ICMP packet has such source. May be something with
> the ping tool you are using? Check 'strace ping -c 1 10.1.1.9', may
> be it binds to first device IP?
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
