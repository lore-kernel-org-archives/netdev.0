From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Wed, 8 Nov 2006 12:58:44 +0100
Message-ID: <20061108125844.46831cda@griffin.suse.cz>
References: <1162741174.24574.22.camel@johannes.berg>
	<20061106210145.6824bec6@griffin.suse.cz>
	<1162847394.1412.17.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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
Received: from styx.suse.cz ([82.119.242.94]:37774 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1754544AbWKHL6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 06:58:47 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1162847394.1412.17.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 06 Nov 2006 22:09:54 +0100, Johannes Berg wrote:
> > What did happen with
> > d80211: add a function to get the wiphy index
> > d80211: add a perm_addr hardware property
> > d80211: add a struct device* hardware property
> > d80211: add a ethtool_ops hardware property
> > patches?
> 
> Well after some chat with a few people I decided that it was stupid and
> not very maintainable to copy all the fields in net_device to a new
> structure.

Ok. Personally, I don't care if we pass net_device or ieee80211_local
to drivers. I see pros and cons of both solutions.

> Oh come off it! It's really stupid to have to check all the tabs/spaces
> all the time. The patch changes 451 lines. And wiggle can handle that
> just fine. Besides, if you do
> s/^\+       /+\t/
> s/^-       /-\t/
> s/        /\t/
> on your patches, they'll be fine too.

I understand that. But the patch isn't small - it's 71 kiB and I'm
concerned mainly about David's bitfields conversion patches. So, what
about this: let's clean up those spaces (and perhaps do more coding
style cleanups?) after David's patches are merged. Is it feasible for
you?

> Yeah. It's pretty bad actually, but I couldn't really find a good way to
> split it into logical chunks.

Unfortunately, in the current form it's unreviewable for me,

Individual patches may be laid as follows (take it as a guideline only):
- introduce IEEE80211_IF_TYPE_MASTER and convert mdev to be of this type
- get rid of mdev's sdata (you'll probably find out that you need to
  preserve it at least in some form but let's see)
- do whatever you feel appropriate with driver's private data (I'm not
  saying I'll be happy with any such solution, though)
- do other changes of memory layout
- remove ieee80211_dev.c and replace it by cfg80211 index
- do some changes to the sysfs layout (again, I'm not promising to be
  happy with it)
- introduce ieee80211_tx.c and ieee80211_rx.c files (I'll probably NAK
  such patch for the same reasons as the white space cleanup, though)
- do .h files cleanup (I'd really like to see this)

> I don't think I understand this. I mean, my patch actually gives us
> native 802.11 devices by making the drivers register those and then
> handling them virtually similar to how 8021q handles ethernet devices. I
> honestly thought that this was the plan for said "native 802.11
> devices".

What I understand as a "native 802.11 device":
1. it uses native 802.11 protocol, ie. no conversions from/to Ethernet
   frames
2. better qdiscs support

(1) implies some interesting things:
a. drivers can call netif_rx directly
b. tx/rx path cleanup happens, this will lead to solving of some
   currently hardly solvable issues
c. overall speedup of the frame processing

(1) _doesn't_ particularly mean the following things:
a. requiring drivers to register net_device by themselves (I'd like to
   preserve the concept of add_interface/remove_interface callbacks)
b. setting hard_start_xmit of mdev by drivers instead of using
   ieee80211_hw->tx callback (but this isn't disallowed either)
c. removing of master net_device (again, this is possible to happen)

The main goal for me is to make things as easy as possible for driver
developers. Currently, we're going the way of mixed layer/library
approach and I really like it. I'm afraid that a pure library way would
put unnecessary requirements to drivers.

Also, please note that making a patch to use native 802.11 protocol is
easy. Actually, I wrote it long time ago (it doesn't apply now and I'd
need to rewrite it completly, but anyway). However, it's not possible to
apply such patch now - the bridging needs to be solved first.

> > > * sysfs layout changed. There is no wiphy or an ieee80211 class any more,
> > >   the attributes that used to be there are now in the net_device that
> > >   the driver registered, and our attributes are below the devices we created.
> > 
> > Doesn't belong to this patch.
> 
> Had to be here initially due to the way I did things, but ok, probably
> changeable.

Sorry, cut&paste error. My comment belonged to:

>  * memory layout. struct ieee80211_local is allocated by itself now.
> 
>  * saner source layout. rx/tx handlers in their own files, one header
>    for each C file that exports things.

But it's valid for the sysfs part as well anyway :-)

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
