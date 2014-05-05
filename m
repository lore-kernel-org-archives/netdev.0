From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 0/2] net: ip: push gso skb forwarding handling down the stack
Date: Mon,  5 May 2014 15:00:42 +0200
Message-ID: <1399294844-7231-1-git-send-email-fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36395 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932187AbaEENGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 09:06:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turns out doing the segmentation in forwarding was not a bright idea,
there are corner-cases where this has unintended side-effects.

This patch pushes the segmentation downwards.

After this, netif_skb_dev_features() function can be removed
again, it was only added to fetch the features of the output device,
we can just use skb->dev after the pushdown.

Tested with following setup:

host -> kvm_router  -> kvm_host
  mtu 1500        mtu1280

- 'host' has route to kvm_host with locked mtu of 1500
- gso/gro enabled on all interfaces

Did tests with all of following combinations:
- netfilter conntrack off and on on kvm_router
- virtio-net and e1000 driver on kvm_router
- tcp and udp bulk xmit from host to kvm_host

for tcp, I added TCPMSS mangling on kvm_host to make it lie about tcp mss.

Also added a dummy '-t mangle -A POSTROUTING -p udp -f'
rule to make sure no udp fragments are seen in the 'conntrack on'
and 'virtio-net' case.

Also checked (with ping -M do -s 1400)' that it still sends the wanted
icmp error message when size exceeds 1280.
