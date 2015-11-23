From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 23 Nov 2015 10:53:08 +0100
Message-ID: <1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, davewatson@fb.com, alexei.starovoitov@gmail.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54679 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753816AbbKWJxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 04:53:09 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 4D443207A1
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 04:53:09 -0500 (EST)
In-Reply-To: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, Nov 20, 2015, at 22:21, Tom Herbert wrote:
> Kernel Connection Multiplexor (KCM) is a facility that provides a
> message based interface over TCP for generic application protocols.
> The motivation for this is based on the observation that although
> TCP is byte stream transport protocol with no concept of message
> boundaries, a common use case is to implement a framed application
> layer protocol running over TCP. To date, most TCP stacks offer
> byte stream API for applications, which places the burden of message
> delineation, message I/O operation atomicity, and load balancing
> in the application. With KCM an application can efficiently send
> and receive application protocol messages over TCP using a
> datagram interface.

I am a bit struggling seeing a real need to come up with a new socket
type and subsystem for that. It looks like you want to solve the same
problem that PACKET_FANOUT does? TCP has TCP-PSH flag which could help
delimit messages and a way to improve FANOUT like PACKET_FANOUT would
solve this same problem, too? A propoer fallback has to be in user space
anyway but messages could maybe simply be flagged with an skb->mark and
fanout could push it to the correct FANOUT-subsocket.

> In order to delineate message in a TCP stream for receive in KCM, the
> kernel implements a message parser. For this we chose to employ BPF
> which is applied to the TCP stream. BPF code parses application layer
> messages and returns a message length. Nearly all binary application
> protocols are parsable in this manner, so KCM should be applicable
> across a wide range of applications. Other than message length
> determination in receive, KCM does not require any other application
> specific awareness. KCM does not implement any other application
> protocol semantics-- these are are provided in userspace or could be
> implemented in a kernel module layered above KCM.

For me this still looks a little bit like messages could be delimited by
TCP PSH flag, where we might need to have some more fine grained control
over and besides that just adding better fanout semantics to TCP, no?

Do kcm sockets still allow streaming unlimited amounts of data? E.g. if
you want to pass a data stream attached to a rpc message? I think not
allowing streaming is a major shortcoming then (even though this will
induce head of line blocking).

> Future support:
> 
>  - Integration with TLS (TLS-in-kernel is a separate initiative).

This is interesting:

Regarding the last week's discussion about better OOB support in TCP
e.g. for SOCKET_DESTROY, do you already have a plan to handle TLS alerts
and do CHANGE_CIPHER on the socket synchronously?

Thanks,
Hannes
