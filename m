From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: don't return uninitialized addresses on
 concurrent socket shutdown
Date: Sat, 16 Nov 2013 16:36:24 -0800
Message-ID: <1384648584.8604.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com>
	 <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com>
	 <20131116054344.GG26901@order.stressinduktion.org>
	 <20131116054814.GH26901@order.stressinduktion.org>
	 <20131116191916.GC16541@order.stressinduktion.org>
	 <1384634802.8604.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131116224330.GF16541@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mpb <mpb.mail@gmail.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:48617 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab3KQAg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 19:36:26 -0500
Received: by mail-pa0-f48.google.com with SMTP id bj1so5185268pad.21
        for <netdev@vger.kernel.org>; Sat, 16 Nov 2013 16:36:26 -0800 (PST)
In-Reply-To: <20131116224330.GF16541@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-16 at 23:43 +0100, Hannes Frederic Sowa wrote:

> I do think it is common to call recvfrom, process the packet and sendto
> back a packet with the updated values from recvfrom. We accept AF_UNSPEC
> on an IPv4 UDP socket and use the addresses as it would be a AF_INET
> sockaddr. We only bail out if the port is 0.
> 
> It was my intend to at least clear the addressing portions of the regular
> sockaddr_* structure for the user as it could be reused as explained
> earlier and be allocated uninitialized on the stack (or reused, so
> sending packet to a previous destination). I think it is very uncommon to
> expect a non-error value on a recvfrom/recvmsg and have AF_UNSPEC in the
> sockaddr.
> 
> (I erroneously stated that we could return the full 128 zero bytes, we only
> clear 128 bytes and return only max(128, msg.msg_namelen). msg_namelen gets
> updated by the recvmsg handler and that only iff we have this concurrent
> shutdown and blocking read issue.)
> 
> If the socket structure is cleared a following sendto would produce a -EINVAL.
> 
> Maybe I am too sensible regarding such problems and will think about that a
> bit more (and check for AF_INVALID/AF_UNSPEC).
> 


I think the _default_ should be to clear it.

-	msg.msg_namelen = sizeof(address);
+	msg.msg_namelen = 0;

And subsystems filling a real address would set it back to the length
they took care of.

in recvfrom() paths, the kernel _knows_ it uses an array of 128 bytes.
(struct sockaddr_storage)
