From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Sat, 13 Sep 2003 21:59:37 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <200309132159.37834.bdschuym@pandora.be>
References: <200309022116.41697.bdschuym@pandora.be> <20030905153152.GA3623@obroa-skai.de.gnumonks.org> <20030908191400.5ef59ab6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netfilter-devel@lists.netfilter.org,
	netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>,
	Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030908191400.5ef59ab6.davem@redhat.com>
Content-Disposition: inline
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Tuesday 09 September 2003 04:14, David S. Miller wrote:
> On Fri, 5 Sep 2003 17:31:52 +0200
>
> Harald Welte <laforge@netfilter.org> wrote:
> > The problem is that it is _not_ a simple reimplementation of memcmp(),
> > but a mask-compare.
>
> Ok.  It still should be fixed by not using the "unsigned long *"
> cast-and-op tricks...

The patch below should fix things. It just uses unsigned int instead
of unsigned long, so there should be no problem with the evil Sparc64.
Perhaps the ip_tables.c code from which I copied the original code should
be altered too.
It's a real optimization btw, the .o file is 32 bytes
larger when doing the bit operations on a char with i<IFNAMSIZ.
All hail Rusty :)
The patch doesn't change the .o file on my i386 system. It will probably
be slower for systems where sizeof(unsigned long)>sizeof(unsigned int),
but this is the easiest solution for me.

cheers,
Bart

--- linux-2.6.0-test5/net/ipv4/netfilter/ipt_physdev.c.old	2003-09-11 21:04:12.000000000 +0200
+++ linux-2.6.0-test5/net/ipv4/netfilter/ipt_physdev.c	2003-09-13 21:42:23.000000000 +0200
@@ -23,7 +23,7 @@ match(const struct sk_buff *skb,
 	int i;
 	static const char nulldevname[IFNAMSIZ];
 	const struct ipt_physdev_info *info = matchinfo;
-	unsigned long ret;
+	unsigned int ret;
 	const char *indev, *outdev;
 	struct nf_bridge_info *nf_bridge;
 
@@ -65,10 +65,10 @@ match(const struct sk_buff *skb,
 	if (!(info->bitmask & IPT_PHYSDEV_OP_IN))
 		goto match_outdev;
 	indev = nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)indev)[i]
-			^ ((const unsigned long *)info->physindev)[i])
-			& ((const unsigned long *)info->in_mask)[i];
+	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned int); i++) {
+		ret |= (((const unsigned int *)indev)[i]
+			^ ((const unsigned int *)info->physindev)[i])
+			& ((const unsigned int *)info->in_mask)[i];
 	}
 
 	if ((ret == 0) ^ !(info->invert & IPT_PHYSDEV_OP_IN))
@@ -79,10 +79,10 @@ match_outdev:
 		return MATCH;
 	outdev = nf_bridge->physoutdev ?
 		 nf_bridge->physoutdev->name : nulldevname;
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)outdev)[i]
-			^ ((const unsigned long *)info->physoutdev)[i])
-			& ((const unsigned long *)info->out_mask)[i];
+	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned int); i++) {
+		ret |= (((const unsigned int *)outdev)[i]
+			^ ((const unsigned int *)info->physoutdev)[i])
+			& ((const unsigned int *)info->out_mask)[i];
 	}
 
 	return (ret != 0) ^ !(info->invert & IPT_PHYSDEV_OP_OUT);
--- linux-2.6.0-test5/include/linux/netfilter_ipv4/ipt_physdev.h.old	2003-09-13 21:32:23.000000000 +0200
+++ linux-2.6.0-test5/include/linux/netfilter_ipv4/ipt_physdev.h	2003-09-13 21:33:04.000000000 +0200
@@ -15,7 +15,7 @@
 struct ipt_physdev_info {
 	u_int8_t invert;
 	u_int8_t bitmask;
-	char physindev[IFNAMSIZ];
+	char physindev[IFNAMSIZ] __attribute__ ((aligned (__alignof__(unsigned int))));
 	char in_mask[IFNAMSIZ];
 	char physoutdev[IFNAMSIZ];
 	char out_mask[IFNAMSIZ];
