From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/7] netprio_cgroup: reimplement priomap expansion
Date: Tue, 20 Nov 2012 06:38:32 -0800
Message-ID: <20121120143832.GO15971@htj.dyndns.org>
References: <1353400211-5182-1-git-send-email-tj@kernel.org>
	<1353400211-5182-5-git-send-email-tj@kernel.org>
	<50AB435E.8060901@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	tgraf-G/eBtMaohhA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50AB435E.8060901-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, Daniel.

On Tue, Nov 20, 2012 at 09:46:22AM +0100, Daniel Wagner wrote:
> struct netprio_map {
> 	struct rcu_head rcu;
> 	struct netprio_aux *aux;	/* auxiliary config array */
> 	u32 priomap_len;
> 	u32 priomap[];
> };
> 
> Is there a specific reason why aux and priomap is handled
> differently? Couldn't you just use same approach for both variables,
> e.g. re/allocating only them here and leave the allocation struct
> netprio_map in cgrp_css_alloc()?

->aux is no longer added, so the consistency issue doesn't exist
anymore.  The reason why they were handled differently before (or
rather why I didn't change priomap[] to be allocated separately) was
that pointer chasing tends to be more expensive than offsetting.  I
don't know how much effect it would have in this case but things
sitting in packet in/out paths can be very hot so didn't wanna disturb
it.

> Also the algorithm to figure out the size of the array might be a
> bit too aggressive in my opinion. So you always start at
> PRIOMAP_MIN_SIZE and then try to double the size until target_idx
> fits. Wouldn't it make sense to start to look for the new size
> beginning at old->priomap_len and then do the power-of-two increase?

The only downside of always starting from PRIOMAP_MIN_SIZE is
iterating several more times in the sizing loop which isn't really
anything to worry about.  The loop is structured that way because I
wanted to keep the size of the whole thing power-of-two.  Due to the
fields before priomap[], if we size priomap_len power-of-two, we'll
always end up with something slightly over power-of-two, which is
usually the worst size to allocate.

Thanks.

-- 
tejun
