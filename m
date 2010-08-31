From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [rfc] Merging the Open vSwitch datapath
Date: Tue, 31 Aug 2010 10:04:09 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F6432E3E@orsmsx508.amr.corp.intel.com>
References: <20100830062755.GA22396@verge.net.au>
 <201008302304.38061.arnd@arndb.de>
 <43F901BD926A4E43B106BF17856F0755F63A0B62@orsmsx508.amr.corp.intel.com>
 <201008311348.55883.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39518 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770Ab0HaREN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 13:04:13 -0400
In-Reply-To: <201008311348.55883.arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Arnd Bergmann [mailto:arnd@arndb.de]
>Sent: Tuesday, August 31, 2010 4:49 AM
>To: Rose, Gregory V
>Cc: Ben Pfaff; netdev@vger.kernel.org; Jesse Gross; Stephen Hemminger;
>Chris Wright; Herbert Xu; David Miller
>Subject: Re: [rfc] Merging the Open vSwitch datapath
>
>On Tuesday 31 August 2010, Rose, Gregory V wrote:
>>
>> I should probably read up a bit more on 802.1ad.
>
>What we need here is an extension of the vlan module to allow
>double tagging with the right ethertype on the outer frame.

Yes.

>
>> >The other parts are configuration protocols like LLDP and CDP, which
>> >we normally do in user space (e.g. lldpad).
>> >
>> >What else is there that you think should go into the kernel.
>>
>> It seems to me that the IFLA_VF_INFO netlink attributes are station
>> oriented.  The kernel support I see there is insufficient for some
>> other things that need to be done for access control, forwarding
>> rules and actions taken on certain kind of packets.  I think there'll
>> be a need to configure the switch itself, not just the stations
>> attached to the switch.
>
>Ok, I'm beginning to understand what you want to do.
>
>1. VEPA using software: use a traditional NIC, and macvtap (or similar)
>   in the hypervisor to separate traffic between the guests, do
>   bridging in an external switch. Works now.
>2. VEPA using hardware: give each guest a VF, configure VFs into VEPA
>   mode. Requires a trivial addition to IFLA_VF_INFO to allow VEPA
>setting
>3. Simple bridge using software: like 1, but forward traffic between
>   some or all macvtap ports. Works now.
>4. Simple bridge using hardware: Like 2, this is what we do today when
>   using VFs.
>5. Full-featured bridge using brctl/ebtables/iptables. This has access
>   to all features of the Linux kernel. Works today, but requires
>management
>   infrastructure (see: Vyatta) that is not present everywhere.
>6. Full-featured bridge in hardware with the features of
>ebtables/iptables.
>   Not going to happen IMHO, see below.
>7. Full-featured distributed bridge using Open vSwitch. This is
>   what the current discussion is about.
>8. Full-featured distributed bridge using Open vSwitch and hardware
>support.

Yep, that about covers it.

;-)

Agree on item # 6.

>I was arguing against 6, which would not even work using the same Open
>vSwitch netlink interface, while I guess what you want is 8.
>
>Now I would not call that "configuring the switch", since the switch in
>this case is basically a daemon running on the host and configuring the
>data path, which has now moved into the hardware from the kernel.

Yeah, the semantics get tricky sometimes but we're on the same page.

>>
>> What if the NIC is the external switch?
>
>I don't think that is going to happen. All embedded switches
>are of the edge (a.k.a. dumb) type right now, and I believe that
>will stay this way.
>By an external switch, I mean something that is running an
>operating system and allows users to log in for configuring
>the switch rules.
>
>> I mean, what if the
>> NIC has an edge virtual bridge embedded in it?  The IFLA_VF_INFO
>> messages are sufficient for many features but there are some that
>> it doesn't address.  And I don't know of any way to get iptables
>> rules down to the VF using existing kernel interfaces.
>
>Exactly! The problem is that I don't think any edge virtual bridge
>can ever implement the full set of features we have in software,
>and for this reason I wouldn't spend too much time in adding a small
>subset of the features.

Not sure I agree there.  I've gotten specific requests for a small number of features that would make an embedded NIC switch useful to some customers.

>
>We probably have a few hundreds features implemented in iptables,
>ebtables and tc, e.g. connection tracking, quality of service
>and filtering. Implementing all these on a NIC is both an enourmous
>(or close to impossible) development task and a security risk,
>unless you are thinking of actually running Linux on the NIC
>to implement them.

No need to implement all of them but there are a small subset of useful rules and associated actions that would be very useful on the embedded switch of an SR-IOV capable NIC.  And these rules and actions would actually promote security from my point of view.  I agree that the embedded NIC switch will never (and should never) attempt to implement all the features a full fledged external switch.  But as things stand now embedded NIC switches are so dumb as to be almost useless for most security conscious virtualized applications.  With the implementation of a small set of rules and associated actions we could make them more useful for a number of our customers.

>
>Anyway, my point was that improvements to the bridging code
>are not directly related to work on EVB, even if we had netfilter
>rules for controlling the integrated bridge in your NIC.
>
>Now, your suggestion to define the Open vSwitch netlink interface
>in a way that works with both hardware bridges as well as the
>kernel code we're discussing does sound great!
>Obviously, there are some nice ways to combine this with the EVB
>protocols, but I can both being useful without the other.

Alright, I'm sort of new to Linux.  Most of my past experience is in the embedded space and is more device oriented so I definitely appreciate getting your perspective on this.  Like many folks I just have product features that I need to make available to customers.  Finding a way to do this that is acceptable to the Linux community and promotes the common welfare (so to speak) is all I'm trying to do here.

>
>> >One idea that we have discussed in the past is to use the macvlan
>> >netlink interface to create ports inside a NIC. This interface
>> >already exists in the kernel, and it allows both bridged and VEPA
>> >interfaces. The main advantage of this is that the kernel can
>> >transparently create ports either using software macvlan or
>> >hardware accelerated functions where available.
>>
>> This actually sounds like a good idea.  I hadn't thought about that.
>> It would cover one of the primary issues I'm dealing with right now.
>
>Ok, cool. Since this is something I've been meaning to work on for
>some time but never got around to, I'll gladly give help and advice
>if you want to work on the implementation. I have access to a number
>of Intel NICs to test things.

Excellent.  I appreciate the offer and will probably take you up on it.

Thanks!

- Greg


