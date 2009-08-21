From: Robert Olsson <robert@herjulf.net>
Subject: [PATCH net-next-2.6] fib_trie: resize rework
Date: Fri, 21 Aug 2009 16:10:02 +0200
Message-ID: <19086.43706.337854.749226@gargle.gargle.HOWL>
References: <alpine.LNX.2.00.0908211318070.28188@jens.its.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, robert@herjulf.net
To: Jens Laas <jens.laas@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av11-2-sn2.hy.skanova.net ([81.228.8.184]:33523 "EHLO
	av11-2-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932213AbZHUOdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 10:33:32 -0400
In-Reply-To: <alpine.LNX.2.00.0908211318070.28188@jens.its.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jens Laas writes:
 > Here is rework and cleanup of the resize function.
 >=20
 > Some bugs we had. We were using ->parent when we should use=20
 > node_parent(). Also we used ->parent which is not assigned by
 > inflate in inflate loop.
 >=20
 > Also a fix to set thresholds to power 2 to fit halve=20
 > and double strategy.
 >=20
 > max_resize is renamed to max_work which better indicates
 > it's function.
 >=20
 > Reaching max_work is not an error, so warning is removed.=20
 > max_work only limits amount of work done per resize.
 > (limits CPU-usage, outstanding memory etc).
 >=20
 > The clean-up makes it relatively easy to add fixed sized=20
 > root-nodes if we would like to decrease the memory pressure
 > on routers with large routing tables and dynamic routing.
 > If we'll need that...
 >=20
 > Its been tested with 280k routes.
 >=20
 > Work done together with Robert Olsson.
 >=20
 > Signed-off-by: Jens L=E5=E5s <jens.laas@its.uu.se>


Right we think is a step forward. No performance differences seen=20
either for lookup or insert.

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Cheers.
					--ro

PS.
We see ~7 Gbit/s simplex routing w/o route cache using packet distribut=
ion
seen on core links. Using multiQ of course



 > ---
 >  net/ipv4/fib_trie.c |   95 ++++++++++++----------------------------=
----------
 >  1 files changed, 23 insertions(+), 72 deletions(-)
 >=20
 > diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
 > index fe3c846..291bdf5 100644
 > --- a/net/ipv4/fib_trie.c
 > +++ b/net/ipv4/fib_trie.c
 > @@ -48,7 +48,7 @@
 >   *		Patrick McHardy <kaber@trash.net>
 >   */
 > =20
 > -#define VERSION "0.408"
 > +#define VERSION "0.409"
 > =20
 >  #include <asm/uaccess.h>
 >  #include <asm/system.h>
 > @@ -325,10 +325,7 @@ static inline void check_tnode(const struct tno=
de *tn)
 >  static const int halve_threshold =3D 25;
 >  static const int inflate_threshold =3D 50;
 >  static const int halve_threshold_root =3D 15;
 > -static const int inflate_threshold_root =3D 25;
 > -
 > -static int inflate_threshold_root_fix;
 > -#define INFLATE_FIX_MAX 10	/* a comment in resize() */
 > +static const int inflate_threshold_root =3D 30;
 > =20
 >  static void __alias_free_mem(struct rcu_head *head)
 >  {
 > @@ -516,14 +513,14 @@ static void tnode_put_child_reorg(struct tnode=
 *tn, int i, struct node *n,
 >  	rcu_assign_pointer(tn->child[i], n);
 >  }
 > =20
 > +#define MAX_WORK 10
 >  static struct node *resize(struct trie *t, struct tnode *tn)
 >  {
 >  	int i;
 > -	int err =3D 0;
 >  	struct tnode *old_tn;
 >  	int inflate_threshold_use;
 >  	int halve_threshold_use;
 > -	int max_resize;
 > +	int max_work;
 > =20
 >  	if (!tn)
 >  		return NULL;
 > @@ -538,18 +535,7 @@ static struct node *resize(struct trie *t, stru=
ct tnode *tn)
 >  	}
 >  	/* One child */
 >  	if (tn->empty_children =3D=3D tnode_child_length(tn) - 1)
 > -		for (i =3D 0; i < tnode_child_length(tn); i++) {
 > -			struct node *n;
 > -
 > -			n =3D tn->child[i];
 > -			if (!n)
 > -				continue;
 > -
 > -			/* compress one level */
 > -			node_set_parent(n, NULL);
 > -			tnode_free_safe(tn);
 > -			return n;
 > -		}
 > +		goto one_child;
 >  	/*
 >  	 * Double as long as the resulting node has a number of
 >  	 * nonempty nodes that are above the threshold.
 > @@ -618,15 +604,17 @@ static struct node *resize(struct trie *t, str=
uct tnode *tn)
 > =20
 >  	/* Keep root node larger  */
 > =20
 > -	if (!tn->parent)
 > -		inflate_threshold_use =3D inflate_threshold_root +
 > -					inflate_threshold_root_fix;
 > -	else
 > +	if (!node_parent((struct node*) tn)) {
 > +		inflate_threshold_use =3D inflate_threshold_root;
 > +		halve_threshold_use =3D halve_threshold_root;
 > +	}
 > +	else {
 >  		inflate_threshold_use =3D inflate_threshold;
 > +		halve_threshold_use =3D halve_threshold;
 > +	}
 > =20
 > -	err =3D 0;
 > -	max_resize =3D 10;
 > -	while ((tn->full_children > 0 &&  max_resize-- &&
 > +	max_work =3D MAX_WORK;
 > +	while ((tn->full_children > 0 &&  max_work-- &&
 >  		50 * (tn->full_children + tnode_child_length(tn)
 >  		      - tn->empty_children)
 >  		>=3D inflate_threshold_use * tnode_child_length(tn))) {
 > @@ -643,47 +631,19 @@ static struct node *resize(struct trie *t, str=
uct tnode *tn)
 >  		}
 >  	}
 > =20
 > -	if (max_resize < 0) {
 > -		if (!tn->parent) {
 > -			/*
 > -			 * It was observed that during large updates even
 > -			 * inflate_threshold_root =3D 35 might be needed to avoid
 > -			 * this warning; but it should be temporary, so let's
 > -			 * try to handle this automatically.
 > -			 */
 > -			if (inflate_threshold_root_fix < INFLATE_FIX_MAX)
 > -				inflate_threshold_root_fix++;
 > -			else
 > -				pr_warning("Fix inflate_threshold_root."
 > -					   " Now=3D%d size=3D%d bits fix=3D%d\n",
 > -					   inflate_threshold_root, tn->bits,
 > -					   inflate_threshold_root_fix);
 > -		} else {
 > -			pr_warning("Fix inflate_threshold."
 > -				   " Now=3D%d size=3D%d bits\n",
 > -				   inflate_threshold, tn->bits);
 > -		}
 > -	} else if (max_resize > 3 && !tn->parent && inflate_threshold_root=
_fix)
 > -		inflate_threshold_root_fix--;
 > -
 >  	check_tnode(tn);
 > =20
 > +	/* Return if at least one inflate is run */
 > +	if( max_work !=3D MAX_WORK)
 > +		return (struct node *) tn;
 > +
 >  	/*
 >  	 * Halve as long as the number of empty children in this
 >  	 * node is above threshold.
 >  	 */
 > =20
 > -
 > -	/* Keep root node larger  */
 > -
 > -	if (!tn->parent)
 > -		halve_threshold_use =3D halve_threshold_root;
 > -	else
 > -		halve_threshold_use =3D halve_threshold;
 > -
 > -	err =3D 0;
 > -	max_resize =3D 10;
 > -	while (tn->bits > 1 &&  max_resize-- &&
 > +	max_work =3D MAX_WORK;
 > +	while (tn->bits > 1 &&  max_work-- &&
 >  	       100 * (tnode_child_length(tn) - tn->empty_children) <
 >  	       halve_threshold_use * tnode_child_length(tn)) {
 > =20
 > @@ -698,19 +658,10 @@ static struct node *resize(struct trie *t, str=
uct tnode *tn)
 >  		}
 >  	}
 > =20
 > -	if (max_resize < 0) {
 > -		if (!tn->parent)
 > -			pr_warning("Fix halve_threshold_root."
 > -				   " Now=3D%d size=3D%d bits\n",
 > -				   halve_threshold_root, tn->bits);
 > -		else
 > -			pr_warning("Fix halve_threshold."
 > -				   " Now=3D%d size=3D%d bits\n",
 > -				   halve_threshold, tn->bits);
 > -	}
 > =20
 >  	/* Only one child remains */
 > -	if (tn->empty_children =3D=3D tnode_child_length(tn) - 1)
 > +	if (tn->empty_children =3D=3D tnode_child_length(tn) - 1) {
 > +one_child:
 >  		for (i =3D 0; i < tnode_child_length(tn); i++) {
 >  			struct node *n;
 > =20
 > @@ -724,7 +675,7 @@ static struct node *resize(struct trie *t, struc=
t tnode *tn)
 >  			tnode_free_safe(tn);
 >  			return n;
 >  		}
 > -
 > +	}
 >  	return (struct node *) tn;
 >  }
 > =20
 > --
 > To unsubscribe from this list: send the line "unsubscribe netdev" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
