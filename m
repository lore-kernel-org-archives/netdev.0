From: Caitlin Bestler <caitlin.bestler@gmail.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 10:26:58 -0700
Message-ID: <469958e00905211026q468de6fbh2b5932d177b7c7a9@mail.gmail.com>
References: <20090520230652.GB5956@ghostprotocols.net>
	 <469958e00905210938s371b5dect28c7b1f8bb751ad1@mail.gmail.com>
	 <20090521165515.GK5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:13897 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbZEUR07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 13:26:59 -0400
Received: by an-out-0708.google.com with SMTP id d40so2660350and.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2009 10:26:59 -0700 (PDT)
In-Reply-To: <20090521165515.GK5956@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2009 at 9:55 AM, Arnaldo Carvalho de Melo
<acme@ghostprotocols.net> wrote:

>
> I.e. recvmmsg would save the value of sk->sk_rcvtimeo at entry and
> restore at exit, and would somehow go on subtracting the time
> sock_recvmsg() took from it so that the following call finds a reduced
> sk->sk_rcvtimeo iif it was configured in the first place and the socket
> is in blocking mode.
>
> How does that sound?
>

I suspect that an additional timeout value will be needed ultimately.

Essentially there is the existing timeout (how long will I wait before I
want to be told that there have been no messages) and an additional
"delivery pending" timeout (how long can the delivery of a message
be delayed to attempt to coalesce it with other messages).

There is also one sticky compliance issue with SCTP, delivery of an
UNORDERED message MUST NOT be delayed waiting for other traffic.
There is no guarantee that the local client will be scheduled immediately,
just a prohibition on delaying delivery for the purpose of bundling.

That might mean a specific transport would have to support multiple
conditional timeouts: maximum delay after an SCTP Event, after an
UNORDERED message, after a message with PPID X, etc. Or for
TCP after a PUSH FLAG, or after certain flags have been set, etc.

Those could probably be reduced to delivering immediately after
any message that the transport flags as "urgent", and *all* error
completions are urgent (which is what the code first shown does).

The specific transport could then use setsockopt to control what
messages qualified as "urgent" in a transport specific manner.
