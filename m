From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 12/13] xen-netfront: implement TX persistent
 grants
Date: Tue, 19 May 2015 11:23:35 +0100
Message-ID: <555B0F27.8040206@citrix.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-13-git-send-email-joao.martins@neclab.eu>
 <555A0B5D.3090505@citrix.com>
 <77896F5F-DC2C-4F2A-9BB3-CE5F404DCECC@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>
To: Joao Martins <Joao.Martins@neclab.eu>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:54791 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbbESKXi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 06:23:38 -0400
In-Reply-To: <77896F5F-DC2C-4F2A-9BB3-CE5F404DCECC@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/05/15 11:20, Joao Martins wrote:
> 
> On 18 May 2015, at 17:55, David Vrabel <david.vrabel@citrix.com> wrote:
>> On 12/05/15 18:18, Joao Martins wrote:
>>> Instead of grant/revoking the buffer related to the skb, it will use
>>> an already granted page and memcpy  to it. The grants will be mapped
>>> by xen-netback and reused overtime, but only unmapped when the vif
>>> disconnects, as opposed to every packet.
>>>
>>> This only happens if the backend supports persistent grants since it
>>> would, otherwise, introduce the overhead of a memcpy on top of the
>>> grant map.
>> [...]
>>> --- a/drivers/net/xen-netfront.c
>>> +++ b/drivers/net/xen-netfront.c
>> [...]
>>> @@ -1610,7 +1622,10 @@ static int xennet_init_queue(struct netfront_queue *queue)
>>> 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
>>> 		skb_entry_set_link(&queue->tx_skbs[i], i+1);
>>> 		queue->grant_tx[i].ref = GRANT_INVALID_REF;
>>> -		queue->grant_tx[i].page = NULL;
>>> +		if (queue->info->feature_persistent)
>>> +			queue->grant_tx[i].page = alloc_page(GFP_NOIO);
>>
>> Need to check for alloc failure here and unwind correctly?
> Sorry, I overlooked this check. I will fix that.
> 
>> Why NOIO?
> May be I am misusing NOIO where I meant __GFP_WAIT.
> Tough given we are under rtnl_lock() perhaps GFP_ATOMIC should be used instead.

rtnl_lock() is a mutex, so sleeping is allowed, so GFP_KERNEL is fine
here I think.

David
