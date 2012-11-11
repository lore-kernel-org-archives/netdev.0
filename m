From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Sun, 11 Nov 2012 12:04:37 +0100
Message-ID: <20121111110437.GA25894@shrek.podlesie.net>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
 <1352292734.7340.35.camel@shinybook.infradead.org>
 <20121110202338.GA1749@shrek.podlesie.net>
 <1352618933.9449.113.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1352618933.9449.113.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 11, 2012 at 07:28:53AM +0000, David Woodhouse wrote:
> On Sat, 2012-11-10 at 21:23 +0100, Krzysztof Mazur wrote:
> > With this tasklet_schedule() we implement a "spin_lock" here, but in
> > this case both conditions (vcc not ready and socket locked) can be
> > true for a long time and we can spin here for a long time. 
> 
> Reading this more carefully this morning... I hadn't realised it was
> these conditions, and not the sock_owned_by_user(), which had triggered.

Yes, but socket can be also locked for a long time, vcc_sendmsg() sleeps
owning socket lock waiting for memory or atm_may_send().

pppd was spinning in tasklet_kill() (at least when I did sysrq+t).

> Yes, perhaps we should just return zero in that case and find another
> wakeup trigger... if indeed a wakeup is ever required in the VF_RELEASED
> and VF_CLOSE case. And if we've fixed things so that !VF_READY can never
> happen (have we?).... perhaps this one doesn't matter at all? It was the

I think we can just drop frame if vcc flags indicate not-ready link
and in this case we not need a wakeup event. I already sent you
an updated patch 3 that drops frame instead of returning zero.

> sock_owned_by_user() case I was most interested in, and I was expecting
> that lock would generally be held briefly enough that the tasklet would
> be fine. Was that not so?
> 

When vcc_sendmsg() waits for memory it can be a problem.

I think we can use release_cb callback that is called when socket lock
is released (we will need small wrapper in ATM layer that will call
new vcc->release_cb callback), but maybe we shouldn't use ATM socket
lock and use some new vcc->send_lock instead that will protect
vcc->send() and us against atm_may_send()/atomic_add(skb->truesize,
&sk->sk_wmem_alloc)/ race with vcc_sendmsg().


Any race with testing vcc flags is probably not really important
because:
	- vcc_release_async() does not take any lock so this check
	  will be always racy so we are probably allowed to send
	  new frames until vcc is really closed,
	- we are already protected against vcc_destroy_socket()
	- the only case that such test is really important
	  is openned, but not ready vcc, and we avoid any race
	  by not doing send.

Krzysiek

-- >8 --
release_cb wrapper for ATM - just to precisely show the first idea,
with this patch we can just implement vcc->release_cb() and call
tasklet_schedule() there (if needed).

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 31c16c6..a6f9d4b 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -310,6 +310,7 @@ struct atm_vcc {
 	struct atm_sap	sap;		/* SAP */
 	void (*push)(struct atm_vcc *vcc,struct sk_buff *skb);
 	void (*pop)(struct atm_vcc *vcc,struct sk_buff *skb); /* optional */
+	void (*release_cb)(struct atm_vcc *vcc);
 	int (*push_oam)(struct atm_vcc *vcc,void *cell);
 	int (*send)(struct atm_vcc *vcc,struct sk_buff *skb);
 	void		*dev_data;	/* per-device data */
diff --git a/net/atm/common.c b/net/atm/common.c
index ea952b2..4e7f305 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -126,10 +126,19 @@ static void vcc_write_space(struct sock *sk)
 	rcu_read_unlock();
 }
 
+void vcc_release_cb(struct sock *sk)
+{
+	struct atm_vcc *vcc = atm_sk(sk);
+
+	if (vcc->release_cb)
+		vcc->release_cb(vcc);
+}
+
 static struct proto vcc_proto = {
 	.name	  = "VCC",
 	.owner	  = THIS_MODULE,
 	.obj_size = sizeof(struct atm_vcc),
+	.release_cb = vcc_release_cb,
 };
 
 int vcc_create(struct net *net, struct socket *sock, int protocol, int family)
