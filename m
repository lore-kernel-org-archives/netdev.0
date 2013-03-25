From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 2/6] xen-netfront: reduce gso_max_size
 to account for ethernet header
Date: Mon, 25 Mar 2013 14:39:02 +0000
Message-ID: <51506F9602000078000C8277@nat28.tlf.novell.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
 <1364209702-12437-3-git-send-email-wei.liu2@citrix.com>
 <51505DF9.4080406@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xen.org>,
	<annie.li@oracle.com>, <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>
To: <david.vrabel@citrix.com>, "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:45911 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932094Ab3CYOiR convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Mon, 25 Mar 2013 10:38:17 -0400
In-Reply-To: <51505DF9.4080406@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 25.03.13 at 15:23, David Vrabel <david.vrabel@citrix.com> wrote:
> On 25/03/13 11:08, Wei Liu wrote:
>> The maximum packet including ethernet header that can be handled by netfront 
> /
>> netback wire format is 65535. Reduce gso_max_size accordingly.
>> 
>> Drop skb and print warning when skb->len > 65535. This can 1) save the effort
>> to send malformed packet to netback, 2) help spotting misconfiguration of
>> netfront in the future.
> [...]
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -547,6 +547,18 @@ static int xennet_start_xmit(struct sk_buff *skb, struct 
> net_device *dev)
>>  	unsigned int len = skb_headlen(skb);
>>  	unsigned long flags;
>>  
>> +	/* Wire format of xen_netif_tx_request only supports skb->len
>> +	 * < 64K, because size field in xen_netif_tx_request is
>> +	 * uint16_t. If skb->len is too big, drop it and alert user about
>> +	 * misconfiguration.
>> +	 */
>> +	if (unlikely(skb->len >= (uint16_t)(~0))) {
> 
> Suggest a #define for this maximum added to include/xen/interface/io/netif.h

I don't see a point in doing so. If you want the connection to be
explicit, just use typeof() here instead of uint16_t.

Jan
