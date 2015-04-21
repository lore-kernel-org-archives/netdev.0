From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/5] ibmveth: Add support for Large Receive Offload
Date: Tue, 21 Apr 2015 13:59:30 -0500
Message-ID: <55369E12.4060509@linux.vnet.ibm.com>
References: <1429043704-22552-1-git-send-email-tlfalcon@linux.vnet.ibm.com> <1429043704-22552-4-git-send-email-tlfalcon@linux.vnet.ibm.com> <1429048822.7346.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Brian King <brking@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:53383 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530AbbDUS7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 14:59:35 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Tue, 21 Apr 2015 12:59:35 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 955F83E40044
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 12:59:32 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3LIxE6138535418
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 11:59:14 -0700
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3LIxVNG013137
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 12:59:31 -0600
In-Reply-To: <1429048822.7346.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2015 05:00 PM, Eric Dumazet wrote:
> On Tue, 2015-04-14 at 15:35 -0500, Thomas Falcon wrote:
>> Enables receiving large packets from other LPARs. These packets
>> have a -1 IP header checksum, so we must recalculate to have
>> a valid checksum.
>>
>> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
>> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
>> ---
>>  drivers/net/ethernet/ibm/ibmveth.c | 15 ++++++++++++++-
>>  1 file changed, 14 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
>> index 08970c7..05eaca6a 100644
>> --- a/drivers/net/ethernet/ibm/ibmveth.c
>> +++ b/drivers/net/ethernet/ibm/ibmveth.c
>> @@ -1092,6 +1092,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
>>  	struct net_device *netdev = adapter->netdev;
>>  	int frames_processed = 0;
>>  	unsigned long lpar_rc;
>> +	struct iphdr *iph;
>>  
>>  restart_poll:
>>  	while (frames_processed < budget) {
>> @@ -1134,8 +1135,20 @@ restart_poll:
>>  			skb_put(skb, length);
>>  			skb->protocol = eth_type_trans(skb, netdev);
>>  
>> -			if (csum_good)
>> +			if (csum_good) {
>>  				skb->ip_summed = CHECKSUM_UNNECESSARY;
>> +				if (be16_to_cpu(skb->protocol) == ETH_P_IP) {
>> +					skb_set_network_header(skb, 0);
>> +					skb_set_transport_header(skb, sizeof(struct iphdr));
>> +					iph = ip_hdr(skb);
>> +
>> +					/* If the IP checksum is not offloaded and if the packet
>> +					 *  is large send, the checksum must be rebuilt.
>> +					 */
>> +					if (iph->check == 0xffff)
>> +						iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
>
> How can this possibly work ?
>
> Normally you would have to set iph->check to 0 before calling
> ip_fast_csum(), as done in ip_send_check()
I don't have an answer for why I weren't seeing any problems while testing this, but I'll go back and set iph->check to zero and retest.  Thanks for noticing this.
>
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
