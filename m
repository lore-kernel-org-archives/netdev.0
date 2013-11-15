From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: When a TCP segment is split up (to be sent through a TUN device
 with a small MTU) who should recalculate the checksum?
Date: Fri, 15 Nov 2013 09:20:47 -0500
Message-ID: <52862DBF.2060801@gmail.com>
References: <5285E0BC.4090402@atlantech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: John Hughes <john@atlantech.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f41.google.com ([209.85.128.41]:43792 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974Ab3KOOUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 09:20:50 -0500
Received: by mail-qe0-f41.google.com with SMTP id x7so2283292qeu.14
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 06:20:49 -0800 (PST)
In-Reply-To: <5285E0BC.4090402@atlantech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2013 03:52 AM, John Hughes wrote:
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
> 11:59:23.020426 IP caronia.CalvaEDI.COM.33232 >
> olympic.calvaedi.com.ssh: Flags [.], seq 3073:9843, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 6770
> 11:59:23.041072 IP caronia.CalvaEDI.COM.33232 >
> olympic.calvaedi.com.ssh: Flags [.], seq 9843:11197, ack 2233, win 148,
> options [nop,nop,TS val 215919297 ecr 1199882508], length 1354
>
>
> Then the packet gets sent out on the tunnel as 5 smaller packets:
>
> 11:59:23.020449 IP caronia.CalvaEDI.COM.33232 >
> olympic.calvaedi.com.ssh: Flags [.], seq 3073:4427, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.020534 IP caronia.CalvaEDI.COM.33232 >
> olympic.calvaedi.com.ssh: Flags [.], seq 4427:5781, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.020536 IP caronia.CalvaEDI.COM.33232 >
> olympic.calvaedi.com.ssh: Flags [.], seq 5781:7135, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.020539 IP caronia.CalvaEDI.COM.33232 >
> olympic.calvaedi.com.ssh: Flags [.], seq 7135:8489, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.020543 IP caronia.CalvaEDI.COM.33232 >
> olympic.calvaedi.com.ssh: Flags [.], seq 8489:9843, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.041086 IP caronia.CalvaEDI.COM.33232 >
> olympic.calvaedi.com.ssh: Flags [.], seq 9843:11197, ack 2233, win 148,
> options [nop,nop,TS val 215919297 ecr 1199882508], length 1354
>
>
>
> And this is what the receiving system sees:
>
> 11:59:23.025658 IP (tos 0x8, ttl 62, id 42831, offset 0, flags [DF],
> proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.],
> cksum 0x1003 (incorrect -> 0xb1b9), seq 3073:4427, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.025907 IP (tos 0x8, ttl 62, id 42832, offset 0, flags [DF],
> proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.],
> cksum 0x1003 (incorrect -> 0x871c), seq 4427:5781, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.025990 IP (tos 0x8, ttl 62, id 42833, offset 0, flags [DF],
> proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.],
> cksum 0x1003 (incorrect -> 0x97dd), seq 5781:7135, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.026183 IP (tos 0x8, ttl 62, id 42834, offset 0, flags [DF],
> proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.],
> cksum 0x1003 (incorrect -> 0x9961), seq 7135:8489, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.026231 IP (tos 0x8, ttl 62, id 42835, offset 0, flags [DF],
> proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.],
> cksum 0x1003 (incorrect -> 0x6a2a), seq 8489:9843, ack 2233, win 148,
> options [nop,nop,TS val 215919291 ecr 1199882508], length 1354
> 11:59:23.046163 IP (tos 0x8, ttl 62, id 42836, offset 0, flags [DF],
> proto TCP (6), length 1406)
>      caronia.CalvaEDI.COM.33232 > olympic.calvaedi.com.ssh: Flags [.],
> cksum 0xd237 (correct), seq 9843:11197, ack 2233, win 148, options
> [nop,nop,TS val 215919297 ecr 1199882508], length 1354
>
>
> The receiving system is, of course, unhappy about that and complains
> that it hasn't got 3073:9843
>
> 11:59:23.045040 IP olympic.calvaedi.com.ssh >
> caronia.CalvaEDI.COM.33232: Flags [.], ack 3073, win 1933, options
> [nop,nop,TS val 1199882514 ecr 215919290,nop,nop,sack 1 {9843:11197}],
> length 0
>
>
> So, when the 6770 byte segment is split up into five 1354 byte segments
> who is supposed to recalculate the checksums?
>
> (This is Debian bug 729567).
>
>

Can you check to see if you have the following patch in your kernel
commit: 1cdbcb7957cf9e5f841dbcde9b38fd18a804208b
Author: Simon Horman <horms@verge.net.au>
Date:   Sun May 19 15:46:49 2013 +0000

     net: Loosen constraints for recalculating checksum in skb_segment()


This commit help if the forwarding system has to re-segment the data
before transition.  Especially if the receiving interface had GRO
enabled with checksum offloading and the transmitting interface does
not support checksum offloading.

-vlad
