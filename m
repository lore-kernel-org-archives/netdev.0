From: Patrick McHardy <kaber@trash.net>
Subject: Re: Sending big Netlink messages to userspace
Date: Tue, 24 Jun 2008 19:00:28 +0200
Message-ID: <4861282C.4000208@trash.net>
References: <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vince Busam <vbusam@google.com>,
	Thomas Graf <tgraf@suug.ch>
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58544 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbYFXRAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 13:00:33 -0400
In-Reply-To: <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julius Volz wrote:
> Hi,
> 
> While adding a Netlink interface to IPVS, I've been wondering how to
> properly send very big messages to userspace and found these posts:
> 
> http://lists.openwall.net/netdev/2007/03/06/214
> http://lists.openwall.net/netdev/2007/03/07/2
> 
> Herbert writes in the second one, "Dumps should be done using 4K
> (NLMSG_GOODSIZE) skb's, where is the problem?" How is that meant?
> Should one manually split up dumps into several NLMSG_GOODSIZE
> messages or is there some mechanism for that?

Thats done automatically through netlink_dump_start().
You send one skb per dump callback invocation. The final
call returns a zero sized skb to indicate the end of the
dump.

> I need to send arbitrarily long lists to userspace and I'm already
> choosing a big enough size for nlmsg_new(), so I get no put failures
> while constructing the message. However, when receiving the data in
> userspace (with libnl), the receive callback is never called. An
> strace shows that MSG_TRUNC is set in the oversized message, so the
> data is never fully received.

You probably need to increase the receive buffer size in libnl.

> I just call nl_recvmsgs_default(sock) once (which does not return an
> error). Am I handling libnl incorrectly or do I need to do this
> differently on the kernel side?

It depends on what kind of attributes you're sending. In case
of top-level attributes you should only dump objects until
you reach NLMSG_GOODSIZE and continue during the next dump
callback invocation. Sending arbitary amounts of nested
data is more tricky, or might even be impossible currently.
