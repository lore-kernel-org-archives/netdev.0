From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace
 and a system freeze
Date: Sun, 09 Mar 2014 21:09:17 -0700
Message-ID: <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310014452.144b0491@north>
	 <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Fan Du <fan.du@windriver.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Jakub Kicinski <moorray3@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:44727 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbaCJEJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 00:09:19 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so6500962pdi.21
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 21:09:19 -0700 (PDT)
In-Reply-To: <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-03-09 at 21:02 -0700, Eric Dumazet wrote:
> On Mon, 2014-03-10 at 01:44 +0100, Jakub Kicinski wrote:
> > Hi!
> > 
> > Running Fedora 20 with net-next I get the following warning when
> > libvirt or rtkit comes up:
> > 
> > [  272.143488] kmem_cache_sanity_check (flow_cache): Cache name already exists.
> > [  272.143586] CPU: 0 PID: 975 Comm: libvirtd Not tainted 3.14.0-rc5+ #1
> > [  272.143589] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [  272.143591]  0000000000000000 ffff88003ceadba0 ffffffff8167baf0 ffff88003db3d300
> > [  272.143595]  ffff88003ceadc18 ffffffff8117795b ffff88003ceadbc8 ffff88003b235158
> > [  272.143599]  0000000000000000 0000000000040000 0000000000000068 0000000000000000
> > [  272.143602] Call Trace:
> > [  272.143610]  [<ffffffff8167baf0>] dump_stack+0x4d/0x66
> > [  272.143615]  [<ffffffff8117795b>] kmem_cache_create_memcg+0x12b/0x420
> > [  272.143618]  [<ffffffff81177c7b>] kmem_cache_create+0x2b/0x30
> > [  272.143622]  [<ffffffff815c4a0e>] flow_cache_init+0x2e/0x2b0
> > [  272.143626]  [<ffffffff8164b017>] xfrm_net_init+0x227/0x360
> > [  272.143629]  [<ffffffff8164af41>] ? xfrm_net_init+0x151/0x360
> > [  272.143632]  [<ffffffff815a5921>] ops_init+0x41/0x150
> > [  272.143635]  [<ffffffff815a5aa3>] setup_net+0x73/0x110
> > [  272.143638]  [<ffffffff815a5fe2>] copy_net_ns+0x72/0x100
> > [  272.143642]  [<ffffffff810943f9>] create_new_namespaces+0xf9/0x190
> > [  272.143645]  [<ffffffff81094560>] copy_namespaces+0xd0/0xf0
> > [  272.143648]  [<ffffffff81094495>] ? copy_namespaces+0x5/0xf0
> > [  272.143651]  [<ffffffff81069be0>] copy_process.part.31+0x950/0x1b30
> > [  272.143655]  [<ffffffff8106af95>] do_fork+0xd5/0x370
> > [  272.143658]  [<ffffffff811c1b2d>] ? __fput+0x17d/0x240
> > [  272.143662]  [<ffffffff8110440c>] ? __audit_syscall_entry+0x9c/0xf0
> > [  272.143665]  [<ffffffff8106b2b6>] SyS_clone+0x16/0x20
> > [  272.143669]  [<ffffffff8168cf19>] stub_clone+0x69/0x90
> > [  272.143673]  [<ffffffff8168cb69>] ? system_call_fastpath+0x16/0x1b
> > 
> > 
> > When I try to add a netns with 
> > # ip netns add abcd
> > I it dies with:
> 
> 
> Yep, commit ca925cf1534ebcec332c08719a7dee6ee1782ce4 is buggy.
> 
>     flowcache: Make flow cache name space aware
>     
>     Inserting a entry into flowcache, or flushing flowcache should be based
>     on per net scope. The reason to do so is flushing operation from fat
>     netns crammed with flow entries will also making the slim netns with only
>     a few flow cache entries go away in original implementation.
>     
>     Since flowcache is tightly coupled with IPsec, so it would be easier to
>     put flow cache global parameters into xfrm namespace part. And one last
>     thing needs to do is bumping flow cache genid, and flush flow cache should
>     also be made in per net style.
>     
>     Signed-off-by: Fan Du <fan.du@windriver.com>
>     Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> I fail to understand why the kmem_cache must be private to a netns.

Could you please try the following patch ?

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 51f0dce7b643..3492434baf88 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -64,7 +64,6 @@ struct netns_xfrm {
 
 	/* flow cache part */
 	struct flow_cache	flow_cache_global;
-	struct kmem_cache	*flow_cachep;
 	atomic_t		flow_cache_genid;
 	struct list_head	flow_cache_gc_list;
 	spinlock_t		flow_cache_gc_lock;
diff --git a/net/core/flow.c b/net/core/flow.c
index 344a184011fd..102f8ea2eb6e 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -45,6 +45,8 @@ struct flow_flush_info {
 	struct completion		completion;
 };
 
+static struct kmem_cache *flow_cachep __read_mostly;
+
 #define flow_cache_hash_size(cache)	(1 << (cache)->hash_shift)
 #define FLOW_HASH_RND_PERIOD		(10 * 60 * HZ)
 
@@ -75,7 +77,7 @@ static void flow_entry_kill(struct flow_cache_entry *fle,
 {
 	if (fle->object)
 		fle->object->ops->delete(fle->object);
-	kmem_cache_free(xfrm->flow_cachep, fle);
+	kmem_cache_free(flow_cachep, fle);
 }
 
 static void flow_cache_gc_task(struct work_struct *work)
@@ -230,7 +232,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 		if (fcp->hash_count > fc->high_watermark)
 			flow_cache_shrink(fc, fcp);
 
-		fle = kmem_cache_alloc(net->xfrm.flow_cachep, GFP_ATOMIC);
+		fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC);
 		if (fle) {
 			fle->net = net;
 			fle->family = family;
@@ -435,10 +437,10 @@ int flow_cache_init(struct net *net)
 	int i;
 	struct flow_cache *fc = &net->xfrm.flow_cache_global;
 
-	/* Initialize per-net flow cache global variables here */
-	net->xfrm.flow_cachep = kmem_cache_create("flow_cache",
-					sizeof(struct flow_cache_entry),
-					0, SLAB_PANIC, NULL);
+	if (!flow_cachep)
+		flow_cachep = kmem_cache_create("flow_cache",
+						sizeof(struct flow_cache_entry),
+						0, SLAB_PANIC, NULL);
 	spin_lock_init(&net->xfrm.flow_cache_gc_lock);
 	INIT_LIST_HEAD(&net->xfrm.flow_cache_gc_list);
 	INIT_WORK(&net->xfrm.flow_cache_gc_work, flow_cache_gc_task);
