From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Mon, 6 Jul 2009 11:02:07 +0200
Message-ID: <20090706090207.GB3065@ami.dom.local>
References: <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl> <4A4FF40B.5090003@itcare.pl> <20090705162003.GA19477@ami.dom.local> <20090705173208.GB19477@ami.dom.local> <20090705213232.GG8943@linux.vnet.ibm.com> <20090705222301.GA3203@ami.dom.local> <4A513D0D.5070204@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:54783 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703AbZGFJCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 05:02:14 -0400
Received: by bwz25 with SMTP id 25so1018857bwz.37
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2009 02:02:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A513D0D.5070204@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2009 at 01:53:49AM +0200, Pawe=B3 Staszewski wrote:
=2E..
> So i make tests with changing sync_pages
> And
>
> ####################################
> sync_pages: 64
> total size reach maximum in 17sec
=2E..
> ######################################
> sync_pages: 128
> Fib trie Total size reach max in 14sec
=2E..
> #########################################
> sync_pages: 256
> hmm no difference also in 10sec

14 =3D=3D 10!? ;-)
=2E..
> And with sync_pages higher that 256 time of filling kernel routes is =
the =20
> same approx 10sec.

Hmm... So, it's better than I expected; syncing after 128 or 256 pages
could be quite reasonable. But then it would be interesting to find
out if with such a safety we could go back to more aggressive values
for possibly better performance. So here is 'the same' patch (so the
previous, take 8, should be reverted), but with additional possibility
to change:
/sys/module/fib_trie/parameters/inflate_threshold_root

I guess, you could try e.g. if: sync_pages 256, inflate_threshold_root =
15
can give faster lookups (or lower cpu loads); with this these inflate
warnings could be back btw.; or maybe you'll find something in between
like inflate_threshold_root 20 is optimal for you. (I think it should b=
e
enough to try this only for PREEMPT_NONE unless you have spare time ;-)

Thanks,
Jarek P.
---> (synchronize take 9; apply on top of the 2.6.29.x with the last
  	all-in-one patch, or net-2.6)

 net/ipv4/fib_trie.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 00a54b2..e8fca11 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -71,6 +71,7 @@
 #include <linux/netlink.h>
 #include <linux/init.h>
 #include <linux/list.h>
+#include <linux/moduleparam.h>
 #include <net/net_namespace.h>
 #include <net/ip.h>
 #include <net/protocol.h>
@@ -164,6 +165,10 @@ static struct tnode *inflate(struct trie *t, struc=
t tnode *tn);
 static struct tnode *halve(struct trie *t, struct tnode *tn);
 /* tnodes to free after resize(); protected by RTNL */
 static struct tnode *tnode_free_head;
+static size_t tnode_free_size;
+
+static int sync_pages __read_mostly =3D 1000;
+module_param(sync_pages, int, 0640);
=20
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct kmem_cache *trie_leaf_kmem __read_mostly;
@@ -316,9 +321,11 @@ static inline void check_tnode(const struct tnode =
*tn)
=20
 static const int halve_threshold =3D 25;
 static const int inflate_threshold =3D 50;
-static const int halve_threshold_root =3D 15;
-static const int inflate_threshold_root =3D 25;
=20
+static int inflate_threshold_root __read_mostly =3D 25;
+module_param(inflate_threshold_root, int, 0640);
+
+#define halve_threshold_root	(inflate_threshold_root / 2 + 1)
=20
 static void __alias_free_mem(struct rcu_head *head)
 {
@@ -393,6 +400,8 @@ static void tnode_free_safe(struct tnode *tn)
 	BUG_ON(IS_LEAF(tn));
 	tn->tnode_free =3D tnode_free_head;
 	tnode_free_head =3D tn;
+	tnode_free_size +=3D sizeof(struct tnode) +
+			   (sizeof(struct node *) << tn->bits);
 }
=20
 static void tnode_free_flush(void)
@@ -404,6 +413,11 @@ static void tnode_free_flush(void)
 		tn->tnode_free =3D NULL;
 		tnode_free(tn);
 	}
+
+	if (tnode_free_size >=3D PAGE_SIZE * sync_pages) {
+		tnode_free_size =3D 0;
+		synchronize_rcu();
+	}
 }
=20
 static struct leaf *leaf_new(void)
