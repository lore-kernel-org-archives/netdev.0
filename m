From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 0/5] netfilter updates for net-next (upcoming 3.5),
 batch 2
Date: Mon, 14 May 2012 10:21:31 +0200
Message-ID: <20120514082131.GA9524@1984>
References: <1336563188-6720-1-git-send-email-pablo@netfilter.org>
 <20120509.181119.549113304045405166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120509.181119.549113304045405166.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 09, 2012 at 06:11:19PM -0400, David Miller wrote:
> From: pablo@netfilter.org
> Date: Wed,  9 May 2012 13:33:03 +0200
> 
> > This is a second batch of netfilter updates for net-next, they contain:
> > 
> > * The new HMARK target from Hans Schillstrom. It took lots of spins
> >   to get this into shape. This target provides a hash-based packet / flow
> >   pre-classifier for iptables that can be used to distribute packets
> >   / flows between uplinks and backend servers. It provides to modes, one
> >   that relies on conntrack, and one that is stateless per-packet.
> > 
> > * Byte-based cost calculation for the hashlimit match, to detect when
> >   a host consumes more bandwidth than expected. This patch from Florian
> >   Westphal.
> > 
> > You can pull these changes from:
> > 
> > git://1984.lsi.us.es/net-next
> 
> Pulled.
> 
> Two suggested improvements:
> 
> 1) The HMARK hash is quite expensive, because it uses a modulus.
> 
>    Consider adjusting it to use the usual trick:
> 
> 	((u64)(HASH_VAL * HASH_SIZE)) >> 32
> 
>    so that this can be a multiply instead of a modulus.

I'll enqueue the patch attached for this. Thanks for spotting this.

--+HP7ph2BbKc20aGI
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-xt_HMARK-modulus-is-expensive-for-hash-cal.patch"

>From 3b81af711d639cdcf820836bad6b4ac0f5a761fa Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 14 May 2012 02:01:46 +0200
Subject: [PATCH] netfilter: xt_HMARK: modulus is expensive for hash
 calculation

Use:

((u64)(HASH_VAL * HASH_SIZE)) >> 32

as suggested by David S. Miller.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_HMARK.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
index 5817d03..0a96a43 100644
--- a/net/netfilter/xt_HMARK.c
+++ b/net/netfilter/xt_HMARK.c
@@ -109,7 +109,7 @@ hmark_hash(struct hmark_tuple *t, const struct xt_hmark_info *info)
 	hash = jhash_3words(t->src, t->dst, t->uports.v32, info->hashrnd);
 	hash = hash ^ (t->proto & info->proto_mask);
 
-	return (hash % info->hmodulus) + info->hoffset;
+	return (((u64)hash * info->hmodulus) >> 32) + info->hoffset;
 }
 
 static void
-- 
1.7.10


--+HP7ph2BbKc20aGI--
