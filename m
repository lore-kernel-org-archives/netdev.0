From: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Date: Thu, 18 Jun 2015 18:50:51 -0400
Message-ID: <20150618185051.2b2828c3@tlielax.poochiereds.net>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
	<CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	<20150618154914.57424225@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150618154914.57424225-f9ZlEuEWxVcJvu8Pb33WZ0EMvNT87kid@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Jun 2015 15:49:14 -0400
Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:

> On Thu, 18 Jun 2015 15:24:52 -0400
> Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> wrote:
> 
> > On Wed, Jun 17, 2015 at 11:08 PM, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> > > On Fri, 12 Jun 2015 11:50:38 -0400
> > > Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> > >
> > >> I reverted the following commits:
> > >>
> > >> c627d31ba0696cbd829437af2be2f2dee3546b1e
> > >> 9e2b9f37760e129cee053cc7b6e7288acc2a7134
> > >> caf4ccd4e88cf2795c927834bc488c8321437586
> > >>
> > >> And the issue goes away. That is, I watched the port go from
> > >> ESTABLISHED to TIME_WAIT, and then gone, and theirs no hidden port.
> > >>
> > >> In fact, I watched the port with my portlist.c module, and it
> > >> disappeared there too when it entered the TIME_WAIT state.
> > >>
> > 
> > I've scanned those commits again and again, and I'm not seeing how we
> > could be introducing a socket leak there. The only suspect I can see
> > would be the NFS swap bugs that Jeff fixed a few weeks ago. Are you
> > using NFS swap?
> 
> Not that I'm aware of.
> 
> > 
> > > I've been running v4.0.5 with the above commits reverted for 5 days
> > > now, and there's still no hidden port appearing.
> > >
> > > What's the status on this? Should those commits be reverted or is there
> > > another solution to this bug?
> > >
> > 
> > I'm trying to reproduce, but I've had no luck yet.
> 
> It seems to happen with the connection to my wife's machine, and that
> is where my wife's box connects two directories via nfs:
> 
> This is what's in my wife's /etc/fstab directory
> 
> goliath:/home/upload     /upload         nfs     auto,rw,intr,soft       0 0
> goliath:/home/gallery    /gallery        nfs     auto,ro,intr,soft	 0 0
> 
> And here's what's in my /etc/exports directory
> 
> /home/upload       wife(no_root_squash,no_all_squash,rw,sync,no_subtree_check)
> /home/gallery      192.168.23.0/24(ro,sync,no_subtree_check)
> 
> Attached is my config.
> 

The interesting bit here is that the sockets all seem to connect to port
55201 on the remote host, if I'm reading these traces correctly. What's
listening on that port on the server?

This might give some helpful info:

    $ rpcinfo -p <NFS servername>

Also, what NFS version are you using to mount here? Your fstab entries
suggest that you're using the default version (for whatever distro this
is), but have you (e.g.) set up nfsmount.conf to default to v3 on this
box?

-- 
Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
