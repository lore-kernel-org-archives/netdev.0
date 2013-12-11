From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: Re: [PATCH 4/4] asix: C1 DUB-E100 double rx_urb_size to 4096
Date: Wed, 11 Dec 2013 13:28:42 +0100
Message-ID: <52A85A7A.7010902@mentor.com>
References: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com> <1386759028-3534-5-git-send-email-Dean_Jenkins@mentor.com> <AE90C24D6B3A694183C094C60CF0A2F6026B747E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:65028 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab3LKM2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 07:28:46 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B747E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/13 12:30, David Laight wrote:
>> From: Dean Jenkins
>> It seems that for the C1 hardware variant of the D-Link DUB-E100
>> that the rx_urb_size of 2048 is truncating IP fragmented packets due
>> to multiple Ethernet frames being present in a single URB.
>>
>> A simple ping test shows a loss of ping responses
>> ping 172.17.0.10 -f -c 200 -s 1965
>> (172.17.0.1 is the IP address of the target)
>>
>> In the worse case, this test requires a 2049 byte data buffer size
>> to hold the IN bulk transfer but the URB is 2048 in size so the last byte
>> of the Ethernet frame is lost and the Ethernet frame is truncated.
>>
>> This modification resolves "asix_rx_fixup() Bad Header" errors caused by
>> truncation of the Ethernet frame due to the URB buffer being too small.
>>
>> Therefore, increase the rx_urb_size to 4096 to accommodate
>> multiple Ethernet frames being present in a single URB.
> I don't think this will help - you've only moved the error.
> If the hardware manages to feed over 4k of ethernet frame data
> into a single usb bulk data frame it will still go wrong.
I agree in principle, however, I have not seen any evidence of the 4K 
buffer being exceeded. I did a ping test of ping payloads from 0 to 5K 
bytes with no errors. Without the patch, the test fails at ping payloads 
of 1965 (and higher). The test causes IP fragmentation.

The patch certainly helps to avoid failures but perhaps there is a 
better solution ?

I checked with a USB protocol analyser that the C1 DUB-E100 sent a IN 
bulk transfer containing 2049 octets despite the RX URB size being 2048 
bytes long. Therefore, the last octet is lost. The current code fails 
because it waits for the next socket buffer which does not contain the 
missing byte, that octet had already been sent over the wire.

Could this be a symptom of a bug in USB bulk transfer handling ?
> The rx code needs to keep the partial ethernet frame until the
> next usb bulk data urb arrives.
> (This only applies if the urb is a multiple of the usb packet size
> and isn't known to have been terminated by a zero length block.)
With the C1 DUB-E100 I have not seen any Ethernet frames spanning 
multiple URBs but my testing has been limited.
> This should work provided the urb size is a multiple of the usb
> packet size - I don't know if a 1536 (3*512) skb fits into a 4k page.
> If it doesn't you should probably allocate a 5k skb (8k memory).
> (I don't believe there is any point allocating a size inbetween?)
>
> USB3 devices (on USB3 ports) need to allocate buffers that are
> multiples of 1k so that they can process very long bulk rx usb data.
>
> 	David
>
>
>
