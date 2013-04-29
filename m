From: David Miller <davem@davemloft.net>
Subject: Re: Question on the use of ETH_P_CONTROL
Date: Mon, 29 Apr 2013 13:42:44 -0400 (EDT)
Message-ID: <20130429.134244.1920449745404305505.davem@davemloft.net>
References: <517821CE.207@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757279Ab3D2Rmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 13:42:46 -0400
In-Reply-To: <517821CE.207@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 24 Apr 2013 11:17:50 -0700

> I have a wired Ethernet driver that will need to support a user space
> application with UIO access and a network device.  The network device
> will need a way to send raw frames with some descriptor data to and from
> the user space application.  The frames are not meant to be routed and
> are not meant for this host, only for the user space application.  After
> doing some digging I came across the definition for ETH_P_CONTROL, which
> seems to be a good solution for my current issue.
> 
> My thought is to do something like this for Rx control frames:
> 	eth_type_trans(skb);
> 	skb->protocol = htons(ETH_P_CONTROL);
> 	skb->mac_header -= sizeof(struct desc_hdr);
> 	desc_hdr = (struct desc_hdr *)skb_mac_header(skb);
> 	desc_hdr->val = val;
> 
> For frames received from the user space application I would essentially
> just leave the descriptor header on and notify the hardware that it is
> present for any frames received that have ETH_P_CONTROL as their protocol.
> 
> Then all that is left is for the user space to allocate a raw packet
> socket and bind it to our interface specifying the control protocol so
> that it can send and receive just the control frames.
> 
> I'm looking for any thoughts, issues, or concerns with this approach.

I looked this over briefly a few nights ago, and the only other place I
see this used is the hostap driver.  hostap is a big body of code that
does lot of things in unique and rather ad-hoc ways.

hostap was written in an environment where interfaces and
infrastructure for what it wanted to do didn't exist, so the author
just did his own thing in each and every such instance.

I want to encourage you to steer away from that kind of approach.

Although I'm cautiously skeptical, you may not end up being the only
other person trying to push descriptors into the kernel from userspace
and then trigger device TX/RX.  If every driver makes it's own control
plane for this, wait for troubles...
