From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 05 Jul 2016 01:21:54 -0700
Message-ID: <1467706914.19760.16.camel@perches.com>
References: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Haiyang Zhang <haiyangz@microsoft.com>,
	Rolf Neugebauer <rolf.neugebauer@docker.com>
To: Dexuan Cui <decui@microsoft.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Cathy Avery <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-06-30 at 15:58 +0000, Dexuan Cui wrote:
> Hyper-V Sockets (hv_sock) supplies a byte-stream based communication
> mechanism between the host and the guest. It's somewhat like TCP over
> VMBus, but the transportation layer (VMBus) is much simpler than IP.

trivia:

> diff --git a/include/net/af_hvsock.h b/include/net/af_hvsock.h
[]
> @@ -0,0 +1,59 @@
[]
> +#define sk_to_hvsock(__sk)=A0=A0=A0((struct hvsock_sock *)(__sk))
> +#define hvsock_to_sk(__hvsk) ((struct sock *)(__hvsk))

Might as well be static inlines

> +/* We send at most 4KB payload per VMBus packet. */
> +struct hvsock_send_buf {
> +	struct vmpipe_proto_header hdr;
> +	u8 buf[PAGE_SIZE];

PAGE_SIZE might not be the right define here if
the comment is to be believed.

> diff --git a/include/uapi/linux/hyperv.h b/include/uapi/linux/hyperv.=
h
[]
> @@ -396,4 +397,27 @@ struct hv_kvp_ip_msg {
> =A0	struct hv_kvp_ipaddr_value=A0=A0=A0=A0=A0=A0kvp_ip_val;
> =A0} __attribute__((packed));
> =A0
> +/* This is the address fromat of Hyper-V Sockets.

format

> diff --git a/net/hv_sock/af_hvsock.c b/net/hv_sock/af_hvsock.c
[]
> @@ -0,0 +1,1519 @@
> +/*
> + * Hyper-V Sockets -- a socket-based communication channel between t=
he
> + * Hyper-V host and the virtual machines running on it.
> + *
> + * Copyright(c) 2016, Microsoft Corporation. All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or withou=
t
> + * modification, are permitted provided that the following condition=
s
> + * are met:
> + *
> + * 1. Redistributions of source code must retain the above copyright
> + *=A0=A0=A0=A0notice, this list of conditions and the following disc=
laimer.
> + * 2. Redistributions in binary form must reproduce the above copyri=
ght
> + *=A0=A0=A0=A0notice, this list of conditions and the following disc=
laimer in the
> + *=A0=A0=A0=A0documentation and/or other materials provided with the=
 distribution.
> + * 3. The name of the author may not be used to endorse or promote
> + *=A0=A0=A0=A0products derived from this software without specific p=
rior written
> + *=A0=A0=A0=A0permission.
> + * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS=
 OR
> + * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
> + * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOS=
E
> + * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DI=
RECT,
> + * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGE=
S
> + * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS O=
R
> + * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION=
)
> + * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRAC=
T,
> + * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARI=
SING
> + * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF TH=
E
> + * POSSIBILITY OF SUCH DAMAGE.
> + */

Is this license GPL compatible?

> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include=20
> +#include=20
> +#include=20
> +#include=20
> +
> +static struct proto hvsock_proto =3D {
> +	.name =3D "HV_SOCK",
> +	.owner =3D THIS_MODULE,
> +	.obj_size =3D sizeof(struct hvsock_sock),
> +};
=09
const?

> +static int hvsock_recvmsg_wait(struct sock *sk, struct msghdr *msg,
> +			=A0=A0=A0=A0=A0=A0=A0size_t len, int flags)
> +{
[]
> +				if (ret !=3D 0 || payload_len >
> +						sizeof(hvsk->recv->buf)) {

This could look nicer as

				if (ret !=3D 0 ||
				=A0 =A0 payload_len > sizeof(hvsk->recv->buf)) {
