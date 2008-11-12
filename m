From: Ben Greear <greearb@candelatech.com>
Subject: ARP table question
Date: Wed, 12 Nov 2008 11:43:39 -0800
Message-ID: <491B31EB.4050304@candelatech.com>
References: <491B1600.4080505@candelatech.com> <491B1841.9050404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38401 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbYKLTno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 14:43:44 -0500
In-Reply-To: <491B1841.9050404@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have 500 mac-vlans on a system talking to 500 other
mac-vlans.  My problem is that the arp-table gets extremely
huge because every time an arp-request comes in on all mac-vlans,
a stale arp entry is added for each mac-vlan.  I have filtering
turned on, but that doesn't help because the neigh_event_ns call
below will cause a stale neighbor entry to be created regardless
of whether a replay will be sent or not.

Maybe the neigh_event code should be below the checks for dont_send,
and only create check neigh_event_ns if we are !dont_send?


This is the code I'm talking about, in arp.c (in kernel 2.6.25.15)


	if (arp->ar_op == htons(ARPOP_REQUEST) &&
	    ip_route_input(skb, tip, sip, 0, dev) == 0) {

		rt = (struct rtable*)skb->dst;
		addr_type = rt->rt_type;

		if (addr_type == RTN_LOCAL) {
			n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
				int dont_send = 0;

				if (!dont_send)
					dont_send |= arp_ignore(in_dev,sip,tip);
				if (!dont_send && IN_DEV_ARPFILTER(in_dev))
					dont_send |= arp_filter(sip,tip,dev);
				if (!dont_send)
					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

