From: Andrew Morton <akpm@osdl.org>
Subject: Re: Oops at "NET: Registering protocol family 23" at boot with
 2.6.0t9-bk
Date: Sat, 1 Nov 2003 16:03:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031101160350.2f1fe0af.akpm@osdl.org>
References: <1067705386.666.1.camel@chevrolet.hybel>
	<20031101133601.7cf12497.akpm@osdl.org>
	<1067723628.643.0.camel@chevrolet.hybel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stian Jordet <liste@jordet.nu>
In-Reply-To: <1067723628.643.0.camel@chevrolet.hybel>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stian Jordet <liste@jordet.nu> wrote:
>
> l=F8r, 01.11.2003 kl. 22.36 skrev Andrew Morton:
>  > Stian Jordet <liste@jordet.nu> wrote:
>  > >
>  > > Hello,
>  > > kernel 2.6.0-test9 works perfect here, but with the latest cset I =
get
>  > > the attached oops at boottime. Hope this helps someone.
>  > >=20
>  >=20
>  > Please send your .config.
>=20
>  Here you are :) Thanks for looking into this :)

OK, it goes bang because ptype_all has not been initialised yet.

This is because net_dev_init() is fs_initcall, and irda_init() is
subsys_initcall - irda_init() runs before net_dev_init().

Dave, I'm not sure what's the best thing to do here - I was afraid that t=
he
initcall level shuffling was a bit premature.

IRDA doesn't look flexible (hugs to JT for commenting this nicely):

/*
 * The IrDA stack must be initialised *before* drivers get initialised,
 * and *before* higher protocols (IrLAN/IrCOMM/IrNET) get initialised,
 * otherwise bad things will happen (hashbins will be NULL for example).
 * Those modules are at module_init()/device_initcall() level.
 *
 * On the other hand, it needs to be initialised *after* the basic
 * networking, the /proc/net filesystem and sysctl module. Those are
 * currently initialised in .../init/main.c (before initcalls).
 * Also, IrDA drivers needs to be initialised *after* the random number
 * generator (main stack and higher layer init don't need it anymore).
 *
 * Jean II
 */

So I dunno.   Maybe we need to just revert the PNP patch, think
about it some more?


diff -puN drivers/pnp/isapnp/core.c~pnp-initcall-revert drivers/pnp/isapn=
p/core.c
--- 25/drivers/pnp/isapnp/core.c~pnp-initcall-revert	2003-11-01 16:02:36.=
000000000 -0800
+++ 25-akpm/drivers/pnp/isapnp/core.c	2003-11-01 16:02:54.000000000 -0800
@@ -1160,7 +1160,7 @@ int __init isapnp_init(void)
 	return 0;
 }
=20
-fs_initcall(isapnp_init);
+device_initcall(isapnp_init);
=20
 /* format is: noisapnp */
=20
diff -puN net/core/dev.c~pnp-initcall-revert net/core/dev.c
--- 25/net/core/dev.c~pnp-initcall-revert	2003-11-01 16:02:36.000000000 -=
0800
+++ 25-akpm/net/core/dev.c	2003-11-01 16:02:54.000000000 -0800
@@ -3067,7 +3067,7 @@ out:
 	return rc;
 }
=20
-fs_initcall(net_dev_init);
+subsys_initcall(net_dev_init);
=20
 EXPORT_SYMBOL(__dev_get);
 EXPORT_SYMBOL(__dev_get_by_flags);

_
