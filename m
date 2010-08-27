From: Roland Dreier <rdreier@cisco.com>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Fri, 27 Aug 2010 09:20:15 -0700
Message-ID: <adaiq2w2fk0.fsf@cisco.com>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca>
	<20100823080543.319143e3@nehalam>
	<alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca>
	<1282672647.2302.15.camel@achroite.uk.solarflarecom.com>
	<alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
	<1282688441.22839.34.camel@localhost> <20100824153920.63360072@s6510>
	<alpine.WNT.2.00.1008251408520.632@cluij.ucs.ualberta.ca>
	<1282823827.2476.663.camel@edumazet-laptop>
	<alpine.WNT.2.00.1008260835020.2008@cluij.ucs.ualberta.ca>
	<20100826165359.3b79b27d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Aurele La France <tsi@ualberta.ca>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola \(ipv6\)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100826165359.3b79b27d@nehalam> (Stephen Hemminger's message of
	"Thu, 26 Aug 2010 16:53:59 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Infiniband device driver needs to be fixed to do SG and checksum offload.
 > Otherwise it is insane to try and run large MTU over it. I even wonder if
 > the dev_change_mtu() function should reject > PAGESIZE mtu for devices
 > that don't do scatter/gather or at least a raise a warning.

It's not possible to "fix" the driver to do checksum offload, since the
underlying hardware does not support it.  Theoretically we could handle
SG but of course there's no point in that without checksum offload.

I think there is some confusion about what IPoIB is in this thread, so
let me try to give some basic background to help the discussion.  There
are two "modes" that an IPoIB interface can operate in: datagram mode
and connected mode.

In datagram mode, packets given to the IPoIB driver are sent as IB
unreliable datagram messages, which means each skb turns into one packet
on the wire -- very much like the ethernet case.  In this mode, the MTU
is limited by the MTU on the IB side, which is typically either 2K or 4K
depending on the adapter and the switches involved.  Modern IB adapters
do support checksum offload and large send offload for datagrams, so we
can and do enable SG and IP_CSUM.

In connected mode, the IPoIB driver actually makes a reliable connection
to each peer.  For reliable connections, IB adapters can actually send
messages up to 4GB, with the adapter handling all the segmentation and
transport level acks etc. -- the host system simply queues one work
request for each message of any size.  These work requests do support
gather/scatter, but no existing adapter supports checksum offload for
messages on reliable connections.

However, since reliable connections support arbitrary sized messages, in
connected mode the IPoIB driver allows an MTU up to roughly the maximum
64K IP message size.  (I don't think anyone has tried it with bigger
IPv6 jumbograms ;)

It does seem even with all the horrible memory allocation problems
caused by requiring huge linear skbs, connected mode does offer very
good performance for at least some real-world uses (although apparently
NFS is not one such use).  In fact as far as I know, connected mode with
a huge MTU continues to outperform datagram mode even with LSO and LRO
(although I don't have any particularly recent numbers).  So I don't
think we want to completely disallow such uses.

 - R.
