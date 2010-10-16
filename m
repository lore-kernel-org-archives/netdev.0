From: Patrick Ringl <patrick_@freenet.de>
Subject: 2.6.36-rc7: net/bridge causes temporary network I/O lockups [2]
Date: Sat, 16 Oct 2010 20:15:31 +0200
Message-ID: <4CB9EBC3.4070905@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout6.freenet.de ([195.4.92.96]:35338 "EHLO mout6.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753030Ab0JPSPn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Oct 2010 14:15:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

okay I narrowed down the issue. I watched all function calls of the 
'bridge' module with the help of a small systemtap probe of mine. I 
first traced a timespan where the issue did not occur, then one where it 
did and composed an intersection of these two:

br_fdb_cleanup
br_flood
br_flood_forward
br_ip4_multicast_add_group
br_ip4_multicast_alloc_query
br_ip4_multicast_leave_group
br_ip6_multicast_alloc_query
br_mdb_get
br_multicast_alloc_query
br_multicast_flood
br_multicast_forward
br_multicast_ipv4_rcv
br_multicast_port_query_expired
br_multicast_query_expired
br_multicast_rcv
__br_multicast_send_query
br_multicast_send_query

igmp_hdr
ip_hdrlen
ipv6_addr_copy
ipv6_addr_set
ipv6_eth_mc_map
ipv6_hdr

maybe_deliver
netdev_alloc_skb
netdev_alloc_skb_ip_align

skb_checksum_complete
__skb_pull
__skb_push
skb_reserve
skb_reset_transport_header
skb_set_network_header
skb_set_transport_header

These are the function calls that are exclusively called during the 
'nonfunctional'-timespan.

This again gave me the idea to use tcpdump and watch out for igmp and 
v6. Well, and that is also where the issue is coming from.

Once a multicast membership query (igmp) arrives, A multicast listener 
query (icmpv6) is sent.
  From my understanding of the bridge code br_flood will propgate the 
packet to all nodes (simple multicast) and this is also where things 
stop working. Systemtap itself and thus in my case function calls of the 
bridge module are not delayed, but something needs to be wrong in the 
multicast handling of the bridge interface, since as pointed out in my 
previous email with 2.6.32 everything is working fine.

Can anyone reconfirm this issue, or give a helping hand in how to 
proceed further?

PS: Herbert, I've seen your changes for 2.6.34 which I think are 
responsible for this behavior (even 2.6.33 here works fine. Anything 
containing your multicast-related fixed breaks here).
Could you specifically take a look into it and/or tell me how I can help 
you?

PPS: Again please CC back to me, since I am not subscribed

regards,
Patrick

