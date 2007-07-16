From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec freeze
Date: Mon, 16 Jul 2007 20:12:28 +0200
Message-ID: <469BB50C.10203@trash.net>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090304020705000308040400"
Cc: netdev@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55943 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbXGPSMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 14:12:34 -0400
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090304020705000308040400
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Beschorner Daniel wrote:
>>I managed to reproduce a crash with ipcomp, will try to fix it later.
> 
> 
> Yes, I can confirm this.
> After disabling IPComp the crashes went away.


The crash happens in xfrm_bundle_ok when walking the bundle upwards
following xfrm_dst->u.next. The loop should be stopped when
xfrm_dst->u.next == first (the topmost xfrm_dst), but it points to
NULL instead. I'm pretty sure the attached patch is responsible,
it breaks XFRM's assumption that dst->next and xfrm_dst->u.next are
the same pointer and xfrm_dst now shares the next pointer with
rcu_head.next in struct dst_entry.

Eric, could you look into this please?

--------------090304020705000308040400
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Reorder fields of struct dst_entry

This last patch (but not least :) ) finally moves the next pointer at
the end of struct dst_entry. This permits to perform route cache
lookups with a minimal cost of one cache line per entry, instead of
two.

Both 32bits and 64bits platforms benefit from this new layout.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

---
commit 1e19e02ca0c5e33ea73a25127dbe6c3b8fcaac4b
tree 23afba2945a9e09b137b094a868ea176c1e1c800
parent 0c195c3fc4e95a06b0c0017506f074c94af99c35
author Eric Dumazet <dada1@cosmosbay.com> Fri, 09 Feb 2007 16:26:55 -0800
committer David S. Miller <davem@sunset.davemloft.net> Sat, 10 Feb 2007 23:20:45 -0800

 include/net/dst.h |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 5d62342..e12a8ce 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -37,14 +37,7 @@ struct sk_buff;
 
 struct dst_entry
 {
-	union {
-		struct dst_entry *next;
-		struct rtable    *rt_next;
-		struct rt6_info   *rt6_next;
-		struct dn_route  *dn_next;
-	};
-	atomic_t		__refcnt;	/* client references	*/
-	int			__use;
+	struct rcu_head		rcu_head;
 	struct dst_entry	*child;
 	struct net_device       *dev;
 	short			error;
@@ -55,7 +48,6 @@ struct dst_entry
 #define DST_NOPOLICY		4
 #define DST_NOHASH		8
 #define DST_BALANCED            0x10
-	unsigned long		lastuse;
 	unsigned long		expires;
 
 	unsigned short		header_len;	/* more space at head required */
@@ -80,8 +72,16 @@ struct dst_entry
 #endif
 
 	struct  dst_ops	        *ops;
-	struct rcu_head		rcu_head;
 		
+	unsigned long		lastuse;
+	atomic_t		__refcnt;	/* client references	*/
+	int			__use;
+	union {
+		struct dst_entry *next;
+		struct rtable    *rt_next;
+		struct rt6_info   *rt6_next;
+		struct dn_route  *dn_next;
+	};
 	char			info[0];
 };
 

--------------090304020705000308040400--
