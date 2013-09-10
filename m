From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large
 packets
Date: Tue, 10 Sep 2013 05:35:36 -0700
Message-ID: <1378816536.26319.71.camel@edumazet-glaptop>
References: <20130906101635.GI14104@zion.uk.xensource.com>
	   <1378472268.31445.15.camel@edumazet-glaptop>
	 <522A049A.7000105@citrix.com>  <1378486604.31445.34.camel@edumazet-glaptop>
	 <522D9466.6020205@redhat.com> <1378734444.26319.28.camel@edumazet-glaptop>
	 <522ECE2B.7020409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:35211 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab3IJMfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 08:35:38 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so7454669pbc.25
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 05:35:38 -0700 (PDT)
In-Reply-To: <522ECE2B.7020409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-10 at 15:45 +0800, Jason Wang wrote:

> For example, virtio-net will stop the tx queue when it finds the tx
> queue may full and enable the queue when some packets were sent. In this
> case, tsq works and throttles the total bytes queued in qdisc. This
> usually happen during heavy network load such as two sessions of netperf.

You told me skb were _orphaned_.

This automatically _disables_ TSQ, after packets leave Qdisc.

So you have a problem because your skb orphaning is only working when
packets leave Qdisc.

If you cant afford sockets being throttled, make sure you have no
Qdisc !

> We notice a regression, and bisect shows it was introduced by TSQ.

You do realize TSQ is a balance between throughput and latencies ?

In case of TSQ, it was very clear that limiting amount of outstanding
bytes in queues could have an impact on bandwidth.

Pushing Megabytes of TCP packets with identical TCP timestamps is
bad, because it prevents us doing delay based congestion control and
a single flow could fill the Qdisc with a thousand of packets.
(Self induced delays, see BufferBloat discussions)

One known problem in TCP stack is that sendmsg() locks the socket for
the duration of the call. sendpage() do not have this problem.

tcp_tsq_handler() is deferred if tcp_tasklet_func() finds a locked
socket. The owner of socket will call tcp_tsq_handler() when socket is
released.

So if you use sendmsg() with large buffers or if copyin data from user
land involves page faults, it may explain why you need larger number of
in-flight bytes to sustain a given throughput.

You could take a look at commit c9bee3b7fdecb0c1d070c
("tcp: TCP_NOTSENT_LOWAT socket option"), and play
with /proc/sys/net/ipv4/tcp_notsent_lowat, to force sendmsg() to release
the socket lock every hundreds of kbytes.
