From: "Simon Barber" <simon@devicescape.com>
Subject: RE: wireless notes / pre d80211 merge
Date: Tue, 14 Nov 2006 18:10:50 -0800
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0192722C@dhost002-46.dex002.intermedia.net>
References: <20061115011123.0eb1eff6@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>,
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
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:10719 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S966464AbWKOCKb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 21:10:31 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20061115011123.0eb1eff6@logostar.upir.cz>
To: "Jiri Benc" <jbenc@suse.cz>,
	"Johannes Berg" <johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

I disagree that the master device is a hack - I also disagree that we
should use 802.11 format frames anywhere but internally inside the
802.11 stack. The 802.11 specification does not use 802.11 format frames
to communicate with the upper layers - it uses almost exactly the same
interface as 802.3 ethernet does. This is a 2 address interface. I
believe that using the standard 2 address format to talk with upper
layers matches well with the spec and is the right way to do things. If
you put 802.11 frame format directly into the L3 protocols then you make
all these protocols depend on the MAC - since they will now implement
part of the MAC inside the L3 protocol. I don't think this is the right
thing to do. I believe that the mapping of 3 and 4 address frames to a
particular virtual 2 address port is the right way to do this mapping.

It is normal to have a single interface to represent the physical
hardware network interface. This is exactly the pattern that many other
physical network devices use. Things like sniffing should go on on this
physical interface - and the changes that johannes proposes are exactly
the right things to enable this.

I would go further - and perhaps move some of the meta-data that is in
the skb->cb into a d80211 specific hardware header. This would allow
sniffers to directly attach to the master device and both send and
receive frames complete with the meta data. It would also reduce the
amount of cb space we need. Virtual devices could be created in order to
use sniffers that use a different hardware header format (with a small
performance penalty when using those).

Simon
 

-----Original Message-----
From: Jiri Benc [mailto:jbenc@suse.cz] 
Sent: Tuesday, November 14, 2006 6:11 PM
To: Johannes Berg
Cc: netdev; Jeff Garzik; John W. Linville; Simon Barber; Michael Buesch;
Ivo van Doorn; Michael Wu; Jouni Malinen; Daniel Drake; Hong Liu; Luis
R. Rodriguez; James Ketrenos; David Kimdon; Udayan Singh
Subject: Re: wireless notes / pre d80211 merge

On Tue, 14 Nov 2006 23:19:57 +0100, Johannes Berg wrote:
> 1. master netdev
> 
> Currently, we have the 'master' netdev wmasterN which is created as 
> native 802.11 device but is essentially useless. It is exported to 
> userspace but only supports wireless extensions and, depending on what

> the drivers do, ethtool ops. It isn't really useful for network 
> functionality although outgoing frames can be seen on it. See section
> (3) for why.

I wouldn't say "useless". It's actually a hack (and you yourself
described in (7) why it is currently necessary). We'll need to live with
it or cripple the stack to support only very basic features or rewrite
the Linux networking core. Choose your own favorite solution :-)

> [1] why we didn't make a static inline ieee80211_rx() that calls an 
> exported __ieee80211_rx() until we get rid of the other ieee80211 is 
> beyond me. Would have been good but I guess we can also just convert 
> all the drivers when we change the name again.

Yes, it's just temporary and it doesn't matter.

> 3. skb path during tx
> 
> This is more complicated. When a frame is created in one of the 
> virtual interfaces, it first goes through through conversion from 
> 802.3 into 802.11, some tx control is added on and the frame is queued

> to the master netdev. This is why we see outgoing frames in tcpdump.
> 
> After getting queued to the master netdev, the frame goes through the 
> qdiscs and some more info is tacked on into skb->cb by the 802.11
qdisc.
> Afterwards, if the frame is not dropped, it shows up in 
> ieee80211_master_start_xmit where skb->cb is copied onto the stack and

> cleared afterwards. Then, the frame goes through all the tx handlers 
> including fragmentation and encryption and is finally given to the 
> lowlevel driver via the hardware description's tx() call.

During the "tx handlers" phase that "copy of skb->cb" is extended quite
a lot with other information determined in the tx handlers. The result
is a structure that doesn't fit into cb anymore. This is a reason for
not using cb to pass tx information to drivers.

> 4. "wiphy" concept
> 
> Straying a bit from the discussion of frames and similar, let me 
> describe the "wiphy" concept we currently have. Currently, in sysfs we

> have class/ieee80211/phy%d/ and below that a wealth of information not

> only about various hardware related things but also, for example, a 
> list of all stations associated to any virtual access points 
> intermixed with those 'stations' that we are associated to on any
virtual interface.
> Also, we here find 'add_iface' and 'remove_iface', knobs to create and

> destroy virtual interfaces.
> 
> The second wiphy concept is currently present in cfg80211 which 
> currently requires this concept in the userspace interface and should 
> effectively replace the 'add_iface' and 'remove_iface' hooks and make 
> them more generically available for non-d80211 drivers. I was thinking

> of ipw2200 when I wrote it which allows adding a monitor device 
> (currently through some config option I think).

Not a big problem to combine these two "wiphys" into just one.

> 5. so it works, what's wrong?
> 
> Pretty broad question I asked myself here, but let me try to answer it

> anyway.
> 
> For one, I think that having the master device in its current form is 
> useless. It sees outgoing frames that are to be sent to the hardware 
> for transmission, and in that way represents the actual underlying
hardware.
> However, it never sees incoming frames, so there again it doesn't 
> represent the hardware. Not seeing incoming frames makes it useless, 
> and even through it sees outgoing frames you cannot send frames to it.
> 
> Also, if the master netdev is thought of as representing the hardware 
> (which I don't think it fully does), it collides with the notion of 
> the 'wiphy' as described above.

Please note that master interface has been always considered as a hack.
Of course, this perception can be changed if it's desirable.

Personally, I tried to make this interface uninteresting for users as
much as possible - so we can tell ordinary users: "That's just an
annoying internal thing, don't touch it and don't care about it." Of
course, advanced users need to care (because of qdiscs). This is not
optimal (although I'm not sure there exists an optimal solution here)
and I'm not strongly attached to this.

> The master netdev and wiphy create two orthogonal interfaces to 
> userspace that nonetheless pretty much represent the same thing---the 
> underlying hardware.

Yup.

> As said previously, the master netdev represents the hardware when it 
> comes to qdisc manipulation, but the wiphy represents the hardware 
> when it comes to manipulation of virtual interfaces. I believe that 
> this is fundamentally wrong because they both manipulate operation of 
> the underlying hardware.

There is one thing you haven't mentioned and which was probably the key
reason for not believing this concept was wrong: we want to make the
transition to the new stack as smooth to the users as possible. Users
are not used to use the master interface. But since we're going to have
a new set of userspace tools anyway, this point is no longer valid.

> I know I actually strengthened the wiphy concept by adding it to 
> cfg80211, but to my defense at that point I was still pretty sure we 
> would be getting rid of the master device in the future. This seems to

> have been naive, but see below.
> 
> This is my biggest problem with d80211 at the moment. All the internal

> inefficiencies can be cleaned up without any externally visible
impact.

If this is your biggest problem with d80211 you're really happy :-) Try
to fix some locking issue ;-)

> 6. d80211 as a protocol?
> 
> Some proof-of-concept patches I posted converted d80211 to a protocol.

A full conversion to 802.11 protocol should do much more things and is
not possible until we rewrite bridging. You converted the master
interface only. That's not what I would call converting d80211 to a
802.11 protocol.

> This seems quite elegant, but there are a couple of problems with it:
>  - skb->cb is sort of abused, and might be too small in the future. If

This is a blocker issue for me.

>    it becomes too small, we could put a pointer into skb->cb instead
and
>    do lifetime management with an skb desctructor.

Not very effective but will work.

>  - because of the transmit status requirement, skbs need to be 'given
>    back' to d80211
> 
> Problems that have solutions:
>  - the qdiscs can drop fragments of a frame which is useless, hence
>    fragmentation (and consequently also encryption) should probably be
>    moved to the qdisc, need to make sure that the 802.11 qdisc is
>    attached first on the device and can't be removed.

Just for clarification: The problem here is that you need to ensure
fragments are not reordered. This mean you cannot do fragmentation (and
hence encryption) in virtual interfaces, i.e. before you enqueue the
frame into the master interface. Because 802.11 qdisc is the last one
seeing the frame before it reaches a hardware, we can move fragmentation
and encryption there. Actually, we have to do that if we want to convert
master interface to the 802.11 protocol.

> Also something that has been proposed is to add the transmission 
> control information as a header to a newly invented protocol. This 
> seems nice at first, but if d80211 were to be a protocol then it would

> also mean that
> d80211 would have to serialise the internal transmission control 
> structure and the driver deserialise it again. Also, adding new items 
> to the structure becomes impossible (unless the parser we require is
> complicated...)

Doesn't sound like a good solution to me.

> 9. conclusion

As I said when discussing your patch for passing ieee80211_hw to
drivers, I don't much care. I see pros and cons for both ways (the
current one with master interface perceived as a necessary evil, perhaps
even strengthened by passing ieee80211_hw to drivers, or the proposed
one with drivers caring of master netdev). If you feel strongly biased
towards the second one, feel free to send patches (but please not just
one big patch this time :-)).

Thanks,

 Jiri

--
Jiri Benc
SUSE Labs
