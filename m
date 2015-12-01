From: Mark Brown <broonie@kernel.org>
Subject: linux-next: manual merge of the ipvs-next tree with the  tree
Date: Tue, 1 Dec 2015 19:26:09 +0000
Message-ID: <20151201192609.d3b1069f650471db2bdd61f4@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__1_Dec_2015_19_26_09_+0000_+5XStNDi1zknY4p7"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Joe Stringer <joestringer@nicira.com>,
	David Miller <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>,
	Michal Kubecek <mkubecek@suse.cz>,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__1_Dec_2015_19_26_09_+0000_+5XStNDi1zknY4p7
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Simon,

Today's linux-next merge of the ipvs-next tree got a conflict in  between c=
ommit 264640fc2c5f4f ("ipv6: distinguish frag queues by device for multicas=
t and link-local packets") from the net tree and commit 029f7f3b8701c ("net=
filter: ipv6: nf_defrag: avoid/free clone operations") from the ipvs-next t=
ree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

diff --cc net/ipv6/netfilter/nf_conntrack_reasm.c
index bab4441ed4e4,912bc3afc183..000000000000
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@@ -582,31 -576,19 +577,21 @@@ int nf_ct_frag6_gather(struct net *net
  	}
 =20
  	if (find_prev_fhdr(skb, &prevhdr, &nhoff, &fhoff) < 0)
- 		return skb;
+ 		return -EINVAL;
 =20
- 	clone =3D skb_clone(skb, GFP_ATOMIC);
- 	if (clone =3D=3D NULL) {
- 		pr_debug("Can't clone skb\n");
- 		return skb;
- 	}
-=20
- 	NFCT_FRAG6_CB(clone)->orig =3D skb;
-=20
- 	if (!pskb_may_pull(clone, fhoff + sizeof(*fhdr))) {
- 		pr_debug("message is too short.\n");
- 		goto ret_orig;
- 	}
+ 	if (!pskb_may_pull(skb, fhoff + sizeof(*fhdr)))
+ 		return -ENOMEM;
 =20
- 	skb_set_transport_header(clone, fhoff);
- 	hdr =3D ipv6_hdr(clone);
- 	fhdr =3D (struct frag_hdr *)skb_transport_header(clone);
+ 	skb_set_transport_header(skb, fhoff);
+ 	hdr =3D ipv6_hdr(skb);
+ 	fhdr =3D (struct frag_hdr *)skb_transport_header(skb);
 =20
  	fq =3D fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr,
 -		     ip6_frag_ecn(hdr));
 -	if (fq =3D=3D NULL)
 +		     skb->dev ? skb->dev->ifindex : 0, ip6_frag_ecn(hdr));
 +	if (fq =3D=3D NULL) {
 +		pr_debug("Can't find and can't create new queue\n");
- 		goto ret_orig;
+ 		return -ENOMEM;
 +	}
 =20
  	spin_lock_bh(&fq->q.lock);
 =20

--Signature=_Tue__1_Dec_2015_19_26_09_+0000_+5XStNDi1zknY4p7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWXfRRAAoJECTWi3JdVIfQswYH/3EFfq+anarhhuY4nWTb5CAD
CX9HJ26ntl6gD7GKiA6vmsBTG2+zfxYD2Bmkx8ILlp3GHLSbeDXMVB4h1Ksehtdl
lhwJycPgeOsoAWhi9l0efrH6Q9tjGXJT8eQPYCGJ3LpjUyyhRo3l29MVRPwKcm9c
RWbC37YSi4GIxCQ6U6iyhlFZPcrOeAuhFvLwrb4222I3dRksx0lEKNh3WKInOZ3i
v+d8MucBZlZpVxVj/dEMvRP65O+EGkRyNzwOQXt7sjFlppuixGtXW9gOrMfn67gt
cz3ETg99vhNPYE3O6H1teIQ0gEhA4zlUr4mY80kIBVcxGgYk4j4r+pvBGz/BmH8=
=gHnV
-----END PGP SIGNATURE-----

--Signature=_Tue__1_Dec_2015_19_26_09_+0000_+5XStNDi1zknY4p7--
