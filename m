From: Jojy Varghese <jojy.varghese@gmail.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 8 Sep 2016 12:08:29 -0700
Message-ID: <CAJD3hpUSqSxtgJMK__V-j8VKRwf-ftZFHw0J38VTxP9tDDZyhA@mail.gmail.com>
References: <CAJD3hpUgNJPOqGmAp7tEaY2+EnOasG=W6VLOMbEhDRgr8M5v8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35642 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937116AbcIHTIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 15:08:31 -0400
Received: by mail-wm0-f66.google.com with SMTP id a6so9198571wmc.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 12:08:31 -0700 (PDT)
In-Reply-To: <CAJD3hpUgNJPOqGmAp7tEaY2+EnOasG=W6VLOMbEhDRgr8M5v8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Updating the patch for the case when a non-loopback dev could be unregiste=
red)

Currently during namespace cleanup, if =E2=80=98dst=E2=80=99 subsystem is h=
olding
a reference to the interface in the namespace, it does not get released.
Current code first does a =E2=80=99dev_hold=E2=80=99 on the same device fol=
lowed by a
=E2=80=98dev_put=E2=80=99 on the same device resulting in a no-op.

This change fixes this leak by assigning the initial namespace=E2=80=99s lo=
opback
device to the =E2=80=98dst=E2=80=99 before releasing the reference to the n=
etwork
device being released.

Additional reference: https://github.com/docker/docker/issues/5618

Signed-off-by: Jojy G Varghese <jojy.varghese@gmail.com>
---
 net/core/dst.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index a1656e3..7e45593 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -433,7 +433,11 @@ static void dst_ifdown(struct dst_entry *dst,
struct net_device *dev,
                dst->input =3D dst_discard;
                dst->output =3D dst_discard_out;
        } else {
-               dst->dev =3D dev_net(dst->dev)->loopback_dev;
+               if (dst->dev =3D=3D dev_net(dst->dev)->loopback_dev)
+                       dst->dev =3D init_net.loopback_dev;
+               else
+                       dst->dev =3D dev_net(dst->dev)->loopback_dev;
+
                dev_hold(dst->dev);
                dev_put(dev);
        }
--
1.8.3.1

On Wed, Sep 7, 2016 at 6:55 PM, Jojy Varghese <jojy.varghese@gmail.com> wro=
te:
> During namespace cleanup, if =E2=80=98dst=E2=80=99 subsystem is holding
> a reference to the loopback interface in the namespace, it does not get
> released. This is because in the case where the net_device held by 'dst'
> is same as the namespace's loopback net_device, current code first
> does a =E2=80=99dev_hold=E2=80=99 on the same device followed by a =E2=80=
=98dev_put=E2=80=99 on the
> same device resulting in a no-op.
>
> This change fixes this leak by assigning the initial namespace=E2=80=99s =
loopback
> device to the =E2=80=98dst=E2=80=99=E2=80=99 before releasing the referen=
ce to the network device
> being unregistered.
>
> Additional reference: https://github.com/docker/docker/issues/5618
>
> Signed-off-by: Jojy G Varghese <jojy.varghese@gmail.com>
> ---
>  net/core/dst.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/dst.c b/net/core/dst.c
> index a1656e3..a18e8ea 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -433,7 +433,7 @@ static void dst_ifdown(struct dst_entry *dst,
> struct net_device *dev,
>                 dst->input =3D dst_discard;
>                 dst->output =3D dst_discard_out;
>         } else {
> -               dst->dev =3D dev_net(dst->dev)->loopback_dev;
> +               dst->dev =3D init_net.loopback_dev;
>                 dev_hold(dst->dev);
>                 dev_put(dev);
>         }
> --
> 1.8.3.1



--=20
Jojy G Varghese
