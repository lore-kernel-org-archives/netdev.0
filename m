From: andrei radulescu-banu <iubica2@yahoo.com>
Subject: Tcpdump, packet sockets and order of timestamps
Date: Tue, 3 Jun 2008 07:59:16 -0700 (PDT)
Message-ID: <13855.16113.qm@web56603.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web56603.mail.re3.yahoo.com ([66.196.97.47]:30458 "HELO
	web56603.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751571AbYFCPF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 11:05:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a question regarding packet sockets: what ensures the sequentiality of the timestamps? It seems at least theoretically possible that packets are posted to a packet socket with timestamps out of order. 

Here is a snip of the dev_queue_xmit_nit() routine in net/core/dev.c 

void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
{
    struct packet_type *ptype;

    net_timestamp(skb);

    rcu_read_lock();
 .....


The buffer is timestamped outside the lock. That makes sense from a scalability perspective, but it also means that sequentiality of timestamps is not guaranteed. Also, transmit timestamps don't seem to be completely synchronized with receive timestamps.

All this being said, I've never observed a case when tcpdump displays packets out of order with respect to timestamps. I wonder if libpcap or tcpdump reorder packets with respect to timestamps? Does anyone know if that is actually the case?

The reason I ask these questions is not purely theoretical - but because I'd like to try to move timestamping of tx buffers in the driver 'transmit done' interrupt. One of the network interface cards we're developing will perform hardware timestamps, and on the transmit side the timestamp will be available only at the time of the transmit done interrupt.

As I move tx timestamping in the tx done interrupt, all these tiny windows to lose sequentiality in packet sockets become exacerbated. I'd like to understand, for example, if this means that I also have specifically to modify packet socket code to rearrange frames in timestamp order in the socket rx queue.

Please cc me on any response, I am not subscribed to the list.



      
