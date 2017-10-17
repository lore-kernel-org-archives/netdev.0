From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [Intel-wired-lan] [RFC PATCH next 2/2] i40e: add support for
 macvlan hardware offload
Date: Tue, 17 Oct 2017 16:12:22 -0700
Message-ID: <c74d6f52-dc7f-eeed-e916-ee7ffacc39f8@oracle.com>
References: <1508275089-430113-1-git-send-email-shannon.nelson@oracle.com>
 <1508275089-430113-3-git-send-email-shannon.nelson@oracle.com>
 <CAKgT0Uft_kCyct==am7W0TGUo-YzUhSVkJir83uGx_XwMuxsHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43825 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753475AbdJQXMb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 19:12:31 -0400
In-Reply-To: <CAKgT0Uft_kCyct==am7W0TGUo-YzUhSVkJir83uGx_XwMuxsHg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 2:32 PM, Alexander Duyck wrote:
> 
> So the select_queue function being needed is the deal breaker on all
> of this as far as I am concerned. We aren't allowed to use it under
> other cases so why should macvlan be an exception to the rule?

I realize that the stack is pretty good at chosing the "right" queue, 
which is my understanding as to why we shouldn't use select_queue(), but 
it doesn't know how to use the accel_priv context associated with the 
macvlan offload.

I saw DaveM's guidance to the HiNIC folks when they tried to add 
select_queue(): "do not implement this function unless you absolutely 
need to do something custom in your driver".  I can see where this might 
be the exception.

When originally thinking about how to do this, I wanted to use the 
accel_priv as a pointer to the VSI to be used for the offload, then we 
could have multiple queues and use all the VSI specific tuning 
operations that XL710 has available.  It can work when selecting the 
queue, but by the time you get to start_xmit(), you no longer have that 
context and only have the queue number.  You can't do any fancy encoding 
in the queue number because the value has to be within 
dev->num_tx_queues.  Maybe we can add accel_priv to the start_xmit 
interface?  (I can hear the groans already...)

However... for our case, you might be right anyway.  If the stack is 
doing its job at keeping the conversation on the one queue/irq/cpu 
combination, any Tx following the offloaded Rx might already be headed 
for the right Tx queue.  I'll check on that.
> I think we should probably look at a different approach for this. For
> example why is it we need to use a different transmit path for a
> macvlan packet vs any other packet? On the Rx side we get the
> advantage of avoiding the software hashing and demux. What do we get
> for reserving queues for transmit?

There are a couple of reasons I can think of to keep the Tx on the 
specific queue pair:

- Keep the Tx traffic on the same CPU and irq as the Rx traffic

- Don't let the flow get interrupted, slowed, or otherwise perturbed by 
other traffic flows.

- Allow for adding hardware assisted bandwidth constraints to the 
offloaded flow without bothering the rest of the NIC's traffic

Are these enough to want to guarantee the Tx queue?

> My plan for this is to go back and "fix" ixgbe so we can get it away
> from having to use the select_queue call for the macvlan offload and
> then maybe look at proving a few select NDO operations for allowing
> macvlans that are being offloaded to make specific calls into the
> hardware to perform tasks as needed.

The ixgbe implementation can certainly be improved.  I think its biggest 
failing is that the rest of the general traffic gets constrained to a 
single queue - no more RSS for load balancing.

sln
