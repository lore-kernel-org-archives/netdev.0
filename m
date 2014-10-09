From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] af_packet:  Add Doorbell transmit mode to AF_PACKET
 sockets
Date: Thu, 9 Oct 2014 12:05:27 -0400
Message-ID: <20141009160527.GD20940@hmsreliant.think-freely.org>
References: <5435724E.5090507@gmail.com>
 <1412861795-25045-1-git-send-email-nhorman@tuxdriver.com>
 <5436A333.4040507@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Florian Westphal <fw@strlen.de>, gerlitz.or@gmail.com,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com,
	danny.zhou@intel.com, Willem de Bruijn <willemb@google.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50168 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbaJIQFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 12:05:39 -0400
Content-Disposition: inline
In-Reply-To: <5436A333.4040507@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2014 at 08:01:07AM -0700, John Fastabend wrote:
> On 10/09/2014 06:36 AM, Neil Horman wrote:
> > This patch adds a variation to the AF_PACKET memory mapped socket transmit
> > mechanism.  Nominally, when using a memory mapped AF_PACKET socket, frames are
> > written into the memory mapped buffer, and then the application calls sendmsg
> > with a NULL buffer which triggers then cleans the mapped space of all pending
> > buffers.
> > 
> > While this provides clean, synchronous operation, improvements can be made.  To
> > this end, I've introduced a doorbell mode of operation to memory mapped packet
> > sockets. When a packet socket is placed into doorbell mode, it write protects
> > the mappings of any process using the packet socket, so that on the first write
> > to it, a kernel trap is generated, which returns the mapping to a read-write
> > state, and forks a task to begin cleaning the buffers on the applications
> > behalf.  This thread contains some hysterisis to continue running a short while
> > after the last buffer has been cleaned, allowing subsquent wrtites to be sent
> > without needing to fork another task.  This allows for additional parallelism in
> > that an application on an smp system can run in parallel with a cleaning task,
> > so that the socket buffer can be filled and emptied in parallel without having
> > to incur multiple system call traps.
> > 
> > I've only done some very rough performance estimates, but early results are
> > promising.  Using this code here:
> > http://wiki.ipxwarzone.com/index.php5?title=Linux_packet_mmap
> > 
> > I made some modifications to support using doorbell mode and compared the time
> > it took to send 1500 packets (each of size 1492 bytes), in basic mmap and
> > doorbell mmaped mode, and used tcpdump to capture the output.  Results:
> > 
> > trace	packets	start time	end time	delta		p/s	size
> > ndb	1500	2.755605	3.000886	0.245281	6115.43	1492b
> > db	1500	4.716448	4.846382	0.129934	11544.32 1492b
> > 
> > Its very rough of course but it would seem I get a 40% increase in throughput
> > when using this method.  I'm sure thats an overestimate, and so more testing is
> > required, but initial results look good.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > ---
> 
> 
> Thanks Neil, This looks helpful I'll see if I can merge something like this with
> my previous patch. Not likely to have anything by next week though ;)
> 
No worries, I'm on vacation next week anyway :)
Thanks!
Neil

> .John
> 
> 
