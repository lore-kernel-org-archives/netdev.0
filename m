From: Ben Hutchings <bhutchings@solarflare.com>
Subject: TX watchdog vs link-layer flow control
Date: Thu, 02 Jun 2011 21:48:40 +0100
Message-ID: <1307047720.2812.59.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:35483 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252Ab1FBUsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:48:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TX watchdog will fire if and only if a TX queue remains stopped for
a certain period for no apparent reason.  Specifically, it requires
netif_device_present(dev) && netif_running(dev) &&
netif_carrier_ok(dev).

However, even if the link is up it can still be blocked by link-layer
flow control.  A customer report (which has not yet been reproduced
here) suggests that when Ethernet flow control is enabled a switch may
in some circumstances throttle the TX packet rate to the extent that a
TX queue cannot be unblocked before the watchdog fires.  It is certainly
possible for a misbehaving link partner to do this, and this should
probably not be considered as a bug in the local hardware or driver!

TX may also be blocked by a 'remote fault' indication.  This should
possibly be translated into netif_carrier_off(), but I'm not sure that
all drivers will be able to detect remote fault without polling.

Perhaps dev_watchdog() should support a driver operation to poll for
cases like this before it decides that the local device is actually
misbehaving?

Even then, I can't think of a reliable way to detect a pause frame
flood.  Also, drivers might well require process context for such an
operation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

