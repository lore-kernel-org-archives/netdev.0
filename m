From: Jiri Kosina <jikos@kernel.org>
Subject: Re: qdisc hash table changes...
Date: Tue, 9 Aug 2016 09:42:01 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608090936180.22028@cbobk.fhfr.pm>
References: <20160808.155335.2122819330212870390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33542 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810AbcHIHmD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2016 03:42:03 -0400
In-Reply-To: <20160808.155335.2122819330212870390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Aug 2016, David Miller wrote:

> I think there will still be build failures even with v6 due to symbol
> clashes.
> 
> For example, kernel/audit_tree.c defines HASH_SIZE as an enumeration
> value, and that (indirectly) includes networking headers.

It does indirectly pull in some networking headers, but it doesn't pull in 
netdevice.h (which is the place where the actual include of hashtable.h 
happens):

$ make kernel/audit_tree.i; grep HASH_SIZE kernel/audit_tree.i; grep netdev.*\.h kernel/audit_tree.i
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHK     include/generated/bounds.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  DESCEND  objtool
  CPP     kernel/audit_tree.i
enum {HASH_SIZE = 128};
static struct list_head chunk_hash_heads[HASH_SIZE];
 return chunk_hash_heads + n % HASH_SIZE;
 for (i = 0; i < HASH_SIZE; i++)
# 1 "./include/linux/netdev_features.h" 1
# 15 "./include/linux/netdev_features.h"
# 85 "./include/linux/netdev_features.h"
struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int length,
 return __netdev_alloc_skb(dev, length, ((( gfp_t)0x20u)|(( gfp_t)0x80000u)|(( gfp_t)0x2000000u)));
 return __netdev_alloc_skb(((void *)0), length, gfp_mask);
 return netdev_alloc_skb(((void *)0), length);
 struct sk_buff *skb = __netdev_alloc_skb(dev, length + 0, gfp);
 return __netdev_alloc_skb_ip_align(dev, length, ((( gfp_t)0x20u)|(( gfp_t)0x80000u)|(( gfp_t)0x2000000u)));

So this is fine.

> There are others all over the tree.
> 
> I would therefore ask that you first fix the namespace conflicts against 
> the hash symbols in the entire tree as a separate patch series (one for 
> each driver/subsystem which has this problem.)  Really, get it down to 
> "git grep hash_add | grep -v _hash_add" and similar returning no output.

Is this really worth the hassle when there are no real conflicts (i.e. the 
code in question doesn't indirectly pull in netdevice.h)?

I just did allmodconfig build with v6, and it passed. Fengguang's 0-day 
bot didn't report any failures either.

> Then we can add the qdisc hash facility.

Thanks,

-- 
Jiri Kosina
SUSE Labs
