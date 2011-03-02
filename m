From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 - rx misses
Date: Tue, 1 Mar 2011 17:01:49 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1103011658050.5424@JBRANDEB-DESK2.amr.corp.intel.com>
References: <2DF55ECAAA7FFF478FB4ED007EF478E7656B070D76@NETS.hillside.glowpoint.com> <alpine.WNT.2.00.1102281058040.5424@JBRANDEB-DESK2.amr.corp.intel.com> <2DF55ECAAA7FFF478FB4ED007EF478E7656B100F27@NETS.hillside.glowpoint.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: John Bermudez <jbermudez@vnocservice.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63986 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757226Ab1CBBBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 20:01:50 -0500
In-Reply-To: <2DF55ECAAA7FFF478FB4ED007EF478E7656B100F27@NETS.hillside.glowpoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<removed non-relevant users>

On Tue, 1 Mar 2011, John Bermudez wrote:

> Thanks for your time
> Can you tell me the command to lengthen the input fifo rx queue?
> is this possible

You can try increasing the number of rx buffers via the command
# ethtool -G ethX rx 4096

and if you were really gung ho, you could increase the amount of fifo 
allocated to the rx side of the fifo by modifying the source.  That said, 
I don't think that will buy you anything because it seems from the small 
amount of data provided that you are having exceptionally long periods of 
time where the data is coming faster than your machine can process (for 
whatever reason) and increasing the fifo only will give you a marginal 
(4kB or so) increasing in buffering.



> 
> -----Original Message-----
> From: Brandeburg, Jesse [mailto:jesse.brandeburg@intel.com] 
> Sent: Monday, February 28, 2011 11:05 AM
> To: John Bermudez
> Cc: cramerj; Ronciak, John; Kirsher, Jeffrey T; Kok, Auke-jan H; netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net
> Subject: Re: e1000 - rx misses
> 
> added e1000-devel, responses inline...
> 
> On Wed, 23 Feb 2011, John Bermudez wrote:
> 
> > Hello All,
> > I got your contact info in a forum.
> > maybe you could give me a quick pointer.
> > 
> > I have a device that is experiencing RX misses. I tried 1000/full and 100/full
> > it occurs at both speeds. I seem to get a burst of loss so I am assuming I am overrunning the FIFO RX queue.
> 
> overrunning at 100Mb/s seems pretty unlikely to be our hardware's fault, 
> as your buffer (in time) is increasing by 10x.
> 
> > 
> > Any known workarounds?
> > Configuration modifications?
> > 
> > your time is much appreciated
> > 
> > 
> > 
> > /lib/modules/2.4.31-uc0/kernel/drivers/net/e1000
> > # ls
> > e1000.o
> 
> ow, 2.4.31 kernel is pretty much so old as to not be supportable.
> 
> > # ethtool -S eth1
> > NIC statistics:
> >      rx_packets: 217454512
> >      tx_packets: 266698397
> >      rx_bytes: 172995819593
> >      tx_bytes: 246744709750
> >      rx_broadcast: 0
> >      tx_broadcast: 528
> <snip>
> >      rx_no_buffer_count: 925
> 
> This count above indicates that your cpu is not returning buffers to 
> hardware fast enough.  Do you have NAPI enabled?
> 
> >      rx_missed_errors: 48206
> 
> This error means that for the length of time the fifo was buffering the 
> adapter was not able to get any data buffers from the OS, filled the FIFO 
> and had to drop this many packets.
> 
> >      tx_aborted_errors: 0
> >      tx_carrier_errors: 0
> >      tx_fifo_errors: 0
> >      tx_heartbeat_errors: 0
> >      tx_window_errors: 0
> >      tx_abort_late_coll: 0
> >      tx_deferred_ok: 0
> >      tx_single_coll_ok: 0
> >      tx_multi_coll_ok: 0
> >      tx_timeout_count: 0
> >      tx_restart_queue: 0
> >      rx_long_length_errors: 0
> >      rx_short_length_errors: 0
> >      rx_align_errors: 0
> >      tx_tcp_seg_good: 0
> >      tx_tcp_seg_failed: 0
> >      rx_flow_control_xon: 0
> >      rx_flow_control_xoff: 0
> >      tx_flow_control_xon: 0
> >      tx_flow_control_xoff: 0
> 
> flow control is either not happenning or is disabled, if it is disabled 
> you could try enabling it on both ends to get a little more buffering in 
> your switch.
> 
> >      rx_long_byte_count: 172995819593
> >      rx_csum_offload_good: 217406235
> >      rx_csum_offload_errors: 17
> >      rx_header_split: 0
> >      alloc_rx_buff_failed: 0
> >      tx_smbus: 0
> >      rx_smbus: 5262
> 
> hm, you have IPMI traffic, could these be related to your stalls?
> 
> >      dropped_smbus: 0
> > #
> > 
> > 
> > Thank you and have a nice day,
> > 
> > Mr. John Bermudez
> > NOC Level 3 Engineer
> > 
> > 
> 
> You didn't include lots of data we need, like hardware type, adapter/chip, 
> ethtool -i output, cat /proc/interrupts, system info, .config, etc.
> 
> I suggest that something is running either in interrupt context on your 
> system for a very long time (keeping us from running our interrupt 
> handler) or that your cpu is underpowered and unable to keep up with 
> whatever tasks it is running besides the network driver.
> 
> If you wish to continue troubleshooting please file a bug at e1000.sf.net 
> and attach the requested info there.
> 
> Jesse
> 
