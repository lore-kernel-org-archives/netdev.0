From: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Subject: Re: [PATCH] net_sched: check skb_transport_header_was_set() in qdisc_pkt_len_init()
Date: Mon, 20 May 2013 16:32:16 -0400
Message-ID: <519A8850.8010209@linux.vnet.ibm.com>
References: <1369075650-21005-1-git-send-email-mjrosato@linux.vnet.ibm.com> <1369076323.3301.200.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:35375 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756637Ab3ETUcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 16:32:20 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mjrosato@linux.vnet.ibm.com>;
	Mon, 20 May 2013 16:32:19 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 972656E803A
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 16:32:14 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4KKWHjp65732770
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 16:32:17 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4KKWHtO025136
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 16:32:17 -0400
In-Reply-To: <1369076323.3301.200.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2013 02:58 PM, Eric Dumazet wrote:
> On Mon, 2013-05-20 at 14:47 -0400, Matthew Rosato wrote:
>> commit 1def9238d4aa2 (net_sched: more precise pkt_len computation) does
>> not check to see if skb_transport_header is valid prior to using it in
>> qdisc_pkt_len_init(), which can lead to a kernel panic if
>> skb_transport_header is not valid but gso_size is nonzero.  This patch
>> adds a check for skb_transport_header_was_set().
>>
>> I managed to hit this scenario by driving a burst of traffic from a
>> qemu guest through a macvtap interface, causing a panic in the host kernel.
>>
>> Signed-off-by: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
>> ---
>>   net/core/dev.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index fc1e289..5d0d3af 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2596,7 +2596,7 @@ static void qdisc_pkt_len_init(struct sk_buff *skb)
>>   	/* To get more precise estimation of bytes sent on wire,
>>   	 * we add to pkt_len the headers size of all segments
>>   	 */
>> -	if (shinfo->gso_size)  {
>> +	if (shinfo->gso_size && skb_transport_header_was_set(skb))  {
>>   		unsigned int hdr_len;
>>   		u16 gso_segs = shinfo->gso_segs;
>>
>
> Have you tried a recent kernel ?
>
> I believe this was already discussed.

Mea Culpa.  You are correct, I was missing a macvtap fix that already 
resolves this issue. For the sake of documentation, that fix is 
9b4d669bc06c2 macvtap: set transport header before passing skb to lower 
device.

Applied and verified that problem is resolved.  You can consider this 
patch withdrawn.  Thanks.

>
> Please fix macvtap instead if its still buggy.
>
>
