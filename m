From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: TODO list before feature freeze
Date: 30 Jul 2002 00:43:52 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1027982632.12630.119.camel@tux>
References: <20020729131239.A5183@wotan.suse.de>
	<Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca>
	<20020729135615.A20412@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Rusty Russell <rusty@rustcorp.com.au>,
   Netfilter-devel <netfilter-devel@lists.netfilter.org>, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20020729135615.A20412@wotan.suse.de>
List-Id: netdev.vger.kernel.org

On Mon, 2002-07-29 at 13:56, Andi Kleen wrote:

> here is a patch for 2.4 that just makes it use get_free_pages to test the 
> TLB theory. Another obvious improvement would be to not use list_heads 
> for the hash table buckets - a single pointer would likely suffice and 
> it would cut the hash table in half, saving cache, TLB and memory.

ip_nat_core is also allocating it's hashtable via vmalloc and it's twice
as large as the one in ip_conntrack. (or rather, it's two hashtables
allocated at once, maybe they should be split up into two allocations?)


diff -x *.orig -x *.rej -urN linux-2.4.19-rc3.old/net/ipv4/netfilter/ip_nat_core.c linux-2.4.19-rc3/net/ipv4/netfilter/ip_nat_core.c
--- linux-2.4.19-rc3.old/net/ipv4/netfilter/ip_nat_core.c	Thu Jul 25 18:26:42 2002
+++ linux-2.4.19-rc3/net/ipv4/netfilter/ip_nat_core.c	Tue Jul 30 00:14:12 2002
@@ -43,6 +43,8 @@
 /* Calculated at init based on memory size */
 static unsigned int ip_nat_htable_size;
 
+static int ip_nat_vmalloc;
+
 static struct list_head *bysource;
 static struct list_head *byipsproto;
 LIST_HEAD(protos);
@@ -958,8 +960,16 @@
 	/* Leave them the same for the moment. */
 	ip_nat_htable_size = ip_conntrack_htable_size;
 
-	/* One vmalloc for both hash tables */
-	bysource = vmalloc(sizeof(struct list_head) * ip_nat_htable_size*2);
+	/* One allocation for both hash tables */
+	ip_nat_vmalloc = 0;
+	bysource = (void *)__get_free_pages(GFP_KERNEL,
+					get_order(sizeof(struct list_head) *
+						  ip_nat_htable_size * 2));
+	if (!bysource) {
+		ip_nat_vmalloc = 1;
+		printk("ip_nat: falling back to vmalloc. performance may be degraded.\n");
+		bysource = vmalloc(sizeof(struct list_head) * ip_nat_htable_size * 2);
+	}
 	if (!bysource) {
 		return -ENOMEM;
 	}
@@ -999,5 +1009,10 @@
 {
 	ip_ct_selective_cleanup(&clean_nat, NULL);
 	ip_conntrack_destroyed = NULL;
-	vfree(bysource);
+
+	if (ip_nat_vmalloc)
+		vfree(bysource);
+	else
+		free_pages((unsigned long)bysource,
+			   get_order(sizeof(struct list_head) * ip_nat_htable_size * 2));
 }
 
-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.
