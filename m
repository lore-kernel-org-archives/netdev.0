From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 5 Jul 2016 09:31:51 +0000
Message-ID: <CO2PR03MB218222BA0DD55CD967ED4F38BF390@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
 <1467706914.19760.16.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Rolf Neugebauer <rolf.neugebauer@docker.com>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: Joe Perches <joe@perches.com>, "davem@davemloft.net"
 <davem@davemloft.net>, "gregkh@linuxfoundation.org"
 <gregkh@linuxfoundation.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org"
 <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "apw@canonical.com" <apw@canonical.com>, "jasowang@redhat.com"
 <jasowang@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Cathy Avery
 <cavery@redhat.com>, KY Srinivasan <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1467706914.19760.16.camel@perches.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: Joe Perches [mailto:joe@perches.com]
> =

> > +#define sk_to_hvsock(__sk)=A0=A0=A0((struct hvsock_sock *)(__sk))
> > +#define hvsock_to_sk(__hvsk) ((struct sock *)(__hvsk))
> =

> Might as well be static inlines
Hi Joe,
Thank you for the suggestions (again)! :-)

I'll change them to static inlines.

> > +/* We send at most 4KB payload per VMBus packet. */
> > +struct hvsock_send_buf {
> > +	struct vmpipe_proto_header hdr;
> > +	u8 buf[PAGE_SIZE];
> =

> PAGE_SIZE might not be the right define here if
> the comment is to be believed.

I'll change to something like this:

+#define HVSOCK_MAX_SND_SIZE_BY_VM (1024 * 4)
 struct hvsock_send_buf {
        struct vmpipe_proto_header hdr;
-       u8 buf[PAGE_SIZE];
+       u8 buf[HVSOCK_MAX_SND_SIZE_BY_VM];
 };

 > > diff --git a/include/uapi/linux/hyperv.h b/include/uapi/linux/hyperv.h
> []
> > @@ -396,4 +397,27 @@ struct hv_kvp_ip_msg {
> > =A0	struct hv_kvp_ipaddr_value=A0=A0=A0=A0=A0=A0kvp_ip_val;
> > =A0} __attribute__((packed));
> >
> > +/* This is the address fromat of Hyper-V Sockets.
> =

> format
I suppose you meant I should change =

/* This is ...
to =

/*
  * This is ...
I'll fix this.

> > diff --git a/net/hv_sock/af_hvsock.c b/net/hv_sock/af_hvsock.c
> []
> > @@ -0,0 +1,1519 @@
> > +/*
> > + * Hyper-V Sockets -- a socket-based communication channel between the
> > + * Hyper-V host and the virtual machines running on it.
> > + *
> > + * Copyright(c) 2016, Microsoft Corporation. All rights reserved.
> > + *
> > + * Redistribution and use in source and binary forms, with or without
> > + * modification, are permitted provided that the following conditions
> > + * are met
> .....
> Is this license GPL compatible?
Yes. At the end of the file, there is a line
+MODULE_LICENSE("Dual BSD/GPL");

> > +static struct proto hvsock_proto =3D {
> > +	.name =3D "HV_SOCK",
> > +	.owner =3D THIS_MODULE,
> > +	.obj_size =3D sizeof(struct hvsock_sock),
> > +};
> =

> const?
No. In hvsock_create(), hvsock_proto is passed to sk_alloc(), which requires
a non-const argument. =


> > +static int hvsock_recvmsg_wait(struct sock *sk, struct msghdr *msg,
> > +			=A0=A0=A0=A0=A0=A0=A0size_t len, int flags)
> > +{
> []
> > +				if (ret !=3D 0 || payload_len >
> > +						sizeof(hvsk->recv->buf)) {
> =

> This could look nicer as
> =

> 				if (ret !=3D 0 ||
> 				=A0 =A0 payload_len > sizeof(hvsk->recv->buf)) {
I'll fix this.

Thanks,
-- Dexuan
