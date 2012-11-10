From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Sat, 10 Nov 2012 23:33:19 +0100
Message-ID: <20121110223319.GA19796@shrek.podlesie.net>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
 <1352292734.7340.35.camel@shinybook.infradead.org>
 <20121110202338.GA1749@shrek.podlesie.net>
 <1352581322.9449.109.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1352581322.9449.109.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 10, 2012 at 09:02:02PM +0000, David Woodhouse wrote:
> On Sat, 2012-11-10 at 21:23 +0100, Krzysztof Mazur wrote:
> > With this tasklet_schedule() we implement a "spin_lock" here, but in
> > this case both conditions (vcc not ready and socket locked) can be
> > true for a long time and we can spin here for a long time. I confirmed
> > it by reverting patch 1 (atm: detach protocol before closing vcc) and
> > now I have 50% of CPU used by ksoftirqd and 50% by pppd (UP system).
> 
> Ah, thanks.
> 
> Can we take the lock in the tasklet, so we wait for it instead of
> spinning?
> 

I don't think so, we cannot sleep in tasklet.

I think we should use sk_add_backlog() or release_cb (introduced by:
46d3ceabd8d98ed0ad10f20c595ca784e34786c5 tcp: TCP Small Queues).
The release_cb callback is almost exactly what we need except that
it works on protocol level, not on socket. The same race with
vcc_sendmsg() exists also in other ATM protocols, so maybe we should
add wrapper in ATM layer that calls vcc->sock_release_cb().

But what about socket flags? Maybe we should just drop that frame?
When ppp is used on serial links "not-ready link" usually does that.
I'm sending an updated patch 6.

Krzysiek
-- >8 --
Subject: [PATCH] pppoatm: drop frames to not-ready vcc

Patches "atm: detach protocol before closing vcc"
and "pppoatm: allow assign only on a connected socket" fixed
common cases where the pppoatm_send() crashes while sending
frame to not-ready vcc. However there are still some other cases
where we can send frames to vcc, which is flagged as ATM_VF_CLOSE
(for instance after vcc_release_async()) or it's opened but not
ready yet.

Now pppoatm_send(), like vcc_sendmsg(), checks for vcc flags that
indicate that vcc is not ready. If the vcc is not ready we just
drop frame. Queueing frames is much more complicated because we
don't have callbacks that inform us about vcc flags changes.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 net/atm/pppoatm.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index c4a57bc..63541a3 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -284,6 +284,13 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 	bh_lock_sock(sk_atm(vcc));
 	if (sock_owned_by_user(sk_atm(vcc)))
 		goto nospace;
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
+			|| test_bit(ATM_VF_CLOSE, &vcc->flags)
+			|| !test_bit(ATM_VF_READY, &vcc->flags)) {
+		bh_unlock_sock(sk_atm(vcc));
+		kfree_skb(skb);
+		return DROP_PACKET;
+	}
 
 	switch (pvcc->encaps) {		/* LLC encapsulation needed */
 	case e_llc:
-- 
1.8.0.268.g9d5ca2e
