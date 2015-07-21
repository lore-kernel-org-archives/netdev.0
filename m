From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH V2 net 1/3] ARM: net: fix condition for load_order > 0 when
 translating load instructions.
Date: Tue, 21 Jul 2015 14:14:12 +0200
Message-ID: <1437480854-22684-2-git-send-email-nschichan@freebox.fr>
References: <1437480854-22684-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Russell King <linux@arm.linux.org.uk>,
 Alexei Starovoitov <ast@plumgrid.com>
To: "David S. Miller" <davem@davemloft.net>,
 Daniel Borkmann <dborkman@redhat.com>,
 Nicolas Schichan <nschichan@freebox.fr>,
 Mircea Gherzan <mgherzan@gmail.com>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1437480854-22684-1-git-send-email-nschichan@freebox.fr>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

To check whether the load should take the fast path or not, the code
would check that (r_skb_hlen - load_order) is greater than the offset
of the access using an "Unsigned higher or same" condition. For
halfword accesses and an skb length of 1 at offset 0, that test is
valid, as we end up comparing 0xffffffff(-1) and 0, so the fast path
is taken and the filter allows the load to wrongly succeed. A similar
issue exists for word loads at offset 0 and an skb length of less than
4.

Fix that by using the condition "Signed greater than or equal"
condition for the fast path code for load orders greater than 0.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 arch/arm/net/bpf_jit_32.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 4550d24..21f5ace 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -547,7 +547,7 @@ load_common:
 				emit(ARM_SUB_I(r_scratch, r_skb_hl,
 					       1 << load_order), ctx);
 				emit(ARM_CMP_R(r_scratch, r_off), ctx);
-				condt = ARM_COND_HS;
+				condt = ARM_COND_GE;
 			} else {
 				emit(ARM_CMP_R(r_skb_hl, r_off), ctx);
 				condt = ARM_COND_HI;
-- 
1.9.1
