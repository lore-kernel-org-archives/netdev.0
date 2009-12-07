From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/3] e1000: increase skb size to prevent dma over skb
	boundary (v2)
Date: Mon, 7 Dec 2009 10:59:53 -0500
Message-ID: <20091207155953.GE8073@hmsreliant.think-freely.org>
References: <20091207144623.GA8073@hmsreliant.think-freely.org> <20091207144736.GB8073@hmsreliant.think-freely.org> <4B1D1E12.8010200@lastsummer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54403 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbZLGP7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 10:59:53 -0500
Content-Disposition: inline
In-Reply-To: <4B1D1E12.8010200@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 07, 2009 at 04:24:02PM +0100, Franco Fichtner wrote:
> Hi Neil,
>
> Neil Horman wrote:
>> Update e1000 driver to not allow dma beyond the end of the allocated skb
>>     Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>>
>>
>> e1000_main.c |   34 +++++++++++++++++++++++++++++++++-
>> 1 file changed, 33 insertions(+), 1 deletion(-)
>>
>>
>> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
>> index 7e855f9..7600deb 100644
>> --- a/drivers/net/e1000/e1000_main.c
>> +++ b/drivers/net/e1000/e1000_main.c
>> @@ -1667,6 +1667,19 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
>>  	return err;
>>  }
>>  +static inline u32 normalize_rx_len(u32 len)
>> +{
>> +        u32 match, last_match;
>> +
>>   
> Skip newline and get rid of last_match. Also, there is a whitespace error...
I'll just wash this all out, based on your comments, ben's and Michals, its not
needed..
>> <snip>  
> If you modify rx_buffer_len anyway, then get rid of normed_rx_len and
> do a quick
>
>    adapter->rx_buffer_len = normalize_rx_len(adapter->rx_buffer_len);
>
> instead. With the modification above, it never fails, so no need to check
> for !normed_rx_len.
>
Agreed, by using roundup_pow_of_two as was previously suggested the extra
variable is no longer needed.

> But I don't really know the context of this change. Is it okay to shorten
> rx_buffer_len here? Why was it not set appropriately as the driver
> expects?
>
We're not shortening, we're rounding up.  And yes its both ok, and necessecary.
The problem (from the intial email I sent), was that this driver tells the
hardware that potentially it can dma up to X bytes to a given rx buffer, but it
is possible and likely that we only provide Y bytes to dma to, where X > Y.
This leads to corruption of the skb_shared_info structure.

> Oh, BTW, the default case in the switch statement is stupid and should
> be removed.
>
I agree, its silly, but with the above changes, it becomes needed (or beneficial
again), to catch cases in which roundup_pow_of_two returns a value beyond what
the hardware can handle.  I think in this case we should just panic, as
rx_buffer_len should never be larger than 16384.


Thanks all for the comments, heres version two of this patch, taking all
comments into account:


Update e1000 driver to not allow dma beyond the end of the allocated skb
    
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


e1000_main.c |   15 ++++++++++++++-
1 file changed, 14 insertions(+), 1 deletion(-)


diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7e855f9..cb16615 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1697,6 +1697,17 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	/* Setup buffer sizes */
 	rctl &= ~E1000_RCTL_SZ_4096;
 	rctl |= E1000_RCTL_BSEX;
+
+	/*
+	 * We need to normalize the rx_buffer_len here
+	 * since the hardware only knows about 7 discrete
+	 * frame lengths here.  To accomodate that we need
+	 * to set the rx length in the hardware to the next highest
+	 * size over the rx_buffer_len, then increase rx_buffer_len
+	 * to match it, so that we can get a full mtu sized frame
+	 */
+	adapter->rx_buffer_len = roundup_pow_of_two(adapter->rx_buffer_len);
+
 	switch (adapter->rx_buffer_len) {
 		case E1000_RXBUFFER_256:
 			rctl |= E1000_RCTL_SZ_256;
@@ -1711,7 +1722,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 			rctl &= ~E1000_RCTL_BSEX;
 			break;
 		case E1000_RXBUFFER_2048:
-		default:
 			rctl |= E1000_RCTL_SZ_2048;
 			rctl &= ~E1000_RCTL_BSEX;
 			break;
@@ -1724,6 +1734,9 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 		case E1000_RXBUFFER_16384:
 			rctl |= E1000_RCTL_SZ_16384;
 			break;
+		default:
+			panic("Bad rx_buffer_len size\n");
+			break;
 	}
 
 	ew32(RCTL, rctl);
