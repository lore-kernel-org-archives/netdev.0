From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2 RFC net-next] net/vxlan: Fix kernel unaligned access
 in __vxlan_find_mac
Date: Sat, 18 Jul 2015 11:06:26 -0700
Message-ID: <1437242786.24289.11.camel@perches.com>
References: <20150717200031.GB30336@oracle.com>
	 <1437174422.2495.75.camel@perches.com>
	 <20150717.181825.641987192390100037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0206.hostedemail.com ([216.40.44.206]:46211 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751501AbbGRSGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 14:06:30 -0400
In-Reply-To: <20150717.181825.641987192390100037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-17 at 18:18 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com> Date: Fri, 17 Jul 2015 16:07:02 -0700
> > On Fri, 2015-07-17 at 22:00 +0200, Sowmini Varadhan wrote:
> >> __vxlan_find_mac invokes ether_addr_equal on the eth_addr field,
> >> which triggers unaligned access messages, so rearrange vxlan_fdb
> >> to avoid this in the most non-intrusive way.

> > What arch does this?

> Sparc, MIPS, etc.

It seems that this code has had unaligned accesses
on this field even before compare_ether_addr was
converted to ether_addr_equal.

Is sparc64 the only one that emits / ratelimits that
unaligned access message?  I looked a little, but I
didn't find a fixup message when MIPS does unaligned
accesses.  Are all the other arches silent when
fixing up unaligned accesses?  Maye adding a generic
debug only ratelimited message might help remove
more of these.  As it's not fatal, naybe the sparc64
message should be KERN_DEBUG/pr_debug.

---

 arch/sparc/kernel/unaligned_64.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/sparc/kernel/unaligned_64.c b/arch/sparc/kernel/unaligned_64.c
index 62098a8..6b7aeb7 100644
--- a/arch/sparc/kernel/unaligned_64.c
+++ b/arch/sparc/kernel/unaligned_64.c
@@ -294,13 +294,9 @@ static void kernel_mna_trap_fault(int fixup_tstate_asi)
 
 static void log_unaligned(struct pt_regs *regs)
 {
-	static DEFINE_RATELIMIT_STATE(ratelimit, 5 * HZ, 5);
+	pr_debug_ratelimited("Kernel unaligned access at TPC[%lx] %pS\n",
+			     regs->tpc, (void *)regs->tpc);
 
-	if (__ratelimit(&ratelimit)) {
-		printk("Kernel unaligned access at TPC[%lx] %pS\n",
-		       regs->tpc, (void *) regs->tpc);
-	}
-}
 
 asmlinkage void kernel_unaligned_trap(struct pt_regs *regs, unsigned int insn)
 {
