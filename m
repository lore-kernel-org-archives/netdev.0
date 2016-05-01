From: =?UTF-8?Q?Peter_Pal=c3=bach?= <Peter.Paluch@fri.uniza.sk>
Subject: Re: Q: How to disable vlan strip in Intel igb driver ?
Date: Sun, 1 May 2016 22:51:08 +0200
Message-ID: <add3dc34-51fc-73e2-489a-e3230cc081f6@fri.uniza.sk>
References: <CAJ2oMhKyMbgLZiGSGQxRGVdbGARvMHeO3=vpgO0uOzOBqvf79Q@mail.gmail.com>
 <afa69dcb-0905-a556-0208-49a2363ae818@fri.uniza.sk>
 <CAJ2oMhJp9M93QujnPYmp5CQkt-tx8P-uRCveiMEkDRLrcZmNhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: Ran Shalit <ranshalit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castor.kis.fri.uniza.sk ([158.193.152.2]:55423 "EHLO
	mail.kis.fri.uniza.sk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbcEAUvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 16:51:13 -0400
In-Reply-To: <CAJ2oMhJp9M93QujnPYmp5CQkt-tx8P-uRCveiMEkDRLrcZmNhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ran,


> Alex,
> I don't see rx-vlan-offload option in my ethtool. strange, maybe it is
> not available in all ethtool versions ?

According to my manpage for ethtool v4.5, the relevant -K option is 
"rxvlan".

> Hi Peter,
> Yes, I'm using AF_PACKET (I can't validate it now for 100%, but I
> quite sure about it).

Okay - but I assume that you are writing a userspace application, not a 
kernelspace driver or module, right?

> I'm accessing the ethernet header, and it always gives me non extended
> ethernet header (without vlan information).

It seems that this behavior has been around for a long time, and is 
intentional. See the following thread for more information:

http://www.spinics.net/lists/netdev/msg244668.html

The only legit way of accessing VLAN tag info on an AF_PACKET socket I 
know about is by setting the PACKET_AUXDATA socket option, and reading 
the auxiliary data as a struct tpacket_auxdata using recvmsg().

In addition, however, there seems to be a bug in the kernel in that the 
tp_vlan_tci member of the struct tpacket_auxdata is filled in only if 
the AF_PACKET socket is bound to htons(ETH_P_ALL). If the socket is 
bound to any other specific protocol, the tp_vlan_tci is set to 0. I 
have raised this issue recently in the following thread(s) but have not 
received a response yet:

http://www.spinics.net/lists/netdev/msg372830.html
http://www.spinics.net/lists/netdev/msg373112.html


> I can see the vlan tag in vlan_tci field in sk_buff, but this is not
> exactly what I need, I need the header AS-IS with the original
> (extended) ethernet header.

How are you accessing the vlan_tci field from your software?

In any case, with AF_PACKET sockets, I am afraid you don't have much 
choice. Even libpcap reconstructs VLAN-tagged frames by reading the VLAN 
tag from an auxiliary structure and then re-inserting it into the frame, 
because the frame delivered through an AF_PACKET socket does not have 
the VLAN tag present anymore.

Best regards,
Peter
