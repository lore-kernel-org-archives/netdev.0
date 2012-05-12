From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
 Clock (PHC)
Date: Sat, 12 May 2012 07:34:59 +0200
Message-ID: <20120512053458.GC2190@netboy.at.omicron.at>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141122.GB3392@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB580779423F@ORSMSX105.amr.corp.intel.com>
 <20120511051509.GA2170@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB58077949E8@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42656 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab2ELFfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 01:35:10 -0400
Received: by bkcji2 with SMTP id ji2so2731280bkc.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 22:35:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB58077949E8@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 11, 2012 at 07:23:44PM +0000, Keller, Jacob E wrote:
> 
>
> I believe this very rare case might be possible, but I don't think
> that checking the ptp seqid will fix anything. In normal cases,
> hardware latches Rx packet timestamp, then the ptp packet goes into
> the queue and we process it shortly after. Before we process that
> packet there will never be another packet in the queue that needs a
> timestamp. We know this because the hardware stops timestamping
> until we unlatch the RX registers. This should mean we don't need to
> check the sequence ID, and spending time doing it would never fix
> the issue you are talking about.
>
> The issue is for when a packet is timestamped and then never reaches
> the queue. Then the rx stamp registers are locked for good, because
> we never clear them, and hardware would never timestamp another
> receive packet. I don't know a good solution to this, except to
> clear the registers periodically. Do you have any suggestions?

Well, one solution would be to check every received packet with the
BPF in ptp_classify.h (whenever Rx time stamping is enabled).

When the driver finds an event packet in the Rx queue, and
TSYNCRXCTL[RXTT] is set, it reads out the time stamp along with
RXSATRL/H. If the fields match, then add the time stamp to the skb.

[ Or perhaps instead of using RXSATRL/H, just use the descriptor bit.
  If *not* set, then the time stamp does not belong to this packet. ]

HTH,
Richard
