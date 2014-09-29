From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 32/34] netfilter: bridge: move br_netfilter out of the
 core
Date: Tue, 30 Sep 2014 01:17:48 +0200
Message-ID: <20140929231748.GA11709@breakpoint.cc>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
 <1411994363-8451-33-git-send-email-pablo@netfilter.org>
 <1412028266.30721.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412028266.30721.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-09-29 at 14:39 +0200, Pablo Neira Ayuso wrote:
> > Jesper reported that br_netfilter always registers the hooks since
> > this is part of the bridge core. This harms performance for people =
that
> > don't need this.
> >=20
> > This patch modularizes br_netfilter so it can be rmmod'ed, thus,
> > the hooks can be unregistered. I think the bridge netfilter should =
have
> > been a separated module since the beginning, Patrick agreed on that=
=2E
> >=20
> > Note that this is breaking compatibility for users that expect that
> > bridge netfilter is going to be available after explicitly 'modprob=
e
> > bridge' or via automatic load through brctl.
> >=20
> > However, the damage can be easily undone by modprobing br_netfilter=
=2E
> > The bridge core also spots a message to provide a clue to people th=
at
> > didn't notice that this has been deprecated.
> >=20
> > On top of that, the plan is that nftables will not rely on this sof=
tware
> > layer, but integrate the connection tracking into the bridge layer =
to
> > enable stateful filtering and NAT, which is was bridge netfilter us=
ers
> > seem to require.
> >=20
> > This patch still keeps the fake_dst_ops in the bridge core, since t=
his
> > is required by when the bridge port is initialized. So we can safel=
y
> > modprobe/rmmod br_netfilter anytime.
> >=20
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> > Acked-by: Florian Westphal <fw@strlen.de>
> > ---
>=20
> Hmm... What am I missing here ?
> # CONFIG_BRIDGE_NETFILTER is not set

Nothing.  Our fault.  br_nf_core.o should not be built in this case.

> $ make net/bridge/br_nf_core.o
[..]
>   CC [M]  net/bridge/br_nf_core.o
> net/bridge/br_nf_core.c:77:1: error: expected identifier or =E2=80=98=
(=E2=80=99 before =E2=80=98{=E2=80=99 token
> net/bridge/br_nf_core.c:88:12: error: redefinition of =E2=80=98br_nf_=
core_init=E2=80=99

This patch seems to fix it for me.  Pablo, can you double-check?

Thanks!

Subject: [PATCH nf-next] netfilter: bridge: build br_nf_core only if re=
quired

Eric reports build failure with
CONFIG_BRIDGE_NETFILTER=3Dn

We insist to build br_nf_core.o unconditionally, but we must only do so
if br_netfilter was enabled, else it fails to build due to
functions being defined to empty stubs (and some structure members
being defined out).

Also, BRIDGE_NETFILTER=3Dy|m makes no sense when BRIDGE=3Dn.

=46ixes: 34666d467 (netfilter: bridge: move br_netfilter out of the cor=
e)
Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/Kconfig         | 2 +-
 net/bridge/Makefile | 5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index dc5d700..d6b138e 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -177,7 +177,7 @@ config NETFILTER_ADVANCED
=20
 config BRIDGE_NETFILTER
 	tristate "Bridged IP/ARP packets filtering"
-	depends on (BRIDGE || BRIDGE=3Dn)
+	depends on BRIDGE
 	depends on NETFILTER && INET
 	depends on NETFILTER_ADVANCED
 	default m
diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index 5e3eac5..fd7ee03 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -6,11 +6,12 @@ obj-$(CONFIG_BRIDGE) +=3D bridge.o
=20
 bridge-y	:=3D br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.=
o \
 			br_ioctl.o br_stp.o br_stp_bpdu.o \
-			br_stp_if.o br_stp_timer.o br_netlink.o \
-			br_nf_core.o
+			br_stp_if.o br_stp_timer.o br_netlink.o
=20
 bridge-$(CONFIG_SYSFS) +=3D br_sysfs_if.o br_sysfs_br.o
=20
+bridge-$(subst m,y,$(CONFIG_BRIDGE_NETFILTER)) +=3D br_nf_core.o
+
 obj-$(CONFIG_BRIDGE_NETFILTER) +=3D br_netfilter.o
=20
 bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) +=3D br_multicast.o br_mdb.o
--=20
1.8.1.5
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
