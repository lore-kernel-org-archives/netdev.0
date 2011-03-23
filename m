From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 02/36] scsi,
 rcu: convert call_rcu(fc_rport_free_rcu) to kfree_rcu()
Date: Wed, 23 Mar 2011 06:30:48 -0700
Message-ID: <20110323133048.GX2322@linux.vnet.ibm.com>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com>
	<4D82D45A.30102@cn.fujitsu.com> <1300814913.19083.427.camel@fritz>
	<20110323065014.GU2322@linux.vnet.ibm.com>
	<20110323112257.GD13806@parisc-linux.org>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	"linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"James E.J. Bottomley" <James.Bottomley-l3A5Bk7waGM@public.gmane.org>,
	"devel-s9riP+hp16TNLxjTenLetw@public.gmane.org" <devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Pekka Savola \(ipv6\)" <pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org>
To: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110323112257.GD13806-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>
List-Unsubscribe: <https://lists.open-fcoe.org/mailman/options/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 23, 2011 at 05:22:57AM -0600, Matthew Wilcox wrote:
> On Tue, Mar 22, 2011 at 11:50:14PM -0700, Paul E. McKenney wrote:
> > On Tue, Mar 22, 2011 at 10:28:33AM -0700, Robert Love wrote:
> > > On Thu, 2011-03-17 at 20:41 -0700, Lai Jiangshan wrote:
> > > > -	call_rcu(&rdata->rcu, fc_rport_free_rcu);
> > > > +	kfree_rcu(rdata, rcu);
> > > 
> > > I think this last line should be:
> > > 
> > > kfree_rcu(rdata, &rdata->rcu);
> > 
> > Hello, Robert,
> > 
> > I believe that it is correct as is.  The kfree_rcu() definition is as
> > follows:
> > 
> > #define kfree_rcu(ptr, rcu_head)					\
> > 	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
> > 
> > Then __kfree_rcu() encodes the offset into the rcu_head so that it can
> > be handled properly at the end of the grace period.
> 
> To be fair to Robert, I had the same thought, but decided to check the
> definition of kfree_rcu before I made the same comment.  Unfortunately,
> the definition of kfree_rcu is still not in Linus' tree (and there's no
> indication in the patch series about where to find the definition).  It
> would have been better if kfree_rcu were patch 1/n in the series, then
> we'd've been able to review it more effectively.

Good point!  That said, it is a bit ugly no matter how we handle it
because any of the patches that have not received acked-bys will need
to go up through their respective maintainer trees.  Last time I had a
situation like this, it ended up stalling my commit stream for several
months, so was trying to separate them in order to avoid the stall.

But perhaps this is one of those situations where there is simply no
good way to handle the full series.  :-(

> Any idea when kfree_rcu will be submitted to Linus?

I have it queued, and it passes mild testing.  I therefore expect to
push it for the next merge window.

So, do you guys want to carry the patches for your subsystems, or are
you willing to ack this one so that I can push it via -tip?

							Thanx, Paul
