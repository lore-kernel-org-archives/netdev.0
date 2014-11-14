From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next v3] fast_hash: clobber registers correctly for inline function use
Date: Fri, 14 Nov 2014 09:57:27 -0800
Message-ID: <15618.1415987847@famine>
References: <1415976656.17262.41.camel@edumazet-glaptop2.roam.corp.google.com> <6751d6af4301f283134a419385f65dfcf92a44ab.1415978153.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, discuss@openvswitch.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50328 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161632AbaKNR5f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 12:57:35 -0500
In-reply-to: <6751d6af4301f283134a419385f65dfcf92a44ab.1415978153.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

>In case the arch_fast_hash call gets inlined we need to tell gcc which
>registers are clobbered with. rhashtable was fine, because it used
>arch_fast_hash via function pointer and thus the compiler took care of
>that. In case of openvswitch the call got inlined and arch_fast_hash
>touched registeres which gcc didn't know about.
>
>Also don't use conditional compilation inside arguments, as this confu=
ses
>sparse.
>
>Fixes: e5a2c899957659c ("fast_hash: avoid indirect function calls")
>Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>Cc: Pravin Shelar <pshelar@nicira.com>
>Cc: Jesse Gross <jesse@nicira.com>
>Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>---
>
>
>v2)
>After studying gcc documentation again, it occured to me that I need t=
o
>specificy all input operands in the clobber section, too. Otherwise gc=
c
>can expect that the inline assembler section won't modify the inputs,
>which is not true.
>
>v3)
>added Fixes tag

	This patch does not compile for me when applied to today's
net-next:

  CC [M]  fs/nfsd/nfs4state.o
In file included from ./arch/x86/include/asm/bitops.h:16:0,
                 from include/linux/bitops.h:33,
                 from include/linux/kernel.h:10,
                 from include/linux/list.h:8,
                 from include/linux/wait.h:6,
                 from include/linux/fs.h:6,
                 from fs/nfsd/nfs4state.c:36:
fs/nfsd/nfs4state.c: In function =E2=80=98nfsd4_cb_recall_prepare=E2=80=
=99:
=2E/arch/x86/include/asm/alternative.h:185:2: error: =E2=80=98asm=E2=80=
=99 operand has impossible constraints
  asm volatile (ALTERNATIVE("call %P[old]", "call %P[new]", feature) \
  ^
=2E/arch/x86/include/asm/hash.h:27:2: note: in expansion of macro =E2=80=
=98alternative_call=E2=80=99
  alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
  ^
make[2]: *** [fs/nfsd/nfs4state.o] Error 1
make[1]: *** [fs/nfsd] Error 2
make: *** [fs] Error 2

	-J


>Bye,
>Hannes
>
> arch/x86/include/asm/hash.h | 20 ++++++++++++++------
> 1 file changed, 14 insertions(+), 6 deletions(-)
>
>diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.h
>index a881d78..a25c45a 100644
>--- a/arch/x86/include/asm/hash.h
>+++ b/arch/x86/include/asm/hash.h
>@@ -23,11 +23,15 @@ static inline u32 arch_fast_hash(const void *data,=
 u32 len, u32 seed)
> {
> 	u32 hash;
>=20
>-	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
> #ifdef CONFIG_X86_64
>-			 "=3Da" (hash), "D" (data), "S" (len), "d" (seed));
>+	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
>+			 "=3Da" (hash), "D" (data), "S" (len), "d" (seed)
>+			 : "rdi", "rsi", "rdx", "rcx", "r8", "r9", "r10", "r11",
>+			   "cc", "memory");
> #else
>-			 "=3Da" (hash), "a" (data), "d" (len), "c" (seed));
>+	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
>+			 "=3Da" (hash), "a" (data), "d" (len), "c" (seed)
>+			 : "edx", "ecx", "cc", "memory");
> #endif
> 	return hash;
> }
>@@ -36,11 +40,15 @@ static inline u32 arch_fast_hash2(const u32 *data,=
 u32 len, u32 seed)
> {
> 	u32 hash;
>=20
>-	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
> #ifdef CONFIG_X86_64
>-			 "=3Da" (hash), "D" (data), "S" (len), "d" (seed));
>+	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
>+			 "=3Da" (hash), "D" (data), "S" (len), "d" (seed)
>+			 : "rdi", "rsi", "rdx", "rcx", "r8", "r9", "r10", "r11",
>+			   "cc", "memory");
> #else
>-			 "=3Da" (hash), "a" (data), "d" (len), "c" (seed));
>+	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
>+			 "=3Da" (hash), "a" (data), "d" (len), "c" (seed)
>+			 : "edx", "ecx", "cc", "memory");
> #endif
> 	return hash;
> }
>--=20
>1.9.3

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
