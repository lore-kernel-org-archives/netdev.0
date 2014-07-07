From: Loic Prylli <loicp@google.com>
Subject: Re: [PATCH] net: Fix NETDEV_CHANGE notifier usage causing spurious
 arp flush
Date: Mon, 7 Jul 2014 13:34:32 -0700
Message-ID: <20140707203432.GB25441@google.com>
References: <1404275983-7908-1-git-send-email-loicp@google.com>
 <20140702070349.GA11943@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	timo.teras@iki.fi, Jiri Pirko <jiri@resnulli.us>
To: Dan Aloni <dan@kernelim.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140702070349.GA11943@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 02, 2014 at 10:03:49AM +0300, Dan Aloni wrote:
> On Tue, Jul 01, 2014 at 09:39:43PM -0700, Loic Prylli wrote:
> > A bug was introduced in NETDEV_CHANGE notifier sequence causing the
> > arp table to be sometimes spuriously cleared (including manual arp
> > entries marked permanent), upon network link carrier changes.
> > 
> > The changed argument for the notifier was applied only to a single
> > caller of NETDEV_CHANGE, missing among others netdev_state_change().
> > So upon net_carrier events induced by the network, which are
> > triggering a call to netdev_state_change(), arp_netdev_event() would
> > decide whether to clear or not arp cache based on random/junk stack
> > values (a kind of read buffer overflow).
> [..]
> >  {
> >  	if (dev->flags & IFF_UP) {
> > -		call_netdevice_notifiers(NETDEV_CHANGE, dev);
> > +		struct netdev_notifier_change_info change_info;
> > +
> > +		change_info.flags_changed = 0;
> 
> I think it would be safer to do:
> 
>    struct netdev_notifier_change_info change_info = {};
> 
> So that when future fields are added to the struct and this call-site
> happens to be forgotten, they will get 0 by default rather than
> random stack values.

Thanks for the review. Will take into account suggestion. For the
record, another (possibly bigger) trap from the preexisting code that
remains (and caused the bug) is NETDEV_CHANGE being the only netdev
notifier with a different special calling sequence. Since calls to
NETDEV_CHANGE notifier have been reduced over time to the two
instances in net/core/dev.c, it hopefully won't be a problem (and
fixing that maintainability issue would be out-of-scope of this simple
low-risk bug fix).
