From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net] macvlan: Disable LRO on lowerdev; warn if it's
 turned back on
Date: Sat, 25 Feb 2012 22:49:49 +0000
Message-ID: <1330210189.8460.12.camel@deadeye>
References: <1329851622.2689.6.camel@bwh-desktop>
	 <4F43F816.6070908@intel.com> <1329856136.2689.46.camel@bwh-desktop>
	 <4F4410C7.2000500@candelatech.com> <87fwdytvlw.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Shradha Shah <sshah@solarflare.com>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:32519 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756527Ab2BYWtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 17:49:47 -0500
In-Reply-To: <87fwdytvlw.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-02-25 at 14:07 -0800, Eric W. Biederman wrote:
> Ben Greear <greearb@candelatech.com> writes:
> 
> > On 02/21/2012 12:28 PM, Ben Hutchings wrote:
> >> On Tue, 2012-02-21 at 12:01 -0800, John Fastabend wrote:
> >>> On 2/21/2012 11:13 AM, Ben Hutchings wrote:
> >>>> Large Receive Offload (LRO) is only appropriate for packets that are
> >>>> destined for the host, and should be disabled if received packets may
> >>>> be forwarded.
> >>>>
> >>>> Further, macvtap_skb_to_vnet_hdr() will BUG() on a packet received
> >>>> with LRO (but not GRO).
[...]
> Long story short.
> 
> With the macvlan driver the normal case is not to turn packets around
> but to go directly to the nic or to come directly from the nic.
>
> In the case where packets are turned around and packets go from one
> software interface the design is that the drivers are supposed to
> do software emulation of hardware features like gro so that we don't
> have to take a performance hit when it happens.
> 
> If we are not doing proper software emulation of features like gro
> in macvtap that is a problem.
> 
> I am fuzzy about all of the details but last I looked we were doing
> proper software emulation of the features when just macvlan was
> involved.  I also remember that the macvtap driver really wanted
> gro so that it could work efficiently with emulated hardware.

This doesn't disable GRO; you can still benefit from that.

> So I don't know why people are having a problem, but the correct
> solution is not to give up but to fix the silly software side of
> the drivers to actually handle things properly.

This is not a deficiency in macvtap.  Any skb received with LRO cannot
be re-sent through dev_queue_xmit() or dev_hard_start_xmit().

> Disabling LRO on the lowerdev just so we can avoid writing the
> support in macvtap just sounds sad.

The regular bridge driver and the IPv4 and IPv6 protocols already
disable LRO when enabling forwarding on a device.  This is 'normal'.

Now we could decide that the possible loss of some header information
through LRO is acceptable and we should just require drivers using LRO
to label their skbs with the proper gso_type for re-sending.  Indeed,
although GRO preserves packet boundaries they are actually lost in
re-transmission as GSO/TSO re-segments at regular intervals.  So that's
already happening to an extent.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
