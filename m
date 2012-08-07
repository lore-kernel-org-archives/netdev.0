From: Ali Ayoub <ali@mellanox.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Mon, 06 Aug 2012 17:14:24 -0700
Message-ID: <50205DE0.7080706@mellanox.com>
References: <501C3527.6060809@mellanox.com> <20120803.143315.151094375569109262.davem@davemloft.net> <501C5328.4060301@mellanox.com> <20120803.163627.1867181085116225405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, ogerlitz@mellanox.com, roland@kernel.org,
	netdev@vger.kernel.org, sean.hefty@intel.com,
	erezsh@mellanox.co.il, dledford@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mellanox.cgrafx.com ([67.192.191.215]:58231 "EHLO
	mellanox.cgrafx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757009Ab2HGAO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 20:14:27 -0400
In-Reply-To: <20120803.163627.1867181085116225405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/2012 4:36 PM, David Miller wrote:
> From: Ali Ayoub <ali@mellanox.com>
> Date: Fri, 03 Aug 2012 15:39:36 -0700
> 
>> Users would like to use sockets API from the VM without re-writing their
>> applications on top of IB verbs, this driver meant to allow such a user
>> to do so.
> 
> That's what IPoIB was for, the application writers who don't want to have
> to be knowledgable about IB verbs.
> 
> You're messing with the link layer here, and that's what is upsetting me.
> 
> It's a complete cop-out to changing the VM tools and emulators properly to
> handle a new link layer.
> 
> The applications writers already have a way to use IB whilst using
> something familiar, like IPv4, via IPoIB.  You're doing something
> completely different here, and it stinks.

Indeed, IPoIB driver meant to allow IP applications to run over
InfiniBand, but IPoIB cannot serve IPoE traffic.

The goal of eIPoIB driver to show to the user an Ethernet L2 netdev; by
translating IPoE packets to IPoIB. It keeps the same IPoIB wire
protocol, and exposes to the host an ethX interface, all IPoIB packets
are then translated to IPoIB.

Among other things, the main benefit we're targeting is to allow IPoE
traffic within the VM to go through the (Ethernet) vBridge down to the
eIPoIB PIF, and eventually to IPoIB and to the IB network.

In Para virtualized environment, the VM emulator sends/receives packets
with Ethernet header, and the vBridge also performs L2 switching based
on the Ethernet header, in addition to other tools that expect an
Ethernet link layer. We'd like to support them on top of IPoIB.

I see your point to change the the tools and VM emulations to handle
IPoIB link layer, but this involves not only changing many
components/layers such netfront/vbridge/vconfig/etc.. but also -unlike
Ethernet- having IPoIB-aware network device emulation in the VM domain
requires giving access from the VM to the IB Hardware, and this
association will break upon VM migration, as Tsirkin indicated in the
other Email.

Another issue with IPoIB-aware emulator, is that the IPoIB frame doesn't
include the destination link layer per data packet (RFC 4391), therefor
the neighbor address needs to be passed from the VM domain down to the
ipoib-aware vBridge.

I don't see in other alternatives a solution for the problem we're
trying to solve. If there are changes/suggestions to improve eIPoIB
netdev driver to avoid "messing with the link layer" and make it
acceptable, we can discuss and apply them.
