From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100
	rx: or s and el bits)
Date: Tue, 5 Jun 2007 11:14:29 -0500
Message-ID: <b2809ae38545c6104771af3c3a8b2250@bga.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net>
	<46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com>
	<463BA906.30205@roinet.com>
	<85f07fc58d5ed2147d5214d0f0b4fe32@bga.com>
	<4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com>
	<464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com>
	<464DB619.3070900@roinet.com> <464DC676.90504@intel.com>
	<464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com>
	<464DDE3E.9010400@roinet.com>
	<e3819b7a866b1117fd5a69e6a85e0784@bga.com>
	<4651DAC1.7050604@intel.com>
	<53c44b6f03973eb1b28f221859d3002c@bga.com>
	<465369AF.8080508@roinet.com>
	<f83441453b1233771c5bda869912aeca@bga.com>
	<4654B2E4.9010308@roinet.com>
	<039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com>
	<a4fae96e1c8c7b594207bf77fcb6b38f@bga.com>
	<465C4DBE.6000205@roinet.com>
	<94c8ff9069a77568513a9a1d1e60012d@bga.com>
	<4660856E.80403@roinet.com>
	<fac4512e243d821a94e8ee7304240981@bga.com>
	<4665664D.30906@roinet.com>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: David Acker <dacker@roinet.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4665664D.30906@roinet.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


First, a question especially to Auke and Jeff:

Since this patch both reverts the broken change that is currently in 
-rc and creates the fixed driver, I'm not sure I like the subject 
stating "on ARM", although that is the feature of the rewrite, and was 
the intent of merging the previous patch.  This is actually its a fix 
for all systems relative to current, including those where dma is not 
cache coherent, (unlike a simple revert).

Should we just put a comment about reverting the previous patch early 
in the change log?

Something like this:

Fix the e100 receiver handling, supporting cache incoherent DMA.

Discard the concept of setting the S (suspend) bit with the EL bit 
introduced in commit d52df4a35af569071fda3f4eb08e47cc7023f094.  In 
addition to it not setting either bit, the hardware doesn't work that 
way.


Thoughts?



Here is the changelog portion of the latest patch (quoted), with my 
comments thrown in:


> On the ARM, their is a race condition between software allocating a 
> new receive

On systems that have cache incoherent DMA, including ARM,

> buffer and hardware writing into a buffer.  The two race on touching 
> the last
> Receive Frame Descriptor (RFD).  It has its el-bit set and its next 
> link equal
> to 0.  When hardware encounters this buffer it attempts to write data 
> to it
> and then update Status Word bits and Actual Count in the RFD.  At the 
> same time
> software may try to clear the el-bit and set the link address to a new 
> buffer.
> Since the entire RFD is once cache-line, the two write operations can
> collide.  This can lead to the receive unit stalling or freed receive 
> buffers
> getting written to.

This can lead to the receive unit stalling or interpreting random 
memory as its receive area.

>
> The fix is to set the el-bit on and the size to 0 on the next to last 
> buffer
> in the chain.  When the hardware encounters this buffer it stops and 
> does
> not write to it at all.  The hardware issues an RNR interrupt with the
> receive unit in the No Resources state.  When software allocates 
> buffers,
> it can update the tail of the list when either it knows the hardware
> has stopped or the previous to the new one to mark marked.

Software can write to the tail of the list because it knows hardware 
will stop on the previous descriptor that was marked as the end of 
list.

> Once it has a new next to last buffer prepared, it can clear the el-bit
> and set the size on the previous one.  The race on this buffer is safe
> since the link already points to a valid next buffer.

and we can handle the race setting the size (assuming aligned 16 bit 
writes are atomic with respect to the DMA read).


This paragraph changed from third person (the software or hardware) to 
second person (we).

>   We keep flags
> in our software descriptor to note if the el bit is set and if the size
> was 0.  When we clear the RFD's el bit and set its size, we also clear
> the el flag but we leave the size was 0 bit set.  This was we can find
> this buffer again later.

This way software can identify them when the race may have occurred 
when cleaning the ring.  On these descriptors, it looks ahead and if 
the next one is complete then hardware must have skipped the current 
one.  Logic is added to prevent two packets in a row being marked while 
the receiver is running to avoid running in lockstep with the hardware 
and thereby limiting the required lookahead.

> If the hardware sees the el-bit cleared without the size set, it will
> move on to the next buffer and skip this one.  If it sees
> the size set but the el-bit still set, it will complete that buffer
> and then RNR interrupt and wait.

These sentences should be moved to the mention of the race above to 
reducing mixing descriptions of the hardware and the software.


milton


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
