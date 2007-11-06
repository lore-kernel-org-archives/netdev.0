From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache
	incoherent DMA
Date: Tue, 06 Nov 2007 09:01:15 -0800
Message-ID: <47309DDB.6090403@intel.com>
References: <20071102132703.1652446C128@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Milton Miller <miltonm@bga.com>, Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Acker <dacker@roinet.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20071102132703.1652446C128@localhost>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David Acker wrote:
> On the systems that have cache incoherent DMA, including ARM, there is a
> race condition between software allocating a new receive buffer and hardware
> writing into a buffer.  The two race on touching the last Receive Frame
> Descriptor (RFD).  It has its el-bit set and its next link equal to 0.
> When hardware encounters this buffer it attempts to write data to it and
> then update Status Word bits and Actual Count in the RFD.  At the same time
> software may try to clear the el-bit and set the link address to a new buffer.
> 
> Since the entire RFD is once cache-line, the two write operations can collide.
> This can lead to the receive unit stalling or interpreting random memory as
> its receive area.
> 
> The fix is to set the el-bit on and the size to 0 on the next to last buffer
> in the chain.  When the hardware encounters this buffer it stops and does not
> write to it at all.  The hardware issues an RNR interrupt with the receive
> unit in the No Resources state.  Software can write to the tail of the list
> because it knows hardware will stop on the previous descriptor that was
> marked as the end of list.
> 
> Once it has a new next to last buffer prepared, it can clear the el-bit and
> set the size on the previous one.  The race on this buffer is safe since
> the link already points to a valid next buffer and the software can handle
> the race setting the size (assuming aligned 16 bit writes are atomic with
> respect to the DMA read). If the hardware sees the el-bit cleared without
> the size set, it will move on to the next buffer and skip this one.  If it
> sees the size set but the el-bit still set, it will complete that buffer
> and then RNR interrupt and wait.
> 
> 
> This is a patch for 2.6.24-rc1.
> 
> Signed-off-by: David Acker <dacker@roinet.com>


OK, there are still a few small tests running but I think it's good. It ran over
the weekend in various tests and we didn't see any receive unit hangs, which we
would have spotted by now. That means that the patch as far as I can assess is
good to go and I will send it to Jeff later on.

There is a minute impact to small packet receive performance. the driver uses
about 0.5% more CPU at 64byte packets wire speed but it's still in the 3% total
range, so I think we're fine there.

Thanks for all the work David!

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
