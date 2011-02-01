From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Mon, 31 Jan 2011 17:30:38 -0800
Message-ID: <1296523838.30191.39.camel@sridhar.beaverton.ibm.com>
References: <20110127193131.GD5228@redhat.com>
	 <1296157547.1640.45.camel@localhost.localdomain>
	 <20110127200548.GE5228@redhat.com>
	 <20110127.130240.104065182.davem@davemloft.net>
	 <1296163838.1640.53.camel@localhost.localdomain>
	 <20110128121616.GA8374@redhat.com>
	 <OF05820FED.7465B77B-ON8625782A.0001B247-8625782A.00023FA7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Steve Dobbelstein <steved@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:53170 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754267Ab1BABan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 20:30:43 -0500
In-Reply-To: <OF05820FED.7465B77B-ON8625782A.0001B247-8625782A.00023FA7@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-31 at 18:24 -0600, Steve Dobbelstein wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 01/28/2011 06:16:16 AM:
> 
> > OK, so thinking about it more, maybe the issue is this:
> > tx becomes full. We process one request and interrupt the guest,
> > then it adds one request and the queue is full again.
> >
> > Maybe the following will help it stabilize?
> > By itself it does nothing, but if you set
> > all the parameters to a huge value we will
> > only interrupt when we see an empty ring.
> > Which might be too much: pls try other values
> > in the middle: e.g. make bufs half the ring,
> > or bytes some small value, or packets some
> > small value etc.
> >
> > Warning: completely untested.
> >
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index aac05bc..6769cdc 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -32,6 +32,13 @@
> >   * Using this limit prevents one virtqueue from starving others. */
> >  #define VHOST_NET_WEIGHT 0x80000
> >
> > +int tx_bytes_coalesce = 0;
> > +module_param(tx_bytes_coalesce, int, 0644);
> > +int tx_bufs_coalesce = 0;
> > +module_param(tx_bufs_coalesce, int, 0644);
> > +int tx_packets_coalesce = 0;
> > +module_param(tx_packets_coalesce, int, 0644);
> > +
> >  enum {
> >     VHOST_NET_VQ_RX = 0,
> >     VHOST_NET_VQ_TX = 1,
> > @@ -127,6 +134,9 @@ static void handle_tx(struct vhost_net *net)
> >     int err, wmem;
> >     size_t hdr_size;
> >     struct socket *sock;
> > +   int bytes_coalesced = 0;
> > +   int bufs_coalesced = 0;
> > +   int packets_coalesced = 0;
> >
> >     /* TODO: check that we are running from vhost_worker? */
> >     sock = rcu_dereference_check(vq->private_data, 1);
> > @@ -196,14 +206,26 @@ static void handle_tx(struct vhost_net *net)
> >        if (err != len)
> >           pr_debug("Truncated TX packet: "
> >               " len %d != %zd\n", err, len);
> > -      vhost_add_used_and_signal(&net->dev, vq, head, 0);
> >        total_len += len;
> > +      packets_coalesced += 1;
> > +      bytes_coalesced += len;
> > +      bufs_coalesced += in;
> 
> Should this instead be:
>       bufs_coalesced += out;
> 
> Perusing the code I see that earlier there is a check to see if "in" is not
> zero, and, if so, error out of the loop.  After the check, "in" is not
> touched until it is added to bufs_coalesced, effectively not changing
> bufs_coalesced, meaning bufs_coalesced will never trigger the conditions
> below.

Yes. It definitely should be 'out'. 'in' should be 0 in the tx path.

I tried a simpler version of this patch without any tunables by
delaying the signaling until we come out of the for loop.
It definitely reduced the number of vmexits significantly for small message
guest to host stream test and the throughput went up a little.

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9b3ca10..5f9fae9 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -197,7 +197,7 @@ static void handle_tx(struct vhost_net *net)
 		if (err != len)
 			pr_debug("Truncated TX packet: "
 				 " len %d != %zd\n", err, len);
-		vhost_add_used_and_signal(&net->dev, vq, head, 0);
+		vhost_add_used(vq, head, 0);
 		total_len += len;
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
@@ -205,6 +205,8 @@ static void handle_tx(struct vhost_net *net)
 		}
 	}
 
+	if (total_len > 0)
+		vhost_signal(&net->dev, vq);
 	mutex_unlock(&vq->mutex);
 }
 

> 
> Or am I missing something?
> 
> > +      if (unlikely(packets_coalesced > tx_packets_coalesce ||
> > +              bytes_coalesced > tx_bytes_coalesce ||
> > +              bufs_coalesced > tx_bufs_coalesce))
> > +         vhost_add_used_and_signal(&net->dev, vq, head, 0);
> > +      else
> > +         vhost_add_used(vq, head, 0);
> >        if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> >           vhost_poll_queue(&vq->poll);
> >           break;
> >        }
> >     }
> >
> > +   if (likely(packets_coalesced > tx_packets_coalesce ||
> > +         bytes_coalesced > tx_bytes_coalesce ||
> > +         bufs_coalesced > tx_bufs_coalesce))
> > +      vhost_signal(&net->dev, vq);
> >     mutex_unlock(&vq->mutex);
> >  }

It is possible that we can miss signaling the guest even after
processing a few pkts, if we don't hit any of these conditions.

> >
> 
> Steve D.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

