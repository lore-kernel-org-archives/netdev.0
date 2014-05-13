From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net-tun: restructure tun_do_read for better sleep/wakeup
 efficiency
Date: Tue, 13 May 2014 11:20:27 +0300
Message-ID: <20140513082027.GB29442@redhat.com>
References: <1399422244-22751-1-git-send-email-xii@google.com>
 <5369AB36.6030609@redhat.com>
 <CAOBoifh6X8nbiqcNXNxJeFzWj1Q3N9Jc-xxQNrLWwFQf8LjZzQ@mail.gmail.com>
 <536C4733.9020704@redhat.com>
 <20140512061557.GA12581@redhat.com>
 <5371B87D.3020609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xi Wang <xii@google.com>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752692AbaEMIVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 04:21:40 -0400
Content-Disposition: inline
In-Reply-To: <5371B87D.3020609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 02:15:25PM +0800, Jason Wang wrote:
> On 05/12/2014 02:15 PM, Michael S. Tsirkin wrote:
> > On Fri, May 09, 2014 at 11:10:43AM +0800, Jason Wang wrote:
> >> > On 05/09/2014 02:22 AM, Xi Wang wrote:
> >>> > > On Tue, May 6, 2014 at 8:40 PM, Jason Wang <jasowang@redhat.com> wrote:
> >>>> > >> On 05/07/2014 08:24 AM, Xi Wang wrote:
> >>>>> > >>> tun_do_read always adds current thread to wait queue, even if a packet
> >>>>> > >>> is ready to read. This is inefficient because both sleeper and waker
> >>>>> > >>> want to acquire the wait queue spin lock when packet rate is high.
> >>>> > >> After commit 61a5ff15ebdab87887861a6b128b108404e4706d, this will only
> >>>> > >> help for blocking read. Looks like for performance critical userspaces,
> >>>> > >> they will use non blocking reads.
> >>>>> > >>> We restructure the read function and use common kernel networking
> >>>>> > >>> routines to handle receive, sleep and wakeup. With the change
> >>>>> > >>> available packets are checked first before the reading thread is added
> >>>>> > >>> to the wait queue.
> >>>> > >> This is interesting, since it may help if we want to add rx busy loop
> >>>> > >> for tun. (In fact I worked a similar patch like this).
> >>> > >
> >>> > > Yes this should be a good side effect and I am also interested in trying.
> >>> > > Busy polling in user space is not ideal as it doesn't give the lowest latency.
> >>> > > Besides differences in interrupt latency etc., there is a bad case for
> >>> > > non blocking mode: When a packet arrives right before the polling thread
> >>> > > returns to userspace. The control flow has to cross kernel/userspace
> >>> > > boundary 3 times before the packet can be processed, while kernel
> >>> > > blocking or busy polling only needs 1 boundary crossing.
> >> > 
> >> > So if we want to implement this, we need a feature bit to turn it on.
> >> > Then vhost may benefit from this.
> > IFF_TUN_POLL_BUSY_LOOP ? I'm not sure it has to be
> > a flag. Maybe an ioctl is better, if userspace
> > misconfigures this it is only hurting itself, right?
> 
> Flag has the same effect. But adding new ioctls means userspace needs to
> be modified. This is different with current rx busy polling for tcp/udp
> socket which is transparent to userspace application.

OTOH risk is much lower though.

> > Maybe add a module parameter to control polling timeout,
> > or reuse low_latency_poll.
> >
> 
> If we don't need a global parameter, we can just implement it without
> generic helper like __skb_recv_datagram().

not sure I get the meaning here.
