From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for-next 03/11] IB/hns: Optimize the logic of allocating
 memory using APIs
Date: Wed, 9 Nov 2016 09:21:30 +0200
Message-ID: <20161109072130.GH27883@leon.nu>
References: <20161104163633.141880-1-salil.mehta@huawei.com>
 <20161104163633.141880-4-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="5vjQsMS/9MbKYGLq"
Cc: dledford@redhat.com, xavier.huwei@huawei.com, oulijun@huawei.com,
        mehta.salil.lnk@gmail.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com, Ping Zhang <zhangping5@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161104163633.141880-4-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5vjQsMS/9MbKYGLq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Nov 04, 2016 at 04:36:25PM +0000, Salil Mehta wrote:
> From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
>
> This patch modified the logic of allocating memory using APIs in
> hns RoCE driver. We used kcalloc instead of kmalloc_array and
> bitmap_zero. And When kcalloc failed, call vzalloc to alloc
> memory.
>
> Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
> Signed-off-by: Ping Zhang <zhangping5@huawei.com>
> Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
> ---
>  drivers/infiniband/hw/hns/hns_roce_mr.c |   15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
> index fb87883..d3dfb5f 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_mr.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
> @@ -137,11 +137,12 @@ static int hns_roce_buddy_init(struct hns_roce_buddy *buddy, int max_order)
>
>  	for (i = 0; i <= buddy->max_order; ++i) {
>  		s = BITS_TO_LONGS(1 << (buddy->max_order - i));
> -		buddy->bits[i] = kmalloc_array(s, sizeof(long), GFP_KERNEL);
> -		if (!buddy->bits[i])
> -			goto err_out_free;
> -
> -		bitmap_zero(buddy->bits[i], 1 << (buddy->max_order - i));
> +		buddy->bits[i] = kcalloc(s, sizeof(long), GFP_KERNEL);
> +		if (!buddy->bits[i]) {
> +			buddy->bits[i] = vzalloc(s * sizeof(long));

I wonder, why don't you use directly vzalloc instead of kcalloc fallback?

> +			if (!buddy->bits[i])
> +				goto err_out_free;
> +		}
>  	}

--5vjQsMS/9MbKYGLq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYIs56AAoJEORje4g2clinpeAP/1Y5dEOVusc9e97LxEeAe+AN
CoQe1btGX8WRhg4N52R2F4DkaKm1Y0XrJBZOBH+VwPz9sWv7NSIA0Sol50E/sf5j
5OtQnQfBsONWMQtdqudvwC8/sW3NIkdlDiIiRTTcgD2YARPvgGNbQqOOBTCwcFCF
6WAocSmecBhVjeGJ5PIZWLKL7IrsGeU9bZjE4lE0Q5tt7yuFau+9levs/SXAaNUD
Ol1LJ/vasuubgt+JpXvpt8m0cxhqDH3QdDFv+j+0fPDI+PKjKB2CM+Ip6MnE/bt0
fEfp8zwEhZi0KsXc6Uk6635kwz77z3m3tbgSYMTCzgPG+Ha5EzVUWevuVjZ0lbMZ
OHcRd/Aoo2eKb3glR3cJ2Ti+V7EGqAabmtr/7lImlZIKQ32JyTh0j4KQ404RxAI6
tw3M4E4Upds1d5p3wPHzbBA+xuv9j3byjxD6wn3a7wfApx+63F609uEaRQ9x/6Fg
rA59ZTsPxleTApkTvkL57luciGx031TX+OnFnX0miT/AI8KEk+vN5b5mGmz3IdAI
LhQu3SuJXUX9ZpnkunsX9T/Bz8kLJet2nTsD8vBMrYVgn2AncJMhmopAz97l82OT
xWAnGARYW3r5hsrYkMIgQkRTun2wmQ6SAYadiGtW5ivdkDyjKnlqdz+HyfILeFN8
7keB6ePdvdT7Qqf4NuOH
=UmbZ
-----END PGP SIGNATURE-----

--5vjQsMS/9MbKYGLq--
