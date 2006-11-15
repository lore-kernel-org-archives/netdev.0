From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless notes / pre d80211 merge
Date: Wed, 15 Nov 2006 10:16:18 +0100
Message-ID: <1163582178.2705.16.camel@ux156>
References: <1163542797.5399.106.camel@johannes.berg>
	 <20061115011123.0eb1eff6@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Daniel Drake <dsd@gentoo.org>, Hong Liu <hong.liu@intel.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Udayan Singh <udayan.singh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:64214 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966712AbWKOJPS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 04:15:18 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061115011123.0eb1eff6@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-15 at 01:11 +0100, Jiri Benc wrote:

> I wouldn't say "useless". It's actually a hack (and you yourself described
> in (7) why it is currently necessary). We'll need to live with it or
> cripple the stack to support only very basic features or rewrite the Linux
> networking core. Choose your own favorite solution :-)

I'd be fine with living with what you think of as a "hack" for a while
if the medium- to long-term plan is to rewrite the networking core to
get rid of it. I'm just not sure it makes sense.

> During the "tx handlers" phase that "copy of skb->cb" is extended quite a
> lot with other information determined in the tx handlers. The result is a
> structure that doesn't fit into cb anymore. This is a reason for not using
> cb to pass tx information to drivers.

Actually, no, it isn't :) The part that is passed to drivers does fit,
only the internal stuff doesn't.

> > Straying a bit from the discussion of frames and similar, let me
> > describe the "wiphy" concept we currently have. Currently, in sysfs we
> > have class/ieee80211/phy%d/ and below that a wealth of information not
> > only about various hardware related things but also, for example, a list
> > of all stations associated to any virtual access points intermixed with
> > those 'stations' that we are associated to on any virtual interface.
> > Also, we here find 'add_iface' and 'remove_iface', knobs to create and
> > destroy virtual interfaces.
> > 
> > The second wiphy concept is currently present in cfg80211 which
> > currently requires this concept in the userspace interface and should
> > effectively replace the 'add_iface' and 'remove_iface' hooks and make
> > them more generically available for non-d80211 drivers. I was thinking
> > of ipw2200 when I wrote it which allows adding a monitor device
> > (currently through some config option I think).
> 
> Not a big problem to combine these two "wiphys" into just one.

Right, that's no biggie. I was just trying to describe what we currently
have an forgot to mention it.

> Please note that master interface has been always considered as a hack. Of
> course, this perception can be changed if it's desirable.

Has it? Simon seems to disagree ;)

> > The master netdev and wiphy create two orthogonal interfaces to
> > userspace that nonetheless pretty much represent the same thing---the
> > underlying hardware.
> 
> Yup.

You just say it like that. Aren't you unhappy about that at all?

> There is one thing you haven't mentioned and which was probably the key
> reason for not believing this concept was wrong: we want to make the
> transition to the new stack as smooth to the users as possible. Users are
> not used to use the master interface. But since we're going to have a new
> set of userspace tools anyway, this point is no longer valid.

No, wait! We're transitioning from something that only supports one
interface to something that supports many virtual ones. As long as we
can represent the semantics of the previous single one as the default
virtual one, we're fine. Which is actually very possible and cfg80211's
WE compat code tries to show that.

I don't think the master interface matters here at all. It's just an
additional netdev that users previously didn't have, but so what?

> If this is your biggest problem with d80211 you're really happy :-) Try to
> fix some locking issue ;-)

Let me qualify to externally visible problems :)
I'm not too concerned about the internal stuff. That can be cleaned up
with some effort, but the externally visible stuff can't actually just
be cleaned up without thought and a plan.

> A full conversion to 802.11 protocol should do much more things and is not
> possible until we rewrite bridging. You converted the master interface
> only. That's not what I would call converting d80211 to a 802.11 protocol.

I've said this before but let me repeat.

There are two ends to d80211

top:    virtual interfaces, most likely 802.3 for at least a while if
        not forever
bottom: communication with hardware, qdiscs, etc.

I've never wanted to change the top part (so far anyway :) ). It's
orthogonal. And whether d80211 behaves as an 802.11 protocol is
something that's visible only in the RX path really, struct packet_type
and associated things.

> > This seems quite elegant, but there are a couple of problems with it:
> >  - skb->cb is sort of abused, and might be too small in the future. If
> 
> This is a blocker issue for me.
> 
> >    it becomes too small, we could put a pointer into skb->cb instead and
> >    do lifetime management with an skb desctructor.
> 
> Not very effective but will work.

Not really less effective than copying it around all the time as we do
now and then kmalloc()ing it in some circumstances.

johannes
