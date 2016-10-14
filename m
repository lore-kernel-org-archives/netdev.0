From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] udp: Flow dissection for tunnels
Date: Fri, 14 Oct 2016 11:03:56 -0400 (EDT)
Message-ID: <20161014.110356.1414076388878308737.davem@davemloft.net>
References: <20161012232547.2383961-1-tom@herbertland.com>
        <20161013.151700.1071876162706356206.davem@davemloft.net>
        <CALx6S35hEQzc=pCb6ko23HNFdK96-nb=F8Ni2+c=inSpJC16og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752013AbcJNPD6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 11:03:58 -0400
In-Reply-To: <CALx6S35hEQzc=pCb6ko23HNFdK96-nb=F8Ni2+c=inSpJC16og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 13 Oct 2016 12:29:46 -0700

> On Thu, Oct 13, 2016 at 12:17 PM, David Miller <davem@davemloft.net> wrote:
>> This socket lookup is very heavy handed, and I realize that you
>> need this because we no longer store the encapsulation socket in
>> skb->sk these days.
>>
> I don't quite understand your point about the encapsulation socket.

On the transmit side we used to have an issue wrt. what socket lives
on skb->sk when encapsulation is involved.

The problem is that we need skb->sk to be the transport level socket,
but in the output path we used to make tests on "skb->sk" to determine
things such as the multicast loopback flag.  But we should be looking
at the tunnel socket for that, otherwise we could do crazy things
like dereference an AF_PACKET socket as if it were an inet socket one.

As such we modified the output path to pass the inner tunnel socket
'sk' down through the call chain, as an argument to functions such as
ip_queue_xmit(), ip_local_out*(), etc.
