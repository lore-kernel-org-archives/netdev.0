From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next 0/4] ipv6: fix the reassembly expire code in
 nf_conntrack
Date: Tue, 18 Sep 2012 10:34:16 +0800
Message-ID: <1347935656.14402.12.camel@cr0>
References: <1347517541-10653-1-git-send-email-amwang@redhat.com>
	 <20120917.125419.1478223385564528540.davem@davemloft.net>
	 <20120917.125925.930848734158369358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120917.125925.930848734158369358.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-09-17 at 12:59 -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 17 Sep 2012 12:54:19 -0400 (EDT)
>=20
> > From: Cong Wang <amwang@redhat.com>
> > Date: Thu, 13 Sep 2012 14:25:37 +0800
> >=20
> >> ipv6: add a new namespace for nf_conntrack_reasm
> >> ipv6: unify conntrack reassembly expire code with
> >> ipv6: make ip6_frag_nqueues() and ip6_frag_mem() static
> >> ipv6: unify fragment thresh handling code
> >>=20
> >> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> >> Cc: "David S. Miller" <davem@davemloft.net>
> >> Signed-off-by: Cong Wang <amwang@redhat.com>
> >=20
> > These changes look great, all applied to net-next, thanks.
>=20
> I have to ask if you actually build tested this change at all:
>=20
> net/ipv6/proc.c: In function =E2=80=98sockstat6_seq_show=E2=80=99:
> net/ipv6/proc.c:46:10: error: implicit declaration of function =E2=80=
=98ip6_frag_nqueues=E2=80=99 [-Werror=3Dimplicit-function-declaration]
> net/ipv6/proc.c:46:10: error: implicit declaration of function =E2=80=
=98ip6_frag_mem=E2=80=99 [-Werror=3Dimplicit-function-declaration]
>=20
> It is absolutely impossible for you to have enabled ipv6 and not gott=
en
> that build error.

Weird, I don't see any build error:

% grep CONFIG_IPV6 .config
CONFIG_IPV6=3Dy
CONFIG_IPV6_PRIVACY=3Dy
CONFIG_IPV6_ROUTER_PREF=3Dy
CONFIG_IPV6_ROUTE_INFO=3Dy
CONFIG_IPV6_OPTIMISTIC_DAD=3Dy
CONFIG_IPV6_MIP6=3Dy
CONFIG_IPV6_SIT=3Dy
CONFIG_IPV6_SIT_6RD=3Dy
CONFIG_IPV6_NDISC_NODETYPE=3Dy
CONFIG_IPV6_TUNNEL=3Dy
CONFIG_IPV6_GRE=3Dy
CONFIG_IPV6_MULTIPLE_TABLES=3Dy
CONFIG_IPV6_SUBTREES=3Dy
CONFIG_IPV6_MROUTE=3Dy
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=3Dy
CONFIG_IPV6_PIMSM_V2=3Dy
% rm net/ipv6/proc.o=20
% make net/ipv6/proc.o
make[1]: Nothing to be done for `all'.
make[1]: Nothing to be done for `relocs'.
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  CC      kernel/bounds.s
  GEN     include/generated/bounds.h
  CC      arch/x86/kernel/asm-offsets.s
  GEN     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CC      scripts/mod/empty.o
  MKELF   scripts/mod/elfconfig.h
  HOSTCC  scripts/mod/file2alias.o
  HOSTCC  scripts/mod/modpost.o
  HOSTCC  scripts/mod/sumversion.o
  HOSTLD  scripts/mod/modpost
  CC      net/ipv6/proc.o

Rebuild the whole tree:
=2E..
  CC      net/ipv6/ip6mr.o
  CC      net/ipv6/xfrm6_policy.o
  CC      net/ipv6/xfrm6_state.o
  CC      net/ipv6/xfrm6_input.o
  CC      net/ipv6/xfrm6_output.o
  CC      net/ipv6/netfilter.o
  CC      net/ipv6/fib6_rules.o
  CC      net/ipv6/proc.o
  CC      net/ipv6/syncookies.o
  LD      net/ipv6/ipv6.o
  CC      net/ipv6/ah6.o
  CC      net/ipv6/esp6.o
  CC      net/ipv6/ipcomp6.o
  CC      net/ipv6/xfrm6_tunnel.o
  CC      net/ipv6/tunnel6.o
=2E..
% gcc --version
gcc (GCC) 4.6.3 20120306 (Red Hat 4.6.3-2)
Copyright (C) 2011 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is
NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.


>=20
> The only logical explanation is that you didn't commit the changes
> to net/ipv6/proc.c in your tree when you put together these patches.

There is no change for net/ipv6/proc.c, ip6_frag_nqueues() and
ip6_frag_mem() are now defined as static inline in include/net/ipv6.h
which is already #included by net/ipv6/proc.c. This is why I still don'=
t
see how that build error could happen.

Actually, the #ifdef CONFIG_IPV6 is not needed at all, as
sockstat6_seq_show() is their only caller, which is compiled only when
CONFIG_IPV6 is enabled.

Thanks.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
