From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: next build: 235 warnings 3 failures (next/next-20151117)
Date: Tue, 17 Nov 2015 09:57:30 +0100
Message-ID: <4694362.ZPL12j6kR2@wuerfel>
References: <564a9961.878b420a.331b8.fffffd62@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: kernel-build-reports@lists.linaro.org, olof@lixom.net,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Catalin Marinas <catalin.marinas@arm.com>, will.deacon@arm.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <564a9961.878b420a.331b8.fffffd62@mx.google.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 16 November 2015 19:05:05 Olof's autobuilder wrote:
> 
> Errors:
> 
>         arm64.allmodconfig:
> arch/arm64/include/asm/barrier.h:71:3: error: read-only variable '___p1' used as 'asm' output
> arch/arm64/include/asm/barrier.h:75:3: error: read-only variable '___p1' used as 'asm' output
> arch/arm64/include/asm/barrier.h:79:3: error: read-only variable '___p1' used as 'asm' output
> arch/arm64/include/asm/barrier.h:83:3: error: read-only variable '___p1' used as 'asm' output
> arch/arm64/include/asm/barrier.h:71:3: error: read-only variable '___p1' used as 'asm' output
> arch/arm64/include/asm/barrier.h:75:3: error: read-only variable '___p1' used as 'asm' output
> arch/arm64/include/asm/barrier.h:79:3: error: read-only variable '___p1' used as 'asm' output
> arch/arm64/include/asm/barrier.h:83:3: error: read-only variable '___p1' used as 'asm' output
> arch/arm64/include/asm/barrier.h:71:3: error: read-only variable '___p1' used as 'asm' output

The patch below seems to fix it. Please review/apply.

8<----
Subject: ARM64: make smp_load_acquire() work with const arguments

smp_load_acquire() uses typeof() to declare a local variable for temporarily
storing the output of the memory access. This fails when the argument is
constant, because the assembler complains about using a constant register
as output:

 arch/arm64/include/asm/barrier.h:71:3: error: read-only variable '___p1' used as 'asm' output

This changes the implementation to use an 'unsigned long' for the temporary value
and only cast it to the original type in the end.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/arch/arm64/include/asm/barrier.h b/arch/arm64/include/asm/barrier.h
index 624f9679f4b0..05fa329467f6 100644
--- a/arch/arm64/include/asm/barrier.h
+++ b/arch/arm64/include/asm/barrier.h
@@ -64,7 +64,7 @@ do {									\
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1;						\
+	unsigned long ___p1;						\
 	compiletime_assert_atomic_type(*p);				\
 	switch (sizeof(*p)) {						\
 	case 1:								\
@@ -84,7 +84,7 @@ do {									\
 			: "=r" (___p1) : "Q" (*p) : "memory");		\
 		break;							\
 	}								\
-	___p1;								\
+	(typeof(*p))___p1;								\
 })
 
 #define read_barrier_depends()		do { } while(0)
