From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NETDEV WATCHDOG: eth1 (r8169): transmit queue 0 timed out
Date: Wed, 5 Dec 2012 21:08:22 +0000
Message-ID: <1354741702.2655.46.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121205011910.GA16531@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17076 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354Ab2LEVIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:08:25 -0500
In-Reply-To: <20121205011910.GA16531@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-04 at 20:19 -0500, Dave Jones wrote:
> We continue to see warnings like this reported against the Fedora kernel
> for a number of different NICs. I just hit this one myself for the first time
> on that hardware iirc.
> 
> Anything else I can provide ?
[...]

In general, useful information might include:
- was this preceded by any interface reconfiguration or link changes?
- extended network stats (ethtool -S)
- MDIO register dump (mii-tool -vv) (if the interface has an MDIO PHY)

Having seen this error many times with different causes, I wrote a short
summary for the support team here, which (with some references removed)
may be generally useful:

---
The watchdog will fire if all these conditions are met:
1. The interface is up
2. A TX queue is stopped (normally because it is full)
3. No packets have been added to the queue in the last 5 seconds
4. The driver has not told the kernel that the device is unable to
transmit now (e.g. link is down).

Conditions 2 and 3 together normally mean that the TX queue has been
stopped for 5 seconds and therefore that few packets (not necessarily
none at all) have been completed in that time.  The time taken for
individual packets to be completed is *not* considered.

This can happen due to:
a. Driver bug causing conditions 2 and 4 to be true during
reconfiguration
b. MAC blocked by a pause frame flood
c. IRQ handling is delayed by a long time (can happen due to excessive
serial logging)
d. Firmware bug causes driver to see link as up when it's not
e. Hardware fault (always a possibility)
---

Item d should really be expanded to hardware/firmware/software bug.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
