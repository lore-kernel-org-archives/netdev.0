From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Question on the use of ETH_P_CONTROL
Date: Wed, 24 Apr 2013 11:17:50 -0700
Message-ID: <517821CE.207@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:54580 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756857Ab3DXSSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 14:18:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a wired Ethernet driver that will need to support a user space
application with UIO access and a network device.  The network device
will need a way to send raw frames with some descriptor data to and from
the user space application.  The frames are not meant to be routed and
are not meant for this host, only for the user space application.  After
doing some digging I came across the definition for ETH_P_CONTROL, which
seems to be a good solution for my current issue.

My thought is to do something like this for Rx control frames:
	eth_type_trans(skb);
	skb->protocol = htons(ETH_P_CONTROL);
	skb->mac_header -= sizeof(struct desc_hdr);
	desc_hdr = (struct desc_hdr *)skb_mac_header(skb);
	desc_hdr->val = val;

For frames received from the user space application I would essentially
just leave the descriptor header on and notify the hardware that it is
present for any frames received that have ETH_P_CONTROL as their protocol.

Then all that is left is for the user space to allocate a raw packet
socket and bind it to our interface specifying the control protocol so
that it can send and receive just the control frames.

I'm looking for any thoughts, issues, or concerns with this approach.

Thanks,

Alex
