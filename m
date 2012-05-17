From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Date: Wed, 16 May 2012 22:37:15 -0700
Message-ID: <20120516223715.5d1b4385.akpm@linux-foundation.org>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com>
	<1336767077-25351-3-git-send-email-glommer@parallels.com>
	<20120516140637.17741df6.akpm@linux-foundation.org>
	<4FB46B4C.3000307@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FB46B4C.3000307-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 17 May 2012 07:06:52 +0400 Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> ...
> >> +	else if (val != RESOURCE_MAX) {
> >> +		/*
> >> +		 * ->activated needs to be written after the static_key update.
> >> +		 *  This is what guarantees that the socket activation function
> >> +		 *  is the last one to run. See sock_update_memcg() for details,
> >> +		 *  and note that we don't mark any socket as belonging to this
> >> +		 *  memcg until that flag is up.
> >> +		 *
> >> +		 *  We need to do this, because static_keys will span multiple
> >> +		 *  sites, but we can't control their order. If we mark a socket
> >> +		 *  as accounted, but the accounting functions are not patched in
> >> +		 *  yet, we'll lose accounting.
> >> +		 *
> >> +		 *  We never race with the readers in sock_update_memcg(), because
> >> +		 *  when this value change, the code to process it is not patched in
> >> +		 *  yet.
> >> +		 */
> >> +		if (!cg_proto->activated) {
> >> +			static_key_slow_inc(&memcg_socket_limit_enabled);
> >> +			cg_proto->activated = true;
> >> +		}
> >
> > If two threads run this code concurrently, they can both see
> > cg_proto->activated==false and they will both run
> > static_key_slow_inc().
> >
> > Hopefully there's some locking somewhere which prevents this, but it is
> > unobvious.  We should comment this, probably at the cg_proto.activated
> > definition site.  Or we should fix the bug ;)
> >
> If that happens, locking in static_key_slow_inc will prevent any damage.
> My previous version had explicit code to prevent that, but we were 
> pointed out that this is already part of the static_key expectations, so 
> that was dropped.

This makes no sense.  If two threads run that code concurrently,
key->enabled gets incremented twice.  Nobody anywhere has a record that
this happened so it cannot be undone.  key->enabled is now in an
unknown state.
