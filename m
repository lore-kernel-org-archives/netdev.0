From: Andi Kleen <ak@suse.de>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 13:56:15 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020729135615.A20412@wotan.suse.de>
References: <20020729131239.A5183@wotan.suse.de> <Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Rusty Russell <rusty@rustcorp.com.au>,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Mon, Jul 29, 2002 at 07:23:49AM -0400, jamal wrote:
> 
> 
> On Mon, 29 Jul 2002, Andi Kleen wrote:
> 
> > One obvious problem that it has is that it uses vmalloc to allocate its
> > big hash table. This will likely lead to TLB thrashing on a busy box. It should
> > try to allocate the hashtable with get_free_pages() first and only fall
> > back to vmalloc if that fails. This way it would run with large pages.
> >
> > (case in point: we have at least one report that routing
> > performance breaks down with ip_conntrack when memory size is increased over
> > 1GB on P3s. The hash table size depends on the memory size. The problem does
> > not occur on P4s. P4s have larger TLBs than P3s.)
> >
> 
> They also have a lot of problems with their per-packet computations.
> Robert and I spent a short time looking at "this thing that is making
> us look bad" (perfomance wise) and talked to Harald.
> Something that looked like needs improvement at first glance was the aging
> and hashing schemes.

Yes, some more tuning is probably needed.

here is a patch for 2.4 that just makes it use get_free_pages to test the 
TLB theory. Another obvious improvement would be to not use list_heads 
for the hash table buckets - a single pointer would likely suffice and 
it would cut the hash table in half, saving cache, TLB and memory.

-Andi


--- linux-work/net/ipv4/netfilter/ip_conntrack_core.c-CONNTRACK	Thu Jul 25 13:36:42 2002
+++ linux-work/net/ipv4/netfilter/ip_conntrack_core.c	Mon Jul 29 13:48:33 2002
@@ -50,6 +50,7 @@
 LIST_HEAD(protocol_list);
 static LIST_HEAD(helpers);
 unsigned int ip_conntrack_htable_size = 0;
+static int ip_conntrack_vmalloc;
 static int ip_conntrack_max = 0;
 static atomic_t ip_conntrack_count = ATOMIC_INIT(0);
 struct list_head *ip_conntrack_hash;
@@ -1053,6 +1054,15 @@
 	return 1;
 }
 
+static void free_conntrack_hash(void)
+{
+	if (ip_conntrack_vmalloc)
+		vfree(ip_conntrack_hash);
+	else
+		free_pages((unsigned long)ip_conntrack_hash, 
+			   get_order(sizeof(struct list_head) * ip_conntrack_htable_size));
+}
+
 /* Mishearing the voices in his head, our hero wonders how he's
    supposed to kill the mall. */
 void ip_conntrack_cleanup(void)
@@ -1075,7 +1085,7 @@
 	}
 
 	kmem_cache_destroy(ip_conntrack_cachep);
-	vfree(ip_conntrack_hash);
+	free_conntrack_hash();
 	nf_unregister_sockopt(&so_getorigdst);
 }
 
@@ -1109,8 +1119,17 @@
 	if (ret != 0)
 		return ret;
 
-	ip_conntrack_hash = vmalloc(sizeof(struct list_head)
-				    * ip_conntrack_htable_size);
+	/* AK: the hash table is twice as big than needed because it uses list_head.
+	   it would be much nicer to caches to use a single pointer list head here. */
+	ip_conntrack_vmalloc = 0; 
+	ip_conntrack_hash = (void *)__get_free_pages(GFP_KERNEL, 
+					     get_order(sizeof(struct list_head) * 
+						       ip_conntrack_htable_size));
+	if (!ip_conntrack_hash) { 
+		ip_conntrack_vmalloc = 1;
+		printk("ip_conntrack: falling back to vmalloc. performance may be degraded.\n");
+		ip_conntrack_hash = vmalloc(sizeof(struct list_head) * ip_conntrack_htable_size);
+	}
 	if (!ip_conntrack_hash) {
 		nf_unregister_sockopt(&so_getorigdst);
 		return -ENOMEM;
@@ -1121,7 +1140,7 @@
 	                                        SLAB_HWCACHE_ALIGN, NULL, NULL);
 	if (!ip_conntrack_cachep) {
 		printk(KERN_ERR "Unable to create ip_conntrack slab cache\n");
-		vfree(ip_conntrack_hash);
+		free_conntrack_hash();
 		nf_unregister_sockopt(&so_getorigdst);
 		return -ENOMEM;
 	}
@@ -1145,7 +1164,7 @@
 		= register_sysctl_table(ip_conntrack_root_table, 0);
 	if (ip_conntrack_sysctl_header == NULL) {
 		kmem_cache_destroy(ip_conntrack_cachep);
-		vfree(ip_conntrack_hash);
+		free_conntrack_hash();
 		nf_unregister_sockopt(&so_getorigdst);
 		return -ENOMEM;
 	}
