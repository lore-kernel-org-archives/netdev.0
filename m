From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 2/2] macvtap: restore vlan header on user read
Date: Thu, 3 May 2012 16:07:53 +0300
Message-ID: <20120503130751.GB26366@redhat.com>
References: <m1ipgtzwew.fsf@fess.ebiederm.org>
 <1335373316-612-1-git-send-email-basil.gor@gmail.com>
 <m162cngitu.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Basil Gor <basil.gor@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35873 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754281Ab2ECNHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 09:07:50 -0400
Content-Disposition: inline
In-Reply-To: <m162cngitu.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 25, 2012 at 10:31:25PM -0700, Eric W. Biederman wrote:
> Basil Gor <basil.gor@gmail.com> writes:
> 
> > Vlan tag is restored during buffer transmit to a network device (bridge
> > port) in bridging code in case of tun/tap driver. In case of macvtap it
> > has to be done explicitly. Otherwise vlan_tci is ignored and user always
> > gets untagged packets.
> 
> We could quibble about efficiencies but this looks good except for
> macvtap_recvmsg which isn't setting the auxdata for the vlan header.
> 
> Eric

Right. I'm guessing we need to support old userspace
so if there's auxdata, put vlan there but if not,
put the vlan in the packet like this patch does.

> > Signed-off-by: Basil Gor <basil.gor@gmail.com>
> > ---
> >  drivers/net/macvtap.c |   11 ++++++++++-
> >  1 files changed, 10 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> > index 0427c65..28d2678 100644
> > --- a/drivers/net/macvtap.c
> > +++ b/drivers/net/macvtap.c
> > @@ -1,6 +1,7 @@
> >  #include <linux/etherdevice.h>
> >  #include <linux/if_macvlan.h>
> >  #include <linux/interrupt.h>
> > +#include <linux/if_vlan.h>
> >  #include <linux/nsproxy.h>
> >  #include <linux/compat.h>
> >  #include <linux/if_tun.h>
> > @@ -753,13 +754,21 @@ static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
> >  
> >  /* Put packet to the user space buffer */
> >  static ssize_t macvtap_put_user(struct macvtap_queue *q,
> > -				const struct sk_buff *skb,
> > +				struct sk_buff *skb,
> >  				const struct iovec *iv, int len)
> >  {
> >  	struct macvlan_dev *vlan;
> >  	int ret;
> >  	int vnet_hdr_len = 0;
> >  
> > +	if (vlan_tx_tag_present(skb)) {
> > +		skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
> > +		if (unlikely(!skb))
> > +			return -ENOMEM;
> > +
> > +		skb->vlan_tci = 0;
> > +	}
> > +
> >  	if (q->flags & IFF_VNET_HDR) {
> >  		struct virtio_net_hdr vnet_hdr;
> >  		vnet_hdr_len = q->vnet_hdr_sz;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
