From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Sat, 27 Jun 2009 21:20:57 +0200
Message-ID: <20090627192057.GA5041@ami.dom.local>
References: <19012.37515.146191.198843@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, "Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:47065 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062AbZF0TVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2009 15:21:10 -0400
Received: by fxm18 with SMTP id 18so279630fxm.37
        for <netdev@vger.kernel.org>; Sat, 27 Jun 2009 12:21:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <19012.37515.146191.198843@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Olsson wrote, On 06/26/2009 11:19 AM:

> Jarek Poplawski writes:
> 
>  > >> oprofile: using NMI interrupt.
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
> 
>  > On the other hand, even if there is no problem with memory, it seems
>  > because of hitting max_resize the threshold should be changed, e.g.
>  > by reverting the patch below.
> 
>  You seem to have some temporary memory problem. So the printout might be
>  a bit misleading in this case. We really like to keep the root node as big 
>  as we can to keep the tree as flat as possible for performance reasons.
>  (We're even more motivated now when we can disable the route cache)
> 
>  So I'll guess the next insert/delete inflates the root node to be within
>  the interval. So I'll assume this just a temporary failure?
> 
>  I would be nice to have *threshholds* settable by /proc or /sys. I would
>  use this in the other direction to trade memory for even faster lookups. 
>  
>  But maybe experts memory allocation has some good suggestions.

Robert, you and Eric pointed at memory problems, so I thought I missed
something. But after the second look I see "skipped node resize" should
show this, but it's always zero on these reports. So, isn't it possible
the current inflate_threshold_root is simply unreachable with some
conditions, at least within 10 loops?

Then these settable thresholds might be more useful here than memory
fixes, but here is some idea to try handle this automatically within
some limits. The patch below increases inflate_threshold_root (only)
up to ~50% of its initial value if needed, and should be able to go
back sometimes.

Pawel and Jorge, could you try this? (It applies to 2.6.29 too, with
some offsets.)

Thanks,
Jarek P.
---

 net/ipv4/fib_trie.c |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 012cf5a..1dc1bb4 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -318,6 +318,7 @@ static const int halve_threshold = 25;
 static const int inflate_threshold = 50;
 static const int halve_threshold_root = 8;
 static const int inflate_threshold_root = 15;
+static int inflate_threshold_root_fix;
 
 
 static void __alias_free_mem(struct rcu_head *head)
@@ -602,7 +603,8 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 	/* Keep root node larger  */
 
 	if (!tn->parent)
-		inflate_threshold_use = inflate_threshold_root;
+		inflate_threshold_use = inflate_threshold_root +
+					inflate_threshold_root_fix;
 	else
 		inflate_threshold_use = inflate_threshold;
 
@@ -626,15 +628,22 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 	}
 
 	if (max_resize < 0) {
-		if (!tn->parent)
-			pr_warning("Fix inflate_threshold_root."
-				   " Now=%d size=%d bits\n",
-				   inflate_threshold_root, tn->bits);
-		else
+		if (!tn->parent) {
+			if (inflate_threshold_root_fix * 2 <
+			    inflate_threshold_root)
+				inflate_threshold_root_fix++;
+			else
+				pr_warning("Fix inflate_threshold_root."
+					   " Now=%d size=%d bits fix=%d\n",
+					   inflate_threshold_root, tn->bits,
+					   inflate_threshold_root_fix);
+		} else {
 			pr_warning("Fix inflate_threshold."
 				   " Now=%d size=%d bits\n",
 				   inflate_threshold, tn->bits);
-	}
+		}
+	} else if (max_resize < 5 && !tn->parent && inflate_threshold_root_fix)
+		inflate_threshold_root_fix--;
 
 	check_tnode(tn);
 
