From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v8 0/4] net: Add Keystone NetCP ethernet driver support
Date: Wed, 28 Jan 2015 22:03:09 +0100
Message-ID: <20343006.1NmdQEM9nn@wuerfel>
References: <1421367007-19744-1-git-send-email-m-karicheri2@ti.com> <54C92878.3030207@ti.com> <54C94A0D.9050505@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54C94A0D.9050505@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 28 January 2015 15:43:57 Murali Karicheri wrote:
> > this. Hope I am on the right track.
>=20
> Reproduced this. Following errors seen when building the modules.
>=20
>    LD [M]  drivers/net/ethernet/ti/keystone_netcp.o
> drivers/net/ethernet/ti/netcp_ethss.o: In function `init_module':
> netcp_ethss.c:(.init.text+0x0): multiple definition of `init_module'
> drivers/net/ethernet/ti/netcp_core.o:netcp_core.c:(.init.text+0x0):=20
> first defined here
> drivers/net/ethernet/ti/netcp_ethss.o: In function `cleanup_module':
> netcp_ethss.c:(.exit.text+0x0): multiple definition of `cleanup_modul=
e'
> drivers/net/ethernet/ti/netcp_core.o:netcp_core.c:(.exit.text+0x0):=20
> first defined here
> make[4]: *** [drivers/net/ethernet/ti/keystone_netcp.o] Error 1
>
> BTW, I had to disable cpsw_ale.c to get to build keystone NetCP. I am=
=20
> assuming someone from TI is addressing this.
>=20
> drivers/net/ethernet/ti/cpsw_ale.c: In function =E2=80=98cpsw_ale_sta=
rt=E2=80=99:
> drivers/net/ethernet/ti/cpsw_ale.c:759:2: error: =E2=80=98KBUILD_MODN=
AME=E2=80=99=20
> undeclared (first use in this function)
> drivers/net/ethernet/ti/cpsw_ale.c:759:2: note: each undeclared=20
> identifier is reported only once for each function it appears in

I think both problems are nontrivial to fix. The first one is obviously
that there are multiple init_module functions in one module. You have
to either split the driver into multiple loadable modules with at most
one init_module/cleanup_module pair each, or call one of the functions
from the other one in the right order.

The second problem is where I got stuck myself: cpsw_ale.c (also cpts.c=
)
is getting linked into both modules, which is not allowed: It is
impossible for the kernel to compile these if one driver is a module
and the other one is not, and any use of KBUILD_MODNAME fails because
it is unclear what the modname is if the file is compiled once to
be linked into two drivers.

	Arnd
