From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] filter: add MOD operation
Date: Sat, 08 Sep 2012 10:03:35 +0200
Message-ID: <1347091415.1234.317.camel@edumazet-glaptop>
References: <20120905213941.03c85968@arrowsmith>
	 <C71A36A8-08D2-4D3D-AF2B-EF89FEECE1A6@alum.mit.edu>
	 <20120906073615.693d14e0@arrowsmith>
	 <46AB14E3-73F4-41FA-8086-F1D663AF4549@alum.mit.edu>
	 <20120907074910.2df46817@arrowsmith>
	 <20120908030311.GM17289@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: George Bakos <gbakos@alpinista.org>,
	Jay Schulist <jschlst@samba.org>, netdev@vger.kernel.org
To: Andi Kleen <ak@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47178 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab2IHIDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 04:03:42 -0400
Received: by eekc1 with SMTP id c1so162126eek.19
        for <netdev@vger.kernel.org>; Sat, 08 Sep 2012 01:03:40 -0700 (PDT)
In-Reply-To: <20120908030311.GM17289@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Fri, 2012-09-07 at 20:03 -0700, Andi Kleen wrote:
> On Fri, Sep 07, 2012 at 07:49:10AM +0000, George Bakos wrote:
> > Gents,
> > Any fundamental reason why the following (, etc.) shouldn't be
> > included in net/core/filter.c?
> > 
> >                 case BPF_S_ALU_MOD_X:
> >                         if (X == 0)
> >                                 return 0;
> >                         A %= X;
> >                         continue;
> 
> Copying netdev.
> 
> In principle no reason against it, but you may need to update
> the various BPF JITs too that Linux now has too.

Hi Andi, thanks for the forward

In recent commit ffe06c17afbb was added ALU_XOR_X,
so we could add ALU_MOD_X as well.

ALU_MOD_K is a bit more complex as we cant use an ancillary, and must
instead use a new BPF_OP code :

/* alu/jmp fields */
#define BPF_OP(code)    ((code) & 0xf0)
#define         BPF_ADD         0x00
#define         BPF_SUB         0x10
#define         BPF_MUL         0x20
#define         BPF_DIV         0x30
#define         BPF_OR          0x40
#define         BPF_AND         0x50
#define         BPF_LSH         0x60
#define         BPF_RSH         0x70
#define         BPF_NEG         0x80

So I guess we could use

#define         BPF_MOD         0x90

About the various arches JIT, there is no hurry :
We can update them later.

At JIT 'compile' time, if we find a not yet handled instruction, we fall
back to the net/core/filter.c interpreter.

If the following patch is accepted, I'll do the x86 part as a followup.

Thanks !

[PATCH net-next] filter: add MOD operation

Add a new ALU opcode, to compute a modulus.

Commit ffe06c17afbbb used an ancillary to implement XOR_X,
but here we reserve one of the available ALU opcode to implement both
MOD_X and MOD_K

Signed-off-by: Eric Dumazet <edumazet@google.com>
Suggested-by: George Bakos <gbakos@alpinista.org>
Cc: Jay Schulist <jschlst@samba.org>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>
---
 include/linux/filter.h |    4 ++++
 net/core/filter.c      |   15 +++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 82b0135..3cf5fd5 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -74,6 +74,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define         BPF_LSH         0x60
 #define         BPF_RSH         0x70
 #define         BPF_NEG         0x80
+#define		BPF_MOD		0x90
+
 #define         BPF_JA          0x00
 #define         BPF_JEQ         0x10
 #define         BPF_JGT         0x20
@@ -196,6 +198,8 @@ enum {
 	BPF_S_ALU_MUL_K,
 	BPF_S_ALU_MUL_X,
 	BPF_S_ALU_DIV_X,
+	BPF_S_ALU_MOD_K,
+	BPF_S_ALU_MOD_X,
 	BPF_S_ALU_AND_K,
 	BPF_S_ALU_AND_X,
 	BPF_S_ALU_OR_K,
diff --git a/net/core/filter.c b/net/core/filter.c
index 907efd2..fbe3a8d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -167,6 +167,14 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
 		case BPF_S_ALU_DIV_K:
 			A = reciprocal_divide(A, K);
 			continue;
+		case BPF_S_ALU_MOD_X:
+			if (X == 0)
+				return 0;
+			A %= X;
+			continue;
+		case BPF_S_ALU_MOD_K:
+			A %= K;
+			continue;
 		case BPF_S_ALU_AND_X:
 			A &= X;
 			continue;
@@ -469,6 +477,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 		[BPF_ALU|BPF_MUL|BPF_K]  = BPF_S_ALU_MUL_K,
 		[BPF_ALU|BPF_MUL|BPF_X]  = BPF_S_ALU_MUL_X,
 		[BPF_ALU|BPF_DIV|BPF_X]  = BPF_S_ALU_DIV_X,
+		[BPF_ALU|BPF_MOD|BPF_K]  = BPF_S_ALU_MOD_K,
+		[BPF_ALU|BPF_MOD|BPF_X]  = BPF_S_ALU_MOD_X,
 		[BPF_ALU|BPF_AND|BPF_K]  = BPF_S_ALU_AND_K,
 		[BPF_ALU|BPF_AND|BPF_X]  = BPF_S_ALU_AND_X,
 		[BPF_ALU|BPF_OR|BPF_K]   = BPF_S_ALU_OR_K,
@@ -531,6 +541,11 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 				return -EINVAL;
 			ftest->k = reciprocal_value(ftest->k);
 			break;
+		case BPF_S_ALU_MOD_K:
+			/* check for division by zero */
+			if (ftest->k == 0)
+				return -EINVAL;
+			break;
 		case BPF_S_LD_MEM:
 		case BPF_S_LDX_MEM:
 		case BPF_S_ST:
