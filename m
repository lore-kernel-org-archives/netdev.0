From: "prodyut hazarika" <prodyuth@gmail.com>
Subject: Re: include/linux/skbuff.h: checksumming documentation
Date: Fri, 5 Sep 2008 10:37:31 -0700
Message-ID: <49c0ff980809051037p14de9835y4293f7c63b23a37d@mail.gmail.com>
References: <20080905164711.GB4318@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Ben Dooks" <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.191]:59036 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbYIERhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 13:37:33 -0400
Received: by gv-out-0910.google.com with SMTP id e6so55143gvc.37
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 10:37:31 -0700 (PDT)
In-Reply-To: <20080905164711.GB4318@fluff.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The first line does not make sense, and the rest of it is an
> unslightly rant about hardware manufacturers.
>

The documentation is kind of confusing.
It took me some time to figure this whole thing out.

Note that Linux TCP stack does not support IP checksum offload.
Only TCP/UDP offload is supported - but to confuse all we have skb->ipsummed,
which in reality holds the L4 partial checksum state.
Also, note that the stack always does the L4 pseudo header calculation,
even though the underlying device might be able to perform it. Only
the L4 payload
checksum is offloaded to the device.

The driver exports its capability using the features flag (eg. NETIF_F_HW_CSUM).
In transmit path, Linux TCP stack calculates the L4 partial checksum
(pseudo-header only),
and puts the partial checksum in skb->csum. Look at tcp_v4_send_check.
CHECKSUM_PARTIAL means that the device is capable of performing
partial L4 checksum offload.
The emac driver then grabs this partial checksum and XORs it with the
checksum over the data,
puts this new checksum in the tcp packet header, and sends the packet out.

For RX side, if the driver is capable of computing the complete L4
checksum, it marks
skb->ipsummed = CHECKSUM_UNNECESARY. If it computes the partial L4 checksum,
it puts the partial L4 checksum in skb->csum and marks ip_summed as
CHECKSUM_COMPLETE.
The tcp stack then XORs this value with the psuedo header.
See tcp_v4_checksum_init() which is called from tcp_v4_rcv


> I will have to research what the chip does with checksumming on IP
> fragments as, IIRC, the UDP and TCP checksums cover the entriety of
> the data before fragmentation.
>
Look at Intel e1000 driver to understand checksum offload.

Thanks,
Prodyut Hazarika
