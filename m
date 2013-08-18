From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: NAT stops forwarding ACKs after PMTU discovery
Date: Sat, 17 Aug 2013 22:55:00 -0700
Message-ID: <521061B4.1030508@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from juniper.fatooh.org ([173.255.221.30]:44643 "EHLO
	juniper.fatooh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160Ab3HRGDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 02:03:41 -0400
Received: from juniper.fatooh.org (juniper.fatooh.org [127.0.0.1])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by juniper.fatooh.org (Postfix) with ESMTPS id F3566131
	for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 22:55:00 -0700 (PDT)
Received: from juniper.fatooh.org (juniper.fatooh.org [127.0.0.1])
	by juniper.fatooh.org (Postfix) with ESMTP id D569114A
	for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 22:55:00 -0700 (PDT)
Received: from [198.18.0.3] (173-164-227-83-SFBA.hfc.comcastbusiness.net [173.164.227.83])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by juniper.fatooh.org (Postfix) with ESMTPSA id C25C2131
	for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 22:55:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

If there is a better user-oriented list I should ask this question on,
please tell me; I've asked a couple similar questions on netdev before
and gotten some great help.


I'm having a problem wherein some NATted connections stop forwarding
packets. I've troubleshot the problem far enough to tell that it happens
when path MTU discovery happens--the ACK to the retransmitted packet
never gets forwarded back to my local client (and neither do the
retransmitted ACKs).

This is my setup:
----------------------------------------------------------------------
       MTU 9100                  MTU 1355  MTU 1500
client      --> linux router          -->  vpn  --> work host
198.18.0.3      198.18.0.1    (eth0)                10.15.24.13
                192.168.61.54 (tun0)
----------------------------------------------------------------------

I'm running openconnect on a Linux router to connect to a cisco VPN at
work. The Linux router does SNAT (MASQUERADE) over the virtual tun0
interface created by openconnect.

This is the best test I have so far:

$ sudo ip route flush cache ; ssh workhost.example.com exit
Read from socket failed: Connection reset by peer

Most of the time, this hangs for a few minutes before giving up;
sometimes it just works fine. tcpdumps indicate that when it works, all
packets transmitted are below the VPN's MTU; when it fails, MTU
discovery has happened:

1. client sends large packet, for example 1832 bytes
2. router sends ICMP fragmentation needed
3. client retransmits with a smaller packet, for example 1303 bytes
4. router forwards packet over VPN
5. work host ACKs packet
6. router receives ACK but does not forward it
7. both endpoints retransmit, but ACKs never get forwarded

The NAT table maintains an entry throughout (and continues to SNAT
retransmits from the client), but the ACKs from the server never get
forwarded.

fire:~# netstat-nat -n -d 10.15.24.13
Proto NATed Address           Destination Address            State
tcp   198.18.0.3:51076        10.15.24.13:22                 ESTABLISHED


I put a LOG target on the INPUT chain, though, and apparently these
packets are bypassing the NAT; the kernel does not think they should be
forwarded (else they would be on the FORWARD chain).

[23335.509084] IN=tun0 OUT= MAC= SRC=10.15.24.13 DST=192.168.61.54
LEN=64 TOS=0x00 PREC=0x00 TTL=62 ID=28270 DF PROTO=TCP SPT=22 DPT=51076
WINDOW=134 RES=0x00 ACK FIN URGP=0


The kernel on the router is 3.10-2-amd64 (from Debian testing). I had
the same problem with 3.2.0-4-amd64 (from Debian stable), before I tried
to see if I could upgrade the problem away.

Any help would be much appreciated. I can send full tcpdumps if needed.

Thanks,
Corey
