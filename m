From: Jacob Keller <jacob.e.keller@intel.com>
Subject: Re: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
 Clock (PHC)
Date: Mon, 14 May 2012 10:28:26 -0700
Message-ID: <4FB140BA.3070700@intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com> <1336632413-19135-7-git-send-email-jeffrey.t.kirsher@intel.com> <20120510141122.GB3392@localhost.localdomain> <02874ECE860811409154E81DA85FBB580779423F@ORSMSX105.amr.corp.intel.com> <20120511051509.GA2170@netboy.at.omicron.at> <02874ECE860811409154E81DA85FBB58077949E8@ORSMSX105.amr.corp.intel.com> <20120512053458.GC2190@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53159 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757146Ab2ENR1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 13:27:14 -0400
In-Reply-To: <20120512053458.GC2190@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/2012 10:34 PM, Richard Cochran wrote:
> On Fri, May 11, 2012 at 07:23:44PM +0000, Keller, Jacob E wrote:
>>
>>
>> I believe this very rare case might be possible, but I don't think
>> that checking the ptp seqid will fix anything. In normal cases,
>> hardware latches Rx packet timestamp, then the ptp packet goes into
>> the queue and we process it shortly after. Before we process that
>> packet there will never be another packet in the queue that needs a
>> timestamp. We know this because the hardware stops timestamping
>> until we unlatch the RX registers. This should mean we don't need to
>> check the sequence ID, and spending time doing it would never fix
>> the issue you are talking about.
>>
>> The issue is for when a packet is timestamped and then never reaches
>> the queue. Then the rx stamp registers are locked for good, because
>> we never clear them, and hardware would never timestamp another
>> receive packet. I don't know a good solution to this, except to
>> clear the registers periodically. Do you have any suggestions?
>
> Well, one solution would be to check every received packet with the
> BPF in ptp_classify.h (whenever Rx time stamping is enabled).
>
> When the driver finds an event packet in the Rx queue, and
> TSYNCRXCTL[RXTT] is set, it reads out the time stamp along with
> RXSATRL/H. If the fields match, then add the time stamp to the skb.
>
> [ Or perhaps instead of using RXSATRL/H, just use the descriptor bit.
>    If *not* set, then the time stamp does not belong to this packet. ]
>
> HTH,
> Richard

Ok, this sounds like a good plan. Considering that the device already 
doesn't allow timestamping of other types of packets, so it doesn't need 
to be general purpose.

Am I correct in thinking all I need to do is check the type and if it 
matches the currently configured rx timestamp mode, then double check 
the bit for whether a timestamp is available, and whether the descriptor 
had a timestamp bit enabled?

Thanks

- Jake
