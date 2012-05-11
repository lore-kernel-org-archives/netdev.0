From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
 Clock (PHC)
Date: Fri, 11 May 2012 19:23:44 +0000
Message-ID: <02874ECE860811409154E81DA85FBB58077949E8@ORSMSX105.amr.corp.intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141122.GB3392@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB580779423F@ORSMSX105.amr.corp.intel.com>
 <20120511051509.GA2170@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40025 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760925Ab2EKTXq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 15:23:46 -0400
In-Reply-To: <20120511051509.GA2170@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, May 10, 2012 10:15 PM
> To: Keller, Jacob E
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
> Clock (PHC)
> 
> On Thu, May 10, 2012 at 09:53:18PM +0000, Keller, Jacob E wrote:
> > > > +	/*
> > > > +	 * If this bit is set, then the RX registers contain the time
> stamp. No
> > > > +	 * other packet will be time stamped until we read these
> registers, so
> > > > +	 * read the registers to make them available again. Because only
> one
> > > > +	 * packet can be time stamped at a time, we know that the
> register
> > > > +	 * values must belong to this one here and therefore we don't
> need to
> > > > +	 * compare any of the additional attributes stored for it.
> > >
> > > I suspect that this assumption is wrong. What happens if the time
> > > stamping logic locks a value but the packet is lost because the ring is
> full?
> > >
> > > BTW, the IGB driver also has this defect.
> > >
> >
> > Note how I read the rx registers first? So it will always clear the value.
> > That should unlock the value for the next rx stamp packet.
> 
> 1. Hw recognizes ptp event packet, locks time stamp 2. Hw drops packet because
> queue is full 3. No more time stamps are ever generated
> 
> Can this happen? The docs seems to say it can.
> 
> Richard

I believe this very rare case might be possible, but I don't think that checking the ptp seqid will fix anything. In normal cases, hardware latches Rx packet timestamp, then the ptp packet goes into the queue and we process it shortly after. Before we process that packet there will never be another packet in the queue that needs a timestamp. We know this because the hardware stops timestamping until we unlatch the RX registers. This should mean we don't need to check the sequence ID, and spending time doing it would never fix the issue you are talking about.

The issue is for when a packet is timestamped and then never reaches the queue. Then the rx stamp registers are locked for good, because we never clear them, and hardware would never timestamp another receive packet. I don't know a good solution to this, except to clear the registers periodically. Do you have any suggestions?

- Jake
