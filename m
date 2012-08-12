From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 23:54:57 +0300
Message-ID: <20120812205457.GA14081@redhat.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
 <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
 <87boitz044.fsf@xmission.com>
 <20120805185031.GA18640@redhat.com>
 <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com>
 <20120812102240.GG1421@redhat.com>
 <5027AC88.2020509@mellanox.com>
 <20120812135544.GB6003@redhat.com>
 <5027BA17.6010503@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751871Ab2HLU4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 16:56:12 -0400
Content-Disposition: inline
In-Reply-To: <5027BA17.6010503@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 12, 2012 at 05:13:43PM +0300, Or Gerlitz wrote:
> On 12/08/2012 16:55, Michael S. Tsirkin wrote:
> >I didn't realize you do ARP snooping. Why? I know you mangle
> >outgoing ARP packets,
> 
> Maybe I wasn't accurate/clear, we do mangle outgoing/incoming ARP
> packets, from/to Ethernet ARPs
> to/from IPoIB ARPs.
> 
> 
> >this will go away if you maintain a mapping in SM accessible to
> >all guests.
> 
> guests don't interact with IB, I assume you referred to dom0 code, eIPoIB or
> another driver in the host. But what mapping exactly?

Well we are getting into protocol design here.  So here's a sketch
showing how you could build a protocol that does work.  But note it is
not *exactly* IPoIB. It is I think close enough that you can
use existing NIC hardware/firmware, which is why it
differs slightly from what Eric described, and is
more complex.  But it still shares the same property of no hacks, no
packet snooping in driver, etc.


And if you want to go that route, you really should talk to some IB
protocol people to figure out what works, write a spec and try to
standardize. lkml/netdev is not the right place.

But since you asked, if I had to, I would probably try to
do it like this:

- Each device registers with the SA specifying the
  mac address (+ vlan?), SA stores the translation from that
  to IPoIB address.
- alternatively, SA admin configures the translation statically
- you get a packet with 6 byte mac address,
  query the SA for a mapping to IPoIB address, strip
  ethernet frame and send
- multicast GID addresses can be similar, filled either when registering
  for multicast or by SA admin

I think it's possible that you could also convert a mac address to
EUI-64 and prepend a prefix to get a legal GID. But maybe I'm missing
something.  This could be handy for multicast.


In both cases:
- SA could return GID that you then resolve to
  LID using another query, or it could return LID so you save a roundtrip
- results can be cached locally
- SA can send updates when translation changes to flush this cache


Now above means protocols such as ARP and DHCP use 48 bit addresses so
you can not mix this new protocol with IPoIB.  Maybe IPoIB could simply
ignore irrelevant packets, but it's best not to try, get a
different all-broadcast group and CM ID instead to avoid confusion.

One other interesting thing you can do is forward multicast
registration data from the router, translate to mgid
by the SA and do appropriate IB mcast registrations.

My memory of how IB works is a bit rusty so I probably made some
mistakes above but should roughly work, I think.

> and remember that
> this code (VM through eipoib) can talk to any IPoIB element on the
> fabric, native,
> virtualized,  HW/SW gateways, etc etc.
> 
> Or.

If you want this, then you really want a limited form of IPoIB bridging.

Alternatively, decide that what you do is not IPoIB, have a proper
protocol of your own.

-- 
MST
