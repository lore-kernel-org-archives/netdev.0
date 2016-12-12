From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 1/1] Fixed to BUG_ON to WARN_ON def
Date: Mon, 12 Dec 2016 20:18:38 +0200
Message-ID: <20161212181838.GB8204@mtr-leonro.local>
References: <811031481540339@web1j.yandex.ru>
 <20161212123937.GA6503@mtr-leonro.local>
 <2090831481547868@web27h.yandex.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="WhfpMioaduB5tiZL"
Cc: "yishaih@mellanox.com" <yishaih@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Ozgur Karatas <okaratas@member.fsf.org>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2090831481547868@web27h.yandex.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--WhfpMioaduB5tiZL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 12, 2016 at 03:04:28PM +0200, Ozgur Karatas wrote:
> Dear Romanovsky;

Please avoid top-posting in your replies.
Thanks

>
> I'm trying to learn english and I apologize for my mistake words and phra=
ses. So, I think the code when call to "sg_set_buf" and next time set memor=
y and buffer. For example, isn't to call "WARN_ON" function, get a error to=
 implicit declaration, right?
>
> Because, you will use to "BUG_ON" get a error implicit declaration of fun=
ctions.

I'm not sure that I followed you. mem->offset is set by sg_set_buf from
buf variable returned by dma_alloc_coherent(). HW needs to get very
precise size of this buf, in multiple of pages and aligned to pages
boundaries.

>
>         sg_set_buf(mem, buf, PAGE_SIZE << order);
>         WARN_ON(mem->offset);

See the patch inline which removes this BUG_ON in proper and safe way.

=46rom 7babe807affa2b27d51d3610afb75b693929ea1a Mon Sep 17 00:00:00 2001
=46rom: Leon Romanovsky <leonro@mellanox.com>
Date: Mon, 12 Dec 2016 20:02:45 +0200
Subject: [PATCH] net/mlx4: Remove BUG_ON from ICM allocation routine

This patch removes BUG_ON() macro from mlx4_alloc_icm_coherent()
by checking DMA address aligment in advance and performing proper
folding in case of error.

Fixes: 5b0bf5e25efe ("mlx4_core: Support ICM tables in coherent memory")
Reported-by: Ozgur Karatas <okaratas@member.fsf.org>
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/icm.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/etherne=
t/mellanox/mlx4/icm.c
index 2a9dd46..e1f9e7c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.c
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
@@ -118,8 +118,13 @@ static int mlx4_alloc_icm_coherent(struct device *dev,=
 struct scatterlist *mem,
 	if (!buf)
 		return -ENOMEM;

+	if (offset_in_page(buf)) {
+		dma_free_coherent(dev, PAGE_SIZE << order,
+				  buf, sg_dma_address(mem));
+		return -ENOMEM;
+	}
+
 	sg_set_buf(mem, buf, PAGE_SIZE << order);
-	BUG_ON(mem->offset);
 	sg_dma_len(mem) =3D PAGE_SIZE << order;
 	return 0;
 }
--
2.10.2


--WhfpMioaduB5tiZL
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlhO6f4ACgkQ5GN7iDZy
WKcxpxAAyKvCvlder4m5O/Aatktymu9LfkaalJXpWA6ZJYCmRDRzexedWmbgInPq
xEvlxDHrRNWq908Ia8aLbd0htGp2oAsELxvMhpHYz1T31KWAqwK1YK9Kbc5kHJ5s
yZblel7Sc+psmdno+wPBl6xcobVhFMvotOi42eiJV3dM37zaCSj4KGpGXCp8b1g2
+cCwxxW6AWLN9yIgX/ECwQDirLL8n/nhkOQML0IpS3KGyAnQeWWI58CPnrymOQMs
BETtLjZh6bZ2kSeKQkkJXIU1kM77Pm1SIKSl8I4O5KcxQ2KPPj0obvfUJI/1QrJb
Z8jFdXJHQiCTzUYzbCWG8A2CcShk6Zx44yq8LzRXxHaue0nEDghYL7ojvZc5TpyD
pVZoAHhNveN6cwOt6xOdC5uXkf49+QMcEvUe9hndlqM2kVJyHopCofFK4Pk8aT/y
mfldCRJL1DFg2yprVLePTPaDYr2uveJ5bs6uCu16TIHss76fDEi4mNBhkDEBRdsN
zfoHQXQrovsqaYooqAOqDPTu2lMkildpcBVps1JYNRVcnzX3QZffNlg1+Etwduic
qyX/CCDUv+VImKFAp/FAzCQcrf9ee2LAvHXGC4vSGC1IR1OQ8FYBSAwW6vviA0Aa
dEzXCsTyiQWjL0ajgm+AhR+qzV2CIUsVIvbgblcEoSIOaskDTKE=
=24N9
-----END PGP SIGNATURE-----

--WhfpMioaduB5tiZL--
