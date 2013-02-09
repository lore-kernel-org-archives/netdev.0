From: pablo@netfilter.org
Subject: [PATCH 3/5] netfilter: ip6t_NPT: Fix adjustment calculation
Date: Sat,  9 Feb 2013 13:03:58 +0100
Message-ID: <1360411440-6526-4-git-send-email-pablo@netfilter.org>
References: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yoshf=
uji@linux-ipv6.org>

Cast __wsum from/to __sum16 is wrong.  Instead, apply appropriate
conversion function: csum_unfold() or csum_fold().

[ The original patch has been modified to undo the final ~ that
  csum_fold returns. We only need to fold the 32-bit word that
  results from the checksum calculation into a 16-bit to ensure
  that the original subnet is restored appropriately. Spotted by
  Ulrich Weber. ]

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_NPT.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/ip6t_NPT.c b/net/ipv6/netfilter/ip6t_NP=
T.c
index 7302b0b..68788c8 100644
--- a/net/ipv6/netfilter/ip6t_NPT.c
+++ b/net/ipv6/netfilter/ip6t_NPT.c
@@ -30,7 +30,7 @@ static int ip6t_npt_checkentry(const struct xt_tgchk_=
param *par)
 				(__force __wsum)npt->dst_pfx.in6.s6_addr16[i]);
 	}
=20
-	npt->adjustment =3D (__force __sum16) csum_sub(src_sum, dst_sum);
+	npt->adjustment =3D ~csum_fold(csum_sub(src_sum, dst_sum));
 	return 0;
 }
=20
@@ -66,8 +66,8 @@ static bool ip6t_npt_map_pfx(const struct ip6t_npt_tg=
info *npt,
 			return false;
 	}
=20
-	sum =3D (__force __sum16) csum_add((__force __wsum)addr->s6_addr16[id=
x],
-			 npt->adjustment);
+	sum =3D ~csum_fold(csum_add(csum_unfold((__force __sum16)addr->s6_add=
r16[idx]),
+				  csum_unfold(npt->adjustment)));
 	if (sum =3D=3D CSUM_MANGLED_0)
 		sum =3D 0;
 	*(__force __sum16 *)&addr->s6_addr16[idx] =3D sum;
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
