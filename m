From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 01 Feb 2011 13:09:45 -0800
Message-ID: <1296594585.26937.817.camel@localhost.localdomain>
References: <20110127193131.GD5228@redhat.com>
	 <1296157547.1640.45.camel@localhost.localdomain>
	 <20110127200548.GE5228@redhat.com>
	 <20110127.130240.104065182.davem@davemloft.net>
	 <1296163838.1640.53.camel@localhost.localdomain>
	 <20110128121616.GA8374@redhat.com>
	 <OF05820FED.7465B77B-ON8625782A.0001B247-8625782A.00023FA7@us.ibm.com>
	 <1296523838.30191.39.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steve Dobbelstein <steved@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1296523838.30191.39.camel@sridhar.beaverton.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-01-31 at 17:30 -0800, Sridhar Samudrala wrote:
> Yes. It definitely should be 'out'. 'in' should be 0 in the tx path.
> 
> I tried a simpler version of this patch without any tunables by
> delaying the signaling until we come out of the for loop.
> It definitely reduced the number of vmexits significantly for small
> message
> guest to host stream test and the throughput went up a little.
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 9b3ca10..5f9fae9 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -197,7 +197,7 @@ static void handle_tx(struct vhost_net *net)
>                 if (err != len)
>                         pr_debug("Truncated TX packet: "
>                                  " len %d != %zd\n", err, len);
> -               vhost_add_used_and_signal(&net->dev, vq, head, 0);
> +               vhost_add_used(vq, head, 0);
>                 total_len += len;
>                 if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
>                         vhost_poll_queue(&vq->poll);
> @@ -205,6 +205,8 @@ static void handle_tx(struct vhost_net *net)
>                 }
>         }
> 
> +       if (total_len > 0)
> +               vhost_signal(&net->dev, vq);
>         mutex_unlock(&vq->mutex);
>  }

Reducing the signaling will reduce the CPU utilization by reducing VM
exits. 

The small message BW is a problem we have seen faster guest/slow vhost,
even I increased VHOST_NET_WEIGHT times, it didn't help that much for
BW. For large message size, vhost is able to process all packets on
time. I played around with guest/host codes, I only see huge BW
improvement by dropping packets on guest side so far.

Thanks
Shirley

