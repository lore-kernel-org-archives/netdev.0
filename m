From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [V2 PATCH 9/9] vhost: zerocopy: poll vq in zerocopy callback
Date: Fri, 18 May 2012 08:29:34 -0700
Message-ID: <1337354974.12999.12.camel@oc3660625478.ibm.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <20120502034254.11782.27314.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <1337100630.8220.4.camel@oc3660625478.ibm.com> <4FB317C8.90002@redhat.com>
	 <1337181027.10741.13.camel@oc3660625478.ibm.com>
	 <20120516151444.GC9934@redhat.com>
	 <1337189525.10741.24.camel@oc3660625478.ibm.com>
	 <4FB4677A.8020402@redhat.com>
	 <1337268862.10741.58.camel@oc3660625478.ibm.com>
	 <4FB61D57.4030103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:42020 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754844Ab2ERP3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2012 11:29:43 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Fri, 18 May 2012 11:29:42 -0400
In-Reply-To: <4FB61D57.4030103@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-18 at 17:58 +0800, Jason Wang wrote:
> On 05/17/2012 11:34 PM, Shirley Ma wrote:
> > On Thu, 2012-05-17 at 10:50 +0800, Jason Wang wrote:
> >> The problem is we may stop the tx queue when there no enough
> capacity
> >> to
> >> place packets, at this moment  we depends on the tx interrupt to
> >> re-enable the tx queue. So if we didn't poll the vhost during
> >> callback,
> >> guest may lose the tx interrupt to re-enable the tx queue which
> could
> >> stall the whole tx queue.
> > VHOST_MAX_PEND should handle the capacity.
> >
> > Hasn't the above situation been handled in handle_tx() code?:
> > ...
> >                          if (unlikely(num_pends>  VHOST_MAX_PEND)) {
> >                                  tx_poll_start(net, sock);
> >
> set_bit(SOCK_ASYNC_NOSPACE,&sock->flags);
> >                                  break;
> >                          }
> > ...
> >
> > Thanks
> > Shirley
> 
> It may not help in because:
> 
> - tx polling depends on skb_orphan() which is often called by device 
> driver when it place the packet into the queue of the devices instead 
> of  when the packets were sent. So it was too early for vhost to be 
> notified.
Then do you think it's better to replace with vhost_poll_queue here
instead?

> - it only works when the pending DMAs exceeds VHOST_MAX_PEND, it's 
> highly possible that guest needs to be notified when the pending
> packets 
> isn't so much.
In which situation the guest needs to be notified when there is no TX
besides buffers run out?

> So this piece of code may not help and could be removed and we need
> to 
> poll the virt-queue during zerocopy callback ( through it could be 
> further optimized but may not be easy). 

Thanks
Shirley
