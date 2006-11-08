From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Wed, 08 Nov 2006 13:33:14 +0100
Message-ID: <1162989195.7567.23.camel@ux156>
References: <1162741174.24574.22.camel@johannes.berg>
	 <20061106210145.6824bec6@griffin.suse.cz>
	 <1162847394.1412.17.camel@johannes.berg>
	 <20061108125844.46831cda@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48347 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1754565AbWKHMcM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 07:32:12 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061108125844.46831cda@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-08 at 12:58 +0100, Jiri Benc wrote:

> Ok. Personally, I don't care if we pass net_device or ieee80211_local
> to drivers. I see pros and cons of both solutions.

As I said in the other patchset, I'd prefer to not change the API for
these cleanups unless we have to, so dropping this.

> I understand that. But the patch isn't small - it's 71 kiB and I'm
> concerned mainly about David's bitfields conversion patches. So, what
> about this: let's clean up those spaces (and perhaps do more coding
> style cleanups?) after David's patches are merged. Is it feasible for
> you?

Sure.

> Unfortunately, in the current form it's unreviewable for me,

I know that. Actually, I didn't really expect these to be applied. Just
more of a proof-of-concept of how it would look like when converted to a
protocol. And you've proven me wrong with the subif issue already :)

> Individual patches may be laid as follows (take it as a guideline only):
> - introduce IEEE80211_IF_TYPE_MASTER and convert mdev to be of this type
> - get rid of mdev's sdata (you'll probably find out that you need to
>   preserve it at least in some form but let's see)

Nah, I don't see a reason why that couldn't be completely in local. In
fact, the only things we ought to be using the master device for is
sending packets to the driver and attaching the qdisc. Hence, we can
completely layer the virtual interfaces atop it instead of making it a
peer of them in some ways.

I plan to put a magic constant into sub_if_data as the first entry and
assign some magic to it for all the non-master interfaces and make the
DEV_TO_SUBIF macro BUG_ON() magic != correct. That'll help me get rid of
the sdata ;)

> - introduce ieee80211_tx.c and ieee80211_rx.c files (I'll probably NAK
>   such patch for the same reasons as the white space cleanup, though)

I think it's a pain to work on the code if we don't do this.

> - do .h files cleanup (I'd really like to see this)

So far I only did the internal headers... I can redo that patch though.

> What I understand as a "native 802.11 device":
> 1. it uses native 802.11 protocol, ie. no conversions from/to Ethernet
>    frames
> 2. better qdiscs support

Right. That'd be a native 802.11 device. But you haven't specified where
you want it, and that's the key issue.

For starters, I want it on the master device, sort of like we have now
except that it's pretty useless. But you also want the virtual devices
to be native 802.11 devices. These two, however, are completely
orthogonal!

> (1) implies some interesting things:
> a. drivers can call netif_rx directly
> b. tx/rx path cleanup happens, this will lead to solving of some
>    currently hardly solvable issues
> c. overall speedup of the frame processing

Correct, and desperately needed.

> (1) _doesn't_ particularly mean the following things:
> a. requiring drivers to register net_device by themselves (I'd like to
>    preserve the concept of add_interface/remove_interface callbacks)

Why?

> b. setting hard_start_xmit of mdev by drivers instead of using
>    ieee80211_hw->tx callback (but this isn't disallowed either)

Again, you can't at the same time allow removing the mdev and allow
drivers to set the hard_start_xmit call :)

> c. removing of master net_device (again, this is possible to happen)

Yes, but only if you preserve the semantics of having the stack have
full control over the hardware. I've come to think that this is wrong.

> The main goal for me is to make things as easy as possible for driver
> developers. Currently, we're going the way of mixed layer/library
> approach and I really like it. I'm afraid that a pure library way would
> put unnecessary requirements to drivers.

Actually, I was thinking that it would be a lot easier for driver
authors if they could just register their net_device along with some
802.11 help functions (ieee80211_hw) and otherwise behave just like a
real net_dev.

Here's my proposal in text-form instead of code, vaguely listed in order
of the work to do:

 a) we clean up the rx path to get rid of master sub_if, and mostly
    of the master dev as well.
 b) instead of having __ieee80211_rx() we register a packet_type for
    802.11 frames, and a netdevice notifier to see when new devices show
    up

These are the basic items we have to do.

We gain:
 * drivers must now register a proper net_device with 802.11 arphrd,
   and when they receive skbs they simply netif_rx them, we get rid of
   __ieee80211_rx
 * drivers just assign hard_start_xmit
 * drivers fully control their net_device so ethtool things make sense
   again etc.
 * we don't need the notion of a wiphy since like vlan, the
   sta/ap/wds/... devices are logically stacked on top of the driver's
   802.11 device
 * we can get rid of virtual monitor interfaces (the driver's 802.11
   device gets the frames anyway), we do need a few new config options
   to configure hard monitor mode for example.
 * 802.11 finally becomes a proper protocol instead of being a stack

Hey, I think the last point is pretty good. :)

johannes
