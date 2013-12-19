From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Thu, 19 Dec 2013 11:17:39 +0800
Message-ID: <52B26553.9070103@windriver.com>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com>	 <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>	 <52B24D7D.6060902@windriver.com> <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?546L6IGq?= <xiyou.wangcong@gmail.com>,
	<steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:48504 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab3LSDRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 22:17:34 -0500
In-Reply-To: <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8819=E6=97=A5 10:15, Eric Dumazet wrote:
>> I think an analogy of llist_add_batch for the updating part will be =
ok for this:
>> >
>> >                            struct dst_entry *first;
>> >                            do {
>> >                                    xdst->u.dst.next =3D first =3D =
ACCESS_ONCE(xfrm_policy_sk_bundles);
>> >                            } while (cmpxchg(&xfrm_policy_sk_bundle=
s, first,&xdst->u.dst) !=3D first);
>> >
>> >
>> >  And the deleting part:
>> >
>> >                            head =3D xchg(&net->xfrm.xfrm_policy_sk=
_bundles, NULL);
>> >
>> >
> The point is to_use_  the helpers, so that code review is easy.
>
> llist.h is safe, it was extensively discussed and adopted.
>
> If you want to get rid of the spinlock, then use llist_del_all() for =
the
> deleting, and llist_add() for the addition.
>
> Really, its that simple.

Ok, I will use common api suggested by you, then locks is gone at the c=
ost
of xfrm_dst growing up a bit, sizeof(struct llist_node).



 From b4c5fc86861abd98866111a7b1b51dc13d546a0c Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Thu, 19 Dec 2013 11:03:20 +0800
Subject: [PATCHv3 net-next] xfrm: Namespacify xfrm_policy_sk_bundles

xfrm_policy_sk_bundles, protected by net->xfrm.xfrm_policy_sk_bundle_lo=
ck
should be put into netns xfrm structure, otherwise xfrm_policy_sk_bundl=
es
can be corrupted from different net namespace.

Moreover current xfrm_policy_sk_bundle_lock used in below two scenarios=
:

1. xfrm_lookup(Process context)  vs  __xfrm_garbage_collect(softirq con=
text)
2. xfrm_lookup(Process context)  vs  __xfrm_garbage_collect(Process con=
text
                                                 when SPD change or dev=
 down)

We can use lock less list to cater to those two scenarios as suggested =
by
Eric Dumazet.

Signed-off-by: Fan Du <fan.du@windriver.com>
Assisted-by: Eric Dumazet <edumazet@google.com>
---
v2:
   Fix incorrect commit log.

v3:
   Drop xchg, use llist instead, adviced by Eric Dumazet.
   Build test only.
---
  include/net/netns/xfrm.h |    2 +-
  include/net/xfrm.h       |    1 +
  net/xfrm/xfrm_policy.c   |   26 ++++++--------------------
  3 files changed, 8 insertions(+), 21 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 1006a26..22f4f90 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -58,9 +58,9 @@ struct netns_xfrm {
  	struct dst_ops		xfrm6_dst_ops;
  #endif
  	spinlock_t xfrm_state_lock;
-	spinlock_t xfrm_policy_sk_bundle_lock;
  	rwlock_t xfrm_policy_lock;
  	struct mutex xfrm_cfg_mutex;
+	struct llist_head xp_sk_bundles_list;
  };

  #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 59f5d0a..05296ab 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -957,6 +957,7 @@ struct xfrm_dst {
  	u32 child_mtu_cached;
  	u32 route_cookie;
  	u32 path_cookie;
+	struct llist_node       xdst_llist;
  };

  #ifdef CONFIG_XFRM
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a7487f3..fb286af 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -39,8 +39,6 @@
  #define XFRM_QUEUE_TMO_MAX ((unsigned)(60*HZ))
  #define XFRM_MAX_QUEUE_LEN	100

-static struct dst_entry *xfrm_policy_sk_bundles;
-
  static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
  static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPROTO]
  						__read_mostly;
@@ -2108,12 +2106,7 @@ struct dst_entry *xfrm_lookup(struct net *net, s=
truct dst_entry *dst_orig,
  			}

  			dst_hold(&xdst->u.dst);
-
-			spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-			xdst->u.dst.next =3D xfrm_policy_sk_bundles;
-			xfrm_policy_sk_bundles =3D &xdst->u.dst;
-			spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-
+			llist_add(&xdst->xdst_llist, &net->xfrm.xp_sk_bundles_list);
  			route =3D xdst->route;
  		}
  	}
@@ -2549,18 +2542,12 @@ static struct dst_entry *xfrm_negative_advice(s=
truct dst_entry *dst)

  static void __xfrm_garbage_collect(struct net *net)
  {
-	struct dst_entry *head, *next;
-
-	spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
-	head =3D xfrm_policy_sk_bundles;
-	xfrm_policy_sk_bundles =3D NULL;
-	spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
+	struct llist_node *head;
+	struct xfrm_dst *xdst;

-	while (head) {
-		next =3D head->next;
-		dst_free(head);
-		head =3D next;
-	}
+	head =3D llist_del_all(&net->xfrm.xp_sk_bundles_list);
+	llist_for_each_entry(xdst, head, xdst_llist)
+		dst_free(&xdst->u.dst);
  }

  void xfrm_garbage_collect(struct net *net)
@@ -2942,7 +2929,6 @@ static int __net_init xfrm_net_init(struct net *n=
et)
  	/* Initialize the per-net locks here */
  	spin_lock_init(&net->xfrm.xfrm_state_lock);
  	rwlock_init(&net->xfrm.xfrm_policy_lock);
-	spin_lock_init(&net->xfrm.xfrm_policy_sk_bundle_lock);
  	mutex_init(&net->xfrm.xfrm_cfg_mutex);

  	return 0;
--=20
1.7.9.5


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
