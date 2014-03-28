From: Yann Droneaud <ydroneaud@opteya.com>
Subject: Re: [patch] RDMA/cxgb4: info leak in c4iw_alloc_ucontext()
Date: Fri, 28 Mar 2014 11:27:48 +0100
Message-ID: <1396002468.3297.63.camel@localhost.localdomain>
References: <20140328082428.GH25192@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Wise <swise@chelsio.com>, Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	linux-rdma@vger.kernel.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	roland@purestorage.com, dm@chelsio.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com, Steve Wise <swise@opengridcomputing.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:54136 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751129AbaC1K2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 06:28:08 -0400
In-Reply-To: <20140328082428.GH25192@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le vendredi 28 mars 2014 =C3=A0 11:24 +0300, Dan Carpenter a =C3=A9crit=
 :
> The c4iw_alloc_ucontext_resp struct has a 4 byte hole after the last
> member and we should clear it before passing it to the user.
>=20
> Fixes: 05eb23893c2c ('cxgb4/iw_cxgb4: Doorbell Drop Avoidance Bug Fix=
es')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>=20

It's not the proper fix for this issue: an explicit padding has to be
added (and initialized), see "Re: [PATCH net-next 2/2] cxgb4/iw_cxgb4:
Doorbell Drop Avoidance Bug Fixes"
http://marc.info/?i=3D1395848977.3297.15.camel@localhost.localdomain

In its current form, the c4iw_alloc_ucontext_resp structure does not
require padding on i386, so a 32bits userspace program using this
structure against a x86_64 kernel will make the kernel do a buffer
overflow in userspace, likely on stack, as answer of a GET_CONTEXT
request:

#include <infiniband/verbs.h>
#include <infiniband/kern-abi.h>

#define IBV_INIT_CMD_RESP(cmd, size, opcode, out, outsize) \
do {                                                       \
    (cmd)->command =3D IB_USER_VERBS_CMD_##opcode;           \
    (cmd)->in_words  =3D (size) / 4;                         \
    (cmd)->out_words =3D (outsize) / 4;                      \
    (cmd)->response  =3D (out);                              \
} while (0)

struct c4iw_alloc_ucontext_resp {
        struct ibv_get_context_resp ibv_resp;
        __u64 status_page_key;
        __u32 status_page_size;
};

struct ibv_context *alloc_context(struct ibv_device *ibdev,
                                  int cmd_fd)
{
    struct ibv_get_context cmd;
    struct c4iw_alloc_ucontext_resp resp;
    ssize_t sret;
    ...

    IBV_INIT_CMD_RESP(&cmd, sizeof(cmd),
                      GET_CONTEXT,
                      &resp, sizeof(resp));
    ...
    sret =3D write(context->cmd_fd,
                 &cmd,
                 sizeof(cmd));

    if (sret !=3D sizeof(cmd)) {
        int err =3D errno;
        fprintf(stderr, "GET_CONTEXT failed: %d (%s)\n",
                err, strerror(err));
        ...
    }
    ...
}

Unfortunately, it's not the only structure which has this problem. I'm
currently preparing a report on this issue for this driver (cxgb4) and
another.

> diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infinib=
and/hw/cxgb4/provider.c
> index e36d2a2..a72aaa7 100644
> --- a/drivers/infiniband/hw/cxgb4/provider.c
> +++ b/drivers/infiniband/hw/cxgb4/provider.c
> @@ -107,7 +107,7 @@ static struct ib_ucontext *c4iw_alloc_ucontext(st=
ruct ib_device *ibdev,
>  	struct c4iw_ucontext *context;
>  	struct c4iw_dev *rhp =3D to_c4iw_dev(ibdev);
>  	static int warned;
> -	struct c4iw_alloc_ucontext_resp uresp;
> +	struct c4iw_alloc_ucontext_resp uresp =3D {};
>  	int ret =3D 0;
>  	struct c4iw_mm_entry *mm =3D NULL;
> =20

Regards.

--=20
Yann Droneaud
OPTEYA
