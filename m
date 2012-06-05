From: Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/2] inetpeer: add namespace support for
	inetpeer
Date: Tue, 5 Jun 2012 14:15:10 +0200
Message-ID: <20120605121510.GD27795@secunet.com>
References: <1338882737-11914-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1338886626.2760.2109.camel@edumazet-glaptop>
	<20120605112728.GB27795@secunet.com>
	<1338897630.2760.2433.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1338897630.2760.2433.camel@edumazet-glaptop>
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

On Tue, Jun 05, 2012 at 02:00:30PM +0200, Eric Dumazet wrote:
> On Tue, 2012-06-05 at 13:27 +0200, Steffen Klassert wrote:
> 
> > > 
> > > By the way, I think we have a bug in inetpeer_gc_worker()
> > > 
> > > Steffen ?
> > > 
> > > We have no rcu grace period to make sure the following is safe :
> > > 
> > > if (!atomic_read(&p->refcnt)) {
> > > 	list_del(&p->gc_list);
> > > 	kmem_cache_free(peer_cachep, p);
> > > }
> > 
> > I think this is ok as it is. inetpeer_invalidate_tree()
> > unlinks the whole inetpeer tree from the inetpeer base and
> > adds it to a gc_list. These intetpeer entries are stale,
> > they can't be looked up again. So noone should increment the
> > refcount, they just wait until the refcount get zero.
> > 
> 
> Its not OK, lookups are done under rcu.
> 
> Since there is no RCU grace period, the worker free the entries while
> another cpus are doing their lookups.
> 

Lookups are done under rcu, yes. But a lookup will not find
these stale entries because the whole interpeer tree is removed
from the inetpeer base before the worker is scheduled. A lookup
would have to cerate a new inetpeer entry in this case.
