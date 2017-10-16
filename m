From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net] bpf: disallow arithmetic operations on context
 pointer
Date: Mon, 16 Oct 2017 10:06:59 -0700
Message-ID: <20171016100659.68974aac@cakuba.netronome.com>
References: <20171016154552.30640-1-jakub.kicinski@netronome.com>
        <44a8fb95-298b-8715-ce4e-60df60c86343@solarflare.com>
        <20171016093043.36fcfedc@cakuba.netronome.com>
        <e2c4322a-301f-47f9-d102-725138d1bf67@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: <netdev@vger.kernel.org>, <oss-drivers@netronome.com>,
        <alexei.starovoitov@gmail.com>, <daniel@iogearbox.net>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:45010 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752754AbdJPRHE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 13:07:04 -0400
Received: by mail-qk0-f180.google.com with SMTP id r64so13710898qkc.1
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 10:07:04 -0700 (PDT)
In-Reply-To: <e2c4322a-301f-47f9-d102-725138d1bf67@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Oct 2017 17:47:45 +0100, Edward Cree wrote:
> On 16/10/17 17:30, Jakub Kicinski wrote:
> > On Mon, 16 Oct 2017 17:16:24 +0100, Edward Cree wrote: =20
> >> On 16/10/17 16:45, Jakub Kicinski wrote: =20
> >>> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> >>> index 8b8d6ba39e23..8499759d0c7a 100644
> >>> --- a/kernel/bpf/verifier.c
> >>> +++ b/kernel/bpf/verifier.c
> >>> @@ -1116,7 +1116,12 @@ static int check_mem_access(struct bpf_verifie=
r_env *env, int insn_idx, u32 regn
> >>>  		/* ctx accesses must be at a fixed offset, so that we can
> >>>  		 * determine what type of data were returned.
> >>>  		 */
> >>> -		if (!tnum_is_const(reg->var_off)) {
> >>> +		if (reg->off) {
> >>> +			verbose("derefence of modified ctx ptr R%d off=3D%d+%d, ctx+const=
 is allowed, ctx+const+const is not\n",   =20
> >> This is slightly unclear, it's not that two adds is bad (e.g. r1 +=3D =
8;
> >>  r0 =3D *(u32 *)r1 is bad too), it's that the offset must be in the lo=
ad,
> >>  not the register; your message might be accurate for some compilers b=
ut
> >>  not in full generality (especially for assemblers without compiling).=
 =20
> > I'm happy to hear better suggestions :)  I've spent quite a bit of time
> > scratching my head thinking how to phrase this best.  The first
> > part of the message is general enough IMHO, the second is targeted
> > mostly at C developers. =20
> Hmm, what really bugs me is that if e.g. the compiler turned
>    *(ctx + 4 + 4)
>  or
>    ctx[4 + 4]
>  or even
>    ctx->arraymemb[4]
>  into this kind of arithmetic on ctx, arguably that would be a bug in the
>  compiler =E2=80=94 if it's doing proper constexpr folding on its IR (or =
something
>  along those lines) it should be able to turn them all into good LDX.  The
>  same even goes for if (ctx + 4) got stored in a local, because there's no
>  reason that has to map to a register.
> So it's not even that "your C source breaks the rules", it's that "your C
>  compiler did something silly that we don't handle".
> Maybe the message should be "compiler maybe mishandled ctx+const+const"?

Hm.  We have no proof of compilers doing such things.  It's probably
more likely that this will be hit if someone does:

struct xxx *X =3D &skb->cb;
X->field;

Or just tries to add a constant offset to ctx by hand...  "Complier may
have done something silly" is probably implied in all verifier
messages :)

FWIW the pre-tnum error would be:

R%d invalid mem access 'inv'

So we are making this a lot more clear anyway.
