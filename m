From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Tue, 03 Nov 2015 19:33:22 +0200
Message-ID: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:57653 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbbKCRdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 12:33:36 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 39CC9480FD2
	for <netdev@vger.kernel.org>; Tue,  3 Nov 2015 19:33:30 +0200 (EET)
Received: from webmail.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id CF695480FD2
	for <netdev@vger.kernel.org>; Tue,  3 Nov 2015 19:33:22 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Recently i was testing shaping over single 10G cards, for speeds up to 
3-4Gbps, and noticed interesting effect.

Shaping scheme:
Incoming bandwidth comes to switch port, with access vlan 100
Outgoing bandwidth leaves switch port with access vlan 200
Linux with Intel X710 connected to trunk port, bridge created, eth0.100 
bridged to eth0.200
gso/gro/tso disabled (they doesn't work nice with shapers)
Sure latest kernel

Shaper are installed on eth0.200, and seems multiqueue works on eth0 in 
general (i see packets are distributed over each queue), CPU load is 
very low (max 20% on core, but usually below 5%).
I tried:
HTB with fq, pfifo, pie qdisc
HFSC with fq, pfifo, pie qdisc

After i run shaper with default values, i can see traffic start to queue 
in classes and total traffic doesn't reach more than 2.4Gbit, and if i 
remove shaper it directly reach 4Gbit.
The only trick i found, it is running pie with burst 10000 cburst 10000 
in leaf classes, and 100000 in root class (i think 10000 in root class 
might work as well). If i change discipline to fq, i am returning back 
to 2.4Gbit, but it might be just because fq is not intended to be used 
with HTB leaf class.
So in my case burst/cburst solved issue, but i suspect maybe possible 
more elegant solution/tuning, than putting some random values?
Is there any particular reason why i am limited by ~2.4Gbit on any other 
settings?
