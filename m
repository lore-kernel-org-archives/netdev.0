From: Pankaj Gupta <pagupta@redhat.com>
Subject: Re: [RFC 1/4] net: allow large number of rx queues
Date: Tue, 19 Aug 2014 01:15:28 -0400 (EDT)
Message-ID: <1250944564.24690078.1408425328214.JavaMail.zimbra@redhat.com>
References: <1408369040-1216-1-git-send-email-pagupta@redhat.com> <1408369040-1216-2-git-send-email-pagupta@redhat.com> <53F23B4C.2000507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com, wuzhy@linux.vnet.ibm.com,
	xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:35734 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaHSFPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 01:15:44 -0400
In-Reply-To: <53F23B4C.2000507@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Hello.
> 
> On 08/18/2014 05:37 PM, Pankaj Gupta wrote:
> 
> > netif_alloc_rx_queues() uses kcalloc() to allocate memory
> > for "struct netdev_queue *_rx" array.
> > If we are doing large rx queue allocation kcalloc() might
> > fail, so this patch does a fallback to vzalloc().
> > Similar implementation is done for tx queue allocation in
> > netif_alloc_netdev_queues().
> 
> > We avoid failure of high order memory allocation
> > with the help of vzalloc(), this allows us to do large
> > rx and tx queue allocation which in turn helps us to
> > increase the number of queues in tun.
> 
> > As vmalloc() adds overhead on a critical network path,
> > __GFP_REPEAT flag is used with kzalloc() to do this fallback
> > only when really needed.
> 
> > Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> > Reviewed-by: Michael S. Tsirkin <mst@redhat.com>
> > Reviewed-by: David Gibson <dgibson@redhat.com>
> > ---
> >   net/core/dev.c | 20 +++++++++++++-------
> >   1 file changed, 13 insertions(+), 7 deletions(-)
> 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 1c15b18..a455a02 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -5942,17 +5942,24 @@ void netif_stacked_transfer_operstate(const struct
> > net_device *rootdev,
> >   EXPORT_SYMBOL(netif_stacked_transfer_operstate);
> >
> >   #ifdef CONFIG_SYSFS
> > +static void netif_free_rx_queues(struct net_device *dev)
> > +{
> > +	kvfree(dev->_rx);
> > +}
> > +
> >   static int netif_alloc_rx_queues(struct net_device *dev)
> >   {
> >   	unsigned int i, count = dev->num_rx_queues;
> >   	struct netdev_rx_queue *rx;
> > -
> > +	size_t sz = count * sizeof(*rx);
> 
>    Please keep an empty line after declarations.
     Yes, I will add it. Thanks
> 
> >   	BUG_ON(count < 1);
> >
> 
> WBR, Sergei
> 
> 
