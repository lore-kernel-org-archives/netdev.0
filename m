From: Borislav Petkov <bp@suse.de>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Sun, 12 Mar 2017 22:40:33 +0100
Message-ID: <20170312214033.7zllfclxtjvewo2c@pd.tnic>
References: <58C19607.6000605@iogearbox.net>
 <CA+55aFyxM--wyvxXGhBOqdJHcdC_kKvGYpv-C5SpYvRNkbEmGw@mail.gmail.com>
 <CA+55aFyu-LHqMaZBaa7VNamxhUR99F4Xr+nL9esLDUBhotopVg@mail.gmail.com>
 <58C19F67.3040509@iogearbox.net>
 <58C1C9DC.7070509@iogearbox.net>
 <20170309215547.jmdzznlkzaxwu2pf@pd.tnic>
 <20170309220732.ufqoqlawktsi2gao@pd.tnic>
 <58C1D305.8090802@iogearbox.net>
 <20170309224820.5invcnhvr2tl3ges@pd.tnic>
 <CA+55aFy5vi3af5VBuG6ZOdTeKNxqGSq64J-EkrjaRhGVKXPy0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, the arch/x86 maintainers <x86@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41415 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934858AbdCLVks (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Mar 2017 17:40:48 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFy5vi3af5VBuG6ZOdTeKNxqGSq64J-EkrjaRhGVKXPy0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 09, 2017 at 03:26:02PM -0800, Linus Torvalds wrote:
> Maybe it's the lguest games with PGE that need to be removed?

Btw, tglx suggested something else the other day: warn when we're
changing boot_cpu_data x86_capability bits *after* alternatives have
run. The reasoning behind it being that potentially some patching
static_cpu_has() has done won't be correct anymore.

And it is pretty cheap to do it, it fires nicely on the 32-bit config
with LGUEST=y.

---
diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
index d59c15c3defd..f06c3dc6db70 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -124,8 +124,18 @@ extern const char * const x86_bug_flags[NBUGINTS*32];
 
 #define boot_cpu_has(bit)	cpu_has(&boot_cpu_data, bit)
 
-#define set_cpu_cap(c, bit)	set_bit(bit, (unsigned long *)((c)->x86_capability))
-#define clear_cpu_cap(c, bit)	clear_bit(bit, (unsigned long *)((c)->x86_capability))
+#define set_cpu_cap(c, bit)					\
+({								\
+	WARN_ON(c == &boot_cpu_data && alternatives_patched);	\
+	set_bit(bit, (unsigned long *)((c)->x86_capability));	\
+})
+
+#define clear_cpu_cap(c, bit)					\
+({								\
+	WARN_ON(c == &boot_cpu_data && alternatives_patched);	\
+	clear_bit(bit, (unsigned long *)((c)->x86_capability));	\
+})
+
 #define setup_clear_cpu_cap(bit) do { \
 	clear_cpu_cap(&boot_cpu_data, bit);	\
 	set_bit(bit, (unsigned long *)cpu_caps_cleared); \

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix Imendörffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nürnberg)
-- 
