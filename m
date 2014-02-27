From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet drops observed @ LINUX_MIB_TCPBACKLOGDROP
Date: Thu, 27 Feb 2014 12:49:58 -0800
Message-ID: <1393534198.26794.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJzFV35=wUOA+pQCkAwV2+oF79VAmbsRY08gZUiFz-Vtw-898w@mail.gmail.com>
	 <1393523649.26794.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJzFV35yDOpCx=yPrrN3o4QLFdJLq9E2Jo+v2HsyyVP1q30aUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harout@hedeshian.net
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:57864 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbaB0UuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 15:50:00 -0500
Received: by mail-ie0-f182.google.com with SMTP id tp5so2589044ieb.41
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 12:50:00 -0800 (PST)
In-Reply-To: <CAJzFV35yDOpCx=yPrrN3o4QLFdJLq9E2Jo+v2HsyyVP1q30aUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-27 at 13:40 -0700, Sharat Masetty wrote:
> Hi Eric,
> 
> We are using kernel version 3.10.0 and network driver is our own
> driver designed to work on hsic-usb interconnect. One thing is for
> sure is that we do not pre allocate lots buffers to hold incoming
> traffic, we only allocate buffers of required size when there is data
> to read off the bus.
> 
> I was under the impression that this backlog queue is charged against
> the socket buffer space(sndbuf and rcvbuf), so I am trying to
> understand in more detail how the driver implementation can be linked
> to this drops in the backlog queue.
> 
> Can you explain to me the significance of this backlog queue? mainly
> from the perspective of the userspace application(in this case iperf)
> socket API calls and the kernel/network stack enqueuing packets up the
> stack..


backlog queue is used to hold packets when softirq handler found
the socket being used by a process (user application doing a sendmsg()
system call for example). Since a softirq cannot sleep, it has to queue
the packet into 'backlog' so that the process can process it as soon as
it is going to exit TCP stack.

We have to put a limit on the backlog, otherwise a DOS attack would fill
the queue and the host would crash, because all memory would be
consumed.

We start dropping packet if length of backlog exceeds
 ( sk->sk_rcvbuf + sk->sk_sndbuf ) socket limit, since linux-3.5

So maybe you set too small limits ?
