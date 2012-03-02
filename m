From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom
 load_pointer
Date: Fri, 2 Mar 2012 11:40:14 +0100
Message-ID: <26411fc25ada53b95e90b6a5fa85ad44.squirrel@webmail.greenhost.nl>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, "Will Drewry" <wad@chromium.org>
To: "Will Drewry" <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1330559620-23543-1-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, March 1, 2012 00:53, Will Drewry wrote:
>  include/linux/filter.h |   46 +++++++++++++++++++
>  net/core/filter.c      |  117 +++++++++++++++++++++++++++++++++++++++++++++---
>  2 files changed, 157 insertions(+), 6 deletions(-)

I propose a slightly different approach:

Instead of more or less allowing generic load instructions, do the
same as the ancillary data functions and only allow BPF_S_LD_W_ABS.
In addition to that, rewrite and check the functions ourself after
sk_chk_filter() has done its checks.

Diff for filter.c:

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 8eeb205..63b728c 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -228,6 +228,7 @@ enum {
 	BPF_S_ANC_HATYPE,
 	BPF_S_ANC_RXHASH,
 	BPF_S_ANC_CPU,
+	BPF_S_LD_W_SECCOMP,
 };

 #endif /* __KERNEL__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index 5dea452..7e338d6 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -350,6 +350,9 @@ load_b:
 				A = 0;
 			continue;
 		}
+		case BPF_S_LD_W_SECCOMP:
+			A = seccomp_load(fentry->k);
+			continue;
 		default:
 			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
 				       fentry->code, fentry->jt,
---

And in seccomp add something like:

/*
 * Does SECCOMP specific checks.
 * Should be called after sk_chk_filter(), as it assumes all instructions
 * are rewritten to the kernel enum format.
 * No SKB touching instructions are allowed. Only data LD instruction allowed
 * is BPF_S_LD_W_ABS, which will be handled by seccomp_load().
 */
int seccomp_check_filter(const struct sock_filter *filter, unsigned int flen)
{
	int pc;

	/* Make sure there are no SKB using instructions */
	for (pc = 0; pc < flen; pc++) {
		u16 code = filter->code;
		unsigned int k = filter->k;

		if (code <= BPF_S_ALU_NEG)
			continue;
		if (code >= BPF_S_LDX_IMM && code < BPF_S_ANC_PROTOCOL)
			continue;
		switch (code) {
		case BPF_S_LD_W_ABS:
			filter->code = BPF_S_LD_W_SECCOMP;
			if (k >= sizeof(struct seccomp_data) || k & 3)
				return -EINVAL;
			continue;
		case BPF_S_LD_W_LEN:
			filter->code = BPF_S_LD_IMM;
			filter->k = sizeof(struct seccomp_data);
			continue;
		case BPF_S_LD_IMM:
			continue;
		case BPF_S_LDX_W_LEN:
			filter->code = BPF_S_LDX_IMM;
			filter->k = sizeof(struct seccomp_data);
			continue;
		default:
			return -EINVAL;
		}
	}
	return 0;
}

u32 seccomp_load(int off)
{
	u32 A;
	struct pt_regs *regs = task_pt_regs(current);

	if (off >= BPF_DATA(args[0]) && off < BPF_DATA(args[6])) {
		int arg = (off - BPF_DATA(args[0])) / sizeof(u64);
		int index = (off % sizeof(u64)) ? 1 : 0;
		syscall_get_arguments(current, regs, arg, 1, &value);
		A = get_u32(value, index);
	} else if (off == BPF_DATA(nr)) {
		A = syscall_get_nr(current, regs);
	} else if (off == BPF_DATA(arch)) {
		A = syscall_get_arch(current, regs);
	} else if (off == BPF_DATA(instruction_pointer)) {
		A = get_u32(KSTK_EIP(current), 0);
	} else if (off == BPF_DATA(instruction_pointer) + sizeof(u32)) {
		A = get_u32(KSTK_EIP(current), 1);
	}
	return A;
}

This way you can even add SECCOMP specific functions in the future by using
special offsets. (E.g. 64-bit compare between an arg and scratch memory.)

Greetings,

Indan


