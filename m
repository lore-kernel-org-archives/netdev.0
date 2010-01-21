From: Ben Hutchings <bhutchings@solarflare.com>
Subject: VLAN vs bridging receive precedence
Date: Thu, 21 Jan 2010 16:11:27 +0000
Message-ID: <1264090287.2794.34.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:32806 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab0AUQLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 11:11:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a physical device is attached to a bridge device and also to one or
more VLAN devices, received tagged frames might be passed on to either
the appropriate VLAN device or to the bridge.

Drivers that support VLAN receive acceleration call __vlan_hwaccel_rx(),
which updates skb->dev to point to the VLAN device.

In the absence of VLAN receive acceleration, 802.1q is treated as just
another protocol, and netif_receive_skb() does:

	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
	if (!skb)
		goto out;
	...
	type = skb->protocol;
	list_for_each_entry_rcu(ptype,
			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
		...
	}

So the bridge device claims the skb before the VLAN code has a chance
to.

It is not clear which behaviour is 'correct'.  However it appears that
the XenCenter network management software currently depends on the
accelerated behaviour.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

