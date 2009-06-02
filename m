From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 3/4] virtio_net: don't free buffers in xmit ring
Date: Tue, 02 Jun 2009 09:13:42 +0100
Message-ID: <1243930422.9146.60.camel@blaa>
References: <200905292346.24141.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54271 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754401AbZFBINq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 04:13:46 -0400
In-Reply-To: <200905292346.24141.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-29 at 23:46 +0930, Rusty Russell wrote:
> The virtio_net driver is complicated by the two methods of freeing old
> xmit buffers (in addition to freeing old ones at the start of the xmit
> path).
> 
> The original code used a 1/10 second timer attached to xmit_free(),
> reset on every xmit.  Before we orphaned skbs on xmit, the
> transmitting userspace could block with a full socket until the timer
> fired, the skb destructor was called, and they were re-woken.

The timer was actually added to solve a hang when trying to unload
nf_conntrack AFAIR - nf_conntrack was blocking on the skb being freed
and we never actually freed it.

I think skb_orphan() is enough to prevent this, is it?

> So we added the VIRTIO_F_NOTIFY_ON_EMPTY feature: supporting devices
> send an interrupt (even if normally suppressed) on an empty xmit ring
> which makes us schedule xmit_tasklet().  This was a benchmark win.
> 
> Unfortunately, VIRTIO_F_NOTIFY_ON_EMPTY makes quite a lot of work: a
> host which is faster than the guest will fire the interrupt every xmit
> packet (slowing the guest down further).

Ouch. So, does simply disabling host support for
VIRTIO_F_NOTIFY_ON_EMPTY speed up current guests?

Cheers,
Mark.

