From: Jiri Benc <jbenc@suse.cz>
Subject: Re: wireless notes / pre d80211 merge
Date: Wed, 15 Nov 2006 10:43:59 +0100
Message-ID: <20061115104359.3ce80e3b@griffin.suse.cz>
References: <20061115011123.0eb1eff6@logostar.upir.cz>
	<C86180A8C204554D8A3323D8F6B0A29F0192722C@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"netdev" <netdev@vger.kernel.org>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Michael Buesch" <mbuesch@freenet.de>,
	"Ivo van Doorn" <ivdoorn@gmail.com>,
	"Michael Wu" <flamingice@sourmilk.net>,
	"Jouni Malinen" <jkm@devicescape.com>,
	"Daniel Drake" <dsd@gentoo.org>, "Hong Liu" <hong.liu@intel.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	"James Ketrenos" <jketreno@linux.intel.com>,
	"David Kimdon" <dwhedon@devicescape.com>,
	"Udayan Singh" <udayan.singh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:11923 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932836AbWKOJoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 04:44:05 -0500
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0192722C@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Nov 2006 18:10:50 -0800, Simon Barber wrote:
> I disagree that the master device is a hack

It's a clever hack but still a hack. The Linux network interfaces
wasn't designed for the sort of things we do with master interface.
Actually, the networking core doesn't support the concept of "wiphys"
at all. Yes, Jouni found a really clever way around this. But the most
correct solution is different.

In particular:
- The operations that make sense for user to perform on wiphy/master
  interface are different than the ones on virtual interfaces. It isn't
  this way now.
- Why should master interface appear in ifconfig and similar tools the
  same way as "virtual" interfaces? If you want to know how users are
  confused by this, just search some forums.
- Does attaching of qdiscs to virtual interfaces make sense?
- Etc.

To me, the master interface in its current shape is a nice workaround
of kernel limitations, but still not a clean solution.

> I also disagree that we
> should use 802.11 format frames anywhere but internally inside the
> 802.11 stack. The 802.11 specification does not use 802.11 format frames
> to communicate with the upper layers - it uses almost exactly the same
> interface as 802.3 ethernet does. This is a 2 address interface. I
> believe that using the standard 2 address format to talk with upper
> layers matches well with the spec and is the right way to do things.

This is a different thing. See the difference between SOCK_RAW and
SOCK_DGRAM. The interface you are talking about is SOCK_DGRAM. Except
it supports only one address. The correct solution would be extending
sockaddr_ll (that's not possible, I know) or introduce a new
SOCK_SOMETHING type (not possible either, at least in a short term).

> If
> you put 802.11 frame format directly into the L3 protocols then you make
> all these protocols depend on the MAC - since they will now implement
> part of the MAC inside the L3 protocol. I don't think this is the right
> thing to do. I believe that the mapping of 3 and 4 address frames to a
> particular virtual 2 address port is the right way to do this mapping.

For some kind of applications SOCK_RAW on 802.11 interfaces makes
sense. (Actually, that's not so simple as they need to specify other
things like tx rate but that's an another story.)

> It is normal to have a single interface to represent the physical
> hardware network interface.

Except that all other hardware doesn't need things that we need. They
need just one virtual interface - so their master and virtual interface
is merged. This is net_device. We need to split it into two things.

> This is exactly the pattern that many other
> physical network devices use. Things like sniffing should go on on this
> physical interface - and the changes that johannes proposes are exactly
> the right things to enable this.
> 
> I would go further - and perhaps move some of the meta-data that is in
> the skb->cb into a d80211 specific hardware header. This would allow
> sniffers to directly attach to the master device and both send and
> receive frames complete with the meta data. It would also reduce the
> amount of cb space we need. Virtual devices could be created in order to
> use sniffers that use a different hardware header format (with a small
> performance penalty when using those).

This seems as a really bad solution to me. I fully agree with Johannes
regarding this.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
