From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP checksum problem
Date: Fri, 11 Apr 2014 17:49:28 -0700
Message-ID: <1397263768.4222.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53488811.2080602@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arvid Brodin <arvid.brodin@alten.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:58133 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755055AbaDLAta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 20:49:30 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so5934936pdj.32
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 17:49:30 -0700 (PDT)
In-Reply-To: <53488811.2080602@alten.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-04-12 at 02:25 +0200, Arvid Brodin wrote:
> Hi,
> 
> I'm trying to insert a 6-byte HSR header into a newly copied skb,
> between the ethernet header and the IP header. The skb comes from my
> virtual device's ndo_start_xmit() function and is to be sent on to a
> physical interface after modification. Essentially, this is what I'm
> doing:
> 
> 	skb = skb_copy_expand(skb, skb_headroom(skb) + HSR_HLEN, 0,
> GFP_ATOMIC);
> 
> 	/* Move ethernet header to make room for the HSR header */
> 	src = skb_mac_header(skb);
> 	WARN_ON_ONCE(src != skb->data);
> 	dst = skb_push(skb, HSR_HLEN);
> 	memmove(dst, src, ETH_HLEN);
> 	skb_reset_mac_header(skb);
> 
> 	/* Fill in the 6-byte header */
> 	hsr_fill_tag(skb, frame, port);
> 
> 	/* Point the skb to the physical interface */
> 	skb->dev = port->dev; 
> 
> 	dev_queue_xmit(skb);
> 
> But something goes wrong with the TCP checksum on the way out. Arp,
> ping etc works fine, but anything using TCP is discarded by the
> receiver due to incorrect TCP checksums.
> 
> Using wireshark and some printks, I've managed to decide that the
> updated TCP checksum is written offset by -6 bytes from where it
> should be (into what wireshark calls the TCP header "acknowledgement
> number" field).
> 
> Any idea why this happens? I've spent a few days on this now and I'm
> running out of ideas...
> 
> This is run on the cadence/macb ethernet device. Before the call to
> skb_copy_expand(), skb->ip_summed is CHECKSUM_PARTIAL, skb->csum_start
> is 120, and skb->csum_offset is 16. The total frame length is 80 bytes
> (on the wire as reported by wireshark - I think this is excluding the
> FCS).
> 
> 

You need to set skb->csum_start to the new offset.

( skb_transport_header(skb) - skb->head )

Check how __tcp_v4_send_check() sets csum_start & csum_offset

(csum_offset you can leave it as is)
