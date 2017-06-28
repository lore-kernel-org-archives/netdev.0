From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 7/9] nfp: add metadata to
 each flow offload
Date: Wed, 28 Jun 2017 12:31:34 +0200
Message-ID: <20170628103132.GE9412@vergenet.net>
References: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
 <1498605709-22574-8-git-send-email-simon.horman@netronome.com>
 <20170627231520.28cc48ed@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:36174 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751492AbdF1Kbl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 06:31:41 -0400
Received: by mail-qt0-f178.google.com with SMTP id i2so45538844qta.3
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 03:31:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170627231520.28cc48ed@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 11:15:20PM -0700, Jakub Kicinski wrote:
> On Wed, 28 Jun 2017 01:21:47 +0200, Simon Horman wrote:
> > From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> > 
> > Adds metadata describing the mask id of each flow and keeps track of
> > flows installed in hardware. Previously a flow could not be removed
> > from hardware as there was no way of knowing if that a specific flow
> > was installed. This is solved by storing the offloaded flows in a
> > hash table.
t reb> > 
> > Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> > diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.h b/drivers/net/ethernet/netronome/nfp/flower/main.h
> > index 52db2acb250e..cc184618306c 100644
> > --- a/drivers/net/ethernet/netronome/nfp/flower/main.h
> > +++ b/drivers/net/ethernet/netronome/nfp/flower/main.h
> > @@ -34,6 +34,7 @@
> >  #ifndef __NFP_FLOWER_H__
> >  #define __NFP_FLOWER_H__ 1
> >  
> > +#include <linux/circ_buf.h>
> >  #include <linux/types.h>
> >  
> >  #include "cmsg.h"
> > @@ -45,6 +46,42 @@ struct tc_to_netdev;
> >  struct net_device;
> >  struct nfp_app;
> >  
> > +#define NFP_FLOWER_HASH_BITS		10
> > +#define NFP_FLOWER_HASH_SEED		129004
> > +
> > +#define NFP_FLOWER_MASK_ENTRY_RS	256
> > +#define NFP_FLOWER_MASK_ELEMENT_RS	1
> > +#define NFP_FLOWER_MASK_HASH_BITS	10
> > +#define NFP_FLOWER_MASK_HASH_SEED	9198806
> > +
> > +#define NFP_FL_META_FLAG_NEW_MASK	128
> > +#define NFP_FL_META_FLAG_LAST_MASK	1
> > +
> > +#define NFP_FL_MASK_REUSE_TIME		40
> > +#define NFP_FL_MASK_ID_LOCATION		1
> > +
> > +struct nfp_fl_mask_id {
> > +	struct circ_buf mask_id_free_list;
> > +	struct timeval *last_used;
> > +	u8 init_unallocated;
> > +};
> > +
> > +/**
> > + * struct nfp_flower_priv - Flower APP per-vNIC priv data
> > + * @nn:			Pointer to vNIC
> > + * @flower_version:	HW version of flower
> > + * @mask_ids:		List of free mask ids
> > + * @mask_table:		Hash table used to store masks
> > + * @flow_table:		Hash table used to store flower rules
> > + */
> > +struct nfp_flower_priv {
> > +	struct nfp_net *nn;
> > +	u64 flower_version;
> > +	struct nfp_fl_mask_id mask_ids;
> > +	DECLARE_HASHTABLE(mask_table, NFP_FLOWER_MASK_HASH_BITS);
> > +	DECLARE_HASHTABLE(flow_table, NFP_FLOWER_HASH_BITS);
> 
> Include for hashtable seems missing.

Thanks, I'll include linux/hashtable.h

> > +};
> > +
> >  struct nfp_fl_key_ls {
> >  	u32 key_layer_two;
> >  	u8 key_layer;
> > @@ -69,6 +106,10 @@ struct nfp_fl_payload {
> >  	char *action_data;
> >  };
> >  
> > +int nfp_flower_metadata_init(struct nfp_app *app);
> > +void nfp_flower_metadata_cleanup(struct nfp_app *app);
> > +
> > +int nfp_repr_get_port_id(struct net_device *netdev);
> 
> Isn't this a static inline in repr.h?

Sorry, I think that crept in during some patch shuffling.
I will remove it.

> >  int nfp_flower_repr_init(struct nfp_app *app);
> >  int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
> >  			u32 handle, __be16 proto, struct tc_to_netdev *tc);
> 
> > diff --git a/drivers/net/ethernet/netronome/nfp/flower/metadata.c b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
> > new file mode 100644
> > index 000000000000..acbf4c757988
> 
> > + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> > + * SOFTWARE.
> > + */
> > +
> > +#include <asm/timex.h>
> 
> I think this is unnecessary.

Thanks, removed.

> 
> > +#include <linux/hash.h>
> > +#include <linux/hashtable.h>
> > +#include <linux/jhash.h>
> > +#include <linux/vmalloc.h>
> > +#include <net/pkt_cls.h>
> 
> > +static int nfp_mask_alloc(struct nfp_app *app, u8 *mask_id)
> > +{
> > +	struct nfp_flower_priv *priv = app->priv;
> > +	struct timeval reuse, curr;
> > +	struct circ_buf *ring;
> > +	u8 temp_id, freed_id;
> > +
> > +	ring = &priv->mask_ids.mask_id_free_list;
> > +	freed_id = NFP_FLOWER_MASK_ENTRY_RS - 1;
> > +	/* Checking for unallocated entries first. */
> > +	if (priv->mask_ids.init_unallocated > 0) {
> > +		*mask_id = priv->mask_ids.init_unallocated;
> > +		priv->mask_ids.init_unallocated--;
> > +		goto exit_check_timestamp;
> 
> Do you really need to check the timestamp here?  Isn't this if() for the
> case where we have some masks which were never used by the driver?

I think not. I will drop this.

> > +	}
> > +
> > +	/* Checking if buffer is empty. */
> > +	if (ring->head == ring->tail) {
> > +		*mask_id = freed_id;
> > +		return -ENOENT;
> > +	}
> > +
> > +	memcpy(&temp_id, &ring->buf[ring->tail], NFP_FLOWER_MASK_ELEMENT_RS);
> > +	*mask_id = temp_id;
> > +	memcpy(&ring->buf[ring->tail], &freed_id, NFP_FLOWER_MASK_ELEMENT_RS);
> > +
> > +	ring->tail = (ring->tail + NFP_FLOWER_MASK_ELEMENT_RS) %
> > +		     (NFP_FLOWER_MASK_ENTRY_RS * NFP_FLOWER_MASK_ELEMENT_RS);
> > +
> > +exit_check_timestamp:
> > +	do_gettimeofday(&curr);
> > +	reuse.tv_sec = curr.tv_sec -
> > +		       priv->mask_ids.last_used[*mask_id].tv_sec;
> > +	reuse.tv_usec = curr.tv_usec -
> > +			priv->mask_ids.last_used[*mask_id].tv_usec;
> 
> Could you perhaps use timespec64 as the type?  You will then be able to
> use timespec64_sub() and it will save a nsec -> usec conversion in
> do_gettimeofday().

Thanks for the suggestion. It seems to clean things up a bit.

> > +	if (!reuse.tv_sec && reuse.tv_usec < NFP_FL_MASK_REUSE_TIME) {
> > +		nfp_release_mask_id(app, *mask_id);
> > +		return -ENOENT;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int
> > +nfp_add_mask_table(struct nfp_app *app, char *mask_data, u32 mask_len)
> > +{
> > +	struct nfp_flower_priv *priv = app->priv;
> > +	struct nfp_mask_id_table *mask_entry;
> > +	unsigned long hash_key;
> > +	u8 mask_id;
> > +
> > +	if (nfp_mask_alloc(app, &mask_id))
> > +		return -ENOENT;
> > +
> > +	mask_entry = kmalloc(sizeof(*mask_entry), GFP_ATOMIC);
> 
> GFP_KERNEL, I think there used to be a spinlock around this which is no
> more?

Yes, I think so too.
I'll change this to use GFP_KERNEL.

> > +	if (!mask_entry) {
> > +		nfp_release_mask_id(app, mask_id);
> > +		return -ENOMEM;
> > +	}
> > +
> > +	INIT_HLIST_NODE(&mask_entry->link);
> > +	mask_entry->mask_id = mask_id;
> > +	hash_key = jhash(mask_data, mask_len, NFP_FLOWER_MASK_HASH_SEED);
> > +	mask_entry->hash_key = hash_key;
> > +	mask_entry->ref_cnt = 1;
> > +	hash_add(priv->mask_table, &mask_entry->link, hash_key);
> > +
> > +	return mask_id;
> > +}
> 
> > +static int
> > +nfp_check_mask_add(struct nfp_app *app, char *mask_data, u32 mask_len,
> > +		   u8 *mask_id)
> > +{
> > +	int allocate_mask;
>
> bool? (same for the return type)

Thanks, I have reworked this a bit.

> > +	int err;
> > +
> > +	allocate_mask = 0;
> > +	err = nfp_find_in_mask_table(app, mask_data, mask_len);
> > +	if (err < 0) {
> > +		/* Could not find an existing mask id. */
> > +		allocate_mask = NFP_FL_META_FLAG_NEW_MASK;
> > +		err = nfp_add_mask_table(app, mask_data, mask_len);
> > +		if (err < 0)
> > +			return -ENOENT;
> > +	}
> > +	*mask_id = err;
> > +
> > +	return allocate_mask;
> > +}
> 
> > +int nfp_flower_metadata_init(struct nfp_app *app)
> > +{
> > +	struct nfp_flower_priv *priv = app->priv;
> > +
> > +	hash_init(priv->mask_table);
> > +	hash_init(priv->flow_table);
> > +
> > +	/* Init ring buffer and unallocated mask_ids. */
> > +	priv->mask_ids.mask_id_free_list.buf =
> > +		kzalloc(NFP_FLOWER_MASK_ENTRY_RS * NFP_FLOWER_MASK_ELEMENT_RS,
> > +			GFP_KERNEL);
> 
> Is zeroing this memory necessary?
> 
> > +	if (!priv->mask_ids.mask_id_free_list.buf)
> > +		return -ENOMEM;
> > +
> > +	priv->mask_ids.init_unallocated = NFP_FLOWER_MASK_ENTRY_RS - 1;
> > +
> > +	/* Init timestamps for mask id*/
> > +	priv->mask_ids.last_used = kcalloc(NFP_FLOWER_MASK_ENTRY_RS,
> > +					   sizeof(*priv->mask_ids.last_used),
> > +					   GFP_KERNEL);
> 
> And this, potentially?
> 
> > +	if (!priv->mask_ids.last_used) {
> > +		kfree(priv->mask_ids.mask_id_free_list.buf);
> > +		return -ENOMEM;
> > +	}
> > +
> > +	priv->flower_version = 0;

And here.

No, I don't think so.
I'll see about removing it.

> > +
> > +	return 0;
> > +}
> 
> > diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
> > index c8f9e2996cc6..a7f688bbc761 100644
> > --- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
> > +++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
> 
> > @@ -297,6 +318,9 @@ int nfp_flower_repr_init(struct nfp_app *app)
> >  	u64 version;
> >  	int err;
> >  
> > +	if (nfp_flower_metadata_init(app) < 0)
> > +		return -EOPNOTSUPP;
> 
> app init candidate.

Thanks, I am calling nfp_flower_metadata_init in app init now.
