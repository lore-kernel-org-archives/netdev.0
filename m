From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH] atm: introduce vcc_pop_skb()
Date: Wed, 28 Nov 2012 23:33:00 +0100
Message-ID: <20121128223300.GA12527@shrek.podlesie.net>
References: <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127182843.GA11597@shrek.podlesie.net>
 <20121128201837.GA912@shrek.podlesie.net>
 <20121128162001.3f326720@thirdoffive.cmf.nrl.navy.mil>
 <20121128214533.GA25486@shrek.podlesie.net>
 <20121128165906.05ef5e2b@thirdoffive.cmf.nrl.navy.mil>
 <20121128221040.GA24035@shrek.podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121128221040.GA24035@shrek.podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2012 at 11:10:40PM +0100, Krzysztof Mazur wrote:
> On Wed, Nov 28, 2012 at 04:59:06PM -0500, chas williams - CONTRACTOR wrote:
> > On Wed, 28 Nov 2012 22:45:34 +0100
> > Krzysztof Mazur <krzysiek@podlesie.net> wrote:
> > 
> > > On Wed, Nov 28, 2012 at 04:20:01PM -0500, chas williams - CONTRACTOR wrote:
> > > > i dont like the vcc->pop() implementation and at one point i had the
> > > > crazy idea of using skb->destructors to handle it.  however, i think it
> > > > would be necessary to clone the skb's so any existing destructor is
> > > > preserved.
> > > 
> > > With this patch we will kill vcc->pop() in drivers and in future
> > > we can do that without changes in drivers.
> > 
> > ok
> > 
> > > > 
> > > > > +#define vcc_pop(vcc, skb) vcc_pop_any(vcc, skb)
> > > > > +#define vcc_pop_irq(vcc, skb) vcc_pop_any(vcc, skb)
> > > > 
> > > > don't define these if you dont plan on using them anway.
> > > 
> > > I removed them. I also added check if vcc is NULL, as David Woodhouse
> > > suggested, some drivers use that.
> > 
> > it should probably be if (likely(vcc) && likely(vcc->pop)) since it
> > will almost always be the case.
> 

I think that we should also add that single-argument skb-only version.
Currently it can be used only after the driver does ATM_SKB(skb)->vcc = vcc.
Most drivers do that.

Thanks,

Krzysiek
-- >8 --
Subject: [PATCH] atm: introduce atm_pop_skb()

Many ATM drivers store vcc in ATM_SKB(skb)->vcc and use it for
freeing skbs. Now they can just use atm_pop_skb() to free such
buffers.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 include/linux/atmdev.h | 8 ++++++++
 net/atm/common.c       | 6 ++++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 57bd93f..648fb79 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -291,6 +291,14 @@ void vcc_release_async(struct atm_vcc *vcc, int reply);
  */
 void vcc_pop(struct atm_vcc *vcc, struct sk_buff *skb);
 
+/**
+ * vcc_pop_skb - free transmitted ATM skb
+ *
+ * This variant of vcc_pop() assumes that ATM_SKB(skb)->vcc is set
+ * by driver.
+ */
+void vcc_pop_skb(struct sk_buff *skb);
+
 struct atm_ioctl {
 	struct module *owner;
 	/* A module reference is kept if appropriate over this call.
diff --git a/net/atm/common.c b/net/atm/common.c
index c42ff62..378c911 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -663,6 +663,12 @@ void vcc_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(vcc_pop);
 
+void vcc_pop_skb(struct sk_buff *skb)
+{
+	vcc_pop(ATM_SKB(skb)->vcc, skb);
+}
+EXPORT_SYMBOL(vcc_pop_skb);
+
 unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
 	struct sock *sk = sock->sk;
-- 
1.8.0.411.g71a7da8
