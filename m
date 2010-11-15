From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Remaining problems in firewire-net
Date: Mon, 15 Nov 2010 06:30:01 +0200
Message-ID: <1289795401.11881.62.camel@maxim-laptop>
References: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


I have unexpected progress on remaining issues in firewire-net in regard
to loss of connection after s2ram cycle, and annoying fact that after
cable replug (intentional of course), it takes time for connection to
reestablish. These are separate issues, and I know the exact cause of
both (and as a side effect I now know exactly how what iso transcations
are and how do they work.)


Problem #1: large delay after cable removal/insert cycle.
The reason is that IP over 1394 abuses ARP packets so that they carry
additional vital information describing the node (namely the bus address
that is used for block address, or as they call it the fifo address).
ARP packets also carry less vital pieces of information namely maximum
transfer size (max_rec) and maximum supported speed of the sender node.

The problem here is that bus reset makes these pieces of information
invalid, and more that that the target node and its fw_peer information
disappear, and reappear but without the above fields set.

The network core is of course unaware of such ugly abuse, and thus it
doesn't send an ARP packet to the destanation. In fact it won't even
send it if destanation node is explicitly addressed. because it appears
in the ARP cache.

The solution here is somehow tell the network core to invalidate the ARP
entry for the target node as soon as it disappears.
Don't yet know how to do that.

Actually to demonstrate this problem its enough to execute 'arpping' and
it will instantly make connection work.

And lastly of course eventually connection establishes because kernel
sends ARP requests periodicity to validate the destination network node.


Problem #2:

As was described in problem #1, its obvious that after suspend to ram,
to reestablish connection we need an ARP reply.
The problem is that it is received via iso channel, and it isn't
reinitialized after s2ram.

A quick and dirty hack  to stop/start the ISO channel from fwnet_update
in firewire-net 'fixes' that problem.

A better solution seemed to make the firewire-ohci reinit all ISO
channels after s2ram cycle. But this is actually wrong.

That is because 1394 spec specifies that first of all the ISO channel
must be allocated from the IRM node. The firewire stack currently just
uses hardcoded numbers in two places the ISO is used 
(firewire-net, and firedtv)
However it has all functions implemented for this.

Secondary that allocation must be redone on each bus reset.
Even more that that, since 1394 spec doesn't define a way to address a
channel to a specific client, that must be done in protocol specific
way.

This means that on each bus reset all drivers that use ISO channels must
allocate them again, and inform underlying hardware they serve.

Therefore the first solution is actually the correct one.

In case of firewire-net, it is simpler, because it uses the broadcast
channel, so it only has to find who is the IRM and read its
BROADCAST_CHANNEL.

However, I think I need to write a function to query the IRM its
broadcast channel, don't think it has one.


Speaking of IRM discovery, the spec says it should be a node with
contender bit and largest node id. However, the code in core-topology.c,
build_tree seems to take the node that sent the selfID packet last.

Best regards,
	Maxim Levitsky


------------------------------------------------------------------------------
Centralized Desktop Delivery: Dell and VMware Reference Architecture
Simplifying enterprise desktop deployment and management using
Dell EqualLogic storage and VMware View: A highly scalable, end-to-end
client virtualization framework. Read more!
http://p.sf.net/sfu/dell-eql-dev2dev
