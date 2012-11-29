From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH][RESEND] bonding: delete migrated IP addresses from the rlb hash table
Date: Thu, 29 Nov 2012 13:10:07 -0800
Message-ID: <18712.1354223407@death.nxdomain>
References: <20120620203731.GA4957@midget.suse.cz> <2699.1340319919@death.nxdomain> <20121123124419.GA3002@midget.suse.cz> <26343.1354064725@death.nxdomain> <20121128143853.GA2485@midget.suse.cz> <20121128144214.GB2485@midget.suse.cz>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:60673 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275Ab2K2VLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 16:11:04 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 29 Nov 2012 16:11:03 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 11B546E803C
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 16:11:00 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qATLAxUO300556
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 16:11:00 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qATLA9CS019637
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 14:10:11 -0700
In-reply-to: <20121128144214.GB2485@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>Bonding in balance-alb mode records information from ARP packets
>passing through the bond in a hash table (rx_hashtbl).
>
>At certain situations (e.g. link change of a slave),
>rlb_update_rx_clients() will send out ARP packets to update ARP
>caches of other hosts on the network to achieve RX load
>balancing.
>
>The problem is that once an IP address is recorded in the hash
>table, it stays there indefinitely. If this IP address is
>migrated to a different host in the network, bonding still sends
>out ARP packets that poison other systems' ARP caches with
>invalid information.
>
>This patch solves this by looking at all incoming ARP packets,
>and checking if the source IP address is one of the source
>addresses stored in the rx_hashtbl. If it is, but the MAC
>addresses differ, the corresponding hash table entries are
>removed. Thus, when an IP address is migrated, the first ARP
>broadcast by its new owner will purge the offending entries of
>rx_hashtbl.
>
>The hash table is hashed by ip_dst. To be able to do the above
>check efficiently (not walking the whole hash table), we need a
>reverse mapping (by ip_src).
>
>I added three new members in struct rlb_client_info:
>   rx_hashtbl[x].src_first will point to the start of a list of
>      entries for which hash(ip_src) == x.
>   The list is linked with src_next and src_prev.
>
>When an incoming ARP packet arrives at rlb_arp_recv()
>rlb_purge_src_ip() can quickly walk only the entries on the
>corresponding lists, i.e. the entries that are likely to contain
>the offending IP address.
>
>To avoid confusion, I renamed these existing fields of struct 
>rlb_client_info:
>	next -> used_next
>	prev -> used_prev
>	rx_hashtbl_head -> rx_hashtbl_used_head
>
>(The current linked list is _not_ a list of hash table
>entries with colliding ip_dst. It's a list of entries that are
>being used; its purpose is to avoid walking the whole hash table
>when looking for used entries.)
>
>Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
