From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 29 Nov 2007 10:55:01 +0100
Message-ID: <200711291055.02056.arnd@arndb.de>
References: <20071122343.446909000@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.174]:52149 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756124AbXK2JzZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 04:55:25 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 22 November 2007, Andi Kleen wrote:
> =A0#define EXPORT_SYMBOL(sym)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0\
> -=A0=A0=A0=A0=A0=A0=A0__EXPORT_SYMBOL(sym, "")
> +=A0=A0=A0=A0=A0=A0=A0__EXPORT_SYMBOL(sym, "",,, NULL)
> =A0
> =A0#define EXPORT_SYMBOL_GPL(sym)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0\
> -=A0=A0=A0=A0=A0=A0=A0__EXPORT_SYMBOL(sym, "_gpl")
> +=A0=A0=A0=A0=A0=A0=A0__EXPORT_SYMBOL(sym, "_gpl",,, NULL)
> =A0
> =A0#define EXPORT_SYMBOL_GPL_FUTURE(sym)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0\
> -=A0=A0=A0=A0=A0=A0=A0__EXPORT_SYMBOL(sym, "_gpl_future")
> +=A0=A0=A0=A0=A0=A0=A0__EXPORT_SYMBOL(sym, "_gpl_future",,, NULL)
> =A0
> +/* Export symbol into namespace ns
> + * No _GPL variants because namespaces imply GPL only
> + */
> +#define EXPORT_SYMBOL_NS(ns, sym)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0\
> +=A0=A0=A0=A0=A0=A0=A0__EXPORT_SYMBOL(sym, "_gpl",__##ns, NS_SEPARATO=
R #ns, #ns)
> =A0

I think it would be good if you could specify a default namespace
per module, that could reduce the amount of necessary changes significa=
ntly.

=46or example, you can do

#define EXPORT_SYMBOL_GLOBAL(sym) __EXPORT_SYMBOL(sym, "_gpl",,, NULL)
#ifdef MODULE_NAMESPACE
#define EXPORT_SYMBOL_GPL(sym) EXPORT_SYMBOL_GLOBAL(sym)
#else
#define EXPORT_SYMBOL_GPL(sym) EXPORT_SYMBOL_NS(sym, MODULE_NAMESPACE)
#endif

If we go that way, it may be useful to extend the namespace mechanism t=
o
non-GPL symbols as well, like

#define EXPORT_SYMBOL(sym) __EXPORT_SYMBOL(sym, "",__## MODULE_NAMESPAC=
E, NS_SEPARATOR #MODULE_NAMESPACE, #MODULE_NAMESPACE)

Unfortunately, doing this automatic namespace selection requires to set
the namespace before #include <linux/module.h>. One way to work around =
this
could be to use Makefile magic so you can list a Makefile as

obj-$(CONFIG_COMBINED) +=3D combined.o
combined-$(CONFIG_SUBOPTION) +=3D combined_main.o combined_other.o
obj-$(CONFIG_SINGLE) +=3D single.o
obj-$(CONFIG_OTHER) +=3D other.o
obj-$(CONFIG_API) +=3D api.o

NAMESPACE =3D subsys                       # default, used for other.o
NAMESPACE_single.o =3D single              # used only for single.o
NAMESPACE_combined.o =3D combined          # all parts of combined.o
NAMESPACE_combined_other.o =3D special     #    except this one
NAMESPACE_api.o =3D                        # api.o is put into the glob=
al ns

The Makefile logic here would basically just follow the rules we have f=
or
CFLAGS etc, and then pass -DMODULE_NAMESPACE=3D$(NAMESPACE_$(obj)) to g=
cc.

	Arnd <><
