From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFR] gianfar ethernet driver
Date: Wed, 07 Jul 2004 01:35:00 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40EB8B84.7040301@pobox.com>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com>	 <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com>	 <1089170282.1038.80.camel@jzny.localdomain>	 <20040707032913.GA1822@havoc.gtf.org> <1089171693.1037.87.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
        Kumar Gala <kumar.gala@freescale.com>, netdev@oss.sgi.com,
        dwmw2@infradead.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1089171693.1037.87.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2004-07-06 at 23:29, Jeff Garzik wrote:
> 
>>On Tue, Jul 06, 2004 at 11:18:02PM -0400, jamal wrote:
>>
>>>You dont return a 1 anywhere.
>>
>>That OK in one model.
> 
> 
> True returning 0 this is not wrong; it
> results in an extra call in the layer above the driver.
> (I was trying to point that out in earlier email)

er, I'm confused now?

Every single ethernet driver returns zero, when it has queued a packet 
to hardware :)  That's the common case, I would hope it doesn't result 
in additional work.


>>When you are not dealing with fragments, the most optimal model
>>eliminates the overflow case completely, so your ->hard_start_xmit looks
>>like
>>
>>	lock
>>	queue packet to DMA ring
>>	if (DMA ring full)
>>		netif_stop_queue()
>>	unlock
>>
>>	return 0
>>
>>If you can be sure -- by design -- that room is always available when
>>the queue is not stopped, then that's fine.
>>
>>With fragments, you cannot be sure of this, if you do not wish to
>>reserve MY_HW_MAX_FRAGMENTS slots on the DMA.  Such a case would require
>>moving the "if no more descriptors" check up, and returning 1 when the
>>ring is empty.
>>
>>But ideally, you should write the driver where such a condition does not
>>occur at all.
> 
> 
> Ok, I overlooked fragments. I think it would be useful to capture this
> in the doc you were preping. BTW, why can you figure out the fragment
> count? If you can then the check for number of descriptors availabel
> could account for that.

In one design, you can say

	queue packet
	if (free descriptors < MAX_SKB_FRAGS)
		netif_stop_queue()
	return 0

That design wastes descriptors, but ensures you always have enough room 
when ->hard_start_xmit is called, and thus ensures you never have to 
return 1.

Another design, that attempts to use more descriptors, is

	if (free descriptors < skb->frags)
		netif_stop_queue()
		return 1

	queue packet

	if (free descriptors == 0)
		netif_stop_queue()
	return 0
