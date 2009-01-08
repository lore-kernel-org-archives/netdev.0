From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] hdlc: fix compile problem
Date: Thu, 08 Jan 2009 02:00:00 +0100
Message-ID: <m3tz8atxwv.fsf@maximus.localdomain>
References: <20090107141343.3e256119@extreme>
	<m3d4eyvh28.fsf@maximus.localdomain> <20090107152858.6fb8ac5d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:53361 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753436AbZAHBAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 20:00:03 -0500
In-Reply-To: <20090107152858.6fb8ac5d@extreme> (Stephen Hemminger's message of "Wed\, 7 Jan 2009 15\:28\:58 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> It was introduced (by me) in previous patch. Since that isn't applied yet,
> I'll go back and fix.

I can see it now, I must have missed it because of the "synclink"
subject.

@@ -106,7 +98,7 @@ static int hdlc_device_event(struct noti
        if (dev_net(dev) != &init_net)
                return NOTIFY_DONE;
 
-       if (dev->get_stats != hdlc_get_stats)
+       if (dev->header_ops != &hdlc_null_ops)
                return NOTIFY_DONE; /* not an HDLC device */

This won't work because hdlc_null_ops may be substituted by
cisco_header_ops or ppp_header_ops. Current test works for now but is
wrong, too, at least for wanxl driver (it tries to use its
get_stats()).

Perhaps some
+       if (dev->header_ops->something != &something)
would do? Alternatively we can return to hdlc_carrier_on|off() and
hdlc_device_event() won't be needed.

Essentially, it's a bit hard to check if the device is one of ours if
we are the middle layer.


There are two layers here:
- hardware drivers (10+)
- protocol drivers (5 - hdlc* files)

Protocol drivers want to define things like:
- dev->header_ops (no problem)
- dev->change_mtu (perhaps)
- dev->hard_start_xmit

Hardware drivers need to define the rest of NDO.

Hmm, not much, only hard_start_xmit() is really problematic. I think
we need a trampoline: hw driver will define the NDO and set
hard_start_xmit and possibly change_mtu to (exported by hdlc.c)
hdlc_xmit (hdlc_change_mtu), and hdlc_start_xmit will just call
protocol's xmit().
We could also use it for the test in hdlc_device_event:
	if (dev->netdev_ops->start_hard_xmit != hdlc_xmit)

If we could then get rid of this special xmit() and do all header and
TX preparations in hard_header(), it would be even better (cleaner)
though IIRC it requires some changes to Ethernet(?) code.


The changes have to be applied to the 4 synclink drivers and to most
.c files in drivers/net/wan simultaneously, perhaps it's more practical
if I do it?
-- 
Krzysztof Halasa
