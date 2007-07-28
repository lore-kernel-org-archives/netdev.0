From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: netdevice queueing / sendmsg issue?
Date: Sun, 29 Jul 2007 00:25:07 +0200
Message-ID: <m3lkd0upx8.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:52369 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756724AbXG1WZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jul 2007 18:25:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have noticed an unexpected behaviour of a userland program sending
packets with AF_PACKET through a network device driver. The problem
is that the userland program waits on sock_wait_for_wmem() for a long
time even if the transmitter is ready and all skb packets have been
transmitted and freed by the driver. Perhaps some clues?
Does it work as designed?

The driver is actually ARM Intel IXP425 Ethernet doing bus mastering
TX, it basically does:

xmit()
{
	send_skb_to_hw(skb);
        if (no_more_tx_skb_slots) /* there are 16 TX skb slots total */
		netif_stop_queue(dev);
	return NETDEV_TX_OK;
}

xmit_ready_irq()
{
	count = free_tx_skb_slots;
	while (packets_transmitted) {
		dev_kfree_skb_irq(get_skb_from_hw());
		free_tx_skb_slot();
	}
	if (count == 0)
		netif_start_queue(dev);
}

Now the userland program does something like:

	struct sockaddr_ll tx_addr;

	ip_sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
        strcpy(ifr.ifr_name, "eth0");
	ioctl(ip_sock, SIOCGIFINDEX, &ifr);
	memset(&tx_addr, 0, sizeof(tx_addr));
	tx_addr.sll_family = AF_PACKET;
	tx_addr.sll_protocol = htons(ETH_P_ALL);
	tx_addr.sll_ifindex = ifr->ifr_ifindex;

	tx_sock = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL))
	while (1) {
		sendto(tx_sock, valid_packet_data, 1514, 0, tx_addr,
                       sizeof(tx_addr));
		print('X');
	}

The userland program sends multiple packets and then stops for a period
of several seconds.

What does it wait for?

It seems it's waiting in sock_wait_for_wmem(), at the end of
sock_alloc_send_pskb():

(schedule+0x0/0x6a0) from (schedule_timeout+0x90/0xd0)
(schedule_timeout+0x0/0xd0) from (sock_alloc_send_skb+0x178/0x268)
    r7:c6d01d2c r6:7fffffff r5:c6d00000 r4:c6c13800
(sock_alloc_send_skb+0x0/0x268) from (packet_sendmsg+0x100/0x28c)
(packet_sendmsg+0x0/0x28c) from (sock_sendmsg+0xb4/0xe4)
(sock_sendmsg+0x0/0xe4) from (sys_sendto+0xc8/0xf0)
    r9:c7b5c500 r8:beeb6dac r7:000005ea r6:c73a5580 r5:c6d01e9c r4:00000000
(sys_sendto+0x0/0xf0) from (sys_socketcall+0x154/0x1f4)
(sys_socketcall+0x0/0x1f4) from (ret_fast_syscall+0x0/0x2c)
    r4:00000014

The sequence of events from the device driver POV is:
...

xmit entering and using last skb slot
xmit queue full, netif_stop_queue(dev);
xmit exiting

(now the userland program waits)

xmit_ready_irq entering
xmit_ready_irq dev_kfree_skb_irq()
xmit_ready_irq xmit ready, netif_start_queue(dev);
xmit_ready_irq exiting

(now the TX restarts and the userland program sends another packets)

The above is repeated multiple times, then:

xmit entering and using last skb slot
xmit queue full, netif_stop_queue(dev);

xmit_ready_irq entering
xmit_ready_irq dev_kfree_skb_irq() (1 slot empty and ready for TX)
xmit_ready_irq xmit ready, netif_start_queue(dev);
xmit_ready_irq
xmit_ready_irq dev_kfree_skb_irq() (2 slots empty)

...

xmit_ready_irq dev_kfree_skb_irq() (15 slots empty)
xmit_ready_irq
xmit_ready_irq dev_kfree_skb_irq() (all 16 slots empty)
xmit_ready_irq exiting

(transmitter idle, but the userland program doesn't wake up)

The xmit() is not called again for several seconds, despite
netif_start_queue(dev) called from IRQ handler, all TX skb slots are
ready to be used for transmit.

I wonder if it's dev_kfree_skb_irq() which should but fails to wake
the thing up?

Doing "echo 197665 > /proc/sys/net/core/wmem_default" or
"echo 52824 > /proc/sys/net/core/wmem_default" apparently
"fixes" the problem, anything < 197665 and >= 52825 doesn't.
197665 = 65 * 3041, 52825 = 25 * 2113.

Doing "echo 25560 > /proc/sys/net/core/wmem_default" causes the driver
to never become "TX queue full" (IOW max 15 skb being transmitted),
25561 allows for "TX queue full".
25560 = 16 * 1597.5.
--
Krzysztof Halasa
