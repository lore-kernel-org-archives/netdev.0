From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] smc91x: fix unused flags warnings on UP systems
Date: Sat, 12 Dec 2009 18:49:38 -0800
Message-ID: <20091212184938.bd057145.akpm@linux-foundation.org>
References: <1260366004-27366-1-git-send-email-vapier@gentoo.org>
	<20091211.151502.188418417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, netdev@vger.kernel.org, nico@fluxnic.net,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753023AbZLMCtq@vger.kernel.org>
In-Reply-To: <20091211.151502.188418417.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Dec 2009 15:15:02 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> From: Mike Frysinger <vapier@gentoo.org>
> Date: Wed,  9 Dec 2009 08:40:04 -0500
> 
> > Local flags variables will be declared whenever these functions get used,
> > but obviously on UP systems the flags parameter won't be touched.  So add
> > some dummy ops that get optimized away anyways to satisfy gcc's warnings.
> > 
> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> 
> Applied, although I thought we had a standard macro to handle this
> kind of case.

Nope.

Coverting them to real C functions fixes the warning, and provides
previously-absent typechecking.  ie, (untested):

--- a/drivers/net/smc91x.c~a
+++ a/drivers/net/smc91x.c
@@ -534,9 +534,18 @@ static inline void  smc_rcv(struct net_d
 #define smc_special_lock(lock, flags)		spin_lock_irqsave(lock, flags)
 #define smc_special_unlock(lock, flags) 	spin_unlock_irqrestore(lock, flags)
 #else
-#define smc_special_trylock(lock, flags)	(1)
-#define smc_special_lock(lock, flags)   	do { } while (0)
-#define smc_special_unlock(lock, flags)	do { } while (0)
+static inline int smc_special_trylock(spinlock_t *lock, unsigned long flags)
+{
+	return 1;
+}
+
+static inline void smc_special_lock(spinlock_t *lock, unsigned long flags)
+{
+}
+
+static inline void smc_special_unlock(spinlock_t *lock, unsigned long flags)
+{
+}
 #endif
 
 /*
_
