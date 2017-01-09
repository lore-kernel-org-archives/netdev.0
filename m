From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Tue, 10 Jan 2017 00:12:03 +0100
Message-ID: <20170109231203.GC5513@otheros>
References: <1483965843.17582.37.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Braun <michael-dev@fami-braun.de>,
	"David S . Miller" <davem@davemloft.net>, Felix Fietkau <nbd@nbd.name>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1483965843.17582.37.camel@sipsolutions.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 09, 2017 at 10:42:46PM +0100, Johannes Berg wrote:
> On Mon, 2017-01-09 at 22:33 +0100, Linus Lüssing wrote:
> > On Mon, Jan 09, 2017 at 01:44:03PM +0100, Johannes Berg wrote:
> > > 
> > > > >          A host SHOULD silently discard a datagram that is
> > > > > received via
> > > > >          a link-layer broadcast (see Section 2.4) but does not
> > > > > specify
> > > > >          an IP multicast or broadcast destination address.
> > > > 
> > > > This example is the other way round. It specifies how the IP
> > > > destination should look like in case of link-layer broadcast. Not
> > > > how the link-layer destination should look like in case of a
> > > > multicast/broadcast IP destination.
> > > 
> > > You stopped reading too early - snipped the context part for you :)
> > 
> > Sorry for writing to you directly, but I still have some
> > difficulties. In pseudo-code that line says:
> > 
> > -----
> > if ll_dst(pkt) == bcast AND ip_dst(pkt) != mcast/bcast:
> > -> drop(pkt)
> > -----
> > 
> > But after multicast-to-unicast conversion, we have:
> > 
> > -----
> > ll_dst(pkt) == ucast AND ip_dst(pkt) == mcast
> > -----
> > 
> > So none of the two requirements for dropping are matched?
> > 
> 
> Exactly. My point is that this is breaking the expectation that hosts
> are actually able to drop such packets.

[readding CCs I removed earlier]

Ah! Thanks. I was worried about creating packetloss :D.

Hm, for this other other way round, I think it does not apply for
the bridge multicast-to-unicast patch if I'm not misreading the bridge code:

For a packet with a link-layer multicast address but a unicast IP
destination, the bridge MDB lookup will fail.
(http://lxr.free-electrons.com/source/net/bridge/br_multicast.c?v=4.8#L178
 returns NULL)

Case A): No multicast router on port:
-> bridge, br_multicast_flood(), will drop the packet already
   (no matter if multicast-to-unicast is enabled or not)

Case B): Multicast router present on port:
-> The new patch does not apply multicast-to-unicast but just floods
   packet unaltered
   ("else { port = rport; addr = NULL; }" branch)

Regards, Linus
