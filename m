From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Mon, 21 Mar 2011 11:03:07 -0700
Message-ID: <1300730587.3441.24.camel@localhost.localdomain>
References: <20110318133311.GA20623@gondor.apana.org.au>
	 <1300498915.3441.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, rusty@rustcorp.com.au, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:42444 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab1CUSDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 14:03:20 -0400
In-Reply-To: <1300498915.3441.21.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-18 at 18:41 -0700, Shirley Ma wrote:
> > > +       /* Drop packet instead of stop queue for better
> performance
> > */
> > 
> > I would like to see some justification as to why this is the right
> > way to go and not just papering over the real problem. 
> 
> Fair. KVM guest virtio_net TX queue stop/restart is pretty expensive,
> which involves:
> 
> 1. Guest enable callback: one memory barrier, interrupt flag set

Missed this cost: for history reason, it also involves a guest exit from
I/O write (PCI_QUEUE_NOTIFY).

> 2. Host signals guest: one memory barrier, and a TX interrupt from
> host
> to KVM guest through evenfd_signal.
> 
> 
> Most of the workload so far we barely see TX over run, except for
> small
> messages TCP_STREAM. 
> 
> For small message size TCP_STREAM workload, no matter how big the TX
> queue size is, it always causes overrun. I even re-enable the TX queue
> when it's empty, it still hits TX overrun again and again.
> 
> Somehow KVM guest and host is not in pace on processing small packets.
> I
> tried to pin each thread to different CPU, it didn't help. So it
> didn't
> seem to be scheduling related.
> 
> >From the performance results, we can see dramatically performance
> gain
> with this patch.
> 
> I would like to dig out the real reason why host can't in pace with
> guest, but haven't figured it out in month, that's the reason I held
> this patch for a while. However if anyone can give me any ideas on how
> to debug the real problem, I am willing to try it out. 

