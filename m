From: "Kershner, David A" <David.Kershner@unisys.com>
Subject: RE: [PATCH 10/22] staging: unisys: visorbus: Make use of the new
 sg_map helper function
Date: Fri, 14 Apr 2017 16:07:14 +0000
Message-ID: <CY4PR07MB317691139A5B2F902CDA9B0EF0050__40660.1976174445$1492186053$gmane$org@CY4PR07MB3176.namprd07.prod.outlook.com>
References: <1492121135-4437-1-git-send-email-logang@deltatee.com>
 <1492121135-4437-11-git-send-email-logang@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Steve Wise <swise@opengridcomputing.com>,
        Stephen Bates <sbates@raithlin.com>
To: Logan Gunthorpe <logang@deltatee.com>,
        Christoph Hellwig <hch@lst.de>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Sagi Grimberg <sagi@grimberg.me>, Jens Axboe <axboe@kernel.dk>,
        Tejun Heo <tj@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Ross Zwisler <ross.zwisler@linux.intel.com>,
        Matthew Wilcox <mawilcox@microsoft.com>,
        Sumit Semwal <sumit.semwal@linaro.org>,
        Ming Lin <ming.l@ssi.samsung.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
        "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
        "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
        "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.li
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0061.outbound.protection.outlook.com ([104.47.33.61]:59193
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751147AbdDNQHW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Apr 2017 12:07:22 -0400
In-Reply-To: <1492121135-4437-11-git-send-email-logang@deltatee.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Logan Gunthorpe [mailto:logang@deltatee.com]
...
> Subject: [PATCH 10/22] staging: unisys: visorbus: Make use of the new
> sg_map helper function
>=20
> Straightforward conversion to the new function.
>=20
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>

Can you add Acked-by for this patch?=20

Acked-by: David Kershner <david.kershner@unisys.com>

Tested on s-Par and no problems.=20

Thanks,
David Kershner

> ---
>  drivers/staging/unisys/visorhba/visorhba_main.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/staging/unisys/visorhba/visorhba_main.c
> b/drivers/staging/unisys/visorhba/visorhba_main.c
> index 0ce92c8..2d8c8bc 100644
> --- a/drivers/staging/unisys/visorhba/visorhba_main.c
> +++ b/drivers/staging/unisys/visorhba/visorhba_main.c
> @@ -842,7 +842,6 @@ do_scsi_nolinuxstat(struct uiscmdrsp *cmdrsp, struct
> scsi_cmnd *scsicmd)
>  	struct scatterlist *sg;
>  	unsigned int i;
>  	char *this_page;
> -	char *this_page_orig;
>  	int bufind =3D 0;
>  	struct visordisk_info *vdisk;
>  	struct visorhba_devdata *devdata;
> @@ -869,11 +868,14 @@ do_scsi_nolinuxstat(struct uiscmdrsp *cmdrsp,
> struct scsi_cmnd *scsicmd)
>=20
>  		sg =3D scsi_sglist(scsicmd);
>  		for (i =3D 0; i < scsi_sg_count(scsicmd); i++) {
> -			this_page_orig =3D kmap_atomic(sg_page(sg + i));
> -			this_page =3D (void *)((unsigned long)this_page_orig |
> -					     sg[i].offset);
> +			this_page =3D sg_map(sg + i, SG_KMAP_ATOMIC);
> +			if (IS_ERR(this_page)) {
> +				scsicmd->result =3D DID_ERROR << 16;
> +				return;
> +			}
> +
>  			memcpy(this_page, buf + bufind, sg[i].length);
> -			kunmap_atomic(this_page_orig);
> +			sg_unmap(sg + i, this_page, SG_KMAP_ATOMIC);
>  		}
>  	} else {
>  		devdata =3D (struct visorhba_devdata *)scsidev->host-
> >hostdata;
> --
> 2.1.4
