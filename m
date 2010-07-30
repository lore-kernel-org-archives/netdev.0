From: Johannes Berg <johannes@sipsolutions.net>
Subject: RPS vs. hard-irq-context netif_rx()
Date: Fri, 30 Jul 2010 15:03:47 +0200
Message-ID: <1280495027.3710.13.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:49355 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756427Ab0G3NC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 09:02:26 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <johannes@sipsolutions.net>)
	id 1OepEG-0001xQ-IO
	for netdev@vger.kernel.org; Fri, 30 Jul 2010 15:02:24 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got the following on a kvm instance I use for testing:

[   51.358803] WARNING: at kernel/lockdep.c:2327 trace_hardirqs_on_caller+0x167/0x200()
[   51.360210] Hardware name: Bochs
[   51.360210] Modules linked in:
[   51.360210] Pid: 1546, comm: dhclient3 Tainted: G        W   2.6.35-rc6-wl+ #588
[   51.360210] Call Trace:
[   51.360210]  <IRQ>  [<ffffffff8104e87f>] warn_slowpath_common+0x7f/0xc0
[   51.360210]  [<ffffffff8104e8da>] warn_slowpath_null+0x1a/0x20
[   51.360210]  [<ffffffff81087977>] trace_hardirqs_on_caller+0x167/0x200
[   51.360210]  [<ffffffff81087a1d>] trace_hardirqs_on+0xd/0x10
[   51.360210]  [<ffffffff81056ade>] local_bh_enable+0x9e/0x130
[   51.360210]  [<ffffffff8139fa82>] netif_rx+0xc2/0x250
[   51.360210]  [<ffffffff813146d7>] ei_receive+0x1b7/0x2c0
[   51.360210]  [<ffffffff81314ca2>] __ei_interrupt+0x282/0x360
[   51.360210]  [<ffffffff81314dce>] ei_interrupt+0xe/0x10
[   51.360210]  [<ffffffff810abe85>] handle_IRQ_event+0x85/0x300
[   51.360210]  [<ffffffff810aead5>] handle_level_irq+0x95/0x120
[   51.360210]  [<ffffffff81005a12>] handle_irq+0x22/0x30
[   51.360210]  [<ffffffff814394b3>] do_IRQ+0x73/0xf0
...


The reason seems to be that
 * RCU_TREE uses local_bh_disable/enable
 * CONFIG_RPS uses RCU within netif_rx()
 * the driver I'm using calls netif_rx() within the irq context

So .. where's the bug? I'd point to CONFIG_RPS since it's newest.

johannes

