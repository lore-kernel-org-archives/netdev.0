From: Patrick McHardy <kaber@trash.net>
Subject: Re: crash in ipt_do_table
Date: Fri, 18 Aug 2006 07:45:59 +0200
Message-ID: <44E55417.2000508@trash.net>
References: <20060815005422.0c47bddb.akpm@osdl.org>	<44E1D3A2.3020604@trash.net> <20060817.181403.78708132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020105070000050109090809"
Cc: chris@ex-parrot.com, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:26754 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964808AbWHRFqD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 01:46:03 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060817.181403.78708132.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020105070000050109090809
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 15 Aug 2006 16:01:06 +0200
> 
> 
>>Any chance you're also changing your ruleset dynamically? If yes
>>this patch might help.
> 
> 
> I've applied this.

Thanks, but it seems you applied the first patch I sent, which was
missing the same fix for arp_tables. This patch contains the missing
bits.

I'm going to send the (combined) patch to -stable as well, this bug
seems to have hit quite a few people.


--------------020105070000050109090809
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: arp_tables: fix table locking in arpt_do_table

table->private might change because of ruleset changes, don't use it without
holding the lock.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 338fe5c67e8fb799c9e3470331db6f3c60a31b1e
tree 2dc15d63244ed18a8035ae483ae2d722e7fbcf62
parent 32ce9bc41528c327b1353713b2108d2213128dee
author Patrick McHardy <kaber@trash.net> Tue, 15 Aug 2006 16:06:57 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 15 Aug 2006 16:06:57 +0200

 net/ipv4/netfilter/arp_tables.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index df4854c..8d1d7a6 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -236,7 +236,7 @@ unsigned int arpt_do_table(struct sk_buf
 	struct arpt_entry *e, *back;
 	const char *indev, *outdev;
 	void *table_base;
-	struct xt_table_info *private = table->private;
+	struct xt_table_info *private;
 
 	/* ARP header, plus 2 device addresses, plus 2 IP addresses.  */
 	if (!pskb_may_pull((*pskb), (sizeof(struct arphdr) +
@@ -248,6 +248,7 @@ unsigned int arpt_do_table(struct sk_buf
 	outdev = out ? out->name : nulldevname;
 
 	read_lock_bh(&table->lock);
+	private = table->private;
 	table_base = (void *)private->entries[smp_processor_id()];
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);

--------------020105070000050109090809--
