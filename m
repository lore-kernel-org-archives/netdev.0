From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: When a TCP segment is split up (to be sent through a TUN device
 with a small MTU) who should recalculate the checksum?
Date: Fri, 15 Nov 2013 05:06:55 -0800
Message-ID: <1384520815.28716.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5285E0BC.4090402@atlantech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Hughes <john@atlantech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:62535 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084Ab3KONG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 08:06:57 -0500
Received: by mail-pa0-f51.google.com with SMTP id fb1so3579419pad.24
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 05:06:57 -0800 (PST)
In-Reply-To: <5285E0BC.4090402@atlantech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-15 at 09:52 +0100, John Hughes wrote:
> I have two offices, joined by a OpenVPN tunnel.  I've upgraded the 
> kernels in the machines running the tunnel to 3.10.  All of a sudden I'm 
> getting horrible transmission delays between the two offices.
> 
> office1 LAN--------office1 tunnel machine
>                              |
>                              | openvpn tunnel
>                              |
>                      office2 tunnel machine------office2 LAN
>                                    
> 
> What seems to be happening is that packets are arriving at the LAN 
> interface of the machine running the tunnel and being combined by 
> generic-receive-offload.  These packets then have to be split up again 
> as they are too big for the tunnels MTU.
> 
> But when the packets are split the TCP checksum doesn't seem to be being 
> recalculated, so the systems on the other end of the tunnel ignore them, 
> forcing many retries and the observed delays.
> 
> For example, here is a large packet coming in on the NIC of the machine 
> running the tunnel, followed by a smaller packet ("caronia" is on the 
> office 1 LAN, "olympic" is on the office 2 LAN):
> 
> 11:59:23.020426 IP caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], seq 3073:9843, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 6770
> 11:59:23.041072 IP caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], seq 9843:11197, ack 2233, win 148, options [nop,nop,TS val 215919297 ecr 1199882508], length 1354
> 
> 
> Then the packet gets sent out on the tunnel as 5 smaller packets:
> 
> 11:59:23.020449 IP caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], seq 3073:4427, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.020534 IP caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], seq 4427:5781, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.020536 IP caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], seq 5781:7135, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.020539 IP caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], seq 7135:8489, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.020543 IP caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], seq 8489:9843, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.041086 IP caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], seq 9843:11197, ack 2233, win 148, options [nop,nop,TS val 215919297 ecr 1199882508], length 1354
> 
> 
> 
> And this is what the receiving system sees:
> 
> 11:59:23.025658 IP (tos 0x8, ttl 62, id 42831, offset 0, flags [DF], proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], cksum 0x1003 (incorrect -> 0xb1b9), seq 3073:4427, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.025907 IP (tos 0x8, ttl 62, id 42832, offset 0, flags [DF], proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], cksum 0x1003 (incorrect -> 0x871c), seq 4427:5781, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.025990 IP (tos 0x8, ttl 62, id 42833, offset 0, flags [DF], proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], cksum 0x1003 (incorrect -> 0x97dd), seq 5781:7135, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.026183 IP (tos 0x8, ttl 62, id 42834, offset 0, flags [DF], proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], cksum 0x1003 (incorrect -> 0x9961), seq 7135:8489, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.026231 IP (tos 0x8, ttl 62, id 42835, offset 0, flags [DF], proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], cksum 0x1003 (incorrect -> 0x6a2a), seq 8489:9843, ack 2233, win 148, options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.046163 IP (tos 0x8, ttl 62, id 42836, offset 0, flags [DF], proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.], cksum 0xd237 (correct), seq 9843:11197, ack 2233, win 148, options [nop,nop,TS val 215919297 ecr 1199882508], length 1354
> 
> 
> The receiving system is, of course, unhappy about that and complains 
> that it hasn't got 3073:9843
> 
> 11:59:23.045040 IP olympic.calvaedi.com.ssh > caronia.CalvaEDI.COM.33232: Flags [.], ack 3073, win 1933, options [nop,nop,TS val 1199882514 ecr 215919290,nop,nop,sack 1 {9843:11197}], length 0
> 
> 
> So, when the 6770 byte segment is split up into five 1354 byte segments 
> who is supposed to recalculate the checksums?
> 
> (This is Debian bug 729567).
> 

Thanks for the report

It depends on the offload capabilities of the NIC forwarding packets

ethtool -k eth0

TCP checksums can be recomputed by tcp_gso_segment() (it was named
tcp_tso_segment() in linux 3.10), unless the NIC told it was doing the
checksum computation itself.

ethtool -K eth0 tx off

Should request stack to perform the cheksums.

What is the NIC doing the transmits ?
