From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v2 0/7] TCP Fast Open client
Date: Fri, 17 Aug 2012 11:15:44 -0700
Message-ID: <CAK6E8=fUE47EiCQUs=0E2z6VVUChuKccVA_tDWZxKkFPg0YFOg@mail.gmail.com>
References: <1342645307-17772-1-git-send-email-ycheng@google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FB6@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:53987 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757336Ab2HQSQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 14:16:06 -0400
Received: by obbuo13 with SMTP id uo13so5602487obb.19
        for <netdev@vger.kernel.org>; Fri, 17 Aug 2012 11:16:05 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FB6@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 16, 2012 at 1:50 AM, David Laight <David.Laight@aculab.com> wrote:
> This comment is a bit late but ...
>
>> ...
>> This patch series implement the client functionality of TCP Fast Open.
>> TCP Fast Open (TFO) allows data to be carried in the SYN and SYN-ACK
>> packets and consumed by the receiving end during the initial
> connection
>> handshake, thus providing a saving of up to one full round trip time
>> (RTT)
>> compared to standard TCP requiring a three-way handshake (3WHS) to
>> complete before data can be exchanged.
>> ...
>> To use Fast Open, the client application (active SYN sender) must
>> replace connect() socket call with sendmsg() or sendto() with the new
>> MSG_FASTOPEN flag. If the server supports Fast Open the data exchange
>> starts at TCP handshake. Otherwise the connection will automatically
>> fall back to conventional TCP.
>
> It seems wrong to be using sendmsg() to perform a 'connect' action.
> Anything that tries to monitor the socket state from a trace, or
> validate the sequence of library calls will get it all wrong.
>
> IMHO this should be a new connect_xxx() function - and probably
> a new system call entry.
>
> This is similar to the complete fubar where sctp abuses setsockopt().
>
> For development hacking using sendmsg() probably avoided the need
> to hack at some code paths, but I'm sure it will cause grief in
> the long term.
>
> Other OS may have much more difficultly in abusing sendmsg().
User/developers' feedback are always welcome so thanks for that.

First of all, sendmsg(MSG_FASTOPEN) does not exclude a new socket
call like connect_with_data().

Unlike many TCP features that don't require API change, TFO does.
When we started, we have several non-exclusive choices:
a) connect_xxx() like you proposed
b) send{to|msg}(MSG_FASTOPEN)
c) setsockopt(optval=data)
d) setsockopt(optval=TFO), make connect() a nop, first write() sends SYN+data.

We surveyed existing works and also discussed with a few developers
before landing on (b). For example, R. Stevens implemented the
pioneer work T/TCP with sendto(MSG_EOF) in BSD in his TCP/IP
illustrated vol3. There is also a Linux patch too. So we know at
least (b) is a viable route. Chrome browser developers chose (b) and
quickly modified the browser accordingly to support TFO.

Another benefit of sendmsg is it allows vector writes right away
and may support MSG_EOF in the future (connect()+write()+close()=SYN+data+FIN).

Most importantly, we want to minimize the application change in
the hope of broader usage to collect more feedbacks about TFO.
If many developers think a new connect() API is better, it's not
that difficult to add one in the kernel IMO. I am happy to do try that.

Cheers,

Yuchung
>
>         David
>
>
>
