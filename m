From: Jan Kiszka <jan.kiszka@web.de>
Subject: d80211: ieee80211_hw handlers in atomic context
Date: Wed, 04 Oct 2006 17:59:57 +0200
Message-ID: <4523DA7D.2080604@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Ivo Van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:60105 "EHLO
	fmmailgate03.web.de") by vger.kernel.org with ESMTP
	id S1161351AbWJDQAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 12:00:00 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jiri,

Ivo suggested to bring this issue to a broader audience, specifically to
the stack maintainer.

Trying to run my Asus WL167G with rt2500usb I faced the following:

BUG: scheduling while atomic: swapper/0x00000102/0
 <c0103055> show_trace+0x12/0x14
 <c01035e0> dump_stack+0x1c/0x1e
 <c025fad1> schedule+0x5f/0x652
 <c0260324> wait_for_completion+0xb8/0x134
 <d0988fa1> usb_start_wait_urb+0x89/0xcb [usbcore]
 <d0989192> usb_control_msg+0xb2/0xcc [usbcore]
 <d089d127> rt2x00_vendor_request+0x85/0xbb [rt2500usb]
 <d08a1350> rt2500usb_config+0x5e/0x3d7 [rt2500usb]
 <d0823496> ieee80211_hw_config+0x2c/0x93 [80211]
 <d0829950> ieee80211_ioctl_siwfreq+0x132/0x141 [80211]
 <d082ee8b> ieee80211_sta_join_ibss+0xcc/0x5af [80211]
 <d082f698> ieee80211_sta_find_ibss+0x32a/0x374 [80211]
 <d08317f8> ieee80211_sta_timer+0x81/0x1b4 [80211]
 <c011ac50> run_timer_softirq+0x171/0x205
 <c0117536> __do_softirq+0x41/0x90
 <c01175bc> do_softirq+0x37/0x4a
 <c01176b7> irq_exit+0x2d/0x45
 <c0104316> do_IRQ+0x53/0x5f

The reason is the invocation of rt2500usb's config handler in atomic
context (timer handler). But this service requires schedulable context
to submit and wait for some URBs.

That raises the question how to resolve the conflict best, at stack
level by pushing such work into thread context (workqueues?) or at
driver level by deferring these requests (if feasible at all without
breaking the stack's timing)? What other callback handlers in
ieee80211_hw can currently be called in atomic context? Given that all
USB WLAN adapters will have to cope with this issue in some way, it may
be wise to find a common solution.

Ivo told me about a patch for d80211 that moved certain timers to thread
context, effectively avoiding to call config from timer handlers, but I
didn't find any trace yet. Is there some modification in this direction
already scheduled? I'm not necessarily looking for work, at best I would
just enjoy to use it. ;)

Jan
