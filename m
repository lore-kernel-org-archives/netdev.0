From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY instead of copy" series.
Date: Thu, 1 May 2014 15:59:11 +0200
Message-ID: <1810270947.20140501155911@eikelenboom.it>
References: <395225650.20140430124506@eikelenboom.it> <536162D3.5080307@citrix.com> <94755525.20140501002553@eikelenboom.it> <53624E25.8040404@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:40366 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941AbaEAN7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 09:59:16 -0400
In-Reply-To: <53624E25.8040404@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, May 1, 2014, 3:37:41 PM, you wrote:

> On 30/04/14 23:25, Sander Eikelenboom wrote:
>>
>> Wednesday, April 30, 2014, 10:53:39 PM, you wrote:
>>
>>> On 30/04/14 11:45, Sander Eikelenboom wrote:
>>>> Hi Zoltan,
>>>>
>>>> Your series "TX grant mapping with SKBTX_DEV_ZEROCOPY instead of copy", merged into mainline with merge commit 4caeccb4de76440e433a15009636e77d003eb3d6,
>>>> seem to introduce a subtle bug on network traffic between 2 guests on a bridge on the same host.
>>>> I have one guest running apache as webdav server with SSL and another guest that is using that is uploading large files to that webdav server.
>>>> Small requests (some get's and propfind's) seem to work ok, but when the bulk uploading begins it fails with:
>>>>
>>>> Attempt 1 failed. SSLError: [Errno 1] _ssl.c:1415: error:140943FC:SSL routines:SSL3_READ_BYTES:sslv3 alert bad record mac
>>>> Attempt 2 failed. SSLError: [Errno 1] _ssl.c:1415: error:140943FC:SSL routines:SSL3_READ_BYTES:sslv3 alert bad record mac
>>>> Attempt 3 failed. SSLError: [Errno 1] _ssl.c:1415: error:140943FC:SSL routines:SSL3_READ_BYTES:sslv3 alert bad record mac
>>>> Attempt 4 failed. SSLError: [Errno 1] _ssl.c:1415: error:140943FC:SSL routines:SSL3_READ_BYTES:sslv3 alert bad record mac
>>>>
>>>> So some how large (probably fragmented) packets can get mangled when from guest to guest on the same host.
>>>> I don't see this with clients that upload large files from external sources.
>>>> Probably if SSL wasn't complaining it would probably be unnoticed for longer and doing some silent corruption.
>>>>
>>>> I first blamed openssl, since it started around all the latest openssl mayhem and updates, but it turns out it is all xen-netback related again.
>>>>
>>>> Since these commits break bisectabillity:
>>>>       - 1bb332af4cd889e4b64dacbf4a793ceb3a70445d  (note in commit message && kernel panic)
>>>>       - 62bad3199a4c20505fc36c169deef20b25e17c5f  (kernel panic)
>>>> i stopped bisecting at this point.
>>>>
>>>> The upside is .. it's 100% reproduceable :-)
>>> That's good :) Can you take tcpdump captures along the way (sending
>>> guest, dom0, receiving guest), and try to work out which packets are
>>> different, and where? Although taking captures in Dom0 might change your
>>> result, as it triggers the pages to be copied and unmapped before they
>>> reach their target.
>>
>>> Thanks,
>>> Zoli
>>
>>
>> Hrrmm that sounds like a lot of data and a lot of work ..
> If you could make captures in the sending and receiving guest with 
> tcpdump (take care of increasing snaplen so the whole packet is there, 
> and filter to the SSH connection itself), and upload it somewhere for 
> me, that would be enough for start. I will try to work out where the 
> corruption happens.
> Also, do you have timestamps for the above mentioned log entries? I 
> guess they appear on the receiving side.
> And some info about the componenets on the server, so I can work out 
> where is that _ssl.c:1415, and which part of the packet it actually 
> looks for.

They appear on the sending side (duplicity) .. the receiving side (apache + 
mod_dav + ssl | gnu_tls) gives a "Could not get next bucket brigade (URI:"


>>
>> how ever .. could it be just a type and would the following make sense ?
>>
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index 7666540..abeea10 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -1366,7 +1366,7 @@ static int xenvif_handle_frag_list(struct xenvif *vif, struct sk_buff *skb)
>>
>>          xenvif_fill_frags(vif, nskb);
>>          /* Subtract frags size, we will correct it later */
>> -       skb->truesize -= skb->data_len;
>> +       skb->truesize -= nskb->data_len;
>>          skb->len += nskb->len;
>>          skb->data_len += nskb->len;

> Nope, that's correct there: after that skb->truesize will be the size of 
> the struct plus the linear buffer itself. The code is just about the 
> ditch the original fragments plus the skb on the frag_list. When the new 
> pages are created, it will update it again.

Well i just went a head and tried this .. and the uploading does seem to work fine with this change 
.. (that obviously doesn't say anything about correctness)

> Also, this code path runs only if the guest sends more slots we can 
> handle (so we put the extra one to the frag_list until we can get rid of 
> it). On Linux it can only happen with 3.2 or older guest kernels, and 
> only occasionally. As you said, this is 100% reproducible, so I would 
> doubt the problem is with this part of the code.

Well this assumption seems to be incorrect:
        - both dom0 and guest kernels are 3.15-rc3's.
        - but we do end up in this code path

> Zoli
