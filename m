From: Joe Perches <joe@perches.com>
Subject: [PATCH] x86: bpf_jit_comp: Reduce is_ereg() code size
Date: Thu, 04 Dec 2014 15:00:48 -0800
Message-ID: <1417734048.2721.22.camel@perches.com>
References: <CAADnVQKtYkKtsd9rUFm2yfMoh7F_SRFPVP8hpvSY00KpmB-NNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Quentin Lambert <lambert.quentin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAADnVQKtYkKtsd9rUFm2yfMoh7F_SRFPVP8hpvSY00KpmB-NNg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the (1 << reg) & mask trick to reduce code size.

x86-64 size difference -O2 without profiling for various
gcc versions:

$ size arch/x86/net/bpf_jit_comp.o*
   text    data     bss     dec     hex filename
   9266       4       0    9270    2436 arch/x86/net/bpf_jit_comp.o.4.4.new
  10042       4       0   10046    273e arch/x86/net/bpf_jit_comp.o.4.4.old
   9109       4       0    9113    2399 arch/x86/net/bpf_jit_comp.o.4.6.new
   9717       4       0    9721    25f9 arch/x86/net/bpf_jit_comp.o.4.6.old
   8789       4       0    8793    2259 arch/x86/net/bpf_jit_comp.o.4.7.new
  10245       4       0   10249    2809 arch/x86/net/bpf_jit_comp.o.4.7.old
   9671       4       0    9675    25cb arch/x86/net/bpf_jit_comp.o.4.9.new
  10679       4       0   10683    29bb arch/x86/net/bpf_jit_comp.o.4.9.old

Signed-off-by: Joe Perches <joe@perches.com>
---

compiled, untested by me, but per Alexei Starovoitov this passes
the test_bpf suite

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 3f62734..09e2cea 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -135,11 +135,11 @@ static const int reg2hex[] = {
  */
 static inline bool is_ereg(u32 reg)
 {
-	if (reg == BPF_REG_5 || reg == AUX_REG ||
-	    (reg >= BPF_REG_7 && reg <= BPF_REG_9))
-		return true;
-	else
-		return false;
+	return (1 << reg) & (BIT(BPF_REG_5) |
+			     BIT(AUX_REG) |
+			     BIT(BPF_REG_7) |
+			     BIT(BPF_REG_8) |
+			     BIT(BPF_REG_9));
 }
 
 /* add modifiers if 'reg' maps to x64 registers r8..r15 */
