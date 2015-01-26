From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: improve error handling when a remote
 crashes
Date: Mon, 26 Jan 2015 15:19:32 -0500
Message-ID: <54C6A154.3090906@oracle.com>
References: <54C6911B.5040501@oracle.com> <20150126195403.GE6437@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26669 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbbAZUTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 15:19:38 -0500
In-Reply-To: <20150126195403.GE6437@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/26/2015 02:54 PM, Sowmini Varadhan wrote:
> 
> 
> 
>> @@ -934,36 +933,36 @@ static struct sk_buff *vnet_clean_tx_ring(struct vnet_port *port,
>>  
>>  	*pending = 0;
>>  
>> -	txi = dr->prod-1;
>> -	if (txi < 0)
>> -		txi = VNET_TX_RING_SIZE-1;
>> -
>> +	txi = dr->prod;
> 
> As I understand it, this starts at dr->prod and goes through all
> descriptors, cleaning up !READY descriptors as it goes around.
> 
> I think you'll have a higher reclaim rate for finding !READY if you
> started at dr->cons instead: dr->cons is the one that was last ACK'ed,
> and that ack would only have been sent after the peer had marked the 
> descriptor as DONE. (consumer would have had a chance to read more
> descriptors, by the time the tx-reclaim loop goes around) 

	Actually, it starts at dr->prod-1, and it stops as soon as it
gets an already-freed descriptor. It could possibly free something
marked as DONE before we've been acked (ie, faster), but it could look
at stuff it doesn't have to. I wanted to be conservative here, though,
because we don't want to miss any and have unfreed data until we go
around the ring. Any pending (in any state) would begin at dr->prod-1,
so there can't be any races with an ACK there.
	At any rate, the intent for this patch is to check and free
skbs in states other than just VIO_DESC_READY and not requiring that
it be VIO_DESC_DONE when there is an allocated buffer associated with it.
The descriptors indices we look at are unchanged by this patch.

> 
>> +		if (port->tx_bufs[txi].skb) {
>> +			if (d->hdr.state != VIO_DESC_DONE)
>> +				pr_warn("invalid ring buffer state %d\n",
>> +					d->hdr.state);
> 
> I would even suggest skipping the pr_warn (maybe make it a viodbg
> instead) as it might alarm the end-user (who cannot really do 
> anything about it other than call us anyway :-)).

	It should only happen if there is active traffic when a remote
crashes, but if a remote is giving us garbage in other cases, I think an
admin would want to check that out.
	A crash based on the behavior of a remote was definitely too much, and
warnings can be turned off too. viodbg() would be useless here-- you wouldn't
turn it on to find these, and if these are occurring without a transmitter
crashing, it'd indicate something more serious.
	So, I think this one should stay (as a warning, which can also be turned
off). The next one is debatable, since it really is an ordinary reset or shutdown
situation and could be removed entirely. I changed the existing warning to at
least be done only once per ring and give some more info, but removing it entirely
seems reasonable to me too.

> 
>>  			   dr->cookies, dr->ncookies);
>> +	if (active_freed)
>> +		pr_warn("%s: active transmit buffers freed for remote %pM\n",
>> +			dev->name, port->raddr);
> 
> Same comment as above.

						+-DLS
