From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 16 Mar 2015 13:04:47 +1100
Message-ID: <20150316130447.329b3075@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/e7CNdLEZ_CQ.UaGfn_dajba"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/e7CNdLEZ_CQ.UaGfn_dajba
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv4/inet_diag.c between commit c8e2c80d7ec0 ("inet_diag: fix
possible overflow in inet_diag_dump_one_icsk()") from the net tree and
commit a4458343ac59 ("inet_diag: factorize code in new
inet_diag_msg_common_fill() helper") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/inet_diag.c
index 592aff37366b,ac7b5c909fe7..000000000000
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@@ -71,27 -66,39 +66,53 @@@ static void inet_diag_unlock_handler(co
  	mutex_unlock(&inet_diag_table_mutex);
  }
 =20
 +static size_t inet_sk_attr_size(void)
 +{
 +	return	  nla_total_size(sizeof(struct tcp_info))
 +		+ nla_total_size(1) /* INET_DIAG_SHUTDOWN */
 +		+ nla_total_size(1) /* INET_DIAG_TOS */
 +		+ nla_total_size(1) /* INET_DIAG_TCLASS */
 +		+ nla_total_size(sizeof(struct inet_diag_meminfo))
 +		+ nla_total_size(sizeof(struct inet_diag_msg))
 +		+ nla_total_size(SK_MEMINFO_VARS * sizeof(u32))
 +		+ nla_total_size(TCP_CA_NAME_MAX)
 +		+ nla_total_size(sizeof(struct tcpvegas_info))
 +		+ 64;
 +}
 +
+ static void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct soc=
k *sk)
+ {
+ 	r->idiag_family =3D sk->sk_family;
+=20
+ 	r->id.idiag_sport =3D htons(sk->sk_num);
+ 	r->id.idiag_dport =3D sk->sk_dport;
+ 	r->id.idiag_if =3D sk->sk_bound_dev_if;
+ 	sock_diag_save_cookie(sk, r->id.idiag_cookie);
+=20
+ #if IS_ENABLED(CONFIG_IPV6)
+ 	if (sk->sk_family =3D=3D AF_INET6) {
+ 		*(struct in6_addr *)r->id.idiag_src =3D sk->sk_v6_rcv_saddr;
+ 		*(struct in6_addr *)r->id.idiag_dst =3D sk->sk_v6_daddr;
+ 	} else
+ #endif
+ 	{
+ 	memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
+ 	memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
+=20
+ 	r->id.idiag_src[0] =3D sk->sk_rcv_saddr;
+ 	r->id.idiag_dst[0] =3D sk->sk_daddr;
+ 	}
+ }
+=20
  int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
- 			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
- 			      struct user_namespace *user_ns,		      =09
- 			      u32 portid, u32 seq, u16 nlmsg_flags,
- 			      const struct nlmsghdr *unlh)
+ 		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
+ 		      struct user_namespace *user_ns,
+ 		      u32 portid, u32 seq, u16 nlmsg_flags,
+ 		      const struct nlmsghdr *unlh)
  {
  	const struct inet_sock *inet =3D inet_sk(sk);
+ 	const struct inet_diag_handler *handler;
+ 	int ext =3D req->idiag_ext;
  	struct inet_diag_msg *r;
  	struct nlmsghdr  *nlh;
  	struct nlattr *attr;

--Sig_/e7CNdLEZ_CQ.UaGfn_dajba
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVBjpFAAoJEMDTa8Ir7ZwVN5kP/3w1eKyn6dmYSoRpu0N3ZGev
v0hbu77whYCLB8U/ko1udNk7DnssmEb5MKAXnyCI9WB09/TGVrmnMCVEzqpoDOzc
uNjVO08gQ9P4cKWvAf8+l6lP3dsJ+W4Ez5sFBZzOX9bvq02vQFb/aSHDHAq22qff
tT7ratVEeGB9RFe1sPM5oY8GVjB5bpkvWQOkMejh3VtNsoC7v24dmRV3utk91STz
7d1nrx3+cd9v0UkfkoRnNb07oMXcj9AtJlC67zGGfmLjKeMVQfKuANQKpwLPi4QA
mJUkwDh3XxJYzoViZC5CcRJeptU8M8rOWyRGmhCCpST80kAbuuEOZ23X1Md7xNcX
7LT1BhjZl62kXYtlowBDJfao3fayybMBrx/9+iWqGMNXIWBancVpKxBfEEx419mM
ey7ArPEDwzCmj4vdE87FnJ8vzqDWJLKArdLcihOQpYmP/tCj5Tgx6yJqCmm+SNna
OSYgH/CydN6POacEYeVeszHkHIcsOwbdwzSzO/YpfpmVCY1cIP8skRTabxA4sWLZ
e8KadhVXH/W7prBcDwGqj6EWiDi3FzWZ6hV3AbR2J1q8AXLZ/3AteD2UOgnsNO9O
nKCM8+0wgAvzyh5IO5FcBXf4i/LUssLwjLytPLN4kJC7SR9D9qPVPEIjHfVv8urr
BdArsZRjh7pNnmeQfh8+
=piLB
-----END PGP SIGNATURE-----

--Sig_/e7CNdLEZ_CQ.UaGfn_dajba--
