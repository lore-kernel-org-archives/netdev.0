From: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Subject: MACVLANs really best solution? How about a bridge with multiple
 bridge virtual interfaces? (was Re: [PATCH] macvlan: Support creating
 macvlans from macvlans)
Date: Sat, 7 Mar 2009 21:15:27 +1030
Message-ID: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	shemminger@linux-foundation.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.mail.adnap.net.au ([203.6.132.66]:49854 "EHLO
	smtp2.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560AbZCGOLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 09:11:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ben said,
>I wouldn't deny sending with wrong source mac..ethernet interfaces can 
>do this,
>and mac-vlan should look as much like ethernet is possible.

I agree, however there's further things that mac-vlans aren't
currently doing as virtual ethernet interfaces that real ones do.
Unicast ethernet traffic sent out one mac-vlan interface with a
destination address of another mac-vlan interface on the same host
isn't delivered. mac-vlan interfaces, even though they're conceptually
located on the same ethernet segment, are currently isolated from each
other for unicast traffic.

Thinking about the few scenarios where I've been using mac-vlans, it
seems to me that the fundamental goal of mac-vlans is to be
functionaly equivalent to having multiple physical ethernet network
cards attached to the same LAN segment, with those physical
interfaces attached together via a switch or a hub.

Virtualising that scenario using mac-vlans and a single physical
interface means that the outbound mac-vlan code on a host needs to
replicate the functionality of a switch or a hub. Outbound unicast
traffic from one mac-vlan interface needs to be either seen by the
destination address matching code of all other mac-vlan interfaces (i.e.
replicating hub functionality), or selectively forwarded to the
intended mac-vlan interface (replicating switch functionality). If the
unicast destination doesn't match one of the other mac-vlan interfaces,
then it should be forwarded out the mac-vlan interfaces' parent physical
interface, as the destination is likely to be on the physical ethernet.
Blindly forwarding the outbound mac-vlan origin traffic out the physical
interface doesn't solve the problem - switches (and I'm pretty sure at
least functionaly, hubs) don't forward traffic back out the interface
they receive it on. So the hub/switch forwarding functionality between
mac-vlan interfaces and their parent physical interface needs to happen
within the kernel.

I've been thinking of having a go at adding this functionality. But
then I realised that that would just be more duplication of the
functionality of the code that is aleady in the kernel - the bridging
code. It does all those things already.

It seems to me that the only reason the bridging code can't be used
today for "mac-vlan" functionality is that it only allows creation of a
single bridge virtual interface. If the bridging code and associated
utilities were extended to support multiple virtual interfaces
(possibly with the first interface being the "handle" interface for the
bridge instance), then the mac-vlan code would be redundant.
Conceptually, it'd also be more consistent with some of the other
mechanisms that can be added to a bridge, such as adding tap, dummy or
other virtual interfaces to a bridge in conjunction with multiple bridge
virtual interfaces - a scenario I tried to do a while back and asked
about in December in a post titled, "Is it valid to add a macvlan
virtual interface to a bridge? If so, there seems to be a bug with it."

Using the bridge method wouldn't allow the real physical
interface to be used as a normal e.g. IP interface, as is allowed when
using mac-vlans. But I don't think is much of an issue - another bridge
virtual interface could be created to be used instead.

Regards,
Mark.

(please CC me, as I'm not subscribed, although I do read the list via
gmane. Thanks.)

