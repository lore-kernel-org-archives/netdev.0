From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: IPv6 over Firewire
Date: Sun, 23 Dec 2012 14:25:01 +0100
Message-ID: <50D7062D.8040901@gmail.com>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org> <50D4ACFA.6040901@gmail.com> <50D4BD2F.7060006@linux-ipv6.org> <50D54ED9.6090908@gmail.com> <50D6BF6F.2030207@linux-ipv6.org> <50D6E73F.70301@gmail.com> <50D6F488.7060308@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:40200 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab2LWNZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 08:25:06 -0500
Received: by mail-bk0-f48.google.com with SMTP id jc3so2986575bkc.7
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2012 05:25:04 -0800 (PST)
In-Reply-To: <50D6F488.7060308@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Please, please try best not to mangle packets
> and keep/make IPsec, SEND right.
>

O.k., a small excerpt from RFC 3146:
The Source/Target Link-layer Address option has the following form when 
the link layer is IEEE1394.
                          1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |     Type      |  Length = 3   |                               |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                            ---+
    |                    node_unique_ID (EUI-64 identifier)         |
    +---                            +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                               |    max_rec    |      spd      |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                          unicast_FIFO                         |
    +---                            +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                               |            reserved           |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                            reserved                           |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

This is what I _have_ to send to comply with RFC 3146. In the skb I get 
in the firewire net driver I have: Type, Length and node_unique_ID (the 
hardware address), all tail padded to a 8 byte boundary:

                          1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |     Type      |  Length = 3   |                               |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                            ---+
    |                    node_unique_ID (EUI-64 identifier)         |
    +---                            +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                               |    0x00     |      0x00       |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                          0x00000000                           |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

So may aim is to rewrite the LL address option both while transmitting 
and receiving IPv6 data on firewire. While transmitting, I append the 
required information, while receiving I cut away the the firewire 
specific stuff. So the upper layers will not see the firewire related 
information. Yes, that mangling also involves recalculation of the 
ICMPv6 checksum.

Again, if I shall not mangle the ndisc packets in the driver I have to 
build RFC 3146 conformant packets in ndisc_build_skb(). But I see no 
(general) way to get the firewire specific information into the linux 
ndisc stuff. Of course I can add some if/else into 
ndisc_fill_addr_option() and ndisc_recv_na(). But then I have to pull a 
lot of firewire related stuff into the ndisc code.

I think this makes no sense, especially because I need that firewire 
specific information in the firewire net driver to send correct firewire 
packets. Besides that, the IPv4 portion of the firewire net drivers does 
exactly the same with ARP packets what I want to do with IPv6 LL address 
options.

Regards,

Stephan
