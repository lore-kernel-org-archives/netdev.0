From: James Hogan <james.hogan@imgtec.com>
Subject: Re: [RFC PATCH 2/2] bpf: Initialise mod[] in bpf_trace_printk
Date: Mon, 14 Aug 2017 13:25:44 +0100
Message-ID: <20170814122544.GQ6973@jhogan-linux.le.imgtec.org>
References: <59897A7C.10009@iogearbox.net>
 <20170808.094857.245786887664041622.davem@davemloft.net>
 <650EB3B0-1101-4624-905A-E68D2EC5920F@imgtec.com>
 <20170808.145433.1287676484744976417.davem@davemloft.net>
 <20170809073926.GO6973@jhogan-linux.le.imgtec.org>
 <598B71C9.7090303@iogearbox.net>
 <598DDF88.6020809@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="kzRosno1BoFkwaBD"
Cc: David Miller <davem@davemloft.net>, <ast@kernel.org>,
        <linux-kernel@vger.kernel.org>, <rostedt@goodmis.org>,
        <mingo@redhat.com>, <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <598DDF88.6020809@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--kzRosno1BoFkwaBD
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 11, 2017 at 06:47:04PM +0200, Daniel Borkmann wrote:
> Hi James,
>=20
> On 08/09/2017 10:34 PM, Daniel Borkmann wrote:
> > On 08/09/2017 09:39 AM, James Hogan wrote:
> > [...]
> >> time (but please consider looking at the other patch which is certainly
> >> a more real issue).
> >
> > Sorry for the delay, started looking into that and whether we
> > have some other options, I'll get back to you on this.
>=20
> Could we solve this more generically (as in: originally intended) in
> the sense that we don't need to trust the gcc va_list handling; I feel
> this is relying on an implementation detail? Perhaps something like
> below poc patch?

Well it works on MIPS32 and MIPS64 with tracex5.

Tested-by: James Hogan <james.hogan@imgtec.com>

Cheers
James

>=20
> Thanks again,
> Daniel
>=20
>  From 71f16544d455abb6bb82f7253c17c14d2a395e91 Mon Sep 17 00:00:00 2001
> Message-Id: <71f16544d455abb6bb82f7253c17c14d2a395e91.1502469361.git.dani=
el@iogearbox.net>
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Fri, 11 Aug 2017 15:56:32 +0200
> Subject: [PATCH] bpf: fix bpf_trace_printk on 32 bit
>=20
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>   kernel/trace/bpf_trace.c | 31 +++++++++++++++++++++++++++----
>   1 file changed, 27 insertions(+), 4 deletions(-)
>=20
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index 3738519..d4cb36f 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -204,10 +204,33 @@ static const struct bpf_func_proto *bpf_get_probe_w=
rite_proto(void)
>   		fmt_cnt++;
>   	}
>=20
> -	return __trace_printk(1/* fake ip will not be printed */, fmt,
> -			      mod[0] =3D=3D 2 ? arg1 : mod[0] =3D=3D 1 ? (long) arg1 : (u32) =
arg1,
> -			      mod[1] =3D=3D 2 ? arg2 : mod[1] =3D=3D 1 ? (long) arg2 : (u32) =
arg2,
> -			      mod[2] =3D=3D 2 ? arg3 : mod[2] =3D=3D 1 ? (long) arg3 : (u32) =
arg3);
> +#define __BPF_TP_EMIT()	__BPF_ARG3_TP()
> +#define __BPF_TP(...)							\
> +	__trace_printk(1 /* fake ip will not be printed */,		\
> +		       fmt, ##__VA_ARGS__)
> +
> +#define __BPF_ARG1_TP(...)						\
> +	((mod[0] =3D=3D 2 || (mod[0] =3D=3D 1 && __BITS_PER_LONG =3D=3D 64))	\
> +	  ? __BPF_TP(arg1, ##__VA_ARGS__)				\
> +	  : ((mod[0] =3D=3D 1 || (mod[0] =3D=3D 0 && __BITS_PER_LONG =3D=3D 32)=
)	\
> +	      ? __BPF_TP((long)arg1, ##__VA_ARGS__)			\
> +	      : __BPF_TP((u32)arg1, ##__VA_ARGS__)))
> +
> +#define __BPF_ARG2_TP(...)						\
> +	((mod[1] =3D=3D 2 || (mod[1] =3D=3D 1 && __BITS_PER_LONG =3D=3D 64))	\
> +	  ? __BPF_ARG1_TP(arg2, ##__VA_ARGS__)				\
> +	  : ((mod[1] =3D=3D 1 || (mod[1] =3D=3D 0 && __BITS_PER_LONG =3D=3D 32)=
)	\
> +	      ? __BPF_ARG1_TP((long)arg2, ##__VA_ARGS__)		\
> +	      : __BPF_ARG1_TP((u32)arg2, ##__VA_ARGS__)))
> +
> +#define __BPF_ARG3_TP(...)						\
> +	((mod[2] =3D=3D 2 || (mod[2] =3D=3D 1 && __BITS_PER_LONG =3D=3D 64))	\
> +	  ? __BPF_ARG2_TP(arg3, ##__VA_ARGS__)				\
> +	  : ((mod[2] =3D=3D 1 || (mod[2] =3D=3D 0 && __BITS_PER_LONG =3D=3D 32)=
)	\
> +	      ? __BPF_ARG2_TP((long)arg3, ##__VA_ARGS__)		\
> +	      : __BPF_ARG2_TP((u32)arg3, ##__VA_ARGS__)))
> +
> +	return __BPF_TP_EMIT();
>   }
>=20
>   static const struct bpf_func_proto bpf_trace_printk_proto =3D {
> --=20
> 1.9.3

--kzRosno1BoFkwaBD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEd80NauSabkiESfLYbAtpk944dnoFAlmRlrgACgkQbAtpk944
dnq2Fw//T7kLMPdU3JS8q10RNu2mv4ZCmyBB5bOISrzItaW/Nptx9exsCAyzhMsf
OFMU3h0K2fWvqao8xrpUq7GGsIqybkBlCf30skOiygSyGLxXYEE/tyURBXaQPXHN
XY8IT2CWBsgMqKgGWAVwiToRYFhJrdqeNPYwQ3r1GDnV2JSpX1taC2t1z1AVhNW4
El5iOgGO1Lih8zTG0umn6exRBFfXsnUgczBHfTi9jKvT2EKiCqne8hW1vyJ1r2Ao
tKQju7nlaXzGwkrXMf+2votwJjXcJNi+SbqbGTJEA507a7y+LnlWiYw0Y71RNzkZ
ItHv3OA+jQ/w8ehuB+O1Tq305OdmrThUQbkK/eZWdQb9jHRJCbOH3FHkD+k1Y3E7
X/dz3G8zxBf5yVRtAtE/e3vQqgyOQ/rSLg2u5jecbKmWwFYxGuTtXrK3hvSFL8kD
Wf5bbANXnpQNIre0T34QKeSCPyUDVpOyA9fTmBpIOBTgTJC5FcKtp8M6RP8kQ21E
ouTJ+FTFBHKcT5JDB/21Zyvxw63Wn+HcoaY6s2kRuEvySGvJOqGWSPSbJmJUGmnj
oh225ZzPDg08OKSok0jhW6gvNUzhQ5qC9deQ7RvBm5uOeX+Wm89omWWudU/WDCnV
Iuk7eUDtsNnwH4PqXgei9MNt1aNZOmonAgjHk3avefxXoNnLPM4=
=vPZP
-----END PGP SIGNATURE-----

--kzRosno1BoFkwaBD--
