From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: NetXen driver causing slab corruption in -RT kernels
Date: Wed, 19 Sep 2007 12:13:39 +0530
Message-ID: <46F0C51B.2070205@netxen.com>
References: <200709181117.59041.vernux@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Vernon Mauery <vernux@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:59404 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752512AbXISGno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 02:43:44 -0400
In-Reply-To: <200709181117.59041.vernux@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That "00 0e 1e ..." is netxen's mac address, so sounds like the NIC is
dumping a frame in the skb already freed (and poisoned) by the stack.
I suppose -RT kernels preempt the softirq, giving a chance for this race.

The netxen driver doesn't seem to clear the mapped address of the skb in
rx descriptor, instead it replaces it with mapped address of newly
allocated skb. Also, the rx ring is replenished in bursts (at the end of
poll routine), this can help the race if preempted in between.

I am currently reworking the rx handling, hopefully it will fix this.

Thanks for reporting in detail.

-Dhananjay


Vernon Mauery wrote:
> In doing some stress testing of the NetXen driver, I found that my machine was 
> dying in all sorts of weird ways.  I saw several different crashes, BUG 
> messages in the TCP stack and some assert messages in the TCP stack as well.  
> I really didn't think that there could be six different bugs all at once in 
> the TCP/IP stack, so I started looking at possible memory corruption.
> 
> I first saw this on 2.6.16-rt22 with a backported netxen driver from 2.6.22.  
> I figured I should try the latest kernel, so I tried it on 2.6.23-rc6-git7 
> but could not trigger the slab corruption messages with CONFIG_DEBUG_SLAB, so 
> I figured the race must only exist in the -RT kernels.  Next I tried 
> 2.6.23-rc6-git7-rt1 (I applied patch-2.6.23-rc4-rt1 patch to 2.6.23-rc6-git7 
> and fixed the 5 failing hunks).  After an hour or so, lots of slab corruption 
> messages showed up:
> 
> Slab corruption: size-2048 start=f40c4670, len=2048
> Slab corruption: size-2048 start=f313cf48, len=2048
> Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
> Last user: [<c0166be4>](kfree+0x80/0x95)
> 010: 6b 6b 00 0e 1e 00 16 13 00 0e 1e 00 19 3d 08 00
> 020: 45 00 05 dc 92 ab 40 00 40 11 8a 5b 0a 02 02 03
> 030: 0a 02 02 04 80 0c 80 0d 05 c8 dc 39 00 00 00 00
> 040: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 060: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> Prev obj: start=f313c730, len=2048
> Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
> Last user: [<f8f06186>](netxen_post_rx_buffers_nodb+0x62/0x1f0 [netxen_nic])
> 000: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 010: 5a 5a 00 0e 1e 00 16 13 00 0e 1e 00 19 3d 08 00
> Next obj: start=f313d760, len=2048
> Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
> Last user: [<f8f06186>](netxen_post_rx_buffers_nodb+0x62/0x1f0 [netxen_nic])
> 000: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 010: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> Slab corruption: size-2048 start=f395a6f0, len=2048
> Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
> Last user: [<c0166be4>](kfree+0x80/0x95)
> 010: 6b 6b 00 0e 1e 00 16 13 00 0e 1e 00 19 3d 08 00
> 020: 45 00 05 dc 92 ac 40 00 40 11 8a 5a 0a 02 02 03
> 030: 0a 02 02 04 80 0c 80 0d 05 c8 dc 39 00 00 00 00
> 040: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 060: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> Next obj: start=f395af08, len=2048
> Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
> Last user: [<f8f06186>](netxen_post_rx_buffers_nodb+0x62/0x1f0 [netxen_nic])
> 000: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 010: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
> Last user: [<c0166be4>](kfree+0x80/0x95)
> 010: 6b 6b 00 0e 1e 00 16 13 00 0e 1e 00 19 3d 08 00
> 020: 45 00 05 dc 92 aa 40 00 40 11 8a 5c 0a 02 02 03
> 030: 0a 02 02 04 80 0c 80 0d 05 c8 dc 39 00 00 00 00
> 040: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 060: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> Next obj: start=f40c4e88, len=2048
> Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
> Last user: [<f8f06186>](netxen_post_rx_buffers_nodb+0x62/0x1f0 [netxen_nic])
> 000: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 010: 5a 5a 00 0e 1e 00 16 13 00 0e 1e 00 19 3d 08 00
> 
> The stress test that I am running is basically a mixed bag of stuff I threw 
> together.  It runs eight concurrent netperf TCP streams and two concurrent 
> UDP streams in both directions, (and on both 10GbE interfaces), ping -f in 
> both directions, some more disk/cpu loads in the background and a little bit 
> of NFS traffic thrown in for good measure.
> 
> --Vernon
