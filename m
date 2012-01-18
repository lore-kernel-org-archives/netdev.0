From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bpf_jit_compile issues on x86_64
Date: Wed, 18 Jan 2012 07:17:08 +0100
Message-ID: <1326867428.2606.39.camel@edumazet-laptop>
References: <20120118022709.GA4167@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42120 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303Ab2ARGRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 01:17:13 -0500
Received: by wgbdq11 with SMTP id dq11so2811778wgb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 22:17:12 -0800 (PST)
In-Reply-To: <20120118022709.GA4167@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 janvier 2012 =C3=A0 18:27 -0800, Phil Oester a =C3=A9crit :
> On a 3.1.8 kernel, I've had a few snort boxes panic when using the ne=
w bpf_jit
> code.  Setting bpf_jit_enable back to 0 solves the problem.  Below is=
 the
> warning, followed by the panic.  I've checked the current Linus tree,=
 but
> other than a03ffcf8 (which exists in 3.1.8) I don't see anything new =
in this
> area.  Any ideas?  Eric?
>=20

Hi Phil, thanks for the report !

Any chance you could send me the bpf filter that was loaded at this
time ?

Please try the following patch :

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 7b65f75..a7e6baa 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -584,6 +584,7 @@ cond_branch:			f_offset =3D addrs[i + filter[i].jf]=
 - addrs[i];
 			ilen =3D prog - temp;
 			if (image) {
 				if (unlikely(proglen + ilen > oldproglen)) {
+bpf_fatal_error:
 					pr_err("bpb_jit_compile fatal error\n");
 					kfree(addrs);
 					module_free(NULL, image);
@@ -605,7 +606,10 @@ cond_branch:			f_offset =3D addrs[i + filter[i].jf=
] - addrs[i];
 			cleanup_addr -=3D 4; /* mov  -8(%rbp),%rbx */
=20
 		if (image) {
-			WARN_ON(proglen !=3D oldproglen);
+			if (proglen !=3D oldproglen) {
+				pr_err("proglen=3D%u !=3D oldproglen=3D%u\n", proglen, oldproglen)=
;
+				goto bpf_fatal_error;
+			}
 			break;
 		}
 		if (proglen =3D=3D oldproglen) {
