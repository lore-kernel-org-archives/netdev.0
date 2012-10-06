From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH] pppoatm: don't send frames to destroyed vcc
Date: Sat, 6 Oct 2012 17:46:06 +0200
Message-ID: <20121006154606.GA25588@shrek.podlesie.net>
References: <1349525991-21462-1-git-send-email-krzysiek@podlesie.net>
 <1349530370.6524.2.camel@shinybook.infradead.org>
 <20121006153804.GA13564@shrek.podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mitch@sfgoth.com, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121006153804.GA13564@shrek.podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 06, 2012 at 05:38:04PM +0200, Krzysztof Mazur wrote:
> On Sat, Oct 06, 2012 at 02:32:50PM +0100, David Woodhouse wrote:
> > On Sat, 2012-10-06 at 14:19 +0200, Krzysztof Mazur wrote:
> > > Now pppoatm_send(), like vcc_sendmsg(), checks for vcc flags that
> > > indicate that vcc is not ready.
> > 
> > And what locking prevents the flag from being set immediately after we
> > check it?
> > 
> 
> nothing, this patch should fix this. 
> 

I think there is another problem here. The pppoatm gets a reference
to atmvcc, but I don't see anything that protects against removal
of that vcc.

The vcc uses vcc->sk socket for reference counting, so sock_hold()
and sock_put() should be used by pppoatm.

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 29afc68..126f57f 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -154,6 +154,7 @@ static void pppoatm_unassign_vcc(struct atm_vcc *atmvcc)
 	tasklet_kill(&pvcc->wakeup_tasklet);
 	ppp_unregister_channel(&pvcc->chan);
 	atmvcc->user_back = NULL;
+	sock_put(sk_atm(pvcc->atmvcc));
 	kfree(pvcc);
 	/* Gee, I hope we have the big kernel lock here... */
 	module_put(THIS_MODULE);
@@ -371,6 +372,7 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	if (pvcc == NULL)
 		return -ENOMEM;
 	pvcc->atmvcc = atmvcc;
+	sock_hold(sk_atm(atmvcc));
 
 	/* Maximum is zero, so that we can use atomic_inc_not_zero() */
 	atomic_set(&pvcc->inflight, NONE_INFLIGHT);
@@ -385,6 +387,7 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	pvcc->wakeup_tasklet.data = (unsigned long) &pvcc->chan;
 	err = ppp_register_channel(&pvcc->chan);
 	if (err != 0) {
+		sock_put(sk_atm(atmvcc));
 		kfree(pvcc);
 		return err;
 	}

-- 
Krzysiek
