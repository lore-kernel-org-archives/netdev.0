From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 and 802.1ad/stacked vlan tagging
Date: Tue, 29 Aug 2006 22:06:06 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F528A67FB@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <e1000-devel@lists.sf.net>, <netdev@vger.kernel.org>, <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2074 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S965012AbWH3FGQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 01:06:16 -0400
Content-class: urn:content-classes:message
To: "Stephan von Krawczynski" <skraw@ithnet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephan von Krawczynski wrote:
> I can confirm that the setup seems to work if enlarging the hw if mtu
> to 1508. This is good.

Okay, good to hear.

> Nevertheless I think that the receive buffer size of a
> physical device should always be MAX(all virtual device mtu +
> tags and the like), you know what I mean.

Unfortunately that would require us to currently allocate 16kB for every
receive descriptor, which would slow down the general case
significantly, not to mention bring up all sorts of errors as the system
memory fragmentation increases.

> If I enlarge the basic mtu this may or may not have drawbacks
> concerning the traffic routed directly via this interface.

I think that routed traffic won't care at all unless something checks
the path MTU, and even then it should take the lowest MTU.

> Obviously the setup is somehow not consistent, as everything
> works well without tuning mtus as long as you use only 1 tag.
1 tag is the way that things are supposed to work.  In fact, the
hardware takes care of all insertion and stripping of a single tag, so
that the data actually handed to the stack never even has the tag in the
packet data.

> I always thought that the driver uses at least
> hard_header_len + mtu as buffer size which should be correct
> even in stacked setup. Only this information doesn't make it
> to the driver level, right?

Actually I think that first statement isn't correct.  With the stacked
setup your maximum frame length is 1500 (MTU) + 14 enet + 4 (tag1) + 4
(tag2) + CRC = 1526.  The vlan code with stacked vlans is broken (from
the maintainer who mentioned it in this thread) probably because in
order to do stacked vlans correctly the vlan layer must support IP
fragmentation of some kind.

Seems like stacked vlans wouldn't work anyway, at least not very well.
The only way I see to get even close is the MTU increase on the base
interface.

Sorry to not offer much,
  Jesse
