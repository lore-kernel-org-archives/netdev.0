From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Is TCP over IPsec broken in 2.6.18?
Date: Fri, 22 Sep 2006 15:29:48 +0400
Message-ID: <20060922112948.GA17335@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49824 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751115AbWIVL3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 07:29:52 -0400
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.13.7/8.13.7) with ESMTP id k8MBTngo024027
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 15:29:49 +0400
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.13.7/8.12.1/Submit) id k8MBTmmK024026
	for netdev@vger.kernel.org; Fri, 22 Sep 2006 15:29:48 +0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I've found strange behaviour of transport mode IPsec in 2.6.18 tree.
After key daemons exchanged keys (I use racoon) I try following command
on 2.6.18 machine: telnet 192.168.4.79 22 (telnet from 2.6.18 to 2.6.17 based one)
and get very slow response, here is related tcpdump output:

15:15:47.396925 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x21), length 84
15:15:47.397391 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x18), length 84
15:15:47.397025 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x22), length 84
15:15:47.404166 IP 192.168.4.79.ssh > 192.168.4.78.47256: P 2541002438:2541002458(20) ack 1601271418 win 91 
15:15:48.279375 IP 192.168.4.79.ssh > 192.168.4.78.47256: P 0:20(20) ack 1 win 91 
15:15:50.031487 IP 192.168.4.79.ssh > 192.168.4.78.47256: P 0:20(20) ack 1 win 91 
15:15:53.535710 IP 192.168.4.79.ssh > 192.168.4.78.47256: P 0:20(20) ack 1 win 91 
15:16:00.544154 IP 192.168.4.79.ssh > 192.168.4.78.47256: P 0:20(20) ack 1 win 91 
15:16:14.561064 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x19), length 100
15:16:14.561218 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x23), length 84

Unencrypted packets somehow sneaked into the wire.

ping works ok:
15:15:37.919617 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x1c), length 116
15:15:37.919858 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x13), length 116
15:15:38.920772 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x1d), length 116
15:15:38.920823 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x14), length 116
15:15:39.920823 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x1e), length 116
15:15:39.920883 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x15), length 116
15:15:40.920848 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x1f), length 116
15:15:40.920893 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x16), length 116

It was introduced somewhere in 2.6.18 development cycle and as far as I
recall not at the beginning of it (I found it porting IPsec acrypto to 2.6.18,
unfortunately I do not have version which works anymore, except 2.6.17
tree which works ok with both acrypto and vanilla trees), likely after
transport/tunnel modules introduction by Herbert Xu.

telnet from 2.6.17 tree to 2.6.18 tree works ok too:

15:24:33.428978 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x1b), length 84
15:24:33.429130 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x2d), length 84
15:24:33.429236 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x1c), length 84
15:24:33.436885 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x2e), length 100
15:24:33.436962 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x1d), length 84
15:24:35.293140 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x1e), length 84
15:24:35.293259 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x2f), length 84
15:24:35.293315 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x30), length 100
15:24:35.293365 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x1f), length 84
15:24:35.293372 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x31), length 84
15:24:35.293514 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x20), length 84
15:24:35.293639 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x32), length 84

All tcpdumps were obtained on 2.6.17 machine.
On the same machine I frequently get following logs in syslog:

Sep 22 15:10:52 kano racoon: INFO: ISAKMP-SA established 192.168.4.79[500]-192.168.4.78[500] spi:9865a72e87784e17:cb2af1cfc436bd13 
Sep 22 15:10:52 kano racoon: ERROR: none message must be encrypted
Sep 22 15:10:53 kano racoon: INFO: respond new phase 2 negotiation: 192.168.4.79[500]<=>192.168.4.78[500]
Sep 22 15:10:53 kano racoon: INFO: IPsec-SA established: ESP/Transport 192.168.4.78[0]->192.168.4.79[0] spi=40993273(0x27181f9)
Sep 22 15:10:53 kano racoon: INFO: IPsec-SA established: ESP/Transport 192.168.4.79[0]->192.168.4.78[0] spi=157393760(0x961a360)
Sep 22 15:11:02 kano racoon: ERROR: none message must be encrypted
Sep 22 15:11:12 kano racoon: INFO: IPsec-SA expired: ESP/Transport 192.168.4.78[0]->192.168.4.79[0] spi=3540507(0x36061b)
Sep 22 15:11:12 kano racoon: WARNING: the expire message is received but the handler has not been established.
Sep 22 15:11:12 kano racoon: ERROR: 192.168.4.78 give up to get IPsec-SA due to time up to wait.

I do not recall if they existed when 2.6.17<->2.6.17 communication was
established.

I can use git bisect to track bug down if someone will show me simple tutorial.

-- 
	Evgeniy Polyakov
