From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: Re: [PATCH] tcp: properly release md5sig_pool references
Date: Mon, 26 Sep 2011 16:11:55 +0800
Message-ID: <4E8033CB.6050200@intel.com>
References: <4E7FE4DD.5070804@intel.com> <1317018369.2853.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27168 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010Ab1IZIL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 04:11:57 -0400
In-Reply-To: <1317018369.2853.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2011 02:26 PM, Eric Dumazet wrote:
> Le lundi 26 septembre 2011 =C3=A0 10:35 +0800, Yan, Zheng a =C3=A9cri=
t :
>> tcp_v4_md5_do_add() increases use count of md5sig_pool by one for
>> each tcp md5sig peer, so we should call tcp_free_md5sig_pool() for
>> each peer when destroying the socket.
>>
>> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
>=20
> As managing the use count is rather expensive, I think it would be
> better to hold a single reference instead of multiple ones ?
>=20
>=20

Here is the new patch, thanks.

---
tcp: properly handle md5sig_pool references

tcp_v4_clear_md5_list() assumes that multiple tcp md5sig peers
only hold one reference to md5sig_pool. but tcp_v4_md5_do_add()
increases use count of md5sig_pool for each peer. This patch
makes tcp_v4_md5_do_add() only increases use count for the first
tcp md5sig peer.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c34f015..29ecfa9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -927,18 +927,20 @@ int tcp_v4_md5_do_add(struct sock *sk, __be32 add=
r,
 			}
 			sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 		}
-		if (tcp_alloc_md5sig_pool(sk) =3D=3D NULL) {
+
+		md5sig =3D tp->md5sig_info;
+		if (md5sig->entries4 =3D=3D 0 && tcp_alloc_md5sig_pool(sk) =3D=3D NU=
LL) {
 			kfree(newkey);
 			return -ENOMEM;
 		}
-		md5sig =3D tp->md5sig_info;
=20
 		if (md5sig->alloced4 =3D=3D md5sig->entries4) {
 			keys =3D kmalloc((sizeof(*keys) *
 					(md5sig->entries4 + 1)), GFP_ATOMIC);
 			if (!keys) {
 				kfree(newkey);
-				tcp_free_md5sig_pool();
+				if (md5sig->entries4 =3D=3D 0)
+					tcp_free_md5sig_pool();
 				return -ENOMEM;
 			}
=20
@@ -982,6 +984,7 @@ int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
 				kfree(tp->md5sig_info->keys4);
 				tp->md5sig_info->keys4 =3D NULL;
 				tp->md5sig_info->alloced4 =3D 0;
+				tcp_free_md5sig_pool();
 			} else if (tp->md5sig_info->entries4 !=3D i) {
 				/* Need to do some manipulation */
 				memmove(&tp->md5sig_info->keys4[i],
@@ -989,7 +992,6 @@ int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
 					(tp->md5sig_info->entries4 - i) *
 					 sizeof(struct tcp4_md5sig_key));
 			}
-			tcp_free_md5sig_pool();
 			return 0;
 		}
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3c9fa61..20ac0fc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -591,7 +591,8 @@ static int tcp_v6_md5_do_add(struct sock *sk, const=
 struct in6_addr *peer,
 			}
 			sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 		}
-		if (tcp_alloc_md5sig_pool(sk) =3D=3D NULL) {
+		if (tp->md5sig_info->entries6 =3D=3D 0 &&
+			tcp_alloc_md5sig_pool(sk) =3D=3D NULL) {
 			kfree(newkey);
 			return -ENOMEM;
 		}
@@ -600,8 +601,9 @@ static int tcp_v6_md5_do_add(struct sock *sk, const=
 struct in6_addr *peer,
 				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
=20
 			if (!keys) {
-				tcp_free_md5sig_pool();
 				kfree(newkey);
+				if (tp->md5sig_info->entries6 =3D=3D 0)
+					tcp_free_md5sig_pool();
 				return -ENOMEM;
 			}
=20
@@ -647,6 +649,7 @@ static int tcp_v6_md5_do_del(struct sock *sk, const=
 struct in6_addr *peer)
 				kfree(tp->md5sig_info->keys6);
 				tp->md5sig_info->keys6 =3D NULL;
 				tp->md5sig_info->alloced6 =3D 0;
+				tcp_free_md5sig_pool();
 			} else {
 				/* shrink the database */
 				if (tp->md5sig_info->entries6 !=3D i)
@@ -655,7 +658,6 @@ static int tcp_v6_md5_do_del(struct sock *sk, const=
 struct in6_addr *peer)
 						(tp->md5sig_info->entries6 - i)
 						* sizeof (tp->md5sig_info->keys6[0]));
 			}
-			tcp_free_md5sig_pool();
 			return 0;
 		}
 	}
