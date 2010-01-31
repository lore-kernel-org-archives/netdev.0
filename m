From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: 2.6.32: padlock_sha1 and hmac broken?
Date: Sun, 31 Jan 2010 03:11:22 +0100
Message-ID: <201001310311.23116.wolfgang.walter@stwm.de>
References: <201001300044.15769.wolfgang.walter@stwm.de> <201001301734.46003.wolfgang.walter@stwm.de> <20100130221731.GA18982@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752319Ab0AaCL1@vger.kernel.org>
In-Reply-To: <20100130221731.GA18982@gondor.apana.org.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Samstag, 30. Januar 2010 schrieb Herbert Xu:
> On Sat, Jan 30, 2010 at 05:34:45PM +0100, Wolfgang Walter wrote:
> > > Please also try "modprobe tcrypt mode=3D101".
> >
> > [  474.947508] alg: hash: Failed to load transform for hmac(sha1): =
-2
> > [  474.952660] alg: hash: Failed to load transform for hmac(sha1): =
-2
> > [  474.952737] tcrypt: one or more tests failed!
>
> Oops, it looks like this has been broken ever since we added
> prehashing to hmac.
>
> Please try this patch and let me know whether it makes it work
> again.
>
> diff --git a/drivers/crypto/padlock-sha.c b/drivers/crypto/padlock-sh=
a.c
> index 0af8057..a1180ca 100644
> --- a/drivers/crypto/padlock-sha.c
> +++ b/drivers/crypto/padlock-sha.c
> @@ -57,6 +57,20 @@ static int padlock_sha_update(struct shash_desc *d=
esc,
>  	return crypto_shash_update(&dctx->fallback, data, length);
>  }
>
> +static int padlock_sha_export(struct shash_desc *desc, void *out)
> +{
> +	struct padlock_sha_desc *dctx =3D shash_desc_ctx(desc);
> +
> +	return crypto_shash_export(&dctx->fallback, out);
> +}
> +
> +static int padlock_sha_import(struct shash_desc *desc, const void *i=
n)
> +{
> +	struct padlock_sha_desc *dctx =3D shash_desc_ctx(desc);
> +
> +	return crypto_shash_import(&dctx->fallback, in);
> +}
> +
>  static inline void padlock_output_block(uint32_t *src,
>  		 	uint32_t *dst, size_t count)
>  {
> @@ -235,7 +249,10 @@ static struct shash_alg sha1_alg =3D {
>  	.update 	=3D	padlock_sha_update,
>  	.finup  	=3D	padlock_sha1_finup,
>  	.final  	=3D	padlock_sha1_final,
> +	.export		=3D	padlock_sha_export,
> +	.import		=3D	padlock_sha_import,
>  	.descsize	=3D	sizeof(struct padlock_sha_desc),
> +	.statesize	=3D	sizeof(struct sha1_state),
>  	.base		=3D	{
>  		.cra_name		=3D	"sha1",
>  		.cra_driver_name	=3D	"sha1-padlock",
> @@ -256,7 +273,10 @@ static struct shash_alg sha256_alg =3D {
>  	.update 	=3D	padlock_sha_update,
>  	.finup  	=3D	padlock_sha256_finup,
>  	.final  	=3D	padlock_sha256_final,
> +	.export		=3D	padlock_sha_export,
> +	.import		=3D	padlock_sha_import,
>  	.descsize	=3D	sizeof(struct padlock_sha_desc),
> +	.statesize	=3D	sizeof(struct sha256_state),
>  	.base		=3D	{
>  		.cra_name		=3D	"sha256",
>  		.cra_driver_name	=3D	"sha256-padlock",
>
> Thanks,

Not sure.

When I do

modprobe tcrypt mode=3D101

I get a kernel oops:

[  113.074210] BUG: unable to handle kernel NULL pointer dereference at=
=20
00000034                                               =20
[  113.074375] IP: [<dfc92042>] padlock_sha_import+0xa/0x15 [padlock_sh=
a]                                                      =20
[  113.074493] *pde =3D 00000000                                       =
                                                          =20
[  113.074590] Oops: 0000 [#1] PREEMPT                                 =
                                                        =20
[  113.074727] last sysfs file: /sys/module/vt/parameters/default_utf8 =
                                                        =20
[  113.074792] Modules linked in: tcrypt(+) padlock_sha nf_conntrack_tf=
tp=20
nf_conntrack_sip nf_conntrack_sane nf_conntrack_ftp xt_connlimit xt_con=
nbytes=20
xt_CONNMARK xt_connmark xt_helper xt_NOTRACK xt_conntrack nf_conntrack_=
ipv4=20
nf_conntrack nf_defrag_ipv4=20
[  113.075595]                                                         =
                                                        =20
[  113.075653] Pid: 1701, comm: cryptomgr_test Not tainted (2.6.32.7 #1=
)                                                       =20
[  113.075722] EIP: 0060:[<dfc92042>] EFLAGS: 00010246 CPU: 0          =
                                                        =20
[  113.075789] EIP is at padlock_sha_import+0xa/0x15 [padlock_sha]     =
                                                        =20
[  113.075855] EAX: 00000000 EBX: d74619f8 ECX: dfc925d4 EDX: cd280238 =
                                                        =20
[  113.075923] ESI: dc0d2a2c EDI: d74619f0 EBP: cdb77d80 ESP: cdb77d7c =
                                                        =20
[  113.075990]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068           =
                                                        =20
[  113.076057] Process cryptomgr_test (pid: 1701, ti=3Dcdb76000 task=3D=
d97d3b80=20
task.ti=3Dcdb76000)                                  =20
[  113.076133] Stack:                                                  =
                                                        =20
[  113.076187]  cd280238 cdb77d94 c01ec148 00000000 d74619c0 d74619e8 c=
db77d9c=20
c01ec165                                        =20
[  113.076671] <0> cdb77db4 c01e9581 00000008 d74619c0 00000000 0000000=
0=20
cdb77dbc c01e95b6                                     =20
[  113.076671] <0> cdb77dd4 c01e89c5 c01e959c c056fdd8 00000000 cd48900=
8=20
cdb77ddc c01e89dd                                     =20
[  113.076671] Call Trace:                                             =
                                                        =20
[  113.076671]  [<c01ec148>] ? hmac_import+0x3b/0x40                   =
                                                        =20
[  113.076671]  [<c01ec165>] ? hmac_init+0x18/0x1a                     =
                                                        =20
[  113.076671]  [<c01e9581>] ? shash_ahash_digest+0x8c/0xa7            =
                                                        =20
[  113.076671]  [<c01e95b6>] ? shash_async_digest+0x1a/0x1c            =
                                                        =20
[  113.076671]  [<c01e89c5>] ? crypto_ahash_op+0x8f/0x99               =
                                                        =20
[  113.076671]  [<c01e959c>] ? shash_async_digest+0x0/0x1c             =
                                                        =20
[  113.076671]  [<c01e89dd>] ? crypto_ahash_digest+0xe/0x10            =
                                                        =20
[  113.076671]  [<c01ea4cb>] ? test_hash+0x17c/0x4fd                   =
                                                        =20
[  113.076671]  [<c01e4643>] ? crypto_larval_lookup+0x30/0xfe          =
                                                        =20
[  113.076671]  [<c01e4278>] ? crypto_alloc_tfm+0x3d/0x71
[  113.076671]  [<c01e9114>] ? crypto_alloc_shash+0x10/0x12
[  113.076671]  [<dfc92429>] ? padlock_cra_init+0x1c/0x4b [padlock_sha]
[  113.076671]  [<c01e420c>] ? crypto_create_tfm+0x59/0x88
[  113.076671]  [<c01e4eb4>] ? crypto_spawn_tfm2+0x20/0x37
[  113.076671]  [<c01ec551>] ? hmac_init_tfm+0x1b/0x46
[  113.076671]  [<c01e420c>] ? crypto_create_tfm+0x59/0x88
[  113.076671]  [<c01ea88b>] ? alg_test_hash+0x3f/0x55
[  113.076671]  [<c01ec06b>] ? alg_test+0x168/0x1e9
[  113.076671]  [<c011c37e>] ? pick_next_task_fair+0x8b/0xb5
[  113.076671]  [<c0440b4e>] ? schedule+0x1db/0x382
[  113.076671]  [<c01e9a0e>] ? cryptomgr_test+0x0/0x3e
[  113.076671]  [<c01e9a30>] ? cryptomgr_test+0x22/0x3e
[  113.076671]  [<c01308ef>] ? kthread+0x60/0x65
[  113.076671]  [<c013088f>] ? kthread+0x0/0x65
[  113.076671]  [<c0103147>] ? kernel_thread_helper+0x7/0x10
[  113.076671] Code: 41 04 89 c8 8b 52 34 ff 52 d4 5d c3 55 89 e5 53 8d=
 58 08=20
8b 40 08 8b 48 34 89 d8 ff 51 e8 5b 5d c3 55 89 e5 53 8d 58 08 8b 40 08=
 <8b>=20
48 34 89 d8 ff 51 ec 5b 5d c3 55 89 e5 53 8d 58 08 8b 40 04
[  113.076671] EIP: [<dfc92042>] padlock_sha_import+0xa/0x15 [padlock_s=
ha]=20
SS:ESP 0068:cdb77d7c
[  113.076671] CR2: 0000000000000034
[  113.092662] ---[ end trace d25b6d64215b111e ]---
[  123.233370] alg: hash: Failed to load transform for hmac(sha1): -4
[  123.233472] alg: hash: Failed to load transform for hmac(sha1): -4
[  123.233538] tcrypt: one or more tests failed!



Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
