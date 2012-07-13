From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [PATCH] ixgbevf - Prevent RX/TX statistics getting reset to
 zero
Date: Fri, 13 Jul 2012 10:14:01 -0700
Message-ID: <20120713101401.0000421f@unknown>
References: <E31FB011129F30488D5861F38390491520D00B9F01@BLRX7MCDC201.AMER.DELL.COM>
	<4FFF16CA.1090705@gmail.com>
	<E31FB011129F30488D5861F38390491520D0E082C7@BLRX7MCDC201.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jeffrey.t.kirsher@intel.com>, <netdev@vger.kernel.org>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53249 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933254Ab2GMROX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 13:14:23 -0400
In-Reply-To: <E31FB011129F30488D5861F38390491520D0E082C7@BLRX7MCDC201.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Jul 2012 05:36:37 -0700
<Narendra_K@Dell.com> wrote:

> > -----Original Message-----
> > From: Jeff Kirsher [mailto:tarbal@gmail.com]
> > Sent: Thursday, July 12, 2012 11:56 PM
> > To: K, Narendra; gregory.v.rose@intel.com
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH] ixgbevf - Prevent RX/TX statistics getting
> > reset to zero
> > 
> > On 07/12/2012 06:55 AM, Narendra_K@Dell.com wrote:
> > > Hello,
> > >
> > > [Apologies if you are receiving this message twice. I am
> > > resending the
> > message, as I got message delivery failure note].
> > >
> > > While exploring SR-IOV on Intel 82599EB 10-Gigabit SFP+ adapter,
> > > I had the
> > following observation.  I enabled two VFs by passing 'max_vfs=2' to
> > ixgbe driver. One of the VFs was assigned to a guest.
> > > In the guest, the ifconfig and ip tools reported 'RX packets' and
> > > 'TX packets'
> > as zero, after pinging to a remote host. Looking into it further,
> > the commit 4197aa7bb81877ebb06e4f2cc1b5fea2da23a7bd implements 64
> > bit per ring statistics. It seemed like the 'total_bytes' and
> > 'total_packets' of RX and TX ring were being reset to zero by the
> > RX and TX interrupt handlers, resulting in the user space tools
> > reporting zero RX and TX bytes.
> > >
> > > The attached patch addresses the issue by preventing the
> > > resetting of RX
> > and TX ring statistics to zero. The patch was taken against latest
> > mainline 3.5- rc6 kernel.
> > >
> > > I tested the patch by pinging  from the guest OS to a remote host.
> > >
> > > ping -f <remote host> -c 10000
> > >
> > > The ip and ifcofig showed the statistics increased by 10000
> > > packets.
> > >
> > > # lspci | grep 82599
> > > 04:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit
> > > SFP+
> > Network Connection (rev 01)
> > > 04:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit
> > > SFP+
> > Network Connection (rev 01)
> > > 04:10.0 Ethernet controller: Intel Corporation 82599 Ethernet
> > > Controller
> > Virtual Function (rev 01)
> > > 04:10.1 Ethernet controller: Intel Corporation 82599 Ethernet
> > > Controller
> > Virtual Function (rev 01)
> > > 04:10.2 Ethernet controller: Intel Corporation 82599 Ethernet
> > > Controller
> > Virtual Function (rev 01)
> > > 04:10.3 Ethernet controller: Intel Corporation 82599 Ethernet
> > > Controller
> > Virtual Function (rev 01)
> > >
> > > # lspci -s 04:00.0 -n
> > > 04:00.0 0200: 8086:154d (rev 01)
> > > # lspci -s 04:10.0 -n
> > > 04:10.0 0200: 8086:10ed (rev 01)
> > >
> > > Please let me know if additional details and logs are
> > > required.[>]  
> > >
> > > With regards,
> > > Narendra K
> > >
> > >
> > >
> > 
> > Thanks, I will add the patch to my queue
> > 
> [>] 
>  
> Hi Greg,
> 
> I was re-looking at why ' rx_ring->total_packets' and '
> rx_ring->total_bytes' were being set to zero in '
> ixgbevf_msix_clean_rx'.  It looks like ' rx_ring->total_packets' and
> ' rx_ring->total_packets'  are computed per one run of
> 'ixgbevf_clean_rx_irq' .  Then in 'ixgbevf_clean_rxonly' if
> 'adapter->itr_setting & 1' is true, the count is  used in
> 'ixgbevf_set_itr_msix'. When the interrupts are enabled, the '
> rx_ring->total_packets'  and ' rx_ring->total_bytes' are set to zero
> so that they can be re-computed in the poll function and  fed to the
> 'ixgbevf_set_itr_msix'.
> 
> This results in statistics reported by 'ip' and 'ifconfig' as zero.
> The patch addresses the scenario.  But it seems it would change the
> intended behavior in the scenario  when 'adapter->itr_setting & 1' is
> true.  It could be addressed by storing the 'total_rx_packets' and
> 'total_rx_bytes'  computed every time in the poll function in 'struct
> ixgbevf_adapter' . Then the interrupt handler could reset them to
> zero instead of resetting  ' rx_ring->total_packets' and  '
> rx_ring->total_bytes'.
> 
> Also, I observed that  'adapter->itr_setting & 1'  was not true by
> default.  I tried setting it by 'ethtool  -C eth0 adaptive-rx on',
> and it returned 'operation not supported'. 
> 
> I could be missing something here, please let me know.

Nope, you're correct in your analysis.  The ixgbevf driver hasn't
supported adaptive interrupt moderation in the past.  However, a set of
patches we have in the pipeline will turn it on by default.  Also,
as a result of those patches the bug you've reported will be fixed.
We'll go ahead and accept your patch for the net tree and then fix up
any conflicts between that and our new set of patches when they get
pushed to net-next.

Thanks for your work on this.

- Greg
