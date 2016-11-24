From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [scr265482] ip_tunnel.c
Date: Wed, 23 Nov 2016 23:19:38 -0800
Message-ID: <CAM_iQpX7mU7gogGx1peYMoOQbp0CZgYmTZJt=uGFm0c0gviY5A@mail.gmail.com>
References: <860a2905e7f7467f864e13839eb05222@imshyb02.MITRE.ORG> <F41877A268BCDE49BAEE2286FA8C269F6FECFB15@LETV-MBX-IDC09.letv.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "security@kernel.org" <security@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cve-request@mitre.org" <cve-request@mitre.org>
To: =?UTF-8?B?TGl5YW5nIFl1ICjkuo7nq4vmtIsxKQ==?= <yuliyang1@le.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35014 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751146AbcKXHUA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 02:20:00 -0500
Received: by mail-io0-f195.google.com with SMTP id h133so4189183ioe.2
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 23:20:00 -0800 (PST)
In-Reply-To: <F41877A268BCDE49BAEE2286FA8C269F6FECFB15@LETV-MBX-IDC09.letv.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 6:47 PM, Liyang Yu (=E4=BA=8E=E7=AB=8B=E6=B4=8B1) <=
yuliyang1@le.com> wrote:
> Hi:
>         I found that the GRE tunnel in same case can cause integer overfl=
ow in ip_tunnel.c:397
>
> Cause of the problem:
>         When tpi->seq less than tunnel->i_seqno, the packet will be drope=
d.
>
> How to recurrence problem
>         1. Create an tunnel use kernel GRE module.
>     2. Use the tunnel to send packets for awile.
>     3.Reboot one site of the tunnel.
>     4. Communication interrupted

What do you mean by "reboot one site of the tunnel"?

If you mean something like delete and create it again,
it has nothing related to integer overflow, the tunnel->o_seqno
will restart from 0 and the tunnel->i_seqno will remain as it is
since we can't detect the interruption of the tunnel traffic.
If so, the following patch could help?


diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 5719d6b..2738ff2 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -277,6 +277,7 @@ static struct net_device
*__ip_tunnel_create(struct net *net,
        tunnel =3D netdev_priv(dev);
        tunnel->parms =3D *parms;
        tunnel->net =3D net;
+       tunnel->o_seqno =3D UINT_MAX;

        err =3D register_netdevice(dev);
        if (err)
