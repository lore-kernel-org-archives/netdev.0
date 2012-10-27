From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Sat, 27 Oct 2012 10:50:23 +0200
Message-ID: <1351327823.30380.132.camel@edumazet-glaptop>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
	 <alpine.LFD.2.00.1210262325480.2880@ja.ssi.bg>
	 <1351287724.30380.35.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1210270111030.3241@ja.ssi.bg>
	 <CAGK4HS922-xSd0YQdE2kExzMci8A36v_m_GPa17FM7wMJ08n3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com, ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:54824 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756296Ab2J0Iu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 04:50:27 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1105149eaa.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 01:50:26 -0700 (PDT)
In-Reply-To: <CAGK4HS922-xSd0YQdE2kExzMci8A36v_m_GPa17FM7wMJ08n3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-26 at 17:07 -0700, Vijay Subramanian wrote:

> 
> Thanks for the feedback. I will wait for suggestions as to what to do
> with the patch and have another look at the code.

It seems to me current code for defer accept should be fixed as well.

'Allowing' to send the last SYNACK hoping this wont be lost somewhere
seems really strange.

syn_ack_recalc(...)
{

...
        /*
         * Do not resend while waiting for data after ACK,
         * start to resend on end of deferring period to give
         * last chance for data or ACK to create established socket.
         */
        *resend = !inet_rsk(req)->acked ||
                  req->num_timeout >= rskq_defer_accept - 1;
}

DEFER_ACCEPT should really mean :

We have the socket, only defer putting it in the accept queue until :

- Client sent data.
Or
- A given amount of time has elapsed


Defer accept is typically used by protocols where client sends the first
chunk of data. 

If after XX seconds chunk of data is still not there, sending a SYNACK
wont really help : just pass the fd to application and application
probably will wait another XX seconds for the client request, then
timeout and close the socket.

So instead of sending a final SYNACK just to be able to receive an ACK
and finally put the request into listener accept queue is a waste of
bandwidth. We should put the request into listener accept queue and save
one/two messages.
