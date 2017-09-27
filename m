From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 0/3] Check user supplied interface name lengths
Date: Wed, 27 Sep 2017 18:05:28 +0200
Message-ID: <20170927160528.GN32305@orbyte.nwl.cc>
References: <20170926163548.24347-1-phil@nwl.cc>
 <20170927084249.0591ee3a@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60904 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752494AbdI0QFa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 12:05:30 -0400
Content-Disposition: inline
In-Reply-To: <20170927084249.0591ee3a@shemminger-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 08:42:49AM +0100, Stephen Hemminger wrote:
> On Tue, 26 Sep 2017 18:35:45 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > This series adds explicit checks for user-supplied interface names to
> > make sure their length fits Linux's requirements.
> > 
> > The first two patches simplify interface name parsing in some places -
> > these are side-effects of working on the actual implementation provided
> > in patch three.
> > 
> > Changes since v1:
> > - Patches 1 and 2 introduced.
> > - Changes to patch 3 are listed in there.
> > 
> > Phil Sutter (3):
> >   ip{6,}tunnel: Avoid copying user-supplied interface name around
> >   tc: flower: No need to cache indev arg
> >   Check user supplied interface name lengths
> > 
> >  include/utils.h |  1 +
> >  ip/ip6tunnel.c  |  9 +++++----
> >  ip/ipl2tp.c     |  3 ++-
> >  ip/iplink.c     | 27 ++++++++-------------------
> >  ip/ipmaddr.c    |  1 +
> >  ip/iprule.c     |  4 ++++
> >  ip/iptunnel.c   | 27 +++++++++++++--------------
> >  ip/iptuntap.c   |  4 +++-
> >  lib/utils.c     | 10 ++++++++++
> >  misc/arpd.c     |  1 +
> >  tc/f_flower.c   |  6 ++----
> >  11 files changed, 50 insertions(+), 43 deletions(-)
> > 
> 
> I like the idea, and checking arguments is good.

Cool!

> Why not merge the check and copy and put in lib/utils.c
> 
> int get_ifname(char *name, const char *arg)
> {
> ...

What do you have in mind exactly? There are basically three situations
to which check_ifname() is added:

1) Simple pointer caching:

   | check_ifname("name", *argv);
   | name = *argv;

2) Value caching:

   | check_ifname("name", *argv);
   | strncpy(name, *argv, IFNAMSIZ);

3) Direct netlink attribute creation:

   | check_ifname("name", *argv);
   | addattr_l(&req.n, sizeof(req), IFNAME, *argv, strlen(*argv) + 1);

To cover them all, I could introduce the following:

| char *check_ifname(const char *name, const char *argv)
| {
| 	/* check *arg, call invarg() if invalid */
| 	return *argv;
| }
| 
| void copy_ifname(char *dst, const char *name, const char *argv)
| {
| 	strncpy(dst, check_ifname(name, argv), IFNAMSIZ);
| }
| 
| void addattr_ifname(struct nlmsghdr *n, int maxlen, int type,
| 		    const char *name, const char *argv)
| {
| 	addattr_l(n, maxlen, type, check_ifname(name, argv),
| 		  strlen(*argv) + 1);
| }

What do you think?

Cheers, Phil
