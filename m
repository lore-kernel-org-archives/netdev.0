From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 0/3] increase skb size to prevent dma over skb boundary
Date: Mon, 7 Dec 2009 09:46:23 -0500
Message-ID: <20091207144623.GA8073@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34989 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757419AbZLGOqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 09:46:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	I was tracking down a memory corruptor lately in which, with DEBUG_SLAB
enabled we were getting several redzone violoations, which was always followed
by an oops in the rx receive path when using the e1000e driver.  Looking at the
cores, the slabs that had their redzone violated were always adjacent to a
size-2048 slab which was allocated by __netdev_alloc_skb.  Doing some
instrumentation led me to see the following.  When the e1000e driver sets up its
rctl register, which defines the length of each of the buffers in the rx ring,
we do this:

switch (adapter->rx_buffer_len) {
        case 256:
                rctl |= E1000_RCTL_SZ_256;
                rctl &= ~E1000_RCTL_BSEX;
                break;
        case 512:
                rctl |= E1000_RCTL_SZ_512;
                rctl &= ~E1000_RCTL_BSEX;
                break;
        case 1024:
                rctl |= E1000_RCTL_SZ_1024;
                rctl &= ~E1000_RCTL_BSEX;
                break;
        case 2048:
        default:
                rctl |= E1000_RCTL_SZ_2048;
                rctl &= ~E1000_RCTL_BSEX;
                break;
        case 4096:
                rctl |= E1000_RCTL_SZ_4096;
                break;
        case 8192:
                rctl |= E1000_RCTL_SZ_8192;
                break;
        case 16384:
                rctl |= E1000_RCTL_SZ_16384;
                break;
        }
}

This is problematic since rx_buffer_len is set to 1500, which causes the rctl
value to fall into the default case, which configures the hardware to think it
can dma up to 2048 bytes into each buffer, despite the fact that the buffer is
only 1500 bytes long.  If we receive a frame that is longer than 1500 bytes,
then the dma will overrun the 1500 byte limit of the sk_buff's data block
spilling into the skb_shared_info structure (which is placed immediately after
the end of the skb->end pointer (or at skb->head + skb->end if
NET_SKBUFF_DATA_USES_OFFSET is configured).  In either case, the spillover
corrupts the skb_shared_info structure, and sets us up for any number of
subsequent corruptions/oopses/failures.  I've fixed this by normalizing the
rx_buffer_length value in the setup_rctl function, which rounds up the length to
the configured value of rctl, forcing us to allocate buffers of a size that meet
the hardwares configuration needs. 

I've tested this on e1000e and confirmed that it fixes my redzone violations and
the observed oops.  Visual inspection indicates that e1000 and ixgb also need
this fix.  I've not explicitly tested them though, so I've split this into three
separate patches

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

