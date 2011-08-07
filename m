From: Jakub Muszynski <jakubxmuszynski@googlemail.com>
Subject: ping6: echo reply ok in tcpdump, but not captured in ping
 (Depending on address type)
Date: Sun, 07 Aug 2011 11:56:17 +0200
Message-ID: <1312710977.2986.18.camel@fsk1104>
Reply-To: jakubxmuszynski@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49657 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783Ab1HGOOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2011 10:14:05 -0400
Received: by fxh19 with SMTP id 19so4445808fxh.19
        for <netdev@vger.kernel.org>; Sun, 07 Aug 2011 07:14:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, 

I have a problem:
I'm writing my own IPv6 stack, and I faced interesting issue (probably
my mistake).
I do receive ping6 output, depending on address I probe (ff02:x or
fe80:x). The echo reply is the same in both cases.

I do ping:
$ ping6 -I eth0 fe80::21e:33ff:fe0b:872e 
PING fe80::21e:33ff:fe0b:872e(fe80::21e:33ff:fe0b:872e) from
fe80::21e:33ff:fe0b:872f eth0: 56 data bytes
^C
--- fe80::21e:33ff:fe0b:872e ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 999ms

On my device, the ping is replied, and send back.
I can capture it via tcpdump, but can't register in ping6:

tcpdump:
00:1e:33:0b:87:2f > 00:1e:33:0b:87:2e, ethertype IPv6 (0x86dd), length
118: (hlim 64, next-header ICMPv6 (58) payload length: 64)
fe80::21e:33ff:fe0b:872f > fe80::21e:33ff:fe0b:872e: [icmp6 sum ok]
ICMP6, echo request, length 64, seq 2
	0x0000:  6000 0000 0040 3a40 fe80 0000 0000 0000
	0x0010:  021e 33ff fe0b 872f fe80 0000 0000 0000
	0x0020:  021e 33ff fe0b 872e 8000 b3da 0c69 0002
	0x0030:  365b 3e4e e4e0 0700 0809 0a0b 0c0d 0e0f
	0x0040:  1011 1213 1415 1617 1819 1a1b 1c1d 1e1f
	0x0050:  2021 2223 2425 2627 2829 2a2b 2c2d 2e2f
	0x0060:  3031 3233 3435 3637
00:1e:33:0b:87:2f > 00:1e:33:0b:87:2e, ethertype IPv6 (0x86dd), length
118: (hlim 255, next-header ICMPv6 (58) payload length: 64)
fe80::21e:33ff:fe0b:872e > fe80::21e:33ff:fe0b:872f: [icmp6 sum ok]
ICMP6, echo reply, length 64, seq 2
	0x0000:  6000 0000 0040 3aff fe80 0000 0000 0000
	0x0010:  021e 33ff fe0b 872e fe80 0000 0000 0000
	0x0020:  021e 33ff fe0b 872f 8100 b2da 0c69 0002
	0x0030:  365b 3e4e e4e0 0700 0809 0a0b 0c0d 0e0f
	0x0040:  1011 1213 1415 1617 1819 1a1b 1c1d 1e1f
	0x0050:  2021 2223 2425 2627 2829 2a2b 2c2d 2e2f
	0x0060:  3031 3233 3435 3637


>>> Curious case: 
If I do ping and ff02:xxxx address, it works:

ping6 -I eth0 ff02::21e:33ff:fe0b:872e 
PING ff02::21e:33ff:fe0b:872e(ff02::21e:33ff:fe0b:872e) from
fe80::21e:33ff:fe0b:872f eth0: 56 data bytes
64 bytes from ff02::21e:33ff:fe0b:872e: icmp_seq=1 ttl=255 time=125 ms
64 bytes from ff02::21e:33ff:fe0b:872e: icmp_seq=2 ttl=255 time=125 ms
^C
--- ff02::21e:33ff:fe0b:872e ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 125.374/125.423/125.473/0.357 ms


tcpdump:
00:1e:33:0b:87:2f > 33:33:fe:0b:87:2e, ethertype IPv6 (0x86dd), length
118: (hlim 1, next-header ICMPv6 (58) payload length: 64)
fe80::21e:33ff:fe0b:872f > ff02::21e:33ff:fe0b:872e: [icmp6 sum ok]
ICMP6, echo request, length 64, seq 2
	0x0000:  6000 0000 0040 3a01 fe80 0000 0000 0000
	0x0010:  021e 33ff fe0b 872f ff02 0000 0000 0000
	0x0020:  021e 33ff fe0b 872e 8000 b262 0cb4 0002
	0x0030:  bb5c 3e4e 608a 0700 0809 0a0b 0c0d 0e0f
	0x0040:  1011 1213 1415 1617 1819 1a1b 1c1d 1e1f
	0x0050:  2021 2223 2425 2627 2829 2a2b 2c2d 2e2f
	0x0060:  3031 3233 3435 3637
00:1e:33:0b:87:2f > 33:33:fe:0b:87:2e, ethertype IPv6 (0x86dd), length
118: (hlim 255, next-header ICMPv6 (58) payload length: 64)
ff02::21e:33ff:fe0b:872e > fe80::21e:33ff:fe0b:872f: [icmp6 sum ok]
ICMP6, echo reply, length 64, seq 2
	0x0000:  6000 0000 0040 3aff ff02 0000 0000 0000
	0x0010:  021e 33ff fe0b 872e fe80 0000 0000 0000
	0x0020:  021e 33ff fe0b 872f 8100 b162 0cb4 0002
	0x0030:  bb5c 3e4e 608a 0700 0809 0a0b 0c0d 0e0f
	0x0040:  1011 1213 1415 1617 1819 1a1b 1c1d 1e1f
	0x0050:  2021 2223 2425 2627 2829 2a2b 2c2d 2e2f
	0x0060:  3031 3233 3435 3637


Well - all seems quite similar.
I did try to understand strace ping6, it says:
recvmsg(3, 0xbfc64358, 0) = -1 EAGAIN (Resource temporarily unavailable)
But why?
Some specification (RFC) issues?
Do you have any idea, why local-multicast address works, and other not?

Greetings
Kuba

-------------------------------
the tcpdump command:
tcpdump -t -n -i eth0 -e -x -vv

Interface settings:
ip -6 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 fe80::21e:33ff:fe0b:872f/64 scope link 
       valid_lft forever preferred_lft forever

---------------------------

strace :

NOT WORKING: (fe80:xx)

recvmsg(3, 0xbfc64358, 0)               = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1312710414, 968503}, NULL) = 0
poll([{fd=3, events=POLLIN|POLLERR}], 1, 10) = 0 (Timeout)
gettimeofday({1312710414, 978868}, NULL) = 0
gettimeofday({1312710414, 978996}, NULL) = 0
sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58),
inet_pton(AF_INET6, "fe80::2aa:ff:fe28:9c5a", &sin6_addr),
sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0\f\365\0\7
\16_>N4\360\16\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27"..., 64}],
msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...},
msg_flags=MSG_OOB}, 0) = 64
recvmsg(3, 0xbfc64358, 0)               = -1 EAGAIN (Resource
temporarily unavailable)
gettimeofday({1312710415, 976589}, NULL) = 0
poll([{fd=3, events=POLLIN|POLLERR}], 1, 10) = 0 (Timeout)



WOTKING: (ff02:xx)

poll([{fd=3, events=POLLIN|POLLERR}], 1, 870) = 0 (Timeout)
gettimeofday({1312710444, 919737}, NULL) = 0
gettimeofday({1312710444, 919854}, NULL) = 0
sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58),
inet_pton(AF_INET6, "ff02::2aa:ff:fe28:9c5a", &sin6_addr),
sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0\f\376\0
\2,_>N.\t\16\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27"..., 64}],
msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...},
msg_flags=MSG_OOB}, MSG_CONFIRM) = 64
recvmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(0),
inet_pton(AF_INET6, "ff02::2aa:ff:fe28:9c5a", &sin6_addr),
sin6_flowinfo=0, sin6_scope_id=if_nametoindex("eth0")},
msg_iov(1)=[{"\201\0\210\302\f\376\0\2,_>N.\t\16\0\10\t\n\v\f\r\16\17\20
\21\22\23\24\25\26\27"..., 4208}], msg_controllen=36, {cmsg_len=20,
cmsg_level=SOL_SOCKET, cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0},
0) = 64
write(1, "64 bytes from ff02::2aa:ff:fe28:"..., 6964 bytes from
ff02::2aa:ff:fe28:9c5a: icmp_seq=2 ttl=255 time=125 ms
) = 69
gettimeofday({1312710445, 46448}, NULL) = 0
poll([{fd=3, events=POLLIN|POLLERR}], 1, 873) = 0 (Timeout)


