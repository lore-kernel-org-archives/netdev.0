From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Thu, 24 Apr 2014 16:34:27 -0400
Message-ID: <20140424203427.GC19091@redhat.com>
References: <20140416002010.GA5035@redhat.com>
 <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140423164537.GD24651@redhat.com>
 <20140423.132955.671992126955940387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140423.132955.671992126955940387.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 23, 2014 at 01:29:55PM -0400, David Miller wrote:
> From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Wed, 23 Apr 2014 12:45:37 -0400
> 
> > On Tue, Apr 15, 2014 at 08:47:54PM -0700, Andy Lutomirski wrote:
> > 
> > [..]
> >> Here's an attack against SO_PASSCGROUP, as you implemented it: connect
> >> a socket and get someone else to write(2) to it.  This isn't very
> >> hard.  Now you've impersonated.
> > 
> > If this is a problem then I think kernel requires fixing. Because kernel
> > will apply all resource management policies based on the cgroup at write(2)
> > time and not based on open() time.
> 
> Anyways, this is not even worth discussing.
> 
> We already agreed that the cgroup passed at write time with SO_PASSGROUP
> enabled should be the socket creation time cgroup.
> 
> Just like SO_PASSCRED does.
> 
> The identity given is thus the one at open() time.

Hi Dave,

I am not sure about few things. So I will ask.

By open() time you mean at socket() time or at connect() time? I guess
you mean connect() time as at socket() time there are no access control
checks and even if socket fd is passed around, it does not matter. So
connect() seems to be more close to open() as opposed to socket().

You also mentioned that you want SO_PEERCGROUP and SO_PASSCGROUP as pairs
like SO_PEERCRED and SO_PASSCRED. But to me, SO_PEERCRED and SO_PASSCRED
are not *exact* pairs and are little different in their semantics.
SO_PEERCRED gives us client creds at connect() time while SO_PASSCRED
client's real creds at sendmsg() time. SO_PASSCRED does not store client's
credential's at connect() time for datagram sockets.

So which semantics are we looking for. If we are looking for same
semantics as PEERCRED/PASSCRED, then I think my patches are already
there and don't need modifications.

But if we are looking for deviation SO_PASSCRED and store and pass
sender's cgroup info retrieved at connect() time, then that requires
rework of patches.
 
W.r.t privilige escalation by tricking setuid program to write to a 
descriptor, I don't think my patches are susceptible to that. setuid
programs don't change cgroups themselves, so even if caller tricks setuid
to write to an fd, receiver will still receive same cgroup info.

If caller launches setuid program in a different cgroup (using cgexec or some
other program), that means caller has the privilige to get into that
cgroup and there is no magic privilige escalation here because caller
has the permission to go in destination cgroup. IOW, caller can not
force/trick setuid program to run in a cgroup where caller does not
have permission to run itself.

Only caveat to this theory is what happens if setuid program changes
cgroup at his own. As we don't have any notion of real/effective cgroups,
I guess there needs to be a restriction on setuid programs to not change
cgroups at their own.

So which semantics you are looking for. Same as current SO_PASSCRED or
freeze cgroup info at connect() time and pass that info.

Thanks
Vivek
