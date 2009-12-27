From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: lockdep possible recursive lock in slab parent->list->rlock in
 rc2
Date: Sun, 27 Dec 2009 14:33:14 +0200
Message-ID: <1261917194.5933.2.camel@penberg-laptop>
References: <20091227120622.GA480@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, a.p.zijlstra@chello.nl,
	cl@linux-foundation.org, Heiko Carstens <heiko.carstens@de.ibm.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42526 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbZL0MdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2009 07:33:16 -0500
In-Reply-To: <20091227120622.GA480@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andi,

On Sun, 2009-12-27 at 13:06 +0100, Andi Kleen wrote:
> Get this on a NFS root system while booting
> This must be a recent change in the last week, 
> I didn't see it in a post rc1 git* from last week
> (I haven't done a exact bisect)
> 
> It's triggered by the r8169 driver close function, 
> but looks more like a slab problem?
> 
> I haven't checked it in detail if the locks are 
> really different or just lockdep not knowing 
> enough classes.

I broke the lockdep annotations in commit
ce79ddc8e2376a9a93c7d42daf89bfcbb9187e62 ("SLAB: Fix lockdep annotations
for CPU hotplug"). Does this fix things for you? Heiko, the following
patch should fix it for you too.

			Pekka

diff --git a/mm/slab.c b/mm/slab.c
index 7d41f15..7451bda 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -654,7 +654,7 @@ static void init_node_lock_keys(int q)
 
 		l3 = s->cs_cachep->nodelists[q];
 		if (!l3 || OFF_SLAB(s->cs_cachep))
-			return;
+			continue;
 		lockdep_set_class(&l3->list_lock, &on_slab_l3_key);
 		alc = l3->alien;
 		/*
@@ -665,7 +665,7 @@ static void init_node_lock_keys(int q)
 		 * for alloc_alien_cache,
 		 */
 		if (!alc || (unsigned long)alc == BAD_ALIEN_MAGIC)
-			return;
+			continue;
 		for_each_node(r) {
 			if (alc[r])
 				lockdep_set_class(&alc[r]->lock,


