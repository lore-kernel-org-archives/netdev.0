From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding device in balance-alb mode shows packet loss in kernel 3.2-rc6
Date: Wed, 28 Dec 2011 12:08:30 -0800
Message-ID: <27384.1325102910@death>
References: <E31FB011129F30488D5861F38390491520C52BCC8B@BLRX7MCDC201.AMER.DELL.COM>
Cc: netdev@vger.kernel.org
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:41891 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754165Ab1L1UJG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 15:09:06 -0500
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 28 Dec 2011 15:09:04 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBSK8WJo292266
	for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 15:08:32 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBSK8Vpa007684
	for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 13:08:31 -0700
In-reply-to: <E31FB011129F30488D5861F38390491520C52BCC8B@BLRX7MCDC201.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<Narendra_K@Dell.com> wrote:

>Hello,
>
>On kernel version 3.2-rc6, when a bonding device is configured in 'balance-alb' mode,
>ping reported packet losses. By looking at protocol trance, it seemed like the lost
>packets had the destination MAC id of inactive slave. 

	In balance-alb mode, there isn't really an "inactive" slave in
the same sense as for active-backup mode.  For this mode, the "inactive"
slave flag is used to suppress duplicates for multicast and broadcasts,
to prevent multiple copies of those from being received (if each slave
gets one copy).  Unicast traffic should pass normally to all slaves.
Each slave also keeps a discrete MAC address, and peers are assigned to
particular slaves via tailored ARP messages (so, different peers may see
a different MAC for the bond's IP address).

>Scenario:
>
>Host under test:
>
>bond0 IP addr: 10.2.2.1 - balance-alb mode, 2 or more slaves.
>
>Remote Host1: 10.2.2.11
>
>Remote Host2: 10.2.2.2
>
>Ping to Host 1 IP. Observe that there is no packet loss
>
># ping 10.2.2.11
>PING 10.2.2.11 (10.2.2.11) 56(84) bytes of data.
>64 bytes from 10.2.2.11: icmp_seq=1 ttl=64 time=0.156 ms
>64 bytes from 10.2.2.11: icmp_seq=2 ttl=64 time=0.130 ms
>64 bytes from 10.2.2.11: icmp_seq=3 ttl=64 time=0.151 ms
>64 bytes from 10.2.2.11: icmp_seq=4 ttl=64 time=0.137 ms
>64 bytes from 10.2.2.11: icmp_seq=5 ttl=64 time=0.151 ms
>64 bytes from 10.2.2.11: icmp_seq=6 ttl=64 time=0.129 ms
>^C
>--- 10.2.2.11 ping statistics ---
>6 packets transmitted, 6 received, 0% packet loss, time 4997ms
>rtt min/avg/max/mdev = 0.129/0.142/0.156/0.014 ms
>
>Now ping to Host2 IP. Observe that there is packet loss. It is reproducible almost
>always.
>
># ping 10.2.2.2
>PING 10.2.2.2 (10.2.2.2) 56(84) bytes of data.
>64 bytes from 10.2.2.2: icmp_seq=6 ttl=64 time=0.108 ms
>64 bytes from 10.2.2.2: icmp_seq=7 ttl=64 time=0.104 ms
>64 bytes from 10.2.2.2: icmp_seq=8 ttl=64 time=0.119 ms
>64 bytes from 10.2.2.2: icmp_seq=56 ttl=64 time=0.139 ms
>64 bytes from 10.2.2.2: icmp_seq=57 ttl=64 time=0.111 ms
>^C
>--- 10.2.2.2 ping statistics ---
>75 packets transmitted, 5 received, 93% packet loss, time 74037ms
>rtt min/avg/max/mdev = 0.104/0.116/0.139/0.014 ms
>
>More information:
>
>Hardware information: 
>Dell PowerEdge R610
>
># lspci | grep -i ether
>01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
>01:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
>02:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
>02:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
>
>Kernel version:
>3.2.0-rc6
>
># ethtool -i bond0
>driver: bonding
>version: 3.7.1
>
>By observing the packets on remote HOST2, the sequence is
>
>1. 'bond0' broadcasts an ARP request with source MAC equal to
>'bond0' MAC address and receives a ARP response to the same.
>Next few packets are received.

	In this case, it means the peer has been assigned to the "em2"
slave.

>2. After some, there are 2 ARP replies from 'bond0' to HOST2
>with source MAC equal to 'inactive slave' MAC id. Now HOST2 sends
>ICMP response with destnation MAC equal to inactive slave MAC id
>and these packets are dropped.

	This part is not unusual for the balance-alb mode; the traffic
is periodically rebalanced, and in this case the peer HOST2 was likely
assigned to a different slave that it was previously.  I'm not sure why
the packets don't reach their destination, but they shouldn't be dropped
due to the slave being "inactive," as I explained above.

>The wireshark protocol trace is attached to this note.
>
>3. The behavior was independent of the Network adapters models.
>
>4. Also, I had few prints in 'eth_type_trans' and it seemed like the 'inactive slave'
>was not receiving any frames destined to it (00:21:9b:9d:a5:74) except ARP broadcasts.
>Setting the 'inactive slave' in 'promisc' mode made bond0 see the responses.

	This seems very strange, since the MAC information shown later
suggests that the slaves all are using their original MAC addresses, so
the packets ought to be delivered.

	I'm out of the office until next week, so I won't have an
opportunity to try and reproduce this myself until then.  I wonder if
something in the rx_handler changes over the last few months has broken
this, although a look at the code suggests that it should be doing the
right things.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
