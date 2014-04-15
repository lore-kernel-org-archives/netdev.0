From: Jianhua Xie <jianhua.xie@freescale.com>
Subject: Re: TCP checksum problem
Date: Tue, 15 Apr 2014 19:44:10 +0800
Message-ID: <534D1B8A.1090301@freescale.com>
References: <53488811.2080602@alten.se> <1397263768.4222.1.camel@edumazet-glaptop2.roam.corp.google.com> <534C0E18.5050702@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arvid Brodin <arvid.brodin@alten.se>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0185.outbound.protection.outlook.com ([207.46.163.185]:4915
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750866AbaDOL7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2014 07:59:05 -0400
In-Reply-To: <534C0E18.5050702@alten.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/15/2014 12:34 AM, Arvid Brodin wrote:
> On 2014-04-12 02:49, Eric Dumazet wrote:
>> On Sat, 2014-04-12 at 02:25 +0200, Arvid Brodin wrote:
>>> Hi,
>>>
>>> I'm trying to insert a 6-byte HSR header into a newly copied skb,
>>> between the ethernet header and the IP header. The skb comes from my
>>> virtual device's ndo_start_xmit() function and is to be sent on to a
>>> physical interface after modification. Essentially, this is what I'm
>>> doing:
>>>
>>> 	skb = skb_copy_expand(skb, skb_headroom(skb) + HSR_HLEN, 0,
>>> GFP_ATOMIC);
>>>
>>> 	/* Move ethernet header to make room for the HSR header */
>>> 	src = skb_mac_header(skb);
>>> 	WARN_ON_ONCE(src != skb->data);
>>> 	dst = skb_push(skb, HSR_HLEN);
>>> 	memmove(dst, src, ETH_HLEN);
>>> 	skb_reset_mac_header(skb);
>>>
>>> 	/* Fill in the 6-byte header */
>>> 	hsr_fill_tag(skb, frame, port);
>>>
>>> 	/* Point the skb to the physical interface */
>>> 	skb->dev = port->dev;
>>>
>>> 	dev_queue_xmit(skb);
>>>
>>> But something goes wrong with the TCP checksum on the way out. Arp,
>>> ping etc works fine, but anything using TCP is discarded by the
>>> receiver due to incorrect TCP checksums.
>>>
>>> Using wireshark and some printks, I've managed to decide that the
>>> updated TCP checksum is written offset by -6 bytes from where it
>>> should be (into what wireshark calls the TCP header "acknowledgement
>>> number" field).
>>>
>>> Any idea why this happens? I've spent a few days on this now and I'm
>>> running out of ideas...
>>>
>>> This is run on the cadence/macb ethernet device. Before the call to
>>> skb_copy_expand(), skb->ip_summed is CHECKSUM_PARTIAL, skb->csum_start
>>> is 120, and skb->csum_offset is 16. The total frame length is 80 bytes
>>> (on the wire as reported by wireshark - I think this is excluding the
>>> FCS).
>>>
>>>
>> You need to set skb->csum_start to the new offset.
>>
>> ( skb_transport_header(skb) - skb->head )
>>
>> Check how __tcp_v4_send_check() sets csum_start & csum_offset
>>
>> (csum_offset you can leave it as is)
>>
> I recompiled my code today and ran it again, and it worked. I have no
> idea what change I made, althought I know I first used
>
> skb = __pskb_copy(skb, skb_headroom(skb) + HSR_HLEN, GFP_ATOMIC);
>
> instead of
>
> skb = skb_copy_expand(skb, skb_headroom(skb) + HSR_HLEN, 0, GFP_ATOMIC);
>
> for the allocation of the new skb. The latter adjusts csum_start, the
> former doesn't. I may have changed to the latter and simultaneously
> added a manual adjustment to csum_start, because I know I was surprised
> that the checksum moved 2*HSR_HLEN bytes when I did the adjustment. :)
>
> Anyway, it seems to work now. Thanks for the help!
>
>
in your old codes, there called:

dst = skb_push(skb, HSR_HLEN);
this line changed skb->data -= HSR_HLEN;
the skb->csum_start might be from skb->data, you might add 1 line:
skb->csum_start += HSR_HLEN;

I am not very sure, you can have a try. I would be glad if it can help you.

Best Regards,
Jianhua
  
