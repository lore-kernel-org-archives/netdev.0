From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net-next v2 1/1] net: fec: Add VLAN receive HW support.
Date: Tue, 2 Jul 2013 10:39:31 +0100
Message-ID: <51D29FD3.5030804@mentor.com>
References: <Jim_Baxter_<jim_baxter@mentor.com> <1372428503-13744-1-git-send-email-jim_baxter@mentor.com> <20130701.170929.2145379004044730481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <Frank.Li@freescale.com>, <B38611@freescale.com>,
	<fabio.estevam@freescale.com>, <l.stach@pengutronix.de>,
	<shawn.guo@linaro.org>, <netdev@vger.kernel.org>,
	<bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:38767 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250Ab3GBJjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 05:39:36 -0400
In-Reply-To: <20130701.170929.2145379004044730481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/13 01:09, David Miller wrote:
> From: Jim Baxter <jim_baxter@mentor.com>
> Date: Fri, 28 Jun 2013 15:08:23 +0100
> 
>> @@ -803,6 +807,9 @@ fec_enet_rx(struct net_device *ndev, int budget)
>>  	ushort	pkt_len;
>>  	__u8 *data;
>>  	int	pkt_received = 0;
>> +	struct	bufdesc_ex *ebdp = NULL;
>> +	bool	vlan_packet_rcvd = false;
>> +	u16	vlan_tag;
>>  
>>  #ifdef CONFIG_M532x
>>  	flush_cache_all();
>> @@ -866,6 +873,24 @@ fec_enet_rx(struct net_device *ndev, int budget)
>>  		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
>>  			swap_buffer(data, pkt_len);
>>  
>> +		/* Extract the enhanced buffer descriptor */
>> +		ebdp = NULL;
>> +		if (fep->bufdesc_ex)
>> +			ebdp = (struct bufdesc_ex *)bdp;
> 
> I would use a union here, so you'd have something like:
> 
> 	union {
> 		struct bufdesc		*bdp;
> 		struct bufdesc_ex	*bdp_ex;
> 	} *p;
> 
> Alternatively, you can always use "struct bufdesc_ex *p", along with
> the boolean saying if the extended descriptors are in use.
> 

I see (I think) I would replace the variables:
struct bufdesc *bdp;
struct	bufdesc_ex *ebdp

with a single union variable *p and then access p.bdp where the *bdp  is
currently used and use the fep->bufdesc_ex flag to determine if p.bdp_ex
can be accessed instead of my *ebdp variable.


>> +		if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
>> +				ebdp && (ebdp->cbd_esc & BD_ENET_RX_VLAN)) {
> 
> This is not indented properly.   The "ebp" on that second line must line
> up exactly with the first column after the openning parenthesis on the
> first line.
> 
> I see what you're trying to do, purely using TAB characters to indent
> that second line.  But you must take the care and time to use the
> appropriate number of TAB and space characters to place things at the
> proper column.
> 

Thank you, I will do this correctly in future.

>> +			skb_copy_to_linear_data_offset(skb, (2 * ETH_ALEN),
>> +					data + payload_offset,
>> +					pkt_len - 4 - (2 * ETH_ALEN));
> 
> Again, line up the first non-space character on the second and third
> lines of this function call so that they line up to the first column
> after the openning parenthesis of the first line.
> 
>> +				__vlan_hwaccel_put_tag(skb,
>> +						htons(ETH_P_8021Q), vlan_tag);
> 
> Likewise.
> 

Jim
