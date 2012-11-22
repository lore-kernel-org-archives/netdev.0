From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] net: xfrm: use __this_cpu_read per-cpu helper
Date: Thu, 22 Nov 2012 09:02:40 +0100
Message-ID: <1353571362-6774-3-git-send-email-steffen.klassert@secunet.com>
References: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36103 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932387Ab2KVTBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 14:01:18 -0500
In-Reply-To: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Shan Wei <shanwei88@gmail.com>

this_cpu_ptr/this_cpu_read is faster than per_cpu_ptr(p, smp_processor_=
id())
and can reduce  memory accesses.
The latter helper needs to find the offset for current cpu,
and needs more assembler instructions which objdump shows in following.

this_cpu_ptr relocates and address. this_cpu_read() relocates the addre=
ss
and performs the fetch. this_cpu_read() saves you more instructions
since it can do the relocation and the fetch in one instruction.

per_cpu_ptr(p, smp_processor_id())=EF=BC=9A
  1e:   65 8b 04 25 00 00 00 00         mov    %gs:0x0,%eax
  26:   48 98                           cltq
  28:   31 f6                           xor    %esi,%esi
  2a:   48 c7 c7 00 00 00 00            mov    $0x0,%rdi
  31:   48 8b 04 c5 00 00 00 00         mov    0x0(,%rax,8),%rax
  39:   c7 44 10 04 14 00 00 00         movl   $0x14,0x4(%rax,%rdx,1)

this_cpu_ptr(p)
  1e:   65 48 03 14 25 00 00 00 00      add    %gs:0x0,%rdx
  27:   31 f6                           xor    %esi,%esi
  29:   c7 42 04 14 00 00 00            movl   $0x14,0x4(%rdx)
  30:   48 c7 c7 00 00 00 00            mov    $0x0,%rdi

Signed-off-by: Shan Wei <davidshan@tencent.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_ipcomp.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index e5246fb..2906d52 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -276,18 +276,16 @@ static struct crypto_comp * __percpu *ipcomp_allo=
c_tfms(const char *alg_name)
 	struct crypto_comp * __percpu *tfms;
 	int cpu;
=20
-	/* This can be any valid CPU ID so we don't need locking. */
-	cpu =3D raw_smp_processor_id();
=20
 	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
 		struct crypto_comp *tfm;
=20
-		tfms =3D pos->tfms;
-		tfm =3D *per_cpu_ptr(tfms, cpu);
+		/* This can be any valid CPU ID so we don't need locking. */
+		tfm =3D __this_cpu_read(*pos->tfms);
=20
 		if (!strcmp(crypto_comp_name(tfm), alg_name)) {
 			pos->users++;
-			return tfms;
+			return pos->tfms;
 		}
 	}
=20
--=20
1.7.9.5
