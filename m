From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: Setting skb->protocol efficiently for AF_PACKETs via TX_RING
Date: Mon, 24 Feb 2014 22:40:01 +0100
Message-ID: <530BBC31.60107@fokus.fraunhofer.de>
References: <5309D59A.1020304@fokus.fraunhofer.de> <5309FE75.8030802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <jbrouer@redhat.com>, <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay02-dus.antispameurope.com ([94.100.134.202]:42924 "EHLO
	mx-relay02-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751787AbaBXVkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 16:40:20 -0500
In-Reply-To: <5309FE75.8030802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

for our application, basically a light weight (wireless) MPLS switch, we 
are looking for an efficient way to push Ethernet Frames onto NICs via 
TX_RING.

One challenge here is that we might be heavily mixing EtherTypes (MPLS 
unicast & multicast, as well as signalling traffic).

As far as I understand, the fastest method to push packets onto the NIC 
is to not specify a protocol in the socket() call and also to omit the 
protocol for the bind() call.

Hence, the last option to specify the protocol would be the send() call.
The beauty about the TX_RING implementation is that one can push a large 
batch of frames towards the kernel - as long as the EtherType/protocol 
is identical...

In out case, this means fragmenting a nice large send() into potentially 
single frame send() calls.

So, essentially, we're looking for an efficient method to set 
skb->protocol from the EtherType of the respective Ethernet frame.

Looking into the tpacket_fill_skb() function, it seems that the most 
efficient way accomplish this would be to set skb->protocol after 
importing the hard_header into the skb:

     skb_push(skb, dev->hard_header_len);
     err = skb_store_bits(skb, 0, data,
                      dev->hard_header_len);
     if (unlikely(err))
         return err;

     if (skb->protocol == 0) { /* protocol not yet set bu other means */
         struct ethhdr *ehdr = (struct ethhdr*) data;
         skb->protocol = ehdr->h_proto;
     }

This way tpacket_fill_skb() would return with a fully valid skb for 
further processing. And, this would only be done if skb->protocol was 
not set before via socket(), bind() or send().

Hence, there is no need to break a large send() call down into small 
fragments, while the 'skb->protocol = ehdr->h_proto' assignment would 
have to be done in any case. Using the send() method this would require 
an additional overhead since we'd have to fill in a msghdr and pass it 
along.

Needless to say, we tried it and it seems to work fine (on AMD geode and 
also on a more modern Intel Atom).

We'd be open to alternative solutions. Otherwise we would propose those 
few lines to be added to the af_packet code.

Best regards,

Mathias
