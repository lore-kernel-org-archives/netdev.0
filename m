From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Wed, 28 Nov 2012 21:18:37 +0100
Message-ID: <20121128201837.GA912@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127182843.GA11597@shrek.podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>,
	chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121127182843.GA11597@shrek.podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2012 at 07:28:43PM +0100, Krzysztof Mazur wrote:
> 
> While reviewing your br2684 patch I also found that some ATM drivers does
> not call ->pop() when ->send() fails, they should do:
> 
> 	if (vcc->pop)
> 		vcc->pop(vcc, skb);
> 	else
> 		dev_kfree_skb(skb);
> 
> but some drivers just call dev_kfree_skb(skb).
> 
> I think that we should add atm_pop() function that does that and fix all
> drivers.
> 

I'm sending a patch that implements that idea.

Currently we need two arguments vcc and skb. However, we have reserved
ATM_SKB(skb)->vcc in skb control block for keeping vcc
and we can create single argument version vcc_pop(skb). In that case
we need to move:

	ATM_SKB(skb)->vcc = vcc;

from ATM drivers to functions that call atmdev_ops->send().

Krzysiek
-- >8 --
Subject: [PATCH] atm: introduce vcc_pop_*()

The atm drivers to free skb, that they got from ->send(), cannot just use
dev_kfree_skb*(), but they must use something like:

	if (vcc->pop)
		vcc->pop(vcc, skb);
	else
		dev_kfree_skb_any(skb);

When vcc->pop is non-NULL, but they must in such case call vcc->pop().
This causes duplicated code in many drivers, and some drivers even forgot
to call vcc->pop() in some error handling code.

The new vcc_pop_*() functions are equivalent to dev_kfree_skb*().
Currently we always use dev_kfree_skb_any() to free, because using
other versions it's probably worthless optimization - in ->pop() we
already use only dev_kfree_skb_any(). The other functions we added
only to not loose information from converting existing code that
uses some non-any dev_kfree_skb*() variants.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 include/linux/atmdev.h | 11 +++++++++++
 net/atm/common.c       |  9 +++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index c1da539..dedccad 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -283,6 +283,17 @@ int atm_pcr_goal(const struct atm_trafprm *tp);
 
 void vcc_release_async(struct atm_vcc *vcc, int reply);
 
+/*
+ * vcc_pop_*() functions should be used by ATM driver to free transmitted
+ * skbs - skbs that were sent to driver by atmdev_opt->send() function.
+ *
+ * We provide three functions that can be used in different contexts.
+ * See dev_kfree_skb*() documentation for details.
+ */
+void vcc_pop_any(struct atm_vcc *vcc, struct sk_buff *skb);
+#define vcc_pop(vcc, skb) vcc_pop_any(vcc, skb)
+#define vcc_pop_irq(vcc, skb) vcc_pop_any(vcc, skb)
+
 struct atm_ioctl {
 	struct module *owner;
 	/* A module reference is kept if appropriate over this call.
diff --git a/net/atm/common.c b/net/atm/common.c
index 806fc0a..ad9c77d 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -654,6 +654,15 @@ out:
 	return error;
 }
 
+void vcc_pop_any(struct atm_vcc *vcc, struct sk_buff *skb)
+{
+	if (vcc->pop)
+		vcc->pop(vcc, skb);
+	else
+		dev_kfree_skb_any(skb);
+}
+EXPORT_SYMBOL(vcc_pop_any);
+
 unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
 	struct sock *sk = sock->sk;
-- 
1.8.0.411.g71a7da8
