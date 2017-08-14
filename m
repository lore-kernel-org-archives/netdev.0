From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH net-next v2 2/3] net/ncsi: Configure VLAN tag filter
Date: Mon, 14 Aug 2017 11:39:52 +0930
Message-ID: <CACPK8XfD=4=Axh+waO0KMRMntLBBWrb86f92NgX134U72wofzw@mail.gmail.com>
References: <20170814012952.13740-1-sam@mendozajonas.com> <20170814012952.13740-3-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>,
        Ratan K Gupta <ratagupt@in.ibm.com>
To: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814012952.13740-3-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2017 at 10:59 AM, Samuel Mendoza-Jonas
<sam@mendozajonas.com> wrote:
> Make use of the ndo_vlan_rx_{add,kill}_vid callbacks to have the NCSI
> stack process new VLAN tags and configure the channel VLAN filter
> appropriately.
> Several VLAN tags can be set and a "Set VLAN Filter" packet must be sent
> for each one, meaning the ncsi_dev_state_config_svf state must be
> repeated. An internal list of VLAN tags is maintained, and compared
> against the current channel's ncsi_channel_filter in order to keep track
> within the state. VLAN filters are removed in a similar manner, with the
> introduction of the ncsi_dev_state_config_clear_vids state. The maximum
> number of VLAN tag filters is determined by the "Get Capabilities"
> response from the channel.
>
> Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>

I've given this some testing, but there are a few things I saw below
that we should sort out.

> --- a/net/ncsi/ncsi-manage.c
> +++ b/net/ncsi/ncsi-manage.c
> @@ -38,6 +38,22 @@ static inline int ncsi_filter_size(int table)
>         return sizes[table];
>  }
>
> +u32 *ncsi_get_filter(struct ncsi_channel *nc, int table, int index)
> +{
> +       struct ncsi_channel_filter *ncf;
> +       int size;
> +
> +       ncf = nc->filters[table];
> +       if (!ncf)
> +               return NULL;
> +
> +       size = ncsi_filter_size(table);
> +       if (size < 0)
> +               return NULL;
> +
> +       return ncf->data + size * index;
> +}
> +
>  int ncsi_find_filter(struct ncsi_channel *nc, int table, void *data)
>  {
>         struct ncsi_channel_filter *ncf;
> @@ -58,7 +74,7 @@ int ncsi_find_filter(struct ncsi_channel *nc, int table, void *data)
>         index = -1;
>         while ((index = find_next_bit(bitmap, ncf->total, index + 1))
>                < ncf->total) {
> -               if (!memcmp(ncf->data + size * index, data, size)) {
> +               if (!data || !memcmp(ncf->data + size * index, data, size)) {

Not clear why this check is required?

>                         spin_unlock_irqrestore(&nc->lock, flags);
>                         return index;
>                 }
> @@ -639,6 +655,83 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
>         nd->state = ncsi_dev_state_functional;
>  }
>
> +/* Check the VLAN filter bitmap for a set filter, and construct a
> + * "Set VLAN Filter - Disable" packet if found.
> + */
> +static int clear_one_vid(struct ncsi_dev_priv *ndp, struct ncsi_channel *nc,
> +                        struct ncsi_cmd_arg *nca)
> +{
> +       int index;
> +       u16 vid;
> +
> +       index = ncsi_find_filter(nc, NCSI_FILTER_VLAN, NULL);
> +       if (index < 0) {
> +               /* Filter table empty */
> +               return -1;
> +       }
> +
> +       vid = *(u16 *)ncsi_get_filter(nc, NCSI_FILTER_VLAN, index);

You just added this function that returns a pointer to a u32. It's
strange to see the only call site then throw half of it away.

Also, ncsi_get_filter can return NULL.

> +       netdev_printk(KERN_DEBUG, ndp->ndev.dev,
> +                     "ncsi: removed vlan tag %u at index %d\n",
> +                     vid, index + 1);
> +       ncsi_remove_filter(nc, NCSI_FILTER_VLAN, index);
> +
> +       nca->type = NCSI_PKT_CMD_SVF;
> +       nca->words[1] = vid;
> +       /* HW filter index starts at 1 */
> +       nca->bytes[6] = index + 1;
> +       nca->bytes[7] = 0x00;
> +       return 0;
> +}

> @@ -751,6 +876,26 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
>                 break;
>         case ncsi_dev_state_config_done:
>                 spin_lock_irqsave(&nc->lock, flags);
> +               if (nc->reconfigure_needed) {
> +                       /* This channel's configuration has been updated
> +                        * part-way during the config state - start the
> +                        * channel configuration over
> +                        */
> +                       nc->reconfigure_needed = false;
> +                       nc->state = NCSI_CHANNEL_INVISIBLE;
> +                       spin_unlock_irqrestore(&nc->lock, flags);
> +
> +                       spin_lock_irqsave(&ndp->lock, flags);
> +                       nc->state = NCSI_CHANNEL_INACTIVE;

This looks strange. What's nc->state up to? Does setting it to
NCSI_CHANNEL_INVISIBLE have any affect?

The locking is confusing too.

> +                       list_add_tail_rcu(&nc->link, &ndp->channel_queue);
> +                       spin_unlock_irqrestore(&ndp->lock, flags);
> +
> +                       netdev_printk(KERN_DEBUG, dev,
> +                                     "Dirty NCSI channel state reset\n");
> +                       ncsi_process_next_channel(ndp);
> +                       break;
> +               }
> +
>                 if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1) {
>                         hot_nc = nc;
>                         nc->state = NCSI_CHANNEL_ACTIVE;
> @@ -1191,6 +1336,149 @@ static struct notifier_block ncsi_inet6addr_notifier = {
>  };
>  #endif /* CONFIG_IPV6 */
>
> +static int ncsi_kick_channels(struct ncsi_dev_priv *ndp)
> +{
> +       struct ncsi_dev *nd = &ndp->ndev;
> +       struct ncsi_channel *nc;
> +       struct ncsi_package *np;
> +       unsigned long flags;
> +       unsigned int n = 0;
> +
> +       NCSI_FOR_EACH_PACKAGE(ndp, np) {
> +               NCSI_FOR_EACH_CHANNEL(np, nc) {
> +                       spin_lock_irqsave(&nc->lock, flags);
> +
> +                       /* Channels may be busy, mark dirty instead of
> +                        * kicking if;
> +                        * a) not ACTIVE (configured)
> +                        * b) in the channel_queue (to be configured)
> +                        * c) it's ndev is in the config state
> +                        */
> +                       if (nc->state != NCSI_CHANNEL_ACTIVE) {
> +                               if ((ndp->ndev.state & 0xff00) ==
> +                                               ncsi_dev_state_config ||
> +                                               !list_empty(&nc->link)) {
> +                                       netdev_printk(KERN_DEBUG, nd->dev,
> +                                                     "ncsi: channel %p marked dirty\n",
> +                                                     nc);
> +                                       nc->reconfigure_needed = true;
> +                               }
> +                               spin_unlock_irqrestore(&nc->lock, flags);
> +                               continue;
> +                       }
> +
> +                       spin_unlock_irqrestore(&nc->lock, flags);
> +
> +                       ncsi_stop_channel_monitor(nc);
> +                       spin_lock_irqsave(&nc->lock, flags);
> +                       nc->state = NCSI_CHANNEL_INVISIBLE;
> +                       spin_unlock_irqrestore(&nc->lock, flags);
> +
> +                       spin_lock_irqsave(&ndp->lock, flags);
> +                       nc->state = NCSI_CHANNEL_INACTIVE;

This is a similar pattern to ncsi_configure_channel. I suspect the
answer there will be the same as here.

> +                       list_add_tail_rcu(&nc->link, &ndp->channel_queue);
> +                       spin_unlock_irqrestore(&ndp->lock, flags);
> +
> +                       netdev_printk(KERN_DEBUG, nd->dev,
> +                                     "ncsi: kicked channel %p\n", nc);
> +                       n++;
> +               }
> +       }
