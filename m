From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH] net: Add support for device specific address syncing
Date: Fri, 16 May 2014 11:47:57 -0700
Message-ID: <53765D5D.9040207@intel.com>
References: <20140514233444.29822.45400.stgit@ahduyck-cp2.jf.intel.com> <20140515.230540.466419985495775051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59660 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755068AbaEPSsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 14:48:02 -0400
In-Reply-To: <20140515.230540.466419985495775051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2014 08:05 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Wed, 14 May 2014 16:37:27 -0700
> 
>> This change provides a function to be used in order to break the
>> ndo_set_rx_mode call into a set of address add and remove calls.  The code
>> is based on the implementation of dev_uc_sync/dev_mc_sync.  Since they
>> essentially do the same thing but with only one dev I simply named my
>> functions __dev_uc_sync/__dev_mc_sync.
>>
>> I also implemented an unsync version of the functions as well to allow for
>> cleanup on close.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>
>> I still have to do some testing on this patch, but I am looking to see if
>> this is the correct approach or if the community would prefer I take a
>> different one.
> 
> I just wonder about error handling.
> 
> The code just seems to stop trying to sync() if one intermediate
> sync() fails.
> 
> Shouldn't we unwind or signal errors to the caller?

I'm not sure what you are talking about.  That is what the code does.
In the bit of code below on error we break out of the loop and return
the error value.  At that point it is up to the caller to determine the
best way to clean it up since the list may still be synced from the
previous call.  For example one response to the __dev_uc_sync call
failing might be to simply turn on promiscuous mode if the call returns
a value indicating that there aren't enough filters.

The unsync doesn't do this but that is partly because having an
additional address isn't really that big of an issue, and because this
can still be cleaned up the next time this function is called.

I suppose I should break up the loop below though.  It might be better
to do all of the usnync operations first before the sync in the case of
a interface with a limited number of unicast of multicast filters.

-- section from __hw_addr_sync_dev() in the original patch --
> +       list_for_each_entry_safe(ha, tmp, &list->list, list) {
> +               if (!ha->sync_cnt) {
> +                       err = sync(dev, ha->addr);
> +                       if (err)
> +                               break;
> +                       ha->sync_cnt++;
> +                       ha->refcount++;
> +               } else if (ha->refcount == 1) {
> +                       err = unsync(dev, ha->addr);
> +                       if (!err) {
> +                               ha->sync_cnt--;
> +                               __hw_addr_del_entry(list, ha, false, false);
> +                       }
> +               }
> +       }
> +       return err;
--

> 
> Is the idea that the driver has internal state which will track if
> something goes wrong and take care of error recovery itself?  If so,
> that kind of indirect error handling doesn't sit too well with me.
> 

My primary use case for this is to simplify mailbox operations between
two entities such as a PF and VF.  With this the VF only needs to send a
request for new addresses instead of having to send the entire list via
the mailbox.  The issue most likely to cause an error is a mailbox error
which I admit does have some of its own error recovery in the case of a
message timeout.

Thanks,

Alex
