From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [Xen-devel] [RFC PATCH 12/13] xen-netfront: implement TX
 persistent grants
Date: Tue, 19 May 2015 10:20:47 +0000
Message-ID: <77896F5F-DC2C-4F2A-9BB3-CE5F404DCECC@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-13-git-send-email-joao.martins@neclab.eu>
 <555A0B5D.3090505@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:55485 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755253AbbESKVB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 06:21:01 -0400
In-Reply-To: <555A0B5D.3090505@citrix.com>
Content-Language: en-US
Content-ID: <C854FC717322914F94FCBB132218EE22@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 18 May 2015, at 17:55, David Vrabel <david.vrabel@citrix.com> wrote:
> On 12/05/15 18:18, Joao Martins wrote:
>> Instead of grant/revoking the buffer related to the skb, it will use
>> an already granted page and memcpy  to it. The grants will be mapped
>> by xen-netback and reused overtime, but only unmapped when the vif
>> disconnects, as opposed to every packet.
>> 
>> This only happens if the backend supports persistent grants since it
>> would, otherwise, introduce the overhead of a memcpy on top of the
>> grant map.
> [...]
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
> [...]
>> @@ -1610,7 +1622,10 @@ static int xennet_init_queue(struct netfront_queue *queue)
>> 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
>> 		skb_entry_set_link(&queue->tx_skbs[i], i+1);
>> 		queue->grant_tx[i].ref = GRANT_INVALID_REF;
>> -		queue->grant_tx[i].page = NULL;
>> +		if (queue->info->feature_persistent)
>> +			queue->grant_tx[i].page = alloc_page(GFP_NOIO);
> 
> Need to check for alloc failure here and unwind correctly?
Sorry, I overlooked this check. I will fix that.

> Why NOIO?
May be I am misusing NOIO where I meant __GFP_WAIT.
Tough given we are under rtnl_lock() perhaps GFP_ATOMIC should be used instead.