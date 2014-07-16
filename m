From: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Subject: Guest 8021q VLAN tags and macvtap
Date: Wed, 16 Jul 2014 16:15:39 -0400
Message-ID: <53C6DD6B.5090007@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:47645 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750922AbaGPUPn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 16:15:43 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mjrosato@linux.vnet.ibm.com>;
	Wed, 16 Jul 2014 16:15:43 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A537A6E802D
	for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 16:15:30 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6GKFeaf6619584
	for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 20:15:40 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6GKFd8j022226
	for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 16:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to commit 6acf54f1cf (macvtap: Add support of packet capture on
macvtap device), I was able to setup an environment where qemu guests
connected via macvtaps (eg, guest eth0 --> host macvtap0 --> host eth0)
could configure guest 8021q tagging and communicate with each other over
the vlan, with the guests being responsible for tagging/untagging. I
accomplished this by configuring the desired vlan id on both the guest
interface (guest eth0.123) as well as by adding the vlan to the
underlying host macvtap (macvtap0.123).  Configuring the id on the
macvtap was done to allow the tagged packets to get past the lowerdev.

Now, post 6acf54f1cf, guest-tagged traffic never arrives on the target
guest (untagged traffic is fine).  I did some tracing as a tagged packet
comes in on the target host, summarized:

1) __netif_receive_skb calls untag_vlan, vlan_tci is stashed,
vlan_do_receive returns false
2) rx_handler (macvlan_handle_frame) is called
3) netif_rx_ni is called, skb queued/dequeued (pass to macvtap)
4) __netif_receive_skb called again - vlan_do_receive is called
successfully, causing us to lose our stashed vlan_tci
5) rx_handler (macvtap_handle_frame) is called

My understanding is that macvtap expects packets to get untagged, and
intends to re-tag them later at macvtap_put_user.  But, because the
macvtap is vlan-enabled, the stashed vlan_tci is always gone because of
vlan_do_receive.

I think it boils down to the old macvtap_receive/forward logic not
calling vlan_do_receive, but now we do since we're using netif.  Was my
configuration wrong in the first place, or is this a bug?

FWIW, I hacked __netif_receive_skb to skip the vlan_do_receive call for
IFF_MACVLAN, and sure enough that restores my expected behavior, but
I'm not sure if that's the right solution.

Thanks,
Matt
