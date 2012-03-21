From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH 6/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 09:42:37 -0700
Message-ID: <CAL1RGDVv6y-EOiNv-Vmd+jN1dnSPvA0YK_kamYZwmgUzRmUx=g@mail.gmail.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-2-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-3-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-4-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-5-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-6-git-send-email-parav.pandit@emulex.com> <5abe3043-81f8-448a-9e55-b29e23f4eb9a@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5abe3043-81f8-448a-9e55-b29e23f4eb9a-nbYkmrCdWxmgMrCBcu8zE0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +struct ib_pd *ocrdma_alloc_pd(struct ib_device *ibdev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ib_u=
context *context,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ib_u=
data *udata)
> +{
> + =A0 =A0 =A0 struct ocrdma_dev *dev =3D get_ocrdma_dev(ibdev);
> + =A0 =A0 =A0 struct ocrdma_pd *pd;
> + =A0 =A0 =A0 int status;
> +
> + =A0 =A0 =A0 pd =3D kzalloc(sizeof(*pd), GFP_KERNEL);
> + =A0 =A0 =A0 if (!pd)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENOMEM);
> + =A0 =A0 =A0 pd->dev =3D dev;
> + =A0 =A0 =A0 if (udata && context) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pd->dpp_enabled =3D (dev->nic_info.dev_=
family =3D=3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 OCRDMA_GEN2_FAMILY) ? true : false;

Writing

    (<bool expr>) ? true : false

is pretty silly, since it's just an obfuscated way of writing

    <bool expr>

IOW, you can just write

     pd->dpp_enabled =3D (dev->nic_info.dev_family =3D=3D OCRDMA_GEN2_F=
AMILY);


> +int ocrdma_dealloc_pd(struct ib_pd *ibpd)
> +{
> + =A0 =A0 =A0 struct ocrdma_pd *pd =3D get_ocrdma_pd(ibpd);
> + =A0 =A0 =A0 struct ocrdma_dev *dev =3D pd->dev;
> + =A0 =A0 =A0 int status;
> + =A0 =A0 =A0 u64 usr_db;
> +
> + =A0 =A0 =A0 if (atomic_read(&pd->use_cnt)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ocrdma_err("%s(%d) pd=3D0x%x is in use.=
\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, dev->i=
d, pd->id);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto dealloc_err;
> + =A0 =A0 =A0 }

all of the use_cnt tracking in this driver seems to duplicate what the =
rdma
midlayer already does... is there any reason we need that in the low-le=
vel
hardware driver too, or can we just get rid of the various use_cnt memb=
ers?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
