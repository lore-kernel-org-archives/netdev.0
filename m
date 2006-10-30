From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Lost packets after switching Wi-Fi AP
Date: Mon, 30 Oct 2006 15:55:57 +0100
Message-ID: <4546127D.10403@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:27373 "EHLO
	ecfrec.frec.bull.fr") by vger.kernel.org with ESMTP id S964940AbWJ3Ow7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 09:52:59 -0500
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id E156F19D994
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 15:52:50 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 32743-05 for <netdev@vger.kernel.org>;
 Mon, 30 Oct 2006 15:52:46 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id A163019D98E
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 15:52:25 +0100 (CET)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I work on an extension of the mobility protocol for IPv6 
(FMIPv6-RFC4068) and I've noticed the following problem:

When I switch my Mobile Node between 2 Wi-Fi Access Points, there is a 
period of time where all the packets I send are lost, although I got 
the netlink event SIOCGIWAP 'up' for the new AP. The device is 
supposed to be ready, but the packets are lost.

By 'lost', I mean: silently discarded by the kernel, no error returned 
to the user-space application sending the packet, packets never appear 
on the network monitored with wireshark.

Here is the setup:
------------------

1. The daemon decides to switch from one AP to the other for some 
reason (better link quality, ...) and set the new ESSID, etc.

2. The daemon waits for the SIOCGIWAP 'up' netlink event.

3. SIOCGIWAP received: the daemon sends a unique Mobility Header 
packet using a raw socket to its new router to signal it has 
successfully moved. sendmsg() returned 0, no error, but the packet 
never shows up.

- The interface has an IPv6 address configured for the new network 
(previously created).
- There is a route between the node and the router.
- I set the socket option IPV6_RECVERR to get all the errors, but none 
shows up.
- The "black hole" period lasts for about 500ms after the SIOCGIWAP 
event. Every packets sent during this period are lost.
- I tried to get the interface status before sending the packet 
(ioctl(SIOCSIFFLAGS)) but I got a perfect IFF_UP|IFF_RUNNING.

What I've found in the kernel:
------------------------------

- The packet is discarded in the packet scheduler in 
net/sched/sch_generic.c::noop_enqueue() which returns NET_XMIT_CN.

- The error doesn't go up to the application because 
net/ipv6/ip6_output.c::ip6_push_pending_frames() filters this type of 
error (using net_xmit_errno(err)).

- noop_enqueue() is used to enqueue the packet because the device has 
been deactivated by link_watch_run_queue() calling dev_deactivate(). 
The device is re-activated about 500ms later.

- According to net/sched/sch_api.c, NET_XMIT_CN means "probably this 
packet enqueued, but another one dropped". But it seems to me that 
this packet IS actually dropped in noop_enqueue() (kfree_skb()). 
Shouldn't the routine return NET_XMIT_DROP instead? Then the 
application should be able to get the error code when the device is 
deactivated and retry later?


My questions:
-------------

- Am I doing something obviously wrong? Is there another event I 
should expect before sending my packet? An event that signals more 
reliably that the link is up and running and associated with the new AP?

- Shouldn't we change the return code in noop_enqueue()?


Thanks a lot for your help,
Benjamin

-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
