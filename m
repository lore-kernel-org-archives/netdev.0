From: "David S. Miller" <davem@davemloft.net>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Fri, 21 Jan 2005 20:49:48 -0800
Message-ID: <20050121204948.034b2510.davem@davemloft.net>
References: <41F1516D.5010101@hp.com>
	<200501211358.53783.jdmason@us.ibm.com>
	<41F163AD.5070400@hp.com>
	<20050121124441.76cbbfb9.davem@davemloft.net>
	<41F17B7E.2020002@hp.com>
	<20050121141820.7d59a2d1.davem@davemloft.net>
	<41F186A8.9030805@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <41F186A8.9030805@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Jan 2005 14:48:08 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> Indeed, it seems that one would want to decide about TSO when one is about to 
> transmit, not when the user does a send since otherwise, you penalize users 
> doing larger sends.  Someone doing say a sendfile() of a large file would be 
> pretty much precluded from getting benefit from TSO the way things are now right?

Not really, if the file is larger than the send buffer limit, we'll
have a large enough cwnd once the later packets get built.

The cwnd is sampled when we build packets onto the send queue.
Each socket has a send buffer limit on that, so we only build
until we reach that limit.

At user sendmsg/sendfile time is when we do the segmentation and thus
the packet sizing, because it is the most logical place to do this.

The code can potentially get really messy and ugly if we start
preemptively building larger frames "hoping" the cwnd will be
large enough by the time we push it onto the wire.  Segmenting
at send time is completely upside down to the way packets are
built currently for transmission.  A bad guess also means that
we'll spend significant cycles chopping up TSO packets and
resegmenting the queue.
