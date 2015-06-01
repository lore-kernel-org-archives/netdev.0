From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 1 Jun 2015 13:44:13 +1000
Message-ID: <20150601134413.34ccfce3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/xYE8XkCjyfsr8HpZGhrSmiI"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Saeed Mahameed <saeedm@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/xYE8XkCjyfsr8HpZGhrSmiI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/net/ethernet/mellanox/mlx5/core/main.c: In function 'mlx5_irq_set_a=
ffinity_hint':
drivers/net/ethernet/mellanox/mlx5/core/main.c:474:2: error: implicit decla=
ration of function 'cpumask_set_cpu_local_first' [-Werror=3Dimplicit-functi=
on-declaration]
  err =3D cpumask_set_cpu_local_first(i, numa_node, priv->irq_info[i].mask);
  ^

Caused by commit db058a186f98 ("net/mlx5_core: Set irq affinity hints")
interacting with commit f36963c9d3f6 ("cpumask_set_cpu_local_first =3D>
cpumask_local_spread, lament") from Linus' tree.

I have applied the following merge fix patch (Dave, you could do this
by back merging commit f36963c9d3f6 from Linus' tree - which is based
on v4.1-rc2 if that worries you).  Please yell if this is not correct
(it does build).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 1 Jun 2015 13:36:49 +1000
Subject: [PATCH] net/mlx5_core: merge fix for cpumask_set_cpu_local_first A=
PI change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/e=
thernet/mellanox/mlx5/core/main.c
index 1c37f587426d..2510fed3494d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -471,11 +471,8 @@ static int mlx5_irq_set_affinity_hint(struct mlx5_core=
_dev *mdev, int i)
 		return -ENOMEM;
 	}
=20
-	err =3D cpumask_set_cpu_local_first(i, numa_node, priv->irq_info[i].mask);
-	if (err) {
-		mlx5_core_warn(mdev, "cpumask_set_cpu_local_first failed");
-		goto err_clear_mask;
-	}
+	cpumask_set_cpu(cpumask_local_spread(i, numa_node),
+			priv->irq_info[i].mask);
=20
 	err =3D irq_set_affinity_hint(irq, priv->irq_info[i].mask);
 	if (err) {
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/xYE8XkCjyfsr8HpZGhrSmiI
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVa9USAAoJEMDTa8Ir7ZwVH08P/0W1hJ+xAn5Hre5R0r1Lyi+2
JbRQFZnXZRncTIrsbg20onKfOu/IGSYzrIx4DBwq+kbCgkx9ttffcL9xsVpqZkde
91B3+EZhMA4fGvXDaorXHMFpa2fl4DhYRF2bVjrcoz2UZWEo38A/MrTo/YgpUoRj
ivc/Bem/G4jF10y/IAtgKwtOfCcY7wd2vIjIGMqLISdVOJCjF6n5HtW+wZunfKzb
6nGUAwEyt3h0U1NOegfHYJAODNDwn/adVCW+E8xW63e82owCMGban0f+usJ2fhKw
2AMuwO75fATnFpNCMPmhLM4ZuNeuvb+lGSPE7GlDjh0/DIo3FEqTdk60H+E3f4F1
Zn7nmi6Se31W5PGwa8cuTSy95T7xpWMH11hxq42hyoZ9Za1pwu1/D8GI+vPc/EYf
Ah4dPM9KZCORDkoEFLBTJTyVYwAIPnah+ILJ8nC1yPHRelOsBuFx5c+uag8dPJ28
IBjsq1VxodTBjbh6ZYDlo+24mB3rwdjRrhGNaLUmIqgUdZYl2LLB3N0Tdz5AaMPK
VWVmYK0G9qYbB011CVae3hNc22oIO43x0uFbk2he7w5r0aZfHwRi8IPgagP01+s/
jItDae5TvcTkT/dChy0q5iew5GxAvb0NlEeFUSJPwREx+kbeSVYGbcUbEwdaUFMk
x+SqlZ871gl0A103or1m
=ZvZL
-----END PGP SIGNATURE-----

--Sig_/xYE8XkCjyfsr8HpZGhrSmiI--
