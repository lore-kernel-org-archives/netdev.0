From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: Re: af_packet / TX_RING not fully non-blocking (w/ MSG_DONTWAIT)
Date: Sat, 4 Apr 2015 10:36:55 +0200
Message-ID: <551FA2A7.30208@fokus.fraunhofer.de>
References: <551D1F86.8050200@fokus.fraunhofer.de> <551F1296.6090003@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------090402080108040305080700"
Cc: <netdev@vger.kernel.org>, <willemb@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay42-dus.antispameurope.com ([94.100.134.242]:45839 "EHLO
	mx-relay42-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752228AbbDDIhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 04:37:01 -0400
In-Reply-To: <551F1296.6090003@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------090402080108040305080700
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

Hi Daniel,

you are right, EAGAIN seems more appropriate.

I thought packet_snd() would return this - it rather seems that I need 
glasses :)

Anyway, new patch attached. (Hopefully without spaces this time).

Cheers,

Mathias

On 04/04/2015 12:22 AM, Daniel Borkmann wrote:
> Hi Mathias,
>
> On 04/02/2015 12:52 PM, Mathias Kretschmer wrote:
>> Dear all,
>>
>> we have encountered a problem where the send(MSG_DONTWAIT) call on a 
>> TX_RING is not fully non-blocking in cases where the device's sndBuf 
>> is full (i.e. we are trying to write faster than the device can handle).
>>
>> This is on a WLAN radio (so it's not that hard to achieve :).
>>
>> Comparing the TX_RING send() handler to the regular send() handler, 
>> the difference seems to be in the sock_alloc_send_skb() call where, 
>> the regular handler passes a (flags & MSG_DONTWAIT), while the 
>> TX_RING handler always passes a 0 (block).
>>
>> The attached patch changes this behavior by
>>
>> a) also passing (flags & MSG_DONTWAIT)
>> b) adjusting the return code so that -ENOBUFS is returned if no frame 
>> could be sent or to return the number of bytes sent, if frame(s) 
>> could be sent within this call.
>>
>> The proposed modification works fine for us and has been tested 
>> extensively with WLAN and Ethernet device.
>>
>> Feel free to apply this patch if you agree with this solution.
>> Of course, we're also open to other solutions / proposals / ideas.
>
> Please send a proper patch with SOB, and no white space corruption
> (there are spaces instead of tabs).
>
> +        if (skb == NULL) {
> +                    /* we assume the socket was initially writeable 
> ... */
> +                        if (likely(len_sum > 0))
> +                            err = len_sum;
> +                    else
> +                            err = -ENOBUFS;
>              goto out_status;
>
> What I'm a bit worried about is, if existing applications would be
> able to handle -ENOBUFS? Any reason you don't let -EAGAIN from the
> sock_alloc_send_skb() not pass through?
>
> Well, man 2 sendmsg clearly describes the -EAGAIN possibility as
> "the socket is marked nonblocking and the requested operation would
> block". So far it was apparently not returned since here we'd just
> have blocked, but strictly speaking non-blocking applications would
> need to be aware and should handle -EAGAIN, that awareness might be
> more likely than -ENOBUFS, imho. What do you think?
>
> Cheers,
> Daniel


-- 
Dr. Mathias Kretschmer, Head of Competence Center
Fraunhofer FOKUS Network Research
A Schloss Birlinghoven, 53754 Sankt Augustin, Germany
T +49-2241-14-3466, F +49-2241-14-1050
E mathias.kretschmer@fokus.fraunhofer.de


--------------090402080108040305080700
Content-Type: text/x-patch; name="005-af_packet_no_block_tx.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="005-af_packet_no_block_tx.patch"

diff -uNpr linux-3.16.7.orig/net/packet/af_packet.c linux-3.16.7/net/packet/af_packet.c
--- linux-3.16.7.orig/net/packet/af_packet.c	2014-10-30 16:41:01.000000000 +0000
+++ linux-3.16.7/net/packet/af_packet.c	2015-04-04 08:31:20.311554717 +0000
@@ -2291,11 +2291,14 @@ static int tpacket_snd(struct packet_soc
 		tlen = dev->needed_tailroom;
 		skb = sock_alloc_send_skb(&po->sk,
 				hlen + tlen + sizeof(struct sockaddr_ll),
-				0, &err);
+				!need_wait, &err);
 
-		if (unlikely(skb == NULL))
+		if (skb == NULL) {
+			/* we assume the socket was initially writeable ... */
+			if (likely(len_sum > 0))
+				err = len_sum;
 			goto out_status;
-
+		}
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
 					  addr, hlen);
 		if (tp_len > dev->mtu + dev->hard_header_len) {

--------------090402080108040305080700--
