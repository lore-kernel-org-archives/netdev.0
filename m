From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] x86: fix atomic64_xxx_cx8() functions
Date: Tue, 03 Jan 2012 17:35:40 +0100
Message-ID: <1325608540.2320.103.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F01F12A020000780006A19B@nat28.tlf.novell.com>
	 <1325602830.2320.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325603714.2320.73.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325605290.2320.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F03361C020000780006A3A5@nat28.tlf.novell.com>
	 <1325607218.2320.89.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, tglx@linutronix.de,
	Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, hpa@zytor.com
To: Jan Beulich <JBeulich@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1325607218.2320.89.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It appears about all functions in arch/x86/lib/atomic64_cx8_32.S are
wrong in case cmpxchg8b must be restarted, because LOCK_PREFIX macro
defines a label "1" clashing with other local labels :

1:
	some_instructions
	LOCK_PREFIX
	cmpxchg8b (%ebp)
	jne 1b  / jumps to beginning of LOCK_PREFIX !

A possible fix is to use a magic label "672" in LOCK_PREFIX asm
definition, similar to the "671" one we defined in LOCK_PREFIX_HERE. 

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Jan Beulich <JBeulich@suse.com>
CC: Christoph Lameter <cl@linux.com>
CC: Ingo Molnar <mingo@elte.hu>
CC: H. Peter Anvin <hpa@zytor.com>
Cc: stable@vger.kernel.org  [2.6.35+]
---
 arch/x86/include/asm/alternative-asm.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/alternative-asm.h b/arch/x86/include/asm/alternative-asm.h
index 091508b..952bd01 100644
--- a/arch/x86/include/asm/alternative-asm.h
+++ b/arch/x86/include/asm/alternative-asm.h
@@ -4,10 +4,10 @@
 
 #ifdef CONFIG_SMP
 	.macro LOCK_PREFIX
-1:	lock
+672:	lock
 	.section .smp_locks,"a"
 	.balign 4
-	.long 1b - .
+	.long 672b - .
 	.previous
 	.endm
 #else
