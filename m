From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the vfs tree
Date: Tue, 25 Nov 2014 13:42:46 +1100
Message-ID: <20141125134246.2761ada5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ice+t87a0803zj7P9lvPyEQ"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Steven Rostedt (Red Hat)" <rostedt@goodmis.org>,
	Marcelo Leitner <mleitner@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ice+t87a0803zj7P9lvPyEQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/netfilter/nf_log.c between commit e71456ae9871 ("netfilter: Remove
checks of seq_printf() return values") from the vfs tree and commit
0c26ed1c07f1 ("netfilter: nf_log: Introduce nft_log_dereference()
macro") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/netfilter/nf_log.c
index 6e3b9117db1f,49a64174f3f1..000000000000
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@@ -294,39 -303,35 +303,37 @@@ static int seq_show(struct seq_file *s
  {
  	loff_t *pos =3D v;
  	const struct nf_logger *logger;
 -	int i, ret;
 +	int i;
  	struct net *net =3D seq_file_net(s);
 =20
- 	logger =3D rcu_dereference_protected(net->nf.nf_loggers[*pos],
- 					   lockdep_is_held(&nf_log_mutex));
+ 	logger =3D nft_log_dereference(net->nf.nf_loggers[*pos]);
 =20
  	if (!logger)
 -		ret =3D seq_printf(s, "%2lld NONE (", *pos);
 +		seq_printf(s, "%2lld NONE (", *pos);
  	else
 -		ret =3D seq_printf(s, "%2lld %s (", *pos, logger->name);
 +		seq_printf(s, "%2lld %s (", *pos, logger->name);
 =20
 -	if (ret < 0)
 -		return ret;
 +	if (seq_has_overflowed(s))
 +		return -ENOSPC;
 =20
  	for (i =3D 0; i < NF_LOG_TYPE_MAX; i++) {
  		if (loggers[*pos][i] =3D=3D NULL)
  			continue;
 =20
- 		logger =3D rcu_dereference_protected(loggers[*pos][i],
- 					   lockdep_is_held(&nf_log_mutex));
+ 		logger =3D nft_log_dereference(loggers[*pos][i]);
 -		ret =3D seq_printf(s, "%s", logger->name);
 -		if (ret < 0)
 -			return ret;
 -		if (i =3D=3D 0 && loggers[*pos][i + 1] !=3D NULL) {
 -			ret =3D seq_printf(s, ",");
 -			if (ret < 0)
 -				return ret;
 -		}
 +		seq_printf(s, "%s", logger->name);
 +		if (i =3D=3D 0 && loggers[*pos][i + 1] !=3D NULL)
 +			seq_printf(s, ",");
 +
 +		if (seq_has_overflowed(s))
 +			return -ENOSPC;
  	}
 =20
 -	return seq_printf(s, ")\n");
 +	seq_printf(s, ")\n");
 +
 +	if (seq_has_overflowed(s))
 +		return -ENOSPC;
 +	return 0;
  }
 =20
  static const struct seq_operations nflog_seq_ops =3D {

--Sig_/ice+t87a0803zj7P9lvPyEQ
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUc+ysAAoJEMDTa8Ir7ZwVxVoQAJMJK7tRoRBZ7wXRDQ10E8Xe
Y5/EhDqoMCyg8dTGCp/GjDCJ88w/lvdXRVccUA8rfjIcAecnfFY/dS2cNWZXFFE3
nsw7tgzn75TCp8psNthoqKQVncDfMjVEYsPxup8D0qx5C9AGNQVkAVwP4SRcz26f
omMhtL8m2oa7jKXjkn2WMFOt3CdaCHDo/822ZJUoBYVX1O9EvpFuuu5n1ZC5cNA8
K8P5unQ6yxV0D5Dfu1o/3S1iZpzZwqPHw3UbVnNOmh8mYFV0PaIdG9L/owRWvDf9
qwOO+8ZHsy6NCFB+lScJcj8OCQew/nAnhewZOfCHQRqFXnFLoSEnk0uJ/rZXYi+F
XzBh5SiBTJfPjugHf+sLdgVHZWQwQ2wfoHw2Ce232B6C0pLT7yGUvh+iuxclKVcr
5ftKq4xQRuU8ADfUzQ9qlwCkPgmzINLO4BsHWPNwx8HFtiQJt6EbkhblEE7BNwgC
fc5GUmbN3tcBfZT0auas5uMkwgDoQVThuasVnI5Eel80H2lwvc2ijZCfFJC4sOjC
HSsreVWXWCc41WtnEJeQF3qdzbU9hSAWdBIHvId6CItyrmNk1QKu5XJ7x+UG3NSW
S8/469FuAJsMlmPEwoLilNhh9dRjoPuoQJGEnHaqtG/HAW8r66PIrdNCv6p2S5o3
qJ9RBdtpHg4niBXmbRee
=maA7
-----END PGP SIGNATURE-----

--Sig_/ice+t87a0803zj7P9lvPyEQ--
