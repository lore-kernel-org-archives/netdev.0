From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 0/2] tun: lockless xmit
Date: Wed, 13 Apr 2016 06:09:26 -0700
Message-ID: <1460552966.10638.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460393493.git.pabeni@redhat.com>
	 <20160413132816-mutt-send-email-mst@redhat.com>
	 <1460551817.10638.7.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160413155146-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34705 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760090AbcDMNJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 09:09:29 -0400
Received: by mail-pa0-f49.google.com with SMTP id ot11so33368892pab.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 06:09:28 -0700 (PDT)
In-Reply-To: <20160413155146-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-13 at 15:56 +0300, Michael S. Tsirkin wrote:
> On Wed, Apr 13, 2016 at 05:50:17AM -0700, Eric Dumazet wrote:
> > On Wed, 2016-04-13 at 14:08 +0300, Michael S. Tsirkin wrote:
> > > On Wed, Apr 13, 2016 at 11:04:45AM +0200, Paolo Abeni wrote:
> > > > This patch series try to remove the need for any lock in the tun device
> > > > xmit path, significantly improving the forwarding performance when multiple
> > > > processes are accessing the tun device (i.e. in a nic->bridge->tun->vm scenario).
> > > > 
> > > > The lockless xmit is obtained explicitly setting the NETIF_F_LLTX feature bit
> > > > and removing the default qdisc.
> > > > 
> > > > Unlikely most virtual devices, the tun driver has featured a default qdisc
> > > > for a long period, but it already lost such feature in linux 4.3.
> > > 
> > > Thanks -  I think it's a good idea to reduce the
> > > lock contention there.
> > > 
> > > But I think it's unfortunate that it requires
> > > bypassing the qdisc completely: this means
> > > that anyone trying to do traffic shaping will
> > > get back the contention.
> > > 
> > > Can we solve the lock contention for qdisc?
> > > E.g. add a small lockless queue in front of it,
> > > whoever has the qdisc lock would be
> > > responsible for moving things from there to qdisc
> > > proper.
> > > 
> > > Thoughts? Is there a chance this might work reasonably well?
> > 
> > Adding any new queue in front of qdisc is problematic :
> > - Adds a new buffer, with extra latencies.
> 
> Only where lock contention would previously occur, right?
> 
> > - If you want to implement priorities properly for X COS, you need X
> > queues.
> 
> This definitely needs thought.
> 
> > - Who is going to service this extra buffer and feed the qdisc ?
> 
> The way I see it - whoever has the lock, at unlock time.
> 
> > - If the innocent guy is RT thread, maybe the extra latency will hurt.
> 
> Again - more than a lock?

Way more. HTB is slow as hell.

Remember the qdisc dequeue is already a big problem in itself.
Adding another layer can practically double the latencies.

> 
> > - Adding another set of atomic ops.
> 
> That's likely true. Use some per-cpu trick instead?

We tried that, and we got miserable production incidents...

You really need to convince John Fastabend to work full time on the real
thing, not on another queue in front of the existing qdisc.
