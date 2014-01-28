From: David Laight <David.Laight@ACULAB.COM>
Subject: Incorrect skb->truesize calculations in net/usb/ax88179_178a.c
Date: Tue, 28 Jan 2014 09:14:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D4663F5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35821 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754473AbaA1JOc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 04:14:32 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16950-10 for <netdev@vger.kernel.org>;
 Tue, 28 Jan 2014 09:14:29 +0000 (GMT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ax88179_178a driver contains this code for processing receive traffic:

1130         while (pkt_cnt--) {
...
1144                 if (pkt_cnt == 0) {
1145                         /* Skip IP alignment psudo header */
1146                         skb_pull(skb, 2);
1147                         skb->len = pkt_len;
1148                         skb_set_tail_pointer(skb, pkt_len);
1149                         skb->truesize = pkt_len + sizeof(struct sk_buff);
1150                         ax88179_rx_checksum(skb, pkt_hdr);
1151                         return 1;
1152                 }
1153 
1154                 ax_skb = skb_clone(skb, GFP_ATOMIC);
1155                 if (ax_skb) {
1156                         ax_skb->len = pkt_len;
1157                         ax_skb->data = skb->data + 2;
1158                         skb_set_tail_pointer(ax_skb, pkt_len);
1159                         ax_skb->truesize = pkt_len + sizeof(struct sk_buff);
1160                         ax88179_rx_checksum(ax_skb, pkt_hdr);
1161                         usbnet_skb_return(dev, ax_skb);
1162                 } else {
1163                         return 0;
1164                 }

The usb receives are done with 20kB skb.
The loop above implies that they can be filled with multiple ethernet frames.
The hardware supports TSO, I don't know if it also supports receive offload.

I'm not sure what skb->trusize should be for a cloned skb (in order to get
sensible accounting). But is a single ethernet frame is received I thought
the truesize should still be 20k+, not reset to the data size.

This driver would be much better off providing single 4k buffers to the
usb stack, and then generating skb referring to the data - especially
if it does merge receives.
I'm not sure of the best way to handle the splitting of multiple ethernet
frames from shared pages, but I'm pretty sure it isn't the above.

	David
