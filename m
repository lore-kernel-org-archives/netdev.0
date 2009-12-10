From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/3] increase skb size to prevent dma over skb boundary
Date: Thu, 10 Dec 2009 16:00:46 -0500
Message-ID: <20091210210046.GB21024@shamino.rdu.redhat.com>
References: <20091207144623.GA8073@hmsreliant.think-freely.org> <EA929A9653AAE14F841771FB1DE5A1365FA93CD0DD@rrsmsx501.amr.corp.intel.com> <20091209152312.GA11983@hmsreliant.think-freely.org> <EA929A9653AAE14F841771FB1DE5A1365FA9463CD1@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50779 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757222AbZLJU7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 15:59:50 -0500
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FA9463CD1@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2009 at 11:20:58AM -0700, Tantilov, Emil S wrote:
> Neil Horman wrote:
> > On Tue, Dec 08, 2009 at 04:37:39PM -0700, Tantilov, Emil S wrote:
> >> Neil Horman wrote:
> >>> Hey all-
> >>> 	I was tracking down a memory corruptor lately in which, with
> >>> DEBUG_SLAB enabled we were getting several redzone violoations,
> >>> which was always followed by an oops in the rx receive path when
> >>> using the e1000e driver.  Looking at the cores, the slabs that had
> >>> their redzone violated were always adjacent to a size-2048 slab
> >>> which was allocated by __netdev_alloc_skb.  Doing some
> >>> instrumentation led me to see the following.  When the e1000e
> >>> driver sets up its rctl register, which defines the length of each
> >>> of the buffers in the rx ring, we do this: 
> >>> 
> >>> switch (adapter->rx_buffer_len) {
> >>>         case 256:
> >>>                 rctl |= E1000_RCTL_SZ_256;
> >>>                 rctl &= ~E1000_RCTL_BSEX;
> >>>                 break;
> >>>         case 512:
> >>>                 rctl |= E1000_RCTL_SZ_512;
> >>>                 rctl &= ~E1000_RCTL_BSEX;
> >>>                 break;
> >>>         case 1024:
> >>>                 rctl |= E1000_RCTL_SZ_1024;
> >>>                 rctl &= ~E1000_RCTL_BSEX;
> >>>                 break;
> >>>         case 2048:
> >>>         default:
> >>>                 rctl |= E1000_RCTL_SZ_2048;
> >>>                 rctl &= ~E1000_RCTL_BSEX;
> >>>                 break;
> >>>         case 4096:
> >>>                 rctl |= E1000_RCTL_SZ_4096;
> >>>                 break;
> >>>         case 8192:
> >>>                 rctl |= E1000_RCTL_SZ_8192;
> >>>                 break;
> >>>         case 16384:
> >>>                 rctl |= E1000_RCTL_SZ_16384;
> >>>                 break;
> >>>         }
> >>> }
> >>> 
> >>> This is problematic since rx_buffer_len is set to 1500, which causes
> >>> the rctl value to fall into the default case, which configures the
> >>> hardware to think it can dma up to 2048 bytes into each buffer,
> >>> despite the fact that the buffer is only 1500 bytes long.  If we
> >>> receive a frame that is longer than 1500 bytes, then the dma will
> >>> overrun the 1500 byte limit of the sk_buff's data block spilling
> >>> into the skb_shared_info structure (which is placed immediately
> >>> after the end of the skb->end pointer (or at skb->head + skb->end if
> >>> NET_SKBUFF_DATA_USES_OFFSET is configured).  In either case, the
> >>> spillover corrupts the skb_shared_info structure, and sets us up for
> >>> any number of subsequent corruptions/oopses/failures.  I've fixed
> >>> this by normalizing the rx_buffer_length value in the setup_rctl
> >>> function, which rounds up the length to the configured value of
> >>> rctl, forcing us to allocate buffers of a size that meet the
> >>> hardwares configuration needs. 
> >>> 
> >>> I've tested this on e1000e and confirmed that it fixes my redzone
> >>> violations and the observed oops.  Visual inspection indicates that
> >>> e1000 and ixgb also need this fix.  I've not explicitly tested them
> >>> though, so I've split this into three separate patches
> >>> 
> >>> Regards
> >>> Neil
> >>> 
> >>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >> 
> >> Hi Neil,
> >> 
> >> I am trying to test the patches you submitted (thanks btw) and so
> >> far am not able to reproduce the panic you described. When MTU is at
> >> 1500 RCTL.LPE (bit 5) is set to 0 and the HW will not allow the
> >> reception of large packets (>1522 bytes, which is what rx_buffer_len
> >> is set to). This is basically what I am seeing in my tests - packets
> >> are discarded by the HW.     
> >> 
> >> Can you provide more details about the setup you used? Steps to
> >> reproduce and also details (lspci -vvv, ethtool -e, ethtool -d) of
> >> the HW you used and kernel config should help as well.  
> >> 
> >> Thanks,
> >> Emil--
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> 
> > 
> > 
> > Heres the data you asked for.  The config isn't exact, as the system
> > in question was installed a few times over since I worked on this,
> > but it should be very close.  The only differnce I see on this config
> > is that CONFIG_SLAB_DEBUG is turned on.  Everything else should be
> > identical 
> 
> Thanks for the data. Your config could not apply on my kernel (net-next-2.6 master branch). So I attached the one I used for testing in case you see anything that is different. I made sure DEBUG_SLAB is enabled.
> 
It might not apply cleanly no.  as I said, I had to reconstruct it (it was
originoally from an older kernel that I applied to a newer kernel)

> Is this the connectathon suite you were talking about:
> http://www.connectathon.org/nfstests.html
> 
Yes, thats the one.

> I ran overnight stress (1000 iterations of the suite)  plus some netperf stress and so far no signs of issues on a z-200 platform. 
> 
> BTW the HP z-200 is still in pre-production stage. Looking at the eeprom you provided it seems older than what we have. You should probably look into getting an updated FW.
> 
That might be worth looking into.  Thanks.  That said however, if its possible
for the eeprom to allow overlength frames to get dma-ed, isn't it worthwhile to
ensure that our allocation size matches what we tell the driver it is?  We
already do so in e1000_change_mtu:
...

	if (max_frame <= 256)
                adapter->rx_buffer_len = 256;
        else if (max_frame <= 512)
                adapter->rx_buffer_len = 512;
        else if (max_frame <= 1024)
                adapter->rx_buffer_len = 1024;
        else if (max_frame <= 2048)
                adapter->rx_buffer_len = 2048;
        else
                adapter->rx_buffer_len = 4096;
...

These patches just ensure that the same normalization is done for the initial
size of rx_buffer_len, should userspace never change the mtu of the NIC.

Regards
Neil

> Thanks,
> Emil
> 


