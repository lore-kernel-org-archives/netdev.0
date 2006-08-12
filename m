From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Sat, 12 Aug 2006 15:03:31 +0400
Message-ID: <20060812110331.GA31479@ms2.inr.ac.ru>
References: <20060809204821.216122988@postel.suug.ch> <20060809205439.434010049@postel.suug.ch> <20060810155120.GA494@ms2.inr.ac.ru> <20060810190210.GH14627@postel.suug.ch> <20060810203252.GA6414@ms2.inr.ac.ru> <20060810211833.GK14627@postel.suug.ch> <20060811153549.GA16351@ms2.inr.ac.ru> <20060811214744.GO14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:7832 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S964819AbWHLLD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 07:03:59 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060811214744.GO14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Makes sense, especially for auto generated handles. I've been listening
> to the notifications on a separate socket for this purpose.

That's... complicated. But cool. :-)


> It does make sense, the way it has been implemented if at all is
> creepy. Even worse, IPv6 is using current->pid, some other code
> has been using the pid from NETLINK_CREDS() :-)

Yeah, some time ago I sent a path replacing those with 0, but
apparently I forgot to grep IPv6. And did not even search for NETLINK_CREDS().


> when receiving multicasts. Also because some of the multicast
> code is buggy and provides the pid of the requestor's socket to
> netlink_broadcast() leading to excluding that socket.

Actually, it was the idea. If requestor asked NLM_F_ECHO and subscribed
to muticasts, it suppresses double notifications. If it did not ask
NLM_F_ECHO, he is not interested in results, he knows what's going on
without this.

F.e. it was used by my implementation in gated: it did not set either
NLM_F_ECHO or even NLM_F_ACK. And when making massive batch updates,
it received nothing back: only errors and updates made by someone else.


> I'm not sure I understand this correctly, if rcvbuf space was eaten
> by multicasts subsequent recvmsg() will follow invoking netlink_dump()
> again and the dump continues.

Indeed. I forgot how it works. :-)

I understood what is happening there. sock_rmalloc() fails not due
to rcvbuf, but because of global resource limiting. Grr... it does not
look solvable. Luckily, in normal kernel this can happen only if 0-order
GFP_KERNEL allocation fails. Not impossible with oom_killer, but it
definitely moves the status of the problem to marginal.

Alexey

