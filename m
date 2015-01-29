From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [TEMPORARY] net: netfilter: IPV6 XT sockets need CONFIG_NF_DEFRAG_IPV6
Date: Thu, 29 Jan 2015 22:57:39 +0100
Message-ID: <2517612.ARZYBYQ2lu@wuerfel>
References: <1513018.IdvuSAziQY@wuerfel> <1699413.oLnudLOjvJ@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	KOVACS Krisztian <hidden@sch.bme.hu>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:65332 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbbA2V6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 16:58:31 -0500
In-Reply-To: <1699413.oLnudLOjvJ@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 January 2015 17:50:30 Arnd Bergmann wrote:
> On Thursday 29 January 2015 17:18:59 Arnd Bergmann wrote:
> > If IP6_NF_IPTABLES=m, NF_DEFRAG_IPV6 gets selected as a module as well
> > from NETFILTER_XT_MATCH_SOCKET, so the latter cannot be built-in, or
> > we get:
> 
> I messed up the subject line, the [TEMPORARY] was not meant to be
> in there, and I also saw that the subject was mixed up too.
> 
> I will send it again with the proper subject.

After trying to fix up the commit message, I'm no longer sure the
patch was right either. The patch below is what I have now, and it
fixes the broken randconfig, but I'd give it a few hundred more
builds and some thought before I'm actually convinced that it's complete.

Sorry about the messup.

	Arnd

8<-----
>From 6da20879baa5b562c023f1a1b81a0a48da5ab0e4 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 6 Jun 2014 10:07:46 +0200
Subject: [PATCH] [SUBMITTED] net: netfilter: fix IPV6 XT sockets dependency

If IP6_NF_IPTABLES=m, and one of NETFILTER_XT_MATCH_SOCKET or
NETFILTER_XT_TARGET_TPROXY is built-in, we get a link error:

net/built-in.o: In function `socket_mt_init':
:(.init.text+0x32a0): undefined reference to `nf_defrag_ipv6_enable'
net/built-in.o: In function `tproxy_tg_init':
xt_TPROXY.c:582: undefined reference to `nf_defrag_ipv6_enable'

The reason for this is that NF_DEFRAG_IPV6 also gets selected
by NF_CONNTRACK_IPV6, and that forces it to be a module.

To solve this, we add another set of dependencies that enforce that
either IP6_NF_IPTABLES is disabled, or the two netfilter drivers
are also loadable modules.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index b02660fa9eb0..fc4f4a207785 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -875,6 +875,7 @@ config NETFILTER_XT_TARGET_TPROXY
 	depends on NETFILTER_ADVANCED
 	depends on (IPV6 || IPV6=n)
 	depends on IP_NF_MANGLE
+	depends on !NF_CONNTRACK_IPV6 || NF_CONNTRACK_IPV6
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
 	help
@@ -1366,6 +1367,7 @@ config NETFILTER_XT_MATCH_SOCKET
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
 	depends on !NF_CONNTRACK || NF_CONNTRACK
+	depends on !NF_CONNTRACK_IPV6 || NF_CONNTRACK_IPV6
 	depends on (IPV6 || IPV6=n)
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
