From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Sun, 11 Nov 2012 14:50:02 +0100
Message-ID: <20121111135002.GA32390@shrek.podlesie.net>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
 <1352292734.7340.35.camel@shinybook.infradead.org>
 <20121110202338.GA1749@shrek.podlesie.net>
 <1352618933.9449.113.camel@shinybook.infradead.org>
 <20121111110437.GA25894@shrek.podlesie.net>
 <1352633993.9449.120.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1352633993.9449.120.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 11, 2012 at 11:39:53AM +0000, David Woodhouse wrote:
> 
> Right. Something like this then, instead of my previous patch 8/7?
> 
> Only addresses the sock_owned_by_user() case and not ATM_VF_RELEASED,
> ATM_VF_CLOSE or !ATM_VF_READY, but your amended patch 6 fixes that I
> think.
> 

Looks and works ok after:

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 7b8dafe..87e792c 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -414,6 +414,7 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	atmvcc->user_back = pvcc;
 	atmvcc->push = pppoatm_push;
 	atmvcc->pop = pppoatm_pop;
+	atmvcc->unlock_cb = pppoatm_unlock_cb;
 	__module_get(THIS_MODULE);
 	atmvcc->owner = THIS_MODULE;

With this change:
Acked-by: Krzysztof Mazur <krzysiek@podlesie.net>

This patch should be also acked by Chas, at least changes in generic ATM
code (maybe as separate patch).

I need also an ack for new version of patch 6 (pppoatm: drop frames to
not-ready vcc).

Maybe we should schedule tasklet in pppoatm_unlock_cb() only when it's needed.


Thanks,

Krzysiek

-- >8 --
Subject: [PATCH] pppoatm: wakeup after ATM unlock only when it's needed

We need to schedule wakeup tasklet only when ATM socket locked
was previously locked. The locking is provided by the sk->sk_lock.slock
spinlock.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 net/atm/pppoatm.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 87e792c..841b9f8 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -66,6 +66,7 @@ struct pppoatm_vcc {
 	enum pppoatm_encaps encaps;
 	atomic_t inflight;
 	unsigned long blocked;
+	int need_wakeup;
 	int flags;			/* SC_COMP_PROT - compress protocol */
 	struct ppp_channel chan;	/* interface to generic ppp layer */
 	struct tasklet_struct wakeup_tasklet;
@@ -113,7 +114,10 @@ static void pppoatm_unlock_cb(struct atm_vcc *atmvcc)
 {
 	struct pppoatm_vcc *pvcc = atmvcc_to_pvcc(atmvcc);
 
-	tasklet_schedule(&pvcc->wakeup_tasklet);
+	if (pvcc->need_wakeup) {
+		pvcc->need_wakeup = 0;
+		tasklet_schedule(&pvcc->wakeup_tasklet);
+	}
 	if (pvcc->old_unlock_cb)
 		pvcc->old_unlock_cb(atmvcc);
 }
@@ -292,8 +296,10 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 
 	vcc = ATM_SKB(skb)->vcc;
 	bh_lock_sock(sk_atm(vcc));
-	if (sock_owned_by_user(sk_atm(vcc)))
+	if (sock_owned_by_user(sk_atm(vcc))) {
+		pvcc->need_wakeup = 1;
 		goto nospace;
+	}
 	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
 			|| test_bit(ATM_VF_CLOSE, &vcc->flags)
 			|| !test_bit(ATM_VF_READY, &vcc->flags)) {
-- 
1.8.0.268.g9d5ca2e
