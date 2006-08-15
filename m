From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: crash in ipt_do_table
Date: Tue, 15 Aug 2006 16:01:06 +0200
Message-ID: <44E1D3A2.3020604@trash.net>
References: <20060815005422.0c47bddb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070702040503040100020705"
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:24824 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932775AbWHOODO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 10:03:14 -0400
To: Chris Lightfoot <chris@ex-parrot.com>
In-Reply-To: <20060815005422.0c47bddb.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070702040503040100020705
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> From: Chris Lightfoot <chris@ex-parrot.com>
>
> EIP is at ipt_do_table+0xa9/0x2fc [ip_tables]
>
> This has only happened once so far, so I'm not (yet) aware
> of any way to reproduce it. Unfortunately I don't have a
> copy of the iptables rules themselves at the time of the
> crash -- on that system they're created dynamically and
> the specific setup doesn't survive a reboot.

Any chance you're also changing your ruleset dynamically? If yes
this patch might help.


--------------070702040503040100020705
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
commit b7534132e3970ec95ea058a701193a71cb1bcc13
tree c90921385346dd0f61d637c126f2c757261aa2c0
parent 32ce9bc41528c327b1353713b2108d2213128dee
author Patrick McHardy <kaber@trash.net> Tue, 15 Aug 2006 15:28:16 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 15 Aug 2006 15:28:16 +0200

 net/ipv4/netfilter/ip_tables.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

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
 

--------------070702040503040100020705--
