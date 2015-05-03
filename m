From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: fix dependency issues between IPv6
 defragmentation and ip6tables
Date: Sun, 3 May 2015 22:09:42 +0200
Message-ID: <20150503200942.GF22481@breakpoint.cc>
References: <1430646618-7625-1-git-send-email-sdu.liu@huawei.com>
 <20150503110715.GE22481@breakpoint.cc>
 <55462E32.2060806@126.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Westphal <fw@strlen.de>, Liu Hua <sdu.liu@huawei.com>,
	davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: liusdu <liusdu@126.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55462E32.2060806@126.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

liusdu <liusdu@126.com> wrote:
> On 2015=E5=B9=B405=E6=9C=8803=E6=97=A5 19:07, Florian Westphal wrote:
> >Liu Hua <sdu.liu@huawei.com> wrote:
> >>commit f6318e558806c925029dc101f14874be9f9fa78f fix some related is=
sue
> >>when ip6tables is enabled. But when IP6_NF_IPTABLES is disabled and
> >>NETFILTER_XT_TARGET_TPROXY is enabled. We will meet build failure w=
ith
> >>"net/built-in.o: In function `tproxy_tg_init':
> >>net/netfilter/xt_TPROXY.c:588: undefined reference to `nf_defrag_ip=
v6_enable'
> >>"
> >>So this patch change the Kconfig as ipv4 does.
> >>--- a/net/netfilter/Kconfig
> >>+++ b/net/netfilter/Kconfig
> >>@@ -865,7 +865,7 @@ config NETFILTER_XT_TARGET_TPROXY
> >>  	depends on (IPV6 || IPV6=3Dn)
> >>  	depends on IP_NF_MANGLE
> >>  	select NF_DEFRAG_IPV4
> >>-	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
> >>+	select NF_DEFRAG_IPV6
> >IP6_NF_IPTABLES
> >If IP6_NF_IPTABLES is not set, why would we have to pick
> >up IPV6 defragmentation?
> >
> >Without ip6tables, TPROXY cannot be used for ipv6; in fact;
> >xt_TPROXY should be built without ipv6 support in this case.
> >
> >My guess is that you have TPROXY=3Dy but DEFRAG_IPV6=3Dm, but that
> >might warrant a better fix (xt_socket seems to have same issue).
> Hi Florian,
>=20
> Yes, It was exactly what I did.  Actually there is a macro to
> determine whether we compile nf_defrag_ipv6_enable or not,
> called XT_TPROXY_HAVE_IPV6, which will be set to 1 while
> IP6_NF_IPTABLES=3Dy or m.  With the patch below  we can
> make the compiling pass. But I am not sure it is good enough
> or not.
> diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
> index cca96ce..abbda64 100644
> --- a/net/netfilter/xt_TPROXY.c
> +++ b/net/netfilter/xt_TPROXY.c
> @@ -24,7 +24,7 @@
>=20
>  #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
>=20
> -#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
> +#if IS_BUILTIN(CONFIG_IP6_NF_IPTABLES)

This means you need to set IP6_NF_IPTABLES=3Dy, else TPROXY doesn't wor=
k
with ipv6.  I suggest to try and get Kconfig to force the needed
dependency (DEFRAG=3Dy if TPROXY=3Dy && DEFRAG=3Dm if TPROXY=3Dm).

Maybe this is enough (untested)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -863,6 +863,7 @@ config NETFILTER_XT_TARGET_TPROXY
        depends on NETFILTER_XTABLES
        depends on NETFILTER_ADVANCED
        depends on (IPV6 || IPV6=3Dn)
+       depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=3Dn)
        depends on IP_NF_MANGLE
        select NF_DEFRAG_IPV4
        select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
@@ -1356,6 +1357,7 @@ config NETFILTER_XT_MATCH_SOCKET
        depends on NETFILTER_ADVANCED
        depends on !NF_CONNTRACK || NF_CONNTRACK
        depends on (IPV6 || IPV6=3Dn)
+       depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=3Dn)
        select NF_DEFRAG_IPV4
        select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
        help

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
