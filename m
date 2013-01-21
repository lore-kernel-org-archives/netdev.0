From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill
	device specific ndisc information
Date: Mon, 21 Jan 2013 08:39:57 +0100
Message-ID: <20130121083957.6e2c5a68@stein>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org>
	<50FC6068.3020302@gmail.com> <50FCA825.7070609@linux-ipv6.org>
	<50FCDF5D.3060300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>, linux1394-devel@lists.sourceforge.net,
	Miller <davem@davemloft.net>, David
To: stephan.gatzka@gmail.com
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <50FCDF5D.3060300@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Jan 21 Stephan Gatzka wrote:
> > We could have multiple "net_device"s per single physical
> > interface at the same time, then.
> 
> Of course, but I would avoid it if it's not necessary. What's the 
> problem with introducing a function pointer in struct net_device or 
> struct net_device_ops?

Two net_device instances on one 1394 card would be awkward:  They would
have to share one instance of isochronous reception context (for reception
of asynchronous 1394 streams; those are used for broadcasts and
multicasts).  Such a sharing is surely possible, but if double net_device
instantiation can be avoided, then avoid it.

Not to mention the user interface problem of having two netifs, one which
only supports IPv4 and another one which only supports IPv6.  So far I
never had IPv6 configured into a Linux kernel, but I suppose that folks
are used to be able to use eth0 etc. for both protocols.

> > Multicast is a big issue.  Because IPv6 is fan of
> > multicast, and it uses link-local multicast as its
> > core infrastructure.  Without infrastructure to
> > support it, I'm not going to agree.
> 
> firewire net supports multicast and we use it very often. My patch to 
> support IPv6 does not change it. In fact, because I can communicate via 
> IPv6  between two firewire nodes, multicast _is_ running. The driver 
> does not do lot's of special things with multicast packets. But 
> multicast packets are recognized because they have to be sent somehow 
> different (GASP).

(At the moment we transport multicasts to the same 1394 channel like
broadcasts.

IEEE 1394 supports two addressing modes:  IEEE 1212 based memory-mapable
addresses of the form bus:node:offset = 10 bits + 6 bits + 48 bits for
node-to-node communication, and "channel" = a 6 bit channel number for
communication of 1 node to 0...n nodes.

RFC 2734 broadcasts and multicasts use the channel addressing type.  Hence
max_rec/ sspd/ unicast_FIFO come not into play with broadcasts and
multicasts.  Broadcasts are sent to a fixed known channel number;
multicasts are sent either to the broadcast channel number or to a
separate channel number which is negotiated per multicast group using RFC
2734 Multicast Channel Allocation Protocol.  For the time being the Linux
driver only implements multicasts to the broadcast channel.)
-- 
Stefan Richter
-=====-===-= ---= =-=-=
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Master Visual Studio, SharePoint, SQL, ASP.NET, C# 2012, HTML5, CSS,
MVC, Windows 8 Apps, JavaScript and much more. Keep your skills current
with LearnDevNow - 3,200 step-by-step video tutorials by Microsoft
MVPs and experts. SALE $99.99 this month only -- learn more at:
http://p.sf.net/sfu/learnmore_122412
