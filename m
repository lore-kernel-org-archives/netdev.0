From: Mattias =?utf-8?Q?R=C3=B6nnblom?= <hofors@lysator.liu.se>
Subject: VLAN egress performance
Date: Mon, 08 Feb 2010 13:24:44 +0100
Message-ID: <87wrynrk37.fsf@isengard.friendlyfire.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lysator.liu.se ([130.236.254.3]:37542 "EHLO
	mail.lysator.liu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab0BHMYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 07:24:45 -0500
Received: from mail.lysator.liu.se (localhost [127.0.0.1])
	by mail.lysator.liu.se (Postfix) with ESMTP id 79CA340016
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2010 13:22:59 +0100 (CET)
Received: from fritz.lysator.liu.se (fritz.lysator.liu.se [130.236.254.179])
	by mail.lysator.liu.se (Postfix) with ESMTP id 35E2E40016
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2010 13:22:59 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I'm running Linux on PC w/ a Core i7 CPU and two Intel 82598 NICs, and
I see some anomalies when it comes to egress VLAN performance. I
thought maybe someone on this list was interested in my results.

I'm running the stock Ubuntu 2.6.31 kernel, but with a newer ixgbe
driver (2.0.44.14).

The benchmark is IP forwarding with unidirectional UDP flows @ 64 byte
packets, and I get:

Ingress VLAN  Egress VLAN  Packet Rate    CPU utilization (all cores)
No            No           5.0 Mpacket/s  ~70%
Yes           No           5.0 Mpacket/s  ~75%
No            Yes          1.4 Mpacket/s  ~26%
Yes           Yes          1.3 Mpacket/s  ~26%

"VLAN" here mean I've put a VLAN device on top of the real ixgbe
device.

As you can see, if the egress i/f is a VLAN i/f, the performance is
reduced to less than a third. And in the case of egress VLAN, the
systems basically only uses one HW thread (with a softirqd process
taking up all the time).

Enabling lockdep, it looks like execution is serialized to a large
extent by contention around the "vlan_netdev_xmit_lock_key" lock.

I call this anomaly because I was surprised to see it (as oppose to
other performance degradations/scalability issues in the area of
multicore and IP traffic handling performance).

Does anyone know how difficult it would be to resolve this?  There's
not actually any synchronization needed between the different cores in
the case of VLAN. Correct? This is just an artefact of how the
implementation is done?

I looked briefly at the code, and I must admit I had some trouble
understanding where the flow in terms of locking.

Best regards,
     Mattias
