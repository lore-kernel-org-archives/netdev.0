From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: crash in ipt_do_table
Date: Tue, 15 Aug 2006 16:06:02 +0200
Message-ID: <44E1D4CA.1080307@trash.net>
References: <20060815005422.0c47bddb.akpm@osdl.org> <44E1D3A2.3020604@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040401050802090000040704"
Cc: Chris Lightfoot <chris@ex-parrot.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54264 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965111AbWHOOII
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 10:08:08 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <44E1D3A2.3020604@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040401050802090000040704
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Andrew Morton wrote:
> 
>>From: Chris Lightfoot <chris@ex-parrot.com>
>>
>>EIP is at ipt_do_table+0xa9/0x2fc [ip_tables]
>>
>>This has only happened once so far, so I'm not (yet) aware
>>of any way to reproduce it. Unfortunately I don't have a
>>copy of the iptables rules themselves at the time of the
>>crash -- on that system they're created dynamically and
>>the specific setup doesn't survive a reboot.
> 
> 
> Any chance you're also changing your ruleset dynamically? If yes
> this patch might help.
> 
> 
> 
> ------------------------------------------------------------------------
> 
> [NETFILTER]: ip_tables: fix table locking in ipt_do_table


The same bug is present in arp_tables, this patch covers both.


--------------040401050802090000040704
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: ip_tables: fix table locking in ipt_do_table

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
 net/ipv4/netfilter/ip_tables.c  |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

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
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index f316ff5..048514f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -230,7 +230,7 @@ ipt_do_table(struct sk_buff **pskb,
 	const char *indev, *outdev;
 	void *table_base;
 	struct ipt_entry *e, *back;
-	struct xt_table_info *private = table->private;
+	struct xt_table_info *private;
 
 	/* Initialization */
 	ip = (*pskb)->nh.iph;
@@ -247,6 +247,7 @@ ipt_do_table(struct sk_buff **pskb,
 
 	read_lock_bh(&table->lock);
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
+	private = table->private;
 	table_base = (void *)private->entries[smp_processor_id()];
 	e = get_entry(table_base, private->hook_entry[hook]);
 

--------------040401050802090000040704--
