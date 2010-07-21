From: Stephen Hemminger <shemminger@vyatta.com>
Subject: mirred, redirect action vs. dev refcount issue
Date: Wed, 21 Jul 2010 16:24:26 -0700
Message-ID: <20100721162426.5aa4b646@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58791 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507Ab0GUXY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 19:24:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both the mirrored and redirect TC actions, hold a pointer to the
target device and increment the refcount.  The problem is that administrator
may want to remove the target device (for example ifb0) and this will
cause the kernel to get in the "can't delete ifb0 with references" state.

Fixing this isn't trivial but I think that the best way would be to have
the action API have a device notifier and walk the actions and call a new
hook (device_event) similar to existing walk. The device_event in the
action ops can then redirect any mirror/redirect that are going to a dead
device off to bit bucket.

Alternatively, the mirror/redirect could just use ifindex which is
a soft reference, so if device is removed, they just drop.

Lazy me favors the later.
