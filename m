From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [Question] Should `CAP_NET_ADMIN` be needed when opening
 `/dev/ppp`?
Date: Tue, 3 May 2016 15:40:49 +0200
Message-ID: <20160503134049.GA1289@alphalink.fr>
References: <2BEB0C68-EBC6-4A8F-A751-DE8F4A2C9D2C@gmail.com>
 <20160503101240.GA1304@alphalink.fr>
 <CAFLxGvyKMbJyfk5oiRZ6-67yHH=f+3mkY=gd3AsZC1G_o0Xhxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Shanker <shankerwangmiao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Richard Weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:37319 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755979AbcECNk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 09:40:59 -0400
Content-Disposition: inline
In-Reply-To: <CAFLxGvyKMbJyfk5oiRZ6-67yHH=f+3mkY=gd3AsZC1G_o0Xhxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 03, 2016 at 12:35:12PM +0200, Richard Weinberger wrote:
> On Tue, May 3, 2016 at 12:12 PM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> > On Sun, May 01, 2016 at 09:38:57PM +0800, Wang Shanker wrote:
> >> static int ppp_open(struct inode *inode, struct file *file)
> >> {
> >>       /*
> >>        * This could (should?) be enforced by the permissions on /dev/ppp.
> >>        */
> >>       if (!capable(CAP_NET_ADMIN))
> >>               return -EPERM;
> >>       return 0;
> >> }
> >> ```
> >>
> >> I wonder why CAP_NET_ADMIN is needed here, rather than leaving it to the
> >> permission of the device node. If there is no need, I suggest that the
> >> CAP_NET_ADMIN check be removed.
> >>
> > If this test was removed here, then it'd have to be added again in the
> > PPPIOCNEWUNIT ioctl, at the very least, because creating a netdevice
> > should require CAP_NET_ADMIN. Therefore that wouldn't help for your
> > case.
> > I don't know why the test was placed in ppp_open() in the first place,
> > but changing it now would have side effects on user space. So I'd
> > rather leave the code as is.
> 
> I think the question is whether we really require having CAP_NET_ADMIN
> in the initial namespace and not just in the current one.
> Is ppp not network namespace aware?
> 
Indeed, I overlooked the namespace aspect of the problem. PPP is netns
aware, but ioctls performed on /dev/ppp file descriptors are all
serialised with ppp_mutex. A user could therefore affect other PPP
users by artificially creating contention on the ppp_mutex lock.

Other than that, I agree it'd make sense to test for user capabilies in
the current namespace rather than in the initial one.
