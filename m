From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] sfc: Convert the normal transmit complete path
 to dev_consume_skb_any()
Date: Tue, 09 Sep 2014 16:38:32 -0700
Message-ID: <540F8F78.9020502@hp.com>
References: <20140909214327.D474F290042C@tardy> <1410304704.7106.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sshah@solarflare.com,
	linux-net-drivers@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <raj@tardy.usa.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:1113 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527AbaIIXi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 19:38:57 -0400
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com [15.192.137.9])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id B2689118F
	for <netdev@vger.kernel.org>; Tue,  9 Sep 2014 23:38:44 +0000 (UTC)
In-Reply-To: <1410304704.7106.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2014 04:18 PM, Eric Dumazet wrote:
> On Tue, 2014-09-09 at 14:43 -0700, Rick Jones wrote:
>> From: Rick Jones <rick.jones2@hp.com>
 >> ...
>> Compile tested only.  Also a fixup to make scripts/checkpatch.pl
>> happy.
>>
>> diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
>> index 65c220f..3206098 100644
>> --- a/drivers/net/ethernet/sfc/tx.c
>> +++ b/drivers/net/ethernet/sfc/tx.c
>> @@ -78,7 +78,7 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
>>   	if (buffer->flags & EFX_TX_BUF_SKB) {
>>   		(*pkts_compl)++;
>>   		(*bytes_compl) += buffer->skb->len;
>> -		dev_kfree_skb_any((struct sk_buff *) buffer->skb);
>> +		dev_consume_skb_any((struct sk_buff *)buffer->skb);
>>   		netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
>>   			   "TX queue %d transmission id %x complete\n",
>>   			   tx_queue->queue, tx_queue->read_count);
>
> Right, but please remove this ugly cast while you are at it ;)
>

I can remove that const, and then smooth the ripples stemming from it to 
arrive at something like:

diff --git a/drivers/net/ethernet/sfc/net_driver.h 
b/drivers/net/ethernet/sfc/ne
index 9ede320..a75aa08 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -148,7 +148,7 @@ struct efx_special_buffer {
   */
  struct efx_tx_buffer {
         union {
-               const struct sk_buff *skb;
+               struct sk_buff *skb;
                 void *heap_buf;
         };
         union {
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 65c220f..a43c0c5 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -78,7 +78,7 @@ static void efx_dequeue_buffer(struct efx_tx_queue 
*tx_queue,
         if (buffer->flags & EFX_TX_BUF_SKB) {
                 (*pkts_compl)++;
                 (*bytes_compl) += buffer->skb->len;
-               dev_kfree_skb_any((struct sk_buff *) buffer->skb);
+               dev_consume_skb_any(buffer->skb);
                 netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
                            "TX queue %d transmission id %x complete\n",
                            tx_queue->queue, tx_queue->read_count);
@@ -1086,7 +1086,7 @@ static int tso_get_fragment(struct tso_state *st, 
struct e
   * of fragment or end-of-packet.
   */
  static void tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
-                                         const struct sk_buff *skb,
+                                         struct sk_buff *skb,
                                           struct tso_state *st)
  {
         struct efx_tx_buffer *buffer;


(might be mangled by this email client)


But perhaps someone from SolarFlare can say why that was a const to 
begin with.

rick
