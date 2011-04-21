From: Ben Hutchings <bhutchings@solarflare.com>
Subject: rtnetlink and many VFs
Date: Thu, 21 Apr 2011 15:36:16 +0100
Message-ID: <1303396576.3165.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28778 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754277Ab1DUOgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 10:36:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My colleagues have been working on SR-IOV support for sfc.  The hardware
supports up to 127 VFs per port.

If we configure all 127 VFs through the net device, an RTM_GETLINK dump
will need to include messages describing them, with a total size of:

127 * (sizeof(struct ifla_vf_mac) + sizeof(struct ifla_vf_vlan) +
       sizeof(struct ifla_vf_tx_rate) + protocol overhead)
> 7112

These messages are nested within the message describing the device as a
whole, so they cannot be split.  The maximum size of an outgoing netlink
message, based on NLMSG_GOODSIZE, seems to be min(PAGE_SIZE, 8192).  So
when PAGE_SIZE = 4096 it is simply impossible to dump information about
such a device!

I think it needs to be made possible to grow a netlink skb during
generation of the first message.  Userspace may still be unable to
receive the large message but at least it has a chance.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

