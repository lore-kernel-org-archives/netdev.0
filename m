From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH] atm: introduce vcc_pop()
Date: Wed, 28 Nov 2012 22:45:34 +0100
Message-ID: <20121128214533.GA25486@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127182843.GA11597@shrek.podlesie.net>
 <20121128201837.GA912@shrek.podlesie.net>
 <20121128162001.3f326720@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121128162001.3f326720@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2012 at 04:20:01PM -0500, chas williams - CONTRACTOR wrote:
> On Wed, 28 Nov 2012 21:18:37 +0100
> Krzysztof Mazur <krzysiek@podlesie.net> wrote:
> 
> > On Tue, Nov 27, 2012 at 07:28:43PM +0100, Krzysztof Mazur wrote:
> > > I think that we should add atm_pop() function that does that and fix all
> > > drivers.
> > > 
> > 
> > I'm sending a patch that implements that idea.
> > 
> > Currently we need two arguments vcc and skb. However, we have reserved
> > ATM_SKB(skb)->vcc in skb control block for keeping vcc
> > and we can create single argument version vcc_pop(skb). In that case
> > we need to move:
> > 
> > 	ATM_SKB(skb)->vcc = vcc;
> > 
> > from ATM drivers to functions that call atmdev_ops->send().
> 
> i dont like the vcc->pop() implementation and at one point i had the
> crazy idea of using skb->destructors to handle it.  however, i think it
> would be necessary to clone the skb's so any existing destructor is
> preserved.

With this patch we will kill vcc->pop() in drivers and in future
we can do that without changes in drivers.

> 
> > +#define vcc_pop(vcc, skb) vcc_pop_any(vcc, skb)
> > +#define vcc_pop_irq(vcc, skb) vcc_pop_any(vcc, skb)
> 
> don't define these if you dont plan on using them anway.

I removed them. I also added check if vcc is NULL, as David Woodhouse
suggested, some drivers use that.

Krzysiek
-- >8 --
Subject: [PATCH v2] atm: introduce vcc_pop()

The atm drivers to free skb, that they got from ->send(), cannot just use
dev_kfree_skb*(), but they must use something like:

	if (vcc->pop)
		vcc->pop(vcc, skb);
	else
		dev_kfree_skb_any(skb);

When vcc->pop() is non-NULL, but they must in such case call vcc->pop().
This causes duplicated code in many drivers, and some drivers even forgot
to call vcc->pop() in some error handling code.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 include/linux/atmdev.h | 8 ++++++++
 net/atm/common.c       | 9 +++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index c1da539..57bd93f 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -283,6 +283,14 @@ int atm_pcr_goal(const struct atm_trafprm *tp);
 
 void vcc_release_async(struct atm_vcc *vcc, int reply);
 
+/**
+ * vcc_pop - free transmitted ATM skb
+ *
+ * vcc_pop() should be used by ATM driver to free skbs, that were sent
+ * to driver by atmdev_opt->send() function.
+ */
+void vcc_pop(struct atm_vcc *vcc, struct sk_buff *skb);
+
 struct atm_ioctl {
 	struct module *owner;
 	/* A module reference is kept if appropriate over this call.
diff --git a/net/atm/common.c b/net/atm/common.c
index 806fc0a..76bf76c 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -654,6 +654,15 @@ out:
 	return error;
 }
 
+void vcc_pop(struct atm_vcc *vcc, struct sk_buff *skb)
+{
+	if (vcc && vcc->pop)
+		vcc->pop(vcc, skb);
+	else
+		dev_kfree_skb_any(skb);
+}
+EXPORT_SYMBOL(vcc_pop);
+
 unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
 	struct sock *sk = sock->sk;
-- 
1.8.0.411.g71a7da8
