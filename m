From: Elof Vrigborn <elof.vrigborn@ericsson.com>
Subject: RE: [PATCH 1/1] cdc_ncm: Fix TCP Window Size issue by CDC NCM driver
Date: Mon, 13 Jun 2011 13:24:38 +0200
Message-ID: <4E8D7EAEFBB4FB4EA759B93328E8C1A4293DC1CFA5@ESESSCMS0354.eemea.ericsson.se>
References: <1307713174-533-1-git-send-email-elof.vrigborn@ericsson.com>
 <1307715036.4044.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Oliver Neukum <oliver@neukum.name>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:53637 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093Ab1FMLYm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 07:24:42 -0400
In-Reply-To: <1307715036.4044.11.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> I find this patch dubious.
> 
> skb truesize is not meant to be skb->len + sizeof(struct sk_buff);
> 
> truesize is really accounting for the truesize of memory 
> blocks, not the used one.
> 
> Many drivers allocate a full 2Kbyte block, even if only 100 
> bytes are used in it. If we want to reduce "truesize", then 
> we perform a "copybreak", to allocate a right sized skb. Some 
> NICS do that for small frames.
> 
> If you have TCP performance problems, this might be because 
> of another high level problem. This truesize underestimation 
> is only hiding the problem, but makes the whole machine more 
> subject to OOM bugs.
> 
> Could you provide more information ?
> 
> 
> 
I'll explain further: The skb_in input of cdc_ncm_rx_fixup function holds the data of several ethernet packets received, as collected in one NCM packet. In CDC NCM driver cdc_ncm_rx_fixup function the skb_in is traversed and a new skb clone is created for each of the contained ethernet packets. Each of these clones are then modified by the len and data members to present only one ethernet packet each, but the truesize still is indicating the truesize of the parent skb which were holding the data of all clones. Each of the clones, but not the parent, will end up in the tcp_grow_window function now indicating the len of a single ethernet packet but a truesize of the collected ethernet packets. To the tcp_grow_window function of the TCP stack this seems as there is a huge overhead for each sk
 b, as it analyzes the skb clones but not the parent skb when comparing the len to the truesize when determining how to increase rcv_ssthres. By limiting rcv_ssthres, also the the advertised TCP window size will be limited, leading to the TCP throughput performance being low.

The original reason for simply cloning the skb holding the several packets, instead of any "copybreak" would probably be to limit the need for memory operations on the received data. I can not tell if this was a good or not so good choise.

Drivers that allocate 2Kbyte blocks and then use only a portion of that does in fact introduce the indicated overhead. But the situation with the CDC NCM driver is that the skb clones are only seemingly introducing an overhead. In reality, as indicated by the further non-used skb parent, there is in fact no such overhead.

Yes, we do have TCP throughput performance problems. By comparing the handling of data received through other interfaces we could conclude that the performance issue was due to that tcp_grow_window function of the TCP stack did limit the rcv_ssthres in Check #2 because of skb->truesize was much larger than the skb->len, for the abocve described clones. 
