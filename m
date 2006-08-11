From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Fri, 11 Aug 2006 23:47:44 +0200
Message-ID: <20060811214744.GO14627@postel.suug.ch>
References: <20060809204821.216122988@postel.suug.ch> <20060809205439.434010049@postel.suug.ch> <20060810155120.GA494@ms2.inr.ac.ru> <20060810190210.GH14627@postel.suug.ch> <20060810203252.GA6414@ms2.inr.ac.ru> <20060810211833.GK14627@postel.suug.ch> <20060811153549.GA16351@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38113 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751094AbWHKVr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 17:47:26 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060811153549.GA16351@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> 2006-08-11 19:35
> Well, tc was supposed to use it, but this did not happen and
> it remained deficient.

Makes sense, especially for auto generated handles. I've been listening
to the notifications on a separate socket for this purpose. It would
make sense however to extend a wait_for_ack() function and report
back and eventual echoed objects to have a blocking operation as well.

> Actually, it was supposed to be done everywhere, but originator info
> did not propagate deep enough in many cases, especially in IPv6.
> So, this is not a hack, it is a good work. :-)

It does make sense, the way it has been implemented if at all is
creepy. Even worse, IPv6 is using current->pid, some other code
has been using the pid from NETLINK_CREDS() :-)

> Each socket, which subscribes to multicasts becomes sensitive
> to rcvbuf overflows. F.e. when you do control operations on a socket,
> which is subscribed to multicasts, the response can be lost in stream
> of events and -ENOBUFS generated instead. If it is a daemon, it can resync
> the state, but if it is a simple utility, it cannot recover.

Yes, for that reason it is recommended to use a separate socket
when receiving multicasts. Also because some of the multicast
code is buggy and provides the pid of the requestor's socket to
netlink_broadcast() leading to excluding that socket.

> Probably, unicasts sent due to NLM_F_ECHO should somehow override
> rcvbuf limits.
> 
> This reminded me about a capital problem, found by openvz people.
> Frankly speaking, I still have no idea how to repair this, probably you
> will find a solution.
> 
> Look: while a dump, skb allocation can fail (because of many reasons,
> the most obvious is that rcvbuf space was eaten by multicasts).
> But error is not reported! Oops. The worst thing is that even if an error
> is reported, iproute would ignore it.

I'm not sure I understand this correctly, if rcvbuf space was eaten
by multicasts subsequent recvmsg() will follow invoking netlink_dump()
again and the dump continues.
