From: Rui <wirelesser@gmail.com>
Subject: how to make sure that packet is inserted into PACKET_MMAP ring buffer
 strictly according to its timestamp order?
Date: Wed, 22 Dec 2010 12:33:40 +0800
Message-ID: <AANLkTinaMX-yaWRcEf56dPxPdJBJNRnGf3rXEKO-_y86@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:59174 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835Ab0LVEdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 23:33:41 -0500
Received: by pwj3 with SMTP id 3so240373pwj.19
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 20:33:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi

how to make sure that packet is inserted into PACKET_MMAP ring buffer
strictly according to its timestamp order?

I am studying the code below
as the function tpacket_rcv will be running in parallel in multi queue
nic supportted kernel,
is it possible that a later packet get the spinlock earlier,
thus it is copied to the ring buffer prior to packet which timestamp is earlier?


thanks
rui

af_packet.c
static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
		       struct packet_type *pt, struct net_device *orig_dev)
{
...
spin_lock(&sk->sk_receive_queue.lock);
	h.raw = packet_current_frame(po, &po->rx_ring, TP_STATUS_KERNEL);
	if (!h.raw)
		goto ring_is_full;
	packet_increment_head(&po->rx_ring);
	po->stats.tp_packets++;
	if (copy_skb) {
		status |= TP_STATUS_COPY;
		__skb_queue_tail(&sk->sk_receive_queue, copy_skb);
	}
	if (!po->stats.tp_drops)
		status &= ~TP_STATUS_LOSING;
	spin_unlock(&sk->sk_receive_queue.lock);

	skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
}
