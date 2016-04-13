From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 0/2] tun: lockless xmit
Date: Wed, 13 Apr 2016 14:08:50 +0300
Message-ID: <20160413132816-mutt-send-email-mst@redhat.com>
References: <cover.1460393493.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932194AbcDMLIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 07:08:54 -0400
Content-Disposition: inline
In-Reply-To: <cover.1460393493.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 11:04:45AM +0200, Paolo Abeni wrote:
> This patch series try to remove the need for any lock in the tun device
> xmit path, significantly improving the forwarding performance when multiple
> processes are accessing the tun device (i.e. in a nic->bridge->tun->vm scenario).
> 
> The lockless xmit is obtained explicitly setting the NETIF_F_LLTX feature bit
> and removing the default qdisc.
> 
> Unlikely most virtual devices, the tun driver has featured a default qdisc
> for a long period, but it already lost such feature in linux 4.3.

Thanks -  I think it's a good idea to reduce the
lock contention there.

But I think it's unfortunate that it requires
bypassing the qdisc completely: this means
that anyone trying to do traffic shaping will
get back the contention.

Can we solve the lock contention for qdisc?
E.g. add a small lockless queue in front of it,
whoever has the qdisc lock would be
responsible for moving things from there to qdisc
proper.

Thoughts? Is there a chance this might work reasonably well?


> Paolo Abeni (2):
>   tun: don't require serialization lock on tx
>   tun: don't set a default qdisc
> 
>  drivers/net/tun.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> -- 
> 1.8.3.1
