From: Tom Herbert <tom@herbertland.com>
Subject: Re: a question about the kcm proposal
Date: Mon, 12 Oct 2015 15:05:49 -0700
Message-ID: <CALx6S34fN1W+jCKUFHWrLBmtgYBzMmP6sDx-zfeSX2bpnmvs-g@mail.gmail.com>
References: <20151012195132.GY14646@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	davejwatson@fb.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33927 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbbJLWFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 18:05:50 -0400
Received: by igbni9 with SMTP id ni9so46549395igb.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 15:05:49 -0700 (PDT)
In-Reply-To: <20151012195132.GY14646@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> If the user-space  has decided to encrypt the http/2 header using tls,
> the len (and other http/2 fields) is no longer in the clear for the kernel.
>
> My understanding is that http header encryption is common practice/BCP,
> since the http hdr may contain a lot of identity, session and tenancy data.
> If that's true, then wouldn't this break the BPF/kcm assumptions?
>

Right, if data is encrypted then we can't do message delineation on
receive. KCM wouldn't help much on transmit either since the crypto
state would need to be shared. The solution is to move TLS into the
kernel.

> There is a different but related problem in this space- existing TLS/DTLS
> libraries (openssl, gnutls etc) only know how to work with tcp
> or udp sockets - they do not know anything about PF_RDS or the
> newly proposed kcm socket type.
>
TLS-in-kernel would be a lower layer so it shouldn't have to know
anything about RDS or KCM. If it makes sent KCM could be used for
parsing TLS records themselves...

> In theory, it is possible to extend these libraries to handle
> RDS/kcm etc, but (as we found out with RDS and IP_PKTINFO/BINDTODEVICE),
> some things become tricky because of the many-to-one dgram-over-stream
> hybrid.
>
> I've looked at  IPSEC/IKE in transport mode for RDS on the kernel tcp
> socket as we discussed at Plumbers in August, and that has some costs..
> would be interesting to evaluate against other options..
>
The design of TLS in the kernel is that it will be enabled on the TCP
socket, so that receive and transmit path are below RDS and KCM. We
have the transmit path for TLS-in-kernel running with good preliminary
results, we will post that at least as RFC shortly. Receive side still
seems to be feasible.

Thanks,
Tom

> --Sowmini
>
>
