From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH V4 5/7] xen-netfront: reduce gso_max_size to
 account for max TCP header
Date: Fri, 12 Apr 2013 16:07:05 +0100
Message-ID: <51683F3902000078000CCD33@nat28.tlf.novell.com>
References: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
 <1365776646-10796-6-git-send-email-wei.liu2@citrix.com>
 <1365777899.15783.77.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Vrabel" <david.vrabel@citrix.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ian Campbell" <Ian.Campbell@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:44093 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753776Ab3DLPGV convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Fri, 12 Apr 2013 11:06:21 -0400
In-Reply-To: <1365777899.15783.77.camel@zakaz.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 12.04.13 at 16:44, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> On Fri, 2013-04-12 at 15:24 +0100, Wei Liu wrote:
>> The maximum packet including header that can be handled by netfront / 
> netback
>> wire format is 65535. Reduce gso_max_size accordingly.
>> 
>> Drop skb and print warning when skb->len > 65535. This can 1) save the effort
>> to send malformed packet to netback, 2) help spotting misconfiguration of
>> netfront in the future.
>> 
>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>> ---
>>  drivers/net/xen-netfront.c |   14 +++++++++++++-
>>  1 file changed, 13 insertions(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>> index 1bb2e20..9c2eca1 100644
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -547,6 +547,16 @@ static int xennet_start_xmit(struct sk_buff *skb, 
> struct net_device *dev)
>>  	unsigned int len = skb_headlen(skb);
>>  	unsigned long flags;
>>  
>> +	/* If skb->len is too big for wire format, drop skb and alert
>> +	 * user about misconfiguration.
>> +	 */
>> +	if (unlikely(skb->len > (typeof(tx->size))(~0))) {
> 
> This seems rather a complicated way of saying... er, something!
> 
> Perhaps we could have a #define in netif.h to compare against?
> 
> I'm not 100% convinced that the case and the ~ are in the right order to
> have the behaviour you want unless perhaps sizeof(tx->size) <
> sizeof(int). In any case it's too obfuscated for me ;-)

Previously this was (u16)~0, which I complained to have no
correlation to where the restriction actually comes from. Hence
the request to use typeof() on the very field that doesn't
permit a larger value.

Jan
