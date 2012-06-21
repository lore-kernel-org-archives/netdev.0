From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH][RESEND] bonding: delete migrated IP addresses from the rlb hash table
Date: Thu, 21 Jun 2012 16:05:19 -0700
Message-ID: <2699.1340319919@death.nxdomain>
References: <20120620203731.GA4957@midget.suse.cz>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:53604 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760604Ab2FUXF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 19:05:26 -0400
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 21 Jun 2012 19:05:25 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F1E9D38C801C
	for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 19:05:22 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5LN5M7r36438262
	for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 19:05:22 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5M4aDQR026463
	for <netdev@vger.kernel.org>; Fri, 22 Jun 2012 00:36:14 -0400
In-reply-to: <20120620203731.GA4957@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>Hi, this is a resend of the patch discussed here:
>	http://thread.gmane.org/gmane.linux.network/228076
>It has been updated to apply to the lastest net-next.
[...]
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

	Just a note that I'm doing some testing with this patch.  Seems
to be ok for the "direct" case (wherein the IP in question is assigned
to the local system); I haven't tried the "bridge" case yet.  I've
extended some of the debugfs stuff to dump the new information, and I'm
trying some of the corner cases (e.g., breaking the linkages in the
middle) to see if it all hangs together.

	I am thinking that the layout of the "hash"-ish table is now
sufficiently complicated that there should be a comment block somewhere
describing what's going on (because I didn't really quite get it until I
dumped the whole thing and looked at it).  With this patch, there is one
"used" linkage for all of the elements in use, plus some number of "src"
linkages, one for each active source hash.  The "src" linkages are also
notable in that they are separate from the "assigned" state.

>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index e15cc11..8505a24 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
[...]
>@@ -354,6 +357,17 @@ static int rlb_arp_recv(const struct sk_buff *skb, struct bonding *bond,
> 	if (!arp)
> 		goto out;
>
>+	/* We received an ARP from arp->ip_src.
>+	 * We might have used this IP address previously (on the bonding host
>+	 * itself or on a system that is bridged together with the bond).
>+	 * However, if arp->mac_src is different than what is stored in
>+	 * rx_hashtbl, some other host is now using the IP and we must prevent
>+	 * sending out client updates with this IP address and the old MAC address.
>+	 * Clean up all hash table entries that have this address as ip_src but
>+	 * have a dirrerent mac_src.

	Typo here; should be "different."

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
