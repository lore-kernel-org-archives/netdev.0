From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100
 rx: or s and el bits)
Date: Fri, 01 Jun 2007 17:13:34 -0400
Message-ID: <46608BFE.7000905@pobox.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Milton Miller <miltonm@bga.com>, Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Acker <dacker@roinet.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4660856E.80403@roinet.com>
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

David Acker wrote:
> Milton Miller wrote:
>> Your logic works, this adds some conditional branching but saves a 
>> pointer, not sure which is better.  Mine can be used for initializing 
>> without special casing since it will just calculate rx_to_unmark as 
>> rx[n-2] and rx_to_mark as rx[n-2] != rx[n-2]->prev; unmarking a never 
>> marked still works, where as for yours the "was marked" must be 
>> explicitly set to something (hmm, rxs = rx[0] might work for that 
>> initial value until we mark -2??)
>>
>> again, the compare of rx->el instead of rx->rfd->el is to save cache 
>> traffic to the rfd under io.  The rx->was_0 is required, so the el 
>> flag is free.
>>
> 
> Ok, I took a stab at coding and testing these ideas.  Below is a patch 
> against 2.6.22-rc3.
> Let me know what you think.  Testing shows that we can hit any of the 
> following scenarios:
> 
> Find a buffer not complete with rx->el and rx->s0 set. I read back the 
> status and see if
> the receiver is still running.
> Find a buffer not complete with rx->el not set and rx->s0 set.  I check 
> the next buffer
> and if it is complete, I free the skb and return 0.  If the next buffer 
> is not
> complete, I read the receiver's status to see if he is still running.
> Find a buffer that is complete with rx->el not set and rx->s0 set.  It 
> appears that hardware
> can read the rfd's el-bit, then software can clear the rfd el-bit and 
> set the rfd size, and
> then hardware can come in and read the size.  I am reading the status 
> back, although
> I don't think that I have to in this instance.
> 
> I am testing a version of this code patched against 2.6.18.4 on my PXA 
> 255 based system.  I will let you all know how it goes.
> 
> On the ARM, their is a race condition between software allocating a new 
> receive
> buffer and hardware writing into a buffer.  The two race on touching the 
> last
> Receive Frame Descriptor (RFD).  It has its el-bit set and its next link 
> equal
> to 0.  When hardware encounters this buffer it attempts to write data to it
> and then update Status Word bits and Actual Count in the RFD.  At the 
> same time
> software may try to clear the el-bit and set the link address to a new 
> buffer.
> Since the entire RFD is once cache-line, the two write operations can
> collide.  This can lead to the receive unit stalling or freed receive 
> buffers
> getting written to.
> 
> The fix is to set the el-bit on and the size to 0 on the next to last 
> buffer
> in the chain.  When the hardware encounters this buffer it stops and does
> not write to it at all.  The hardware issues an RNR interrupt with the
> receive unit in the No Resources state.  When software allocates buffers,
> it can update the tail of the list when either it knows the hardware
> has stopped or the previous to the new one to mark marked.
> Once it has a new next to last buffer prepared, it can clear the el-bit
> and set the size on the previous one.  The race on this buffer is safe
> since the link already points to a valid next buffer.  We keep flags
> in our software descriptor to note if the el bit is set and if the size
> was 0.  When we clear the RFD's el bit and set its size, we also clear
> the el flag but we leave the size was 0 bit set.  This was we can find
> this buffer again later.
> 
> If the hardware sees the el-bit cleared without the size set, it will
> move on to the next buffer and skip this one.  If it sees
> the size set but the el-bit still set, it will complete that buffer
> and then RNR interrupt and wait.
> 
> 
> Signed-off-by: David Acker <dacker@roinet.com>

That seems to vaguely match my memory of what eepro100 was doing (or 
trying to do).

I _really_ appreciate you working on this problem.  Getting e100 driver 
stable for the long term, and ditching eepro100, is a big hurdle to 
cross.  Getting this right is really one of the last steps.

The patch looks OK at quick glance.

Thanks,

	Jeff




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
