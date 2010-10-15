From: Jonathan Thibault <jonathan@navigue.com>
Subject: large divisor for flow classifier
Date: Fri, 15 Oct 2010 14:14:15 -0400
Message-ID: <4CB899F7.0@navigue.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.navigue.com ([74.117.40.3]:53860 "EHLO mail.navigue.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756655Ab0JOSPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 14:15:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 It appears that when setting a fairly large divisor on the flow classifier for sfq, traffic stops altogether.

On my machine, anything above divisor 2200 seems to stop all traffic.  If I want to be fair between hosts (but not flows) for a large network (say 6000 hosts), I run into problems.  Obviously the rates here are quite low but this is just an example.

I also tested on a real interface with the same results.

Example that works:

tc qdisc add dev ifb0 root handle 3: htb default 10
  tc class add dev ifb0 parent 3: classid 3:1 htb rate 80kbit
    tc class add dev ifb0 parent 3:1 classid 3:10 htb rate 80kbit
      tc qdisc add dev ifb0 parent 3:10 handle 310: sfq perturb 10
      tc filter add dev ifb0 parent 3: protocol all prio 1 u32 match mark 0x000 0xf00 flowid 3:10
      tc filter add dev ifb0 parent 310: protocol all handle 0x310 flow hash keys dst divisor 1024

Example that doesn't work:

tc qdisc add dev ifb0 root handle 3: htb default 10
  tc class add dev ifb0 parent 3: classid 3:1 htb rate 80kbit
    tc class add dev ifb0 parent 3:1 classid 3:10 htb rate 80kbit
      tc qdisc add dev ifb0 parent 3:10 handle 310: sfq perturb 10
      tc filter add dev ifb0 parent 3: protocol all prio 1 u32 match mark 0x000 0xf00 flowid 3:10
      tc filter add dev ifb0 parent 310: protocol all handle 0x310 flow hash keys dst divisor 6144

Jonathan
