From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 23 Nov 2015 20:35:37 +0100
Message-ID: <1448307337.1628829.447962729.60B03DCC@webmail.messagingengine.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
 <1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
 <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davewatson@fb.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:51025 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754545AbbKWTfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 14:35:38 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 7DBA3209E1
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 14:35:37 -0500 (EST)
In-Reply-To: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tom,

On Mon, Nov 23, 2015, at 18:33, Tom Herbert wrote:
> > For me this still looks a little bit like messages could be delimited by
> > TCP PSH flag, where we might need to have some more fine grained control
> > over and besides that just adding better fanout semantics to TCP, no?
> >
> The TCP PSH flag is not defined for message delineation (neither is
> urgent pointer). We can't change that (many people have tried to add
> message semantics to TCP protocol but have always failed miserably).
> The fact is TCP is always going to be a stream based protocol. Period!
> :-) It is up to the application to interpret the stream and extract
> messages. Even if we could somehow apply the PSH bit to "help" in
> message delineation, we would need to change senders to use the PSH
> bit in that fashion for it to be of benefit to receivers.

I see TCP PSH flags as an optimization and I agree it is hard to
properly make use of them in the internet. But in a datacenter where
everything is under control, this could be done?

Anyway, decoding arbitrary messages in the kernel with maybe huge
lengths could result in starvation problems if you adhere to the socket
receive buffer limits at all time. So I wonder if forward progress
guarantee can be achieved here agnostic of the eBPF program? I really
see this becoming a problem as soon as people use it for privilege
separation. Will there be central error handling?

Also, would a TCP option make sense here to add instead of using the TCP
PSH flag? Not sure, yet...

> > Do kcm sockets still allow streaming unlimited amounts of data? E.g. if
> > you want to pass a data stream attached to a rpc message? I think not
> > allowing streaming is a major shortcoming then (even though this will
> > induce head of line blocking).
> >
> RPC messages can be of arbitrary size and with SOCK_SEQPACKET,
> messages can be sent or received in multiple calls. No HOL blocking
> since message are constructed on KCM sockets before starting to send
> on TCP sockets. Socket buffer limits are respected. KCM does not
> enforce a maximum message size, if an applications does have a maximum
> then that can be checked in the BPF code.

I was referring to the receivers end HOL blocking, the same as in user
space TCP, where one data stream (or huge message) keeps the byte stream
busy so no other datagrams in there can be delivered. For low latency I
would actually use multiple streams or switch to UDP with user space
based retry.

I think this problem more and more comes down to improve epoll interface
with somewhat better CPU steered wake-up capabilities to make it more
agnostic. Some programs e.g. want also be woken up if a HTTP header is
received completely, SO_RCVLOWAT was made for this, FreeBSD has
accept_filter for this kind.

You want to use this in thrift which is mainly Java based and reuse the
existing NIO infrastructure?

> >> Future support:
> >>
> >>  - Integration with TLS (TLS-in-kernel is a separate initiative).
> >
> > This is interesting:
> >
> > Regarding the last week's discussion about better OOB support in TCP
> > e.g. for SOCKET_DESTROY, do you already have a plan to handle TLS alerts
> > and do CHANGE_CIPHER on the socket synchronously?
> >
> Dave should be posting the basic TLS-in-the-kenel patches shortly,
> those will be a better context for discussion.

Thanks, I am looking at them right now. :)

Thanks,
Hannes
