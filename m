From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] sctp: change to save MSG_MORE flag into assoc
Date: Fri, 3 Mar 2017 12:49:48 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE74179@AcuExch.aculab.com>
References: <ba64767f352e56cfe694af89445fe155cd431cd0.1488522235.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "Vlad Yasevich" <vyasevich@gmail.com>
To: 'Xin Long' <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:56207 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbdCCNat (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 08:30:49 -0500
In-Reply-To: <ba64767f352e56cfe694af89445fe155cd431cd0.1488522235.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long
> Sent: 03 March 2017 06:24
> David Laight noticed the support for MSG_MORE with datamsg->force_day
> didn't really work as we expected, as the first msg with MSG_MORE set
> would always block the following chunks' dequeuing.
> 
> This Patch is to rewrite it by saving the MSG_MORE flag into assoc as
> Divid Laight suggested.
   ^ typo

> asoc->force_delay is used to save MSG_MORE flag before a msg is sent.
> Once this msg is queued, asoc->force_delay is set back to 0, so that
> it will not affect other places flushing out queue.

That doesn't seem right nor make sense.

> asoc->force_delay works as a 'local param' here as the msg sending is
> under protection of sock lock.  It would make sctp's MSG_MORE work as
> tcp's.

It is much more important to get MSG_MORE working 'properly' for SCTP
than for TCP. For TCP an application can always use a long send.

...
> @@ -1982,6 +1982,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
>  	 * breaks.
>  	 */
>  	err = sctp_primitive_SEND(net, asoc, datamsg);
> +	asoc->force_delay = 0;
>  	/* Did the lower layer accept the chunk? */
>  	if (err) {
>  		sctp_datamsg_free(datamsg);

I don't think this is right - or needed.
You only get to the above if some test has decided to send data chunks.
So it just means that the NEXT time someone tries to send data all the
queued data gets sent.
I'm guessing that the whole thing gets called in a loop (definitely needed
for very long data chunks, or after the window is opened).
Now if an application sends a lot of (say) 100 byte chunks with MSG_MORE
set it would expect to see a lot of full ethernet frames be sent.
With the above a frame will be sent (containing all but 1 chunk) when the
amount of queued data becomes too large for an ethernet frame, and immediately
followed by a second ethernet frame with 1 chunk in it.

Now it might be that the flag needs clearing when retransmissions are queued.
OTOH they might get sent for other reasons.

	David
