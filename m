From: Andrew Gallatin <gallatin@myri.com>
Subject: gro vs vlan in myri10ge
Date: Thu, 08 Nov 2012 21:20:08 -0500
Message-ID: <509C6858.6010105@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:47612 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756980Ab2KICUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 21:20:11 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so727021yhm.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 18:20:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've wanted to convert myri10ge from LRO to GRO for quite a while.
The problem I'm facing is that the NIC cannot perform hardware vlan
tag offload, so GRO performance is far below LRO performance when
receiving vlan tagged TCP traffic.

If a vlan tagged frame is passed to lro_receive_frags(), inet_lro will
look at the encapsulated IPv4 frame and TCP aggregation will succeed.
However, it appears that GRO will not do this.  When I patch the
driver to use GRO, and configure a vlan interface, I see high CPU
utilization and poor bandwidth when I'm receiving a netperf TCP stream
on the vlan interface.  If I use LRO in an unpatched driver, then I
see good receive performance in the same scenario.

What is the best way to "fix" this?

Unless I'm just using GRO wrong, it seems that the simplest thing for
me to do is to claim NETIF_F_HW_VLAN_RX, but pop the tags in the
driver so as to allow myri10ge to pass up a non-encapsulated frame the
same way that (nearly?) every other 10GbE NIC does.  I've got a quick
and dirty patch that confirms doing the vtag pop in the driver gives
me roughly the same performance with GRO as I used to have with LRO.

Is this (popping vlan tags in the driver) acceptable, or is it
too much of a layering violation?

Thanks,

Drew
