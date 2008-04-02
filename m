From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 2 Apr 2008 16:28:34 +0200
Message-ID: <20080402142834.GE20815@postel.suug.ch>
References: <1207000143.4424.167.camel@localhost> <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost> <47F35933.5080305@trash.net> <20080402112103.GB20815@postel.suug.ch> <1207137667.4451.143.camel@localhost> <47F37762.2030705@trash.net> <1207139106.4451.155.camel@localhost> <47F38002.70005@trash.net> <1207141852.4451.181.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50539 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754554AbYDBO2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 10:28:14 -0400
Content-Disposition: inline
In-Reply-To: <1207141852.4451.181.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* jamal <hadi@cyberus.ca> 2008-04-02 09:10
> I think both are of interest.
> Historically in routes for example, the interest would be apps/processes
> (not direct mapping to processids) that are of interest (eg a route
> added by OSPF vs one added by RIP etc). Filtering is done in user space
> so you dont repropagate routes added by the "OSPF process" to RIP if
> policy says so etc.
> That of course has evolved to application name (gated vs zebra vs bird
> etc) which implements all of OSPF/RIP/BGP etc and can keep track of
> things. Theres further evolution which desires to run multiple instances
> of quagga on the same machine etc.
> I dont think the processid is the right thing, but some 32 bit id which
> maps to a name would be useful or even a static field defined in some
> header file. The name serving could be out of the kernel for simplicity
> if the process dies and is re-incarnated it knows what to read(some of
> these ideas are already in genetlink).

I think this is over the top. The netlink port already provides good
means to retrieve information about the originator of a netlink message.
An additional genl interface which would resolve a netlink port to a
a process id / process name would be very helpful though.

If you want to keep track of netlink processes which have already closed
the socket then a userspace daemon which subscribes to all groups and
keeps a log of netlink port plus eventually message sequence numbers
would be a better solution IMHO. The daemon could be used to log netlink
events in general and even have triggers to invoke commands upon certain
events.

However, I'm positive to the idea of storing the netlink port on a per
object basis. It would be nice to know which application is responsible
for the creation of certain qdiscs without having to listen to events.

We could define the netlink port as follows to cover both netlink and
non netlink applications:

  port identifier (10 bits) + process id (22 bits)

A special value for the port identifier is defined (e.g. all zeros) which
specifies that the netlink port is really a ioctl based application. This
way we can encode the process id for both netlink and ioctl, distinguish
between them and support 1023 netlink sockets per application.
