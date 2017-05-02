From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] ipx: call ipxitf_put() in ioctl error path
Date: Tue, 2 May 2017 16:42:33 -0700
Message-ID: <CAGXu5j+sqS_LfuS5Jy2-AfYmRyKWhsyBo9bqHrnnyQ+ONA4nMA@mail.gmail.com>
References: <143C0AFC63FC204CB0C55BB88F3A8ABB33419ED1@EX02.corp.qihoo.net> <20170502105853.yz3ny6lyso6isdvx@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        "security@kernel.org" <security@kernel.org>,
        "secalert@redhat.com" <secalert@redhat.com>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34153 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbdEBXmf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 19:42:35 -0400
Received: by mail-io0-f171.google.com with SMTP id k91so3179588ioi.1
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 16:42:35 -0700 (PDT)
In-Reply-To: <20170502105853.yz3ny6lyso6isdvx@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 2, 2017 at 3:58 AM, Dan Carpenter <dan.carpenter@oracle.com> wr=
ote:
> We should call ipxitf_put() if the copy_to_user() fails.
>
> Reported-by: =E6=9D=8E=E5=BC=BA <liqiang6-s@360.cn>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
> index 8a9219ff2e77..fa31ef29e3fa 100644
> --- a/net/ipx/af_ipx.c
> +++ b/net/ipx/af_ipx.c
> @@ -1168,11 +1168,10 @@ static int ipxitf_ioctl(unsigned int cmd, void __=
user *arg)
>                 sipx->sipx_network      =3D ipxif->if_netnum;
>                 memcpy(sipx->sipx_node, ipxif->if_node,
>                         sizeof(sipx->sipx_node));
> -               rc =3D -EFAULT;
> +               rc =3D 0;
>                 if (copy_to_user(arg, &ifr, sizeof(ifr)))
> -                       break;
> +                       rc =3D -EFAULT;
>                 ipxitf_put(ipxif);
> -               rc =3D 0;
>                 break;
>         }
>         case SIOCAIPXITFCRT:

This refcount overflow flaw (and resulting use-after-free) appears to
be reachable from unprivileged userspace, though I think it requires
an interface already be configured, so this is likely not much risk to
most users. Someone more familiar with IPX should double-check...

And, of course, I should point out this flaw would have been blocked
entirely by using refcount_t:
https://lkml.org/lkml/2017/3/17/193

And if it didn't require a configured interface, it would be mitigated
with module autoload blocking:
https://lkml.org/lkml/2017/4/19/1088

(Yes, yes, I know both are still being worked on, but this is a good
example to show another case where they'd have been useful.)

-Kees

--=20
Kees Cook
Pixel Security
