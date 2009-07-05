From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Sun, 5 Jul 2009 18:20:03 +0200
Message-ID: <20090705162003.GA19477@ami.dom.local>
References: <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl> <20090701101333.GB12715@ff.dom.local> <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl> <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl> <4A4FF40B.5090003@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:56837 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbZGEQUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 12:20:12 -0400
Received: by bwz25 with SMTP id 25so495718bwz.37
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2009 09:20:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A4FF40B.5090003@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2009 at 02:30:03AM +0200, Pawe=B3 Staszewski wrote:
> Oh
>
> I forgot - please Jarek give me patch with sync rcu and i will make t=
est =20
> on preempt kernel

Probably non-preempt kernel might need something like this more, but
comparing is always interesting. This patch is based on Paul's
suggestion (I hope).

Thanks,
Jarek P.
---> (synchronize take 7; apply on top of the 2.6.29.x with the last
	all-in-one patch, or net-2.6)

 net/ipv4/fib_trie.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 00a54b2..fce8238 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -164,6 +164,7 @@ static struct tnode *inflate(struct trie *t, struct=
 tnode *tn);
 static struct tnode *halve(struct trie *t, struct tnode *tn);
 /* tnodes to free after resize(); protected by RTNL */
 static struct tnode *tnode_free_head;
+static size_t tnode_free_size;
=20
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct kmem_cache *trie_leaf_kmem __read_mostly;
@@ -393,6 +394,8 @@ static void tnode_free_safe(struct tnode *tn)
 	BUG_ON(IS_LEAF(tn));
 	tn->tnode_free =3D tnode_free_head;
 	tnode_free_head =3D tn;
+	tnode_free_size +=3D sizeof(struct tnode) +
+			   (sizeof(struct node *) << tn->bits);
 }
=20
 static void tnode_free_flush(void)
@@ -404,6 +407,11 @@ static void tnode_free_flush(void)
 		tn->tnode_free =3D NULL;
 		tnode_free(tn);
 	}
+
+	if (tnode_free_size >=3D PAGE_SIZE * 128) {
+		tnode_free_size =3D 0;
+		synchronize_rcu();
+	}
 }
=20
 static struct leaf *leaf_new(void)
