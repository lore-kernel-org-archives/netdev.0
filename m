From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: remove HW IP header checksum for IPV6 frame
Date: Tue, 17 Jun 2014 15:34:07 -0700 (PDT)
Message-ID: <20140617.153407.622542669190595342.davem@davemloft.net>
References: <1402993895-10955-1-git-send-email-b38611@freescale.com>
	<20140617163121.GM23430@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b38611@freescale.com, netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966283AbaFQWeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 18:34:08 -0400
In-Reply-To: <20140617163121.GM23430@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Tue, 17 Jun 2014 17:31:21 +0100

> On Tue, Jun 17, 2014 at 04:31:35PM +0800, Fugang Duan wrote:
>> The commit 96c50caa5148 (net: fec: Enable IP header hardware checksum)
>> enable HW IP header checksum for IPV4 and IPV6, which causes IPV6 TCP/UDP
>> cannot work. (The issue is reported by Russell King)
>> 
>> The reason is that FEC HW IP cannot detect the transmit frame type (can
>> detect received frame type), and treats all packets as IPv4, overwrites
>> the point in the packet which would be the IPv4 checksum field. Since IPV6
>> don't have IP header checksum, so this results in the frame being corrupted.
>> 
>> The patch just add software detect the current packet type, if it is IPV6
>> frame, it don't enable IP header checksum.
>> 
>> Cc: Russell King <linux@arm.linux.org.uk>
>> Signed-off-by: Fugang Duan <B38611@freescale.com>
>> ---
>>  drivers/net/ethernet/freescale/fec_main.c |   36 +++++++++++++++++++++-------
>>  1 files changed, 27 insertions(+), 9 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
>> index 38d9d27..c13185a 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -320,6 +320,11 @@ static void *swap_buffer(void *bufaddr, int len)
>>  	return bufaddr;
>>  }
>>  
>> +static inline bool is_ipv4_pkt(struct sk_buff *skb)
>> +{
>> +	return skb->protocol == htons(ETH_P_IP) && ip_hdr(skb)->version == 4;
>> +}
>> +
>>  static int
>>  fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
>>  {
>> @@ -330,7 +335,8 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
>>  	if (unlikely(skb_cow_head(skb, 0)))
>>  		return -1;
>>  
>> -	ip_hdr(skb)->check = 0;
>> +	if (is_ipv4_pkt(skb))
>> +		ip_hdr(skb)->check = 0;
>>  	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
>>  
>>  	return 0;
> 
> As I suspected, just applying the above two hunks fixes the problem
> I was seeing.

Someone please respin the patch so that it's just these two hunks and that
the commit message accurately describes the real situation.

Thanks.
