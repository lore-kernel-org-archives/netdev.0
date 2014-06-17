From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP data chunk bundling when SCTP_NODELAY is set
Date: Tue, 17 Jun 2014 11:45:45 -0400
Message-ID: <53A062A9.70806@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1725DD38@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:36480 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756070AbaFQPpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 11:45:49 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so8285366qab.3
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 08:45:48 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725DD38@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2014 10:17 AM, David Laight wrote:
> If SCTP_NODELAY is set it is difficult to get SCTP to bundle
> data chunks into ethernet packets.
> This leads to very high packet rates which bundling could easily
> reduce by a factor or 8 or 10.
> 
> Nagle can't really be enabled because it generates unwanted delays
> when traffic is light (Nagle only really works for unidirectional bulk
> data and command-response when the messages are smaller than the mtu).
> 
> Even if the sending application knows it has more data to send,
> there isn't much it can do to get the chunks bundled.
> 
> AFAICT 'corking' the socket even stops full sized packets being
> sent - so the application will deadlock if the socket write
> buffer size is reached before the socket is 'uncorked'.
> This also means that the application can't send back to back
> full sized packets unless it uncorks the socket at exactly
> the right places.
> 
> MSG_MORE isn't supported by SCTP, but I'm not sure it would help.
> You really need a MSG_NO_MORE flag and to leave Nagle enabled.
> 
> About the only thing I can think of is to normally have Nagle
> enabled, and then perform the following sequence to force the
> buffered data chunks be sent:
> 1) disable Nagle
> 2) cork the socket
> 3) uncork the socket
> 4) enable Nagle
> Four socket calls is a little excessive!

First, how are you corking an SCTP socket?  There is no SCTP_CORK
and looking at the code, I don't see how an SCTP queue can be
cored by user...

I suppose we could implement SCTP_CORK to do the right thing.

I thought is possibly utilizing something like sendmmsg() and passing
an extra flag to let it be know that this is a multi-message send
that should be queued up by sctp..

-vlad

> 
> Any other ideas ?
> 
> 	David
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
