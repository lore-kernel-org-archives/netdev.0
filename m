From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: af_packet / TX_RING not fully non-blocking (w/ MSG_DONTWAIT)
Date: Sat, 04 Apr 2015 00:22:14 +0200
Message-ID: <551F1296.6090003@iogearbox.net>
References: <551D1F86.8050200@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33801 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbbDCWWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 18:22:16 -0400
In-Reply-To: <551D1F86.8050200@fokus.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mathias,

On 04/02/2015 12:52 PM, Mathias Kretschmer wrote:
> Dear all,
>
> we have encountered a problem where the send(MSG_DONTWAIT) call on a TX_RING is not fully non-blocking in cases where the device's sndBuf is full (i.e. we are trying to write faster than the device can handle).
>
> This is on a WLAN radio (so it's not that hard to achieve :).
>
> Comparing the TX_RING send() handler to the regular send() handler, the difference seems to be in the sock_alloc_send_skb() call where, the regular handler passes a (flags & MSG_DONTWAIT), while the TX_RING handler always passes a 0 (block).
>
> The attached patch changes this behavior by
>
> a) also passing (flags & MSG_DONTWAIT)
> b) adjusting the return code so that -ENOBUFS is returned if no frame could be sent or to return the number of bytes sent, if frame(s) could be sent within this call.
>
> The proposed modification works fine for us and has been tested extensively with WLAN and Ethernet device.
>
> Feel free to apply this patch if you agree with this solution.
> Of course, we're also open to other solutions / proposals / ideas.

Please send a proper patch with SOB, and no white space corruption
(there are spaces instead of tabs).

+		if (skb == NULL) {
+	                /* we assume the socket was initially writeable ... */
+                        if (likely(len_sum > 0))
+                        	err = len_sum;
+                	else
+                        	err = -ENOBUFS;
  			goto out_status;

What I'm a bit worried about is, if existing applications would be
able to handle -ENOBUFS? Any reason you don't let -EAGAIN from the
sock_alloc_send_skb() not pass through?

Well, man 2 sendmsg clearly describes the -EAGAIN possibility as
"the socket is marked nonblocking and the requested operation would
block". So far it was apparently not returned since here we'd just
have blocked, but strictly speaking non-blocking applications would
need to be aware and should handle -EAGAIN, that awareness might be
more likely than -ENOBUFS, imho. What do you think?

Cheers,
Daniel
