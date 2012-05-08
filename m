From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_TIMESTAMP on tcp sockets?
Date: Tue, 08 May 2012 06:37:11 +0200
Message-ID: <1336451831.3752.2373.camel@edumazet-glaptop>
References: <CALCETrVUjLz63uzr+UTf-G1jq9QDcX6Gf9D6AWK8_GmunsJGnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42475 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868Ab2EHEhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 00:37:15 -0400
Received: by eeit10 with SMTP id t10so164560eei.19
        for <netdev@vger.kernel.org>; Mon, 07 May 2012 21:37:14 -0700 (PDT)
In-Reply-To: <CALCETrVUjLz63uzr+UTf-G1jq9QDcX6Gf9D6AWK8_GmunsJGnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-07 at 18:39 -0700, Andy Lutomirski wrote:
> I've been using SO_TIMESTAMPNS to good effect on udp sockets.  I'd
> like to do the same thing for tcp.  I realize that this is
> semantically strange [1], but I don't think there's a real issue for
> my use case.  We have very thin streams -- we are likely to process
> each incoming segment as it is received, and I want the most precise
> timestamp possible on each segment.
> 
> A simple approach (I think) would be for a recvmsg on a tcp socket
> with SO_TIMESTAMP(NS) to return at most one skb worth of data along
> with the timestamp associated with that skb.  This could be a little
> strange if multiple segments overlap or if lro is involved, but
> neither of those cases seems like a major problem.
> 
> Is there any interest in something like this?
> 

LRO/GRO is not really a problem, buffers are merged because they are
received in a very short time period. If you want nanosec timestamping
on TCP, just cancel the whole idea.

TCP can 'collapse' several buffers onto single ones (to reduce memory
overhead). Which timestamp would be chosen at collapse time ?

net-next also has tcp coalescing, wich also merge buffers as soon as
they enter receive or ofo queue.

Another problem with SO_TIMESTAMPNS is it globally enables time stamping
on all skbs on the host, adding some latencies. (ktime_get() can be
slowed down when time keeping triggers and hold xtime seqlock)
