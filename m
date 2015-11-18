From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net: tcp: move to timewait when receiving data
 post active-close
Date: Wed, 18 Nov 2015 07:28:00 -0800
Message-ID: <1447860480.22599.151.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447859024-1040-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcelo.leitner@gmail.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33624 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799AbbKRP2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 10:28:03 -0500
Received: by pabfh17 with SMTP id fh17so49635605pab.0
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 07:28:03 -0800 (PST)
In-Reply-To: <1447859024-1040-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-18 at 16:03 +0100, Florian Westphal wrote:
> RFC 1122, 4.2.2.13:
>  [..] if new data is received after CLOSE is called, its TCP
>  SHOULD send a RST to show that data was lost.
> 
>  When a connection is closed actively, it MUST linger in
>  TIME-WAIT state [..].
> 
> We reset a connection, but destroy state immediately.
> 
> After discussing this with Hannes, we decided it was preferable
> to also move to TW state to avoid immediate port reuse.
> 
> packetdrill testcase:
> 
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> 0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> 0.000 bind(3, ..., ...) = 0
> 0.000 listen(3, 1) = 0
> 0.100 < S 0:0(0) win 29200 <mss 1460>
> 0.100 > S. 0:0(0) ack 1 <mss 1460>
> 0.200 < . 1:1(0) ack 1 win 257
> 0.200 accept(3, ..., ...) = 4
> // close our side.
> 0.210 close(4) = 0
> // we should expect to see FIN now, sk moves to FIN_WAIT_1
> 0.210 > F. 1:1(0) ack 1 win 29200
> // receive data, but sk already closed -> Reset
> 0.300 < P. 1:1001(1000) ack 1 win 46
> 0.300 > R 1:1(0) win 0

Thanks for using packetdrill ;)

This packetdrill test shows nothing special regarding your patch, it
should work right now with current kernels ???

lpk51:~# tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 262144 bytes
lpk51:~# ./packetdrill Florian.pkt 
07:26:49.656548 IP 192.0.2.1.59883 > 192.168.155.177.8080: Flags [S], seq 0, win 29200, options [mss 1460], length 0
07:26:49.656611 IP 192.168.155.177.8080 > 192.0.2.1.59883: Flags [S.], seq 1433468786, ack 1, win 29200, options [mss 1460], length 0
07:26:49.756530 IP 192.0.2.1.59883 > 192.168.155.177.8080: Flags [.], ack 1, win 257, length 0
07:26:49.766529 IP 192.168.155.177.8080 > 192.0.2.1.59883: Flags [F.], seq 1, ack 1, win 29200, length 0
07:26:49.856529 IP 192.0.2.1.59883 > 192.168.155.177.8080: Flags [P.], seq 1:1001, ack 1, win 46, length 1000: HTTP
07:26:49.856560 IP 192.168.155.177.8080 > 192.0.2.1.59883: Flags [R], seq 1433468787, win 0, length 0
07:26:49.856806 IP 192.0.2.1.59883 > 192.168.155.177.8080: Flags [R.], seq 1001, ack 1, win 46, length 0
