From: Jakob Unterwurzacher <jakobunt@gmail.com>
Subject: Small bug in ping
Date: Tue, 03 Jun 2014 22:58:13 +0200
Message-ID: <538E36E5.4070204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:47420 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933299AbaFCU6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 16:58:17 -0400
Received: by mail-wi0-f180.google.com with SMTP id hi2so280409wib.7
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 13:58:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I was waiting for a machine to boot, pinging it, and noticed what I
believe is a bug in the output of iputils' ping.

Reproducer:
1) Ping a host on the LAN that is down
2) Wait until you get "Destination Host Unreachable" from your own IP
3) Boot up host
4) Ping replies seem to come from your own IP

ping output looks like this:
> # ping -n 192.168.0.121
> From 192.168.0.251 icmp_seq=54 Destination Host Unreachable
> From 192.168.0.251 icmp_seq=55 Destination Host Unreachable
> 64 bytes from 192.168.0.251: icmp_seq=77 ttl=64 time=0.466 ms
> 64 bytes from 192.168.0.251: icmp_seq=78 ttl=64 time=3.06 ms
> ...

tcpdump looks good:
> # tcpdump host 192.168.0.121 -n
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
> 22:21:59.038558 IP 192.168.0.251 > 192.168.0.121: ICMP echo request, id 4724, seq 116, length 64
> 22:21:59.039095 IP 192.168.0.121 > 192.168.0.251: ICMP echo reply, id 4724, seq 116, length 64
> 22:22:00.038553 IP 192.168.0.251 > 192.168.0.121: ICMP echo request, id 4724, seq 117, length 64
> 22:22:00.039071 IP 192.168.0.121 > 192.168.0.251: ICMP echo reply, id 4724, seq 117, length 64

Also, strace confirms that ping gets the packets correctly:
> # strace -p `pgrep ping`
> Process 4724 attached
> poll([{fd=3, events=POLLIN|POLLERR}], 1, 28) = 0 (Timeout)
> sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("192.168.0.121")}, msg_iov(1)=[{"\10\0\356\373\22t\0\223\206.\216S\0\0\0\0\"\250\0\0\0\0\0\0\20\21\22\23\24\25\26\27"..., 64}], msg_controllen=0, msg_flags=0}, MSG_CONFIRM) = 64
> recvmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("192.168.0.121")}, msg_iov(1)=[{"E\0\0T\200b\0\0@\1w\202\300\250\0y\300\250\0\373\0\0\366\373\22t\0\223\206.\216S"..., 192}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_SOCKET, cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, 0) = 84
> write(1, "64 bytes from 192.168.0.251: icm"..., 63) = 63
> poll([{fd=3, events=POLLIN|POLLERR}], 1, 998) = 0 (Timeout)
> sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("192.168.0.121")}, msg_iov(1)=[{"\10\0\227\363\22t\0\224\207.\216S\0\0\0\0x\257\0\0\0\0\0\0\20\21\22\23\24\25\26\27"..., 64}], msg_controllen=0, msg_flags=0}, MSG_CONFIRM) = 64
> recvmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("192.168.0.121")}, msg_iov(1)=[{"E\0\0T\200c\0\0@\1w\201\300\250\0y\300\250\0\373\0\0\237\363\22t\0\224\207.\216S"..., 192}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_SOCKET, cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, 0) = 84
> write(1, "64 bytes from 192.168.0.251: icm"..., 63) = 63
> ...

( In case the output gets horribly word-wrapped: I have pasted it to
https://gist.github.com/anonymous/597434502b928a75ac05 )

Best regards,
Jakob
