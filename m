From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 1/2] net: Add new network device function to allow
 for MMIO batching
Date: Thu, 12 Jul 2012 08:39:05 -0700
Message-ID: <4FFEEF99.7030707@intel.com>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>  <20120712002603.27846.23752.stgit@gitlad.jf.intel.com> <1342077259.3265.8232.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, therbert@google.com,
	alexander.duyck@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10080 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932627Ab2GLPjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 11:39:17 -0400
In-Reply-To: <1342077259.3265.8232.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/2012 12:14 AM, Eric Dumazet wrote:
> On Wed, 2012-07-11 at 17:26 -0700, Alexander Duyck wrote:
>> This change adds capabilities to the driver for batching the MMIO write
>> involved with transmits.  Most of the logic is based off of the code for
>> the qdisc scheduling.
>>
>> What I did is break the transmit path into two parts.  We already had the
>> ndo_start_xmit function which has been there all along.  The part I added
>> was ndo_complete_xmit which is meant to handle notifying the hardware that
>> frames are ready for delivery.
>>
>> To control all of this I added a net sysfs value for the Tx queues called
>> dispatch_limit.  When 0 it indicates that all frames will notify hardware
>> immediately.  When 1 or more the netdev_complete_xmit call will queue up to
>> that number of packets, and when the value is exceeded it will notify the
>> hardware and reset the pending frame dispatch count.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
> The idea is good, but do we really need so complex schem ?
>
> Most of the transmits are done from __qdisc_run()
>
> We could add logic in __qdisc_run()/qdisc_restart()
>
> qdisc_run_end() would then have to call ndo_complete_xmit() to make
> sure the MMIO is done.

The problem is in both of the cases where I have seen the issue the
qdisc is actually empty.

In the case of pktgen it does not use the qdisc layer at all.  It just
directly calls ndo_start_xmit.

In the standard networking case we never fill the qdisc because the MMIO
write stalls the entire CPU so the application never gets a chance to
get ahead of the hardware.  From what I can tell the only case in which
the qdisc_run solution would work is if the ndo_start_xmit was called on
a different CPU from the application that is doing the transmitting.

Thanks,

Alex
