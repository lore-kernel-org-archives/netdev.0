From: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Thu, 13 Mar 2014 13:51:17 -0400
Message-ID: <1394733077.32465.243.camel@willson.li.ssimo.org>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
	 <1394657163-7472-3-git-send-email-vgoyal@redhat.com>
	 <5320CAEC.6030008@amacapital.net>
	 <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
	 <1394658983.32465.203.camel@willson.li.ssimo.org>
	 <CALCETrU29CpcK4dVRD45BGOD7AVEudADiFxOgFgKWkpFzw07eg@mail.gmail.com>
	 <1394673476.32465.215.camel@willson.li.ssimo.org>
	 <CALCETrWbCuKfV4zMkZajDOGhGkKduW0C2L7uHv=vtvqhVeAc6w@mail.gmail.com>
	 <1394675038.32465.223.camel@willson.li.ssimo.org>
	 <CALCETrV7GE0YL1sDDqTUV81rWL9zk2vTR1-VLkR7CfTA-FSrgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrV7GE0YL1sDDqTUV81rWL9zk2vTR1-VLkR7CfTA-FSrgw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-12 at 19:12 -0700, Andy Lutomirski wrote:
> On Wed, Mar 12, 2014 at 6:43 PM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Wed, 2014-03-12 at 18:21 -0700, Andy Lutomirski wrote:
> >> On Wed, Mar 12, 2014 at 6:17 PM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >> > On Wed, 2014-03-12 at 14:19 -0700, Andy Lutomirski wrote:
> >> >> On Wed, Mar 12, 2014 at 2:16 PM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >> >>
> >> >> >
> >> >> > Connection time is all we do and can care about.
> >> >>
> >> >> You have not answered why.
> >> >
> >> > We are going to disclose information to the peer based on policy that
> >> > depends on the cgroup the peer is part of. All we care for is who opened
> >> > the connection, if the peer wants to pass on that information after it
> >> > has obtained it there is nothing we can do, so connection time is all we
> >> > really care about.
> >>
> >> Can you give a realistic example?
> >>
> >> I could say that I'd like to disclose information to processes based
> >> on their rlimits at the time they connected, but I don't think that
> >> would carry much weight.
> >
> > We want to be able to show different user's list from SSSD based on the
> > docker container that is asking for it.
> >
> > This works by having libnsss_sss.so from the containerized application
> > connect to an SSSD daemon running on the host or in another container.
> >
> > The only way to distinguish between containers "from the outside" is to
> > lookup the cgroup of the requesting process. It has a unique container
> > ID, and can therefore be mapped to the appropriate policy that will let
> > us decide which 'user domain' to serve to the container.
> >
> 
> I can think of at least three other ways to do this.
> 
> 1. Fix Docker to use user namespaces and use the uid of the requesting
> process via SCM_CREDENTIALS.

This is not practical, I have no control on what UIDs will be used
within a container, and IIRC user namespaces have severe limitations
that may make them unusable in some situations. Forcing the use of user
namespaces on docker to satisfy my use case is not in my power.

> 2. Docker is a container system, so use the "container" (aka
> namespace) APIs.  There are probably several clever things that could
> be done with /proc/<pid>/ns.

pid is racy, if it weren't I would simply go straight
to /proc/<pid>/cgroups ...

> 3. Given that Docker uses network namespaces, I assume that the socket
> connection between the two sssd instances either comes from Docker
> itself or uses socket inodes.  In either case, the same mechanism
> should be usable for authentication.

It is a unix socket, ie bind mounted on the container filesystem, not
sure network namespaces really come into the picture, and I do not know
of a racefree way of knowing what is the namespace of the peer at
connect time.
Is there a SO_PEER_NAMESPACE option ?

Simo.
