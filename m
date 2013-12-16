From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 0/6] slight optimization of addr compare for
 some modules
Date: Mon, 16 Dec 2013 07:16:46 -0800
Message-ID: <1387207006.18217.28.camel@joe-AO722>
References: <52AEB8B3.5010405@huawei.com>
	 <1387205111.18217.7.camel@joe-AO722> <52AF13F4.5040409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dthxman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0097.hostedemail.com ([216.40.44.97]:54210 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754391Ab3LPPQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:16:51 -0500
In-Reply-To: <52AF13F4.5040409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 22:53 +0800, Ding Tianhong wrote:
> =E4=BA=8E 2013/12/16 22:45, Joe Perches =E5=86=99=E9=81=93:
> > Are you intending to do more of these?
> >=20
> > $ git grep -E "\bmemcmp\s*\([^,]*,[^,]*,\s*(ETH_ALEN|6)\s*\)" * | w=
c -l
> > 299
> >=20
> > Perhaps the majority of these should use ether_addr_equal
> > or ether_addr_equal_unaligned.
>
> yes, it is a juge work to review the whole places and I think it shou=
ld be
> finished by several times, maybe start from this patchset.

coccinelle (aka: spatch) can help find and change these

$ cat ether_addr_equal_unaligned.cocci
@@
expression e1;
expression e2;
@@

-	!memcmp(e1, e2, 6)
+	ether_addr_equal_unaligned(e1, e2)

@@
expression e1;
expression e2;
@@

-	memcmp(e1, e2, 6) =3D=3D 0
+	ether_addr_equal_unaligned(e1, e2)

@@
expression e1;
expression e2;
@@

-	memcmp(e1, e2, 6)
+	!ether_addr_equal_unaligned(e1, e2)

@@
expression e1;
expression e2;
@@

-	memcmp(e1, e2, 6) !=3D 0
+	!ether_addr_equal_unaligned(e1, e2)

$ spatch -sp-file ether_addr_equal.cocci drivers/media/dvb-core/dvb_net=
=2Ec
init_defs_builtins: /usr/local/share/coccinelle/standard.h
HANDLING: drivers/media/dvb-core/dvb_net.c
diff =3D=20
--- drivers/media/dvb-core/dvb_net.c
+++ /tmp/cocci-output-18744-96d16c-dvb_net.c
@@ -837,7 +837,8 @@ static void dvb_net_sec(struct net_devic
 	}
 	if (pkt[5] & 0x02) {
 		/* handle LLC/SNAP, see rfc-1042 */
-		if (pkt_len < 24 || memcmp(&pkt[12], "\xaa\xaa\x03\0\0\0", 6)) {
+		if (pkt_len < 24 || !ether_addr_equal_unaligned(&pkt[12],
+								"\xaa\xaa\x03\0\0\0")) {
 			stats->rx_dropped++;
 			return;
 		}

I presume many of these should be ether_addr_equal
and not ether_addr_equal_unaligned, but I can't
think of a way to automate that easily.
