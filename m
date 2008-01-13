From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [FIB]: full_children & empty_children should be uint, not ushort
Date: Sun, 13 Jan 2008 23:02:11 +0100
Message-ID: <18314.35427.947982.424287@robur.slu.se>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.659443238@linux-foundation.org>
	<4788A17D.5070903@cosmosbay.com>
	<478A58BD.8010304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Robert Olsson <robert.olsson@its.uu.se>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:51190 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753879AbYAMWCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jan 2008 17:02:16 -0500
In-Reply-To: <478A58BD.8010304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:
 > Eric Dumazet a =E9crit :
 > > 4) full_children & empty_children being 'unsigned short',
 > >    we probably are limited to 2^15 elements, but I could not
 > >    find this limit enforced somewhere.

 > Two fixes are possible : Enlarge full_children & empty_children to 3=
2bits, or=20
 > force a limit in code to never exceed 2^15 children in a tnode. I ch=
ose the=20
 > first solution since it can be done with 0 memory cost on 64bit arch=
es.

 Hello,

 Thanks for spotting this. No we don't want put limits on the (root) no=
de size.
 You see the comment in code is correct so unsigned short are some left=
over from=20
 old testing which could have hit us hard as the routing table slowly g=
rows.

 Cheers
						--ro


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>
=20

 > [FIB]: full_children & empty_children should be uint, not ushort
 >=20
 > If declared as unsigned short, these fields can overflow, and whole =
trie logic
 > is broken. I could not make the machine crash, but some tnode can ne=
ver
 > be freed.
 >=20
 > Note for 64 bit arches : By reordering t_key and parent in [node, le=
af, tnode]=20
 > structures, we can use 32 bits hole after t_key so that sizeof(struc=
t tnode)=20
 > doesnt change after this patch.
 >=20
 > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
 >=20
 > diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
 > index f26ba31..9696722 100644
 > --- a/net/ipv4/fib_trie.c
 > +++ b/net/ipv4/fib_trie.c
 > @@ -97,13 +97,13 @@ typedef unsigned int t_key;
 >  #define IS_LEAF(n) (n->parent & T_LEAF)
 > =20
 >  struct node {
 > -	t_key key;
 >  	unsigned long parent;
 > +	t_key key;
 >  };
 > =20
 >  struct leaf {
 > -	t_key key;
 >  	unsigned long parent;
 > +	t_key key;
 >  	struct hlist_head list;
 >  	struct rcu_head rcu;
 >  };
 > @@ -116,12 +116,12 @@ struct leaf_info {
 >  };
 > =20
 >  struct tnode {
 > -	t_key key;
 >  	unsigned long parent;
 > +	t_key key;
 >  	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
 >  	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 > -	unsigned short full_children;	/* KEYLENGTH bits needed */
 > -	unsigned short empty_children;	/* KEYLENGTH bits needed */
 > +	unsigned int full_children;	/* KEYLENGTH bits needed */
 > +	unsigned int empty_children;	/* KEYLENGTH bits needed */
 >  	struct rcu_head rcu;
 >  	struct node *child[0];
 >  };
 > @@ -329,12 +329,12 @@ static inline void free_leaf_info(struct leaf_=
info *leaf)
 >  	call_rcu(&leaf->rcu, __leaf_info_free_rcu);
 >  }
 > =20
 > -static struct tnode *tnode_alloc(unsigned int size)
 > +static struct tnode *tnode_alloc(size_t size)
 >  {
 >  	struct page *pages;
 > =20
 >  	if (size <=3D PAGE_SIZE)
 > -		return kcalloc(size, 1, GFP_KERNEL);
 > +		return kzalloc(size, GFP_KERNEL);
 > =20
 >  	pages =3D alloc_pages(GFP_KERNEL|__GFP_ZERO, get_order(size));
 >  	if (!pages)
 > @@ -346,8 +346,8 @@ static struct tnode *tnode_alloc(unsigned int si=
ze)
 >  static void __tnode_free_rcu(struct rcu_head *head)
 >  {
 >  	struct tnode *tn =3D container_of(head, struct tnode, rcu);
 > -	unsigned int size =3D sizeof(struct tnode) +
 > -		(1 << tn->bits) * sizeof(struct node *);
 > +	size_t size =3D sizeof(struct tnode) +
 > +		      (sizeof(struct node *) << tn->bits);
 > =20
 >  	if (size <=3D PAGE_SIZE)
 >  		kfree(tn);
 > @@ -386,8 +386,7 @@ static struct leaf_info *leaf_info_new(int plen)
 > =20
 >  static struct tnode* tnode_new(t_key key, int pos, int bits)
 >  {
 > -	int nchildren =3D 1<<bits;
 > -	int sz =3D sizeof(struct tnode) + nchildren * sizeof(struct node *=
);
 > +	size_t sz =3D sizeof(struct tnode) + (sizeof(struct node *) << bit=
s);
 >  	struct tnode *tn =3D tnode_alloc(sz);
 > =20
 >  	if (tn) {
 > @@ -399,8 +398,8 @@ static struct tnode* tnode_new(t_key key, int po=
s, int bits)
 >  		tn->empty_children =3D 1<<bits;
 >  	}
 > =20
 > -	pr_debug("AT %p s=3D%u %u\n", tn, (unsigned int) sizeof(struct tno=
de),
 > -		 (unsigned int) (sizeof(struct node) * 1<<bits));
 > +	pr_debug("AT %p s=3D%u %lu\n", tn, (unsigned int) sizeof(struct tn=
ode),
 > +		 (unsigned long) (sizeof(struct node) << bits));
 >  	return tn;
 >  }
 > =20
