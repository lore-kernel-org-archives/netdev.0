From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v3 0/7] Isolate time_t data types for clock/timer syscalls
Date: Mon, 26 Jun 2017 05:13:34 +0100
Message-ID: <20170626041334.GZ10672@ZenIV.linux.org.uk>
References: <20170624184508.21500-1-deepa.kernel@gmail.com>
 <20170626023525.GY10672@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org,
        john.stultz@linaro.org, nicolas.pitre@linaro.org, arnd@arndb.de,
        y2038@lists.linaro.org, linux-fsdevel@vger.kernel.org,
        netdev@vger.kernel.org
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170626023525.GY10672@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2017 at 03:35:25AM +0100, Al Viro wrote:
> On Sat, Jun 24, 2017 at 11:45:01AM -0700, Deepa Dinamani wrote:
> > The series aims at isolating data conversions of time_t based structures:
> > struct timespec and struct itimerspec at user space boundaries.
> > This helps to later change the underlying types to handle y2038 changes
> > to these.
> 
> Nice...  A few questions:
> 
> * what about setitimer(2)?  Right now that's the only remaining user of
> get_compat_itimerval(); similar for getitimer(2) and put_compat_itimerval().
> 
> * you have two callers of get_compat_itimerspec64(); one is followed by
> itimerspec64_valid(), another - by its open-coded analogue.  The same
> goes for get_itimerspec64(); wouldn't it be better to have both check
> the validity immediately and simply fail with -EINVAL?  Matter of taste,
> but...
> 
> * should __sys_recvmmsg() switch to timespec64?

While we are at it - do we need any locking for accesses of ->sk_stamp?
	* ax25, ipx, netrom, qrtr: sock_get_timestamp() done under lock_sock().
	* bluetooth: without (and case next door in the same switch is
grabbing/dropping lock_sock, so it's not held by caller either)
	* ipv4, ipv6, packet, can: without
	* irda: without, checks for NULL sock->sk for some reason (other
cases do not, so if we ever get there with NULL ->sk, we are fucked).
Incidentally, TIOCINQ in there looks fishy - what's to prevent us from
losing CPU just as skb_peek() returns, with skb getting freed by the
time we regain it and go looking at skb->len?  Don't we need at least
to hold ->lock on queue we are peeking into?
	* rose: without, and TIOCINQ there looks similar to irda one
	* x25: without, with the same odd check for NULL sock->sk
	* atm: without, apparently.  Same unprotected skb_peek() on
TIOCINQ...
	* atalk: ditto.
