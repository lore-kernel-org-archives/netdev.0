From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: santize headers for iproute2
Date: Tue, 25 Dec 2007 17:13:10 -0800
Message-ID: <20071225171310.1c43a0e2@deepthought>
References: <20071221094336.63600b8c@deepthought>
	<20071224.220527.254578945.davem@davemloft.net>
	<20071225124323.70e0c772@deepthought>
	<20071225.150238.193724414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vgusev@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35162 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751240AbXLZBOU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Dec 2007 20:14:20 -0500
In-Reply-To: <20071225.150238.193724414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Dec 2007 15:02:38 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Tue, 25 Dec 2007 12:43:23 -0800
>=20
> > The problem is that iproute ss.c needs linux/tcp.h to get the
> > tcp_info structure definition but linux/tcp.h has incompatible
> > definitions with netinet/tcp.h.  I propose that the enum be moved
> > from net/tcp_states.h to linux/tcp.h.
>=20
> This would be fragile, at best.
>=20
> We need to solve this in a way such that both linux/tcp.h and
> netinet/tcp.h can both be included at the same time by userland.
>=20
> If we export linux/tcp.h to userspace, we have to make it play nice
> with the existing header file namespace.

Well changing netinet/tcp.h is just not a realistic proposition, it tak=
es
too long to filter from glibc through distro's to be worth it. That mea=
ns
fixing linux/tcp.h to not conflict.  How do you propose to resolve?

In file included from ss.c:37:
=2E./include/linux/tcp.h:24: error: redefinition of =E2=80=98struct tcp=
hdr=E2=80=99
=2E./include/linux/tcp.h:106: error: nested redefinition of =E2=80=98en=
um tcp_ca_state=E2=80=99
=2E./include/linux/tcp.h:106: error: redeclaration of =E2=80=98enum tcp=
_ca_state=E2=80=99
=2E./include/linux/tcp.h:107: error: redeclaration of enumerator =E2=80=
=98TCP_CA_Open=E2=80=99
/usr/include/netinet/tcp.h:179: error: previous definition of =E2=80=98=
TCP_CA_Open=E2=80=99 was her

maybe:

--- a/include/linux/tcp.h	2007-12-25 17:09:26.000000000 -0800
+++ b/include/linux/tcp.h	2007-12-25 17:12:12.000000000 -0800
@@ -21,6 +21,9 @@
 #include <asm/byteorder.h>
 #include <linux/socket.h>
=20
+#ifndef __KERNEL__
+#include <netinet/tcp.h>
+#else
 struct tcphdr {
 	__be16	source;
 	__be16	dest;
@@ -55,6 +58,7 @@ struct tcphdr {
 	__sum16	check;
 	__be16	urg_ptr;
 };
+#endif
=20
 /*
  *	The union cast uses a gcc extension to avoid aliasing problems
@@ -102,6 +106,7 @@ enum {=20
 #define TCPI_OPT_WSCALE		4
 #define TCPI_OPT_ECN		8
=20
+#ifdef __KERNEL__
 enum tcp_ca_state
 {
 	TCP_CA_Open =3D 0,
@@ -115,6 +120,7 @@ enum tcp_ca_state
 	TCP_CA_Loss =3D 4
 #define TCPF_CA_Loss	(1<<TCP_CA_Loss)
 };
+#endif


--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>
