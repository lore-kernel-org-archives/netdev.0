From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Tue, 07 Sep 2010 17:37:05 +0200
Message-ID: <4C865C21.5010803@ans.pl>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>	 <1283802132.2585.4.camel@edumazet-laptop>  <4C854737.5040503@ans.pl> <1283804955.2585.12.camel@edumazet-laptop> <4C8552B1.8020806@ans.pl> <4C855385.7030203@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:44488 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756178Ab0IGPhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 11:37:09 -0400
In-Reply-To: <4C855385.7030203@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-06 22:48, Krzysztof Ol=C4=99dzki wrote:
> On 2010-09-06 22:44, Krzysztof Ol=C4=99dzki wrote:
>> On 2010-09-06 22:29, Eric Dumazet wrote:
>>> Le lundi 06 septembre 2010 =C3=A0 21:55 +0200, Krzysztof Ol=C4=99dz=
ki a =C3=A9crit :
>>>
>>>> Yes, conntrack is one of possibilities. However, this problem only
>>>> manifests on 2.6.34 and never on 2.6.31 where iptables and conntra=
ck
>>>> configurations are identically. And of course, each time it is a
>>>> different port.
>>>>
>>>> Please also note that this problem only exists when communication =
is
>>>> handled over a loopback interface - I'm not able to trigger this f=
rom a
>>>> remote host even if I run the test on two hosts (local&    remote)
>>>> simultaneously.
>>>>
>>>
>>> No particular error shown in "netstat -s" ?
>>
>> No... :(
>>
>> Udp:
>>        8542243 packets received
>>        489605 packets to unknown port received.
>>        1 packet receive errors
>>        4254527 packets sent
>>        RcvbufErrors: 1
>>
>>> port randomization on UDP changed in the past, and conntracking cha=
nged
>>> a bit too ;)
>>
>> I know but AFAIR all important changs were alredy included in 2.6.31=
=2E
>> And again: there is no problem in quering DNS from a remote host:
>>     [client 2.6.24.6]<-ethernet->   [server 2.6.34.6]
>>
>> BTW: I have been able to reproduce this problem on a different, less
>> critical host after upgrading its kernel to 2.6.34.6. Unfortunately =
I'm
>> still not able to do in on my lab environment. :( Anyway, I'll try t=
o
>> catch "conntrack -E" output and see what conntrack thinks about such
>> packets.
>
> OK, got it:
>
> *strace (1682.t.lan):
> socket(PF_INET, SOCK_DGRAM|SOCK_NONBLOCK, IPPROTO_IP) =3D 4
> connect(4, {sa_family=3DAF_INET, sin_port=3Dhtons(53), sin_addr=3Dine=
t_addr("192.168.130.53")}, 28) =3D 0
> poll([{fd=3D4, events=3DPOLLOUT}], 1, 0)    =3D 1 ([{fd=3D4, revents=3D=
POLLOUT}])
> sendto(4, "Gz\1\0\0\1\0\0\0\0\0\0\0041683\1t\3lan\0\0\1\0\1", 28, MSG=
_NOSIGNAL, NULL, 0) =3D 28
> poll([{fd=3D4, events=3DPOLLIN}], 1, 5000)  =3D 0 (Timeout)
> poll([{fd=3D4, events=3DPOLLOUT}], 1, 0)    =3D 1 ([{fd=3D4, revents=3D=
POLLOUT}])
>
> * tcpdump:
> 1283805361.395859 IP (tos 0x0, ttl 64, id 47011, offset 0, flags [DF]=
, proto UDP (17), length 56)
>      192.168.130.53.49279>  192.168.130.53.53: 27611+ A? 1682.t.lan. =
(28)
> 1283805361.395933 IP (tos 0x0, ttl 64, id 10738, offset 0, flags [non=
e], proto UDP (17), length 112)
>      192.168.130.53.53>  192.168.130.53.49279: 27611* 1/1/1 1682.t.la=
n. A 127.0.0.1 (84)
>
> * conntrack:
> [1283805361.395862]         [NEW] ipv4     2 udp      17 30 src=3D192=
=2E168.130.53 dst=3D192.168.130.53 sport=3D49279 dport=3D53 [UNREPLIED]=
 src=3D192.168.130.53 dst=3D192.168.130.53 sport=3D53 dport=3D49279 id=3D=
3423125776
> [1283805361.395939]      [UPDATE] ipv4     2 udp      17 30 src=3D192=
=2E168.130.53 dst=3D192.168.130.53 sport=3D49279 dport=3D53 src=3D192.1=
68.130.53 dst=3D192.168.130.53 sport=3D53 dport=3D49279 id=3D3423125776

So far I have found that:

2.6.31.7/2.6.31.12: OK
2.6.32.21: OK
2.6.33-rc1: bad
2.6.33-rc5: bad
2.6.33.7: bad
2.6.34.4/2.6.34.6: bad

It looks like the bug must have been introduced in 2.6.33-rc1. There ar=
e=20
8904 commits between 2.6.32 and 2.6.33-rc1, so with ~15 more reboots I=20
should be able to point the problematic commit. I hope. ;)


Best regards,

			Krzysztof Ol=C4=99dzki

