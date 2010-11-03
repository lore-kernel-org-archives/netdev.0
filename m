From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [SECURITY] memory corruption in X.25 facilities parsing
Date: Wed, 3 Nov 2010 12:12:51 +1100
Message-ID: <AANLkTi=fAMDP-rGZfOcHS0j_J=KSBgxqqbLaQsXxooJn@mail.gmail.com>
References: <1288710168.2504.6.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36244 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245Ab0KCBMx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 21:12:53 -0400
Received: by fxm16 with SMTP id 16so57859fxm.19
        for <netdev@vger.kernel.org>; Tue, 02 Nov 2010 18:12:51 -0700 (PDT)
In-Reply-To: <1288710168.2504.6.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is an issue here, under select scenarios I can crash systems.
However the patch doesn't resolve it fully, I think after breaking at
that point the len and p pointers are messed up before it tries to
parse the next facility.

Maybe it should return not break? It should reject/clear such calls.
I'll start checking if the callers properly handle errors.
Also should it be if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] <=3D 1),
because it does the memcpy with p[1] -1


On Wed, Nov 3, 2010 at 2:02 AM, Dan Rosenberg <drosenberg@vsecurity.com=
> wrote:
> I put this together after a quick glance, so if someone knows this co=
de
> better than I do (i.e. at all), feel free to comment or drop this pat=
ch
> if it's unnecessary.
>
> A value of 0 will cause a memcpy() of ULONG_MAX size, destroying the
> kernel heap.
>
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
>
> --- linux-2.6.36-rc6.orig/net/x25/x25_facilities.c =A0 =A0 =A02010-09=
-28 21:01:22.000000000 -0400
> +++ linux-2.6.36-rc6/net/x25/x25_facilities.c =A0 2010-11-02 10:36:02=
=2E827291324 -0400
> @@ -134,14 +134,14 @@ int x25_parse_facilities(struct sk_buff
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_CLASS_D:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (*p) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_CALLING_A=
E:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p[1=
] > X25_MAX_DTE_FACIL_LEN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p[1=
] > X25_MAX_DTE_FACIL_LEN || p[1] =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dte_fa=
cs->calling_len =3D p[2];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy=
(dte_facs->calling_ae, &p[3], p[1] - 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*vc_fa=
c_mask |=3D X25_MASK_CALLING_AE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_CALLED_AE=
:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p[1=
] > X25_MAX_DTE_FACIL_LEN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p[1=
] > X25_MAX_DTE_FACIL_LEN || p[1] =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dte_fa=
cs->called_len =3D p[2];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy=
(dte_facs->called_ae, &p[3], p[1] - 1);
>
>
>
