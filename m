From: Steffen Maier <smaier@users.sourceforge.net>
Subject: sender throttling for unreliable protocols not garuanteed? (different
 units in sock->wmem_alloc and net_devive->tx_queue_len)
Date: Fri, 11 Aug 2006 14:22:31 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0608111418260.10347@nettc.informatik.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steffen Maier <smaier@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.informatik.uni-stuttgart.de ([129.69.211.42]:38353 "EHLO
	mx3.informatik.uni-stuttgart.de") by vger.kernel.org with ESMTP
	id S932199AbWHKMWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 08:22:35 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

a while ago I wrote a simple network load generator to inject datagrams or 
frames at maximum rate into a network. Maybe I was mistaken but I expected 
the socket's send operation to block, if the transmitting network device 
becomes saturated (no matter if using UDP or PF_PACKET). However, 
sometimes the send operation just returned ENOBUFS immediately without 
blocking.

If I understood Wright&Stevens' TCP/IP Illustrated Vol.2 correctly, BSD 
(at least 4.4 BSD Lite 1) never throttles a UDP sender, since it does not 
account bytes to transmit in any queue on egress path it could block on. 
On the other hand, Linux does in certain cases (details later). Even 
though I found out about the implementation details, I would still like to 
know, if there is any specification or common agreement on the semantics 
of socket send operation blocking (back pressure) with saturated network 
devices?

Please keep me in CC since I lurk and am not subscribed at the moment.

In order to understand why and under what circumstances blocking or 
non-blocking happens, I dug into the protocol stack code. The 
corresponding call traces look as follows (Linux 2.6, similar in 2.4):

sock_sendmsg
  __sock_sendmsg
   socket->ops->sendmsg: e.g. inet_sendmsg or packet_sendmsg
either:
    inet_sendmsg
     sock->sk_prot->sendmsg: e.g. udp_sendmsg
      udp_sendmsg
       ip_append_data
        sock_alloc_send_skb
         sock_alloc_send_pskb
          sock_wait_for_wmem
or:
    packet_sendmsg
     sock_alloc_send_skb
      sock_alloc_send_pskb
       sock_wait_for_wmem

Now this is where a process might block, if the socket send buffer is full 
(atomic_read(&sk->sk_wmem_alloc) >= sk->sk_sndbuf). Suppose sndbuf is 
large enough and it won't block. Then the allocated sk_buff will be 
processed further in udp_sendmsg or packet_sendmsg and finally find its 
way into the device queue. Since we were using an unreliable (transport) 
protocol, the sk_buffs are not actually stored in the socket send buffer 
(there is no need for possible retransmissions). They are only accounted 
for the sndbuf, but they are stored in the device queue:

dev_queue_xmit
  q->enqueue: e.g. pfifo_fast_enqueue
   pfifo_fast_enqueue

This is where the sk_buff may be dropped, if the device queue is full 
(list->qlen >= qdisc->dev->tx_queue_len). Suppose this bad case(?) 
happens, then the code path would return NET_XMIT_DROP. Packet_sendmsg 
would convert this via net_xmit_errno into a -ENOBUFS and finally return 
this as result of the socket send operation to the calling user process. 
Similar thing with the same effect is done for UDP messages.

This means, that there are cases where a socket send operation may just 
not block and immediately return ENOBUFS. If a process wanted to inject 
messages into the network at maximum line speed (or whatever less the NIC 
supports), this would in turn lead to "busy sending". Even worse, I didn't 
come up with a sane configuration of sndbuf and txqueuelen, that could 
prevent this possibly unexpected behavior. If there was only one socket 
transmitting over a certain network device, you could roughly configure 
sndbuf <= txqueuelen / MTU. For a fixed number of sockets we could use 
sndbuf <= txqueuelen / MTU / #sockets. But this breaks as soon as you have 
arbitrarily many sockets transmitting over the same device.

In other words this all just happens because sndbuf accounts in bytes 
but the device queue measures in frames. But frames can have arbitrary 
size within an interval given by the network technology and thus there is 
no fixed relation between those two measurements.

I'd be interested in any opinions on the above mentioned effect.

Thanks,
Steffen.
