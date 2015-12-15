From: "Duda, Lukasz" <Lukasz.Duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org>
Subject: RE: [RFCv4 bluetooth-next 1/2] 6lowpan: iphc: add support for
 stateful compression
Date: Tue, 15 Dec 2015 10:29:51 +0000
Message-ID: <AB80DA35A7B64E4E98291794926897D9011B97546F@MBX03.nvlsi.no>
References: <1450101654-22633-1-git-send-email-alex.aring@gmail.com>
 <1450101654-22633-2-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org" <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org" <mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org>,
	"martin.gergeleit-6wGqcYweBVc@public.gmane.org" <martin.gergeleit-6wGqcYweBVc@public.gmane.org>
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450101654-22633-2-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alex,

> -----Original Message-----
> From: Alexander Aring [mailto:alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org]
> Sent: Monday, December 14, 2015 15:01
> To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org; mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org; Duda, Lukasz;
> martin.gergeleit-6wGqcYweBVc@public.gmane.org; Alexander Aring
> Subject: [RFCv4 bluetooth-next 1/2] 6lowpan: iphc: add support for st=
ateful
> compression
>=20
> This patch introduce support for IPHC stateful address compression. I=
t will
> offer the context table via one debugfs entry.
>=20
> Example to setup a context id:
>=20
> A "cat /sys/kernel/debug/6lowpan/lowpan0/ctx_table" will display all
> contexts which are available. Example:
>=20
> ID ipv6-address/prefix-length                  flags
> 0  0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 1  0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 2  0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 3  0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 4  0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 5  0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 6  0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 7  0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 8  0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 9  0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 10 0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 11 0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 12 0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 13 0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 14 0000:0000:0000:0000:0000:0000:0000:0000/0   0
> 15 0000:0000:0000:0000:0000:0000:0000:0000/0   0
>=20
> For setting a context e.g. context id 0, context 2001::, prefix-lengt=
h 64.
>=20
> Hint: Simple copy one line and then maniuplate it.
>=20
> echo "0 2001:0000:0000:0000:0000:0000:0000:0000/64 3" >
> /sys/kernel/debug/6lowpan/lowpan0/ctx_table
>=20
> The flags are currently two:
>=20
>  - BIT(0) - active: entry is added or deleted to the ctx_table.
>  - BIT(1) - c: compression flag according rfc6775.
>=20
> On transmit side:
>=20
> The IPHC code will automatically search for a context which would be =
match
> for the address. Then it will be use the context with the best compre=
ssion
> method. Means the longest prefix which match will be used.
>=20
> Example:
>=20
> 2001::/126 vs 2001::/127 - the 2001::/127 can be full compressed if t=
he last
> bit of the address which has the prefix 2001::/127 is the same like t=
he IID
> from the Encapsulating Header. A context ID can also be a 2001::1/128=
, which
> is then a full ipv6 address.
>=20
> On Receive side:
>=20
> If there is a context defined (when CID not available then it's the d=
efault
> context 0) then it will be used, if the header doesn't set SAC or DAC=
 bit thens,
> it will be dropped.
>=20
> Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  include/net/6lowpan.h |  31 ++++
>  net/6lowpan/core.c    |   6 +-
>  net/6lowpan/debugfs.c |  97 ++++++++++++
>  net/6lowpan/iphc.c    | 420
> +++++++++++++++++++++++++++++++++++++++++++-------
>  4 files changed, 496 insertions(+), 58 deletions(-)
>=20
> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h index
> 2f6a3f2..db636c8 100644
> --- a/include/net/6lowpan.h
> +++ b/include/net/6lowpan.h
> @@ -75,6 +75,8 @@
>  #define LOWPAN_IPHC_MAX_HC_BUF_LEN	(sizeof(struct ipv6hdr) +
> 	\
>  					 LOWPAN_IPHC_MAX_HEADER_LEN +
> 	\
>  					 LOWPAN_NHC_MAX_HDR_LEN)
> +/* SCI/DCI is 4 bit width, so we have maximum 16 entries */
> +#define LOWPAN_IPHC_CI_TABLE_SIZE	(1 << 4)
>=20
>  #define LOWPAN_DISPATCH_IPV6		0x41 /* 01000001 =3D 65 */
>  #define LOWPAN_DISPATCH_IPHC		0x60 /* 011xxxxx =3D ... */
> @@ -98,9 +100,38 @@ enum lowpan_lltypes {
>  	LOWPAN_LLTYPE_IEEE802154,
>  };
>=20
> +enum lowpan_iphc_ctx_flags {
> +	LOWPAN_IPHC_CTX_FLAG_ACTIVE	=3D BIT(0),
> +	LOWPAN_IPHC_CTX_FLAG_C		=3D BIT(1),
> +};
> +
> +struct lowpan_iphc_ctx {
> +	u8 id;
> +	struct in6_addr pfx;
> +	u8 plen;
> +	u32 flags;
> +};
> +
> +struct lowpan_iphc_ctx_table {
> +	spinlock_t lock;
> +	const struct lowpan_iphc_ctx_ops *ops;
> +	struct lowpan_iphc_ctx table[LOWPAN_IPHC_CI_TABLE_SIZE]; };
> +
> +static inline bool lowpan_iphc_ctx_is_active(const struct
> +lowpan_iphc_ctx *ctx) {
> +	return ctx->flags & LOWPAN_IPHC_CTX_FLAG_ACTIVE; }
> +
> +static inline bool lowpan_iphc_ctx_is_c(const struct lowpan_iphc_ctx
> +*ctx) {
> +	return ctx->flags & LOWPAN_IPHC_CTX_FLAG_C; }
> +
>  struct lowpan_priv {
>  	enum lowpan_lltypes lltype;
>  	struct dentry *iface_debugfs;
> +	struct lowpan_iphc_ctx_table ctx;
>=20
>  	/* must be last */
>  	u8 priv[0] __aligned(sizeof(void *));
> diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c index c7f06f5..7=
72f51c
> 100644
> --- a/net/6lowpan/core.c
> +++ b/net/6lowpan/core.c
> @@ -20,7 +20,7 @@
>  int lowpan_register_netdevice(struct net_device *dev,
>  			      enum lowpan_lltypes lltype)
>  {
> -	int ret;
> +	int i, ret;
>=20
>  	dev->addr_len =3D EUI64_ADDR_LEN;
>  	dev->type =3D ARPHRD_6LOWPAN;
> @@ -29,6 +29,10 @@ int lowpan_register_netdevice(struct net_device
> *dev,
>=20
>  	lowpan_priv(dev)->lltype =3D lltype;
>=20
> +	spin_lock_init(&lowpan_priv(dev)->ctx.lock);
> +	for (i =3D 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++)
> +		lowpan_priv(dev)->ctx.table[i].id =3D i;
> +
>  	ret =3D lowpan_dev_debugfs_init(dev);
>  	if (ret < 0)
>  		return ret;
> diff --git a/net/6lowpan/debugfs.c b/net/6lowpan/debugfs.c index
> 88eef84..5270fa1 100644
> --- a/net/6lowpan/debugfs.c
> +++ b/net/6lowpan/debugfs.c
> @@ -16,19 +16,116 @@
>=20
>  #include "6lowpan_i.h"
>=20
> +#define LOWPAN_DEBUGFS_CTX_NUM_ARGS		11
> +
>  static struct dentry *lowpan_debugfs;
>=20
> +static int lowpan_context_show(struct seq_file *file, void *offset) =
{
> +	struct lowpan_iphc_ctx_table *t =3D file->private;
> +	int i;
> +
> +	seq_printf(file, "%-2s %-43s %s\n", "ID", "ipv6-address/prefix-leng=
th",
> +		   "flags");
> +
> +	spin_lock_bh(&t->lock);
> +	for (i =3D 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++)
> +		seq_printf(file,
> +			   "%-2d
> %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x/%-3d %x\n",
> +			   t->table[i].id,
> +			   be16_to_cpu(t->table[i].pfx.s6_addr16[0]),
> +			   be16_to_cpu(t->table[i].pfx.s6_addr16[1]),
> +			   be16_to_cpu(t->table[i].pfx.s6_addr16[2]),
> +			   be16_to_cpu(t->table[i].pfx.s6_addr16[3]),
> +			   be16_to_cpu(t->table[i].pfx.s6_addr16[4]),
> +			   be16_to_cpu(t->table[i].pfx.s6_addr16[5]),
> +			   be16_to_cpu(t->table[i].pfx.s6_addr16[6]),
> +			   be16_to_cpu(t->table[i].pfx.s6_addr16[7]),
> +			   t->table[i].plen, t->table[i].flags);
> +	spin_unlock_bh(&t->lock);
> +
> +	return 0;
> +}
> +
> +static int lowpan_context_dbgfs_open(struct inode *inode, struct fil=
e
> +*file) {
> +	return single_open(file, lowpan_context_show, inode->i_private); }
> +
> +static ssize_t lowpan_context_dbgfs_write(struct file *fp,
> +					  const char __user *user_buf,
> +					  size_t count, loff_t *ppos)
> +{
> +	char buf[128] =3D {};
> +	struct seq_file *file =3D fp->private_data;
> +	struct lowpan_iphc_ctx_table *t =3D file->private;
> +	struct lowpan_iphc_ctx ctx;
> +	int status =3D count, n, id, i, plen;
> +	unsigned int addr[8], flags;
> +
> +	if (copy_from_user(&buf, user_buf, min_t(size_t, sizeof(buf) - 1,
> +						 count))) {
> +		status =3D -EFAULT;
> +		goto out;
> +	}
> +
> +	n =3D sscanf(buf, "%d
> %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x/%d %x",
> +		   &id, &addr[0], &addr[1], &addr[2], &addr[3], &addr[4],
> +		   &addr[5], &addr[6], &addr[7], &plen, &flags);
> +	if (n !=3D LOWPAN_DEBUGFS_CTX_NUM_ARGS) {
> +		status =3D -EIO;
> +		goto out;
> +	}
> +
> +	if (id > LOWPAN_IPHC_CI_TABLE_SIZE - 1 || plen > 128) {
> +		status =3D -EINVAL;
> +		goto out;
> +	}
> +
> +	ctx.id =3D id;
> +	ctx.plen =3D plen;
> +	ctx.flags =3D flags & (LOWPAN_IPHC_CTX_FLAG_ACTIVE |
> +			     LOWPAN_IPHC_CTX_FLAG_C);
> +
> +	for (i =3D 0; i < 8; i++)
> +		ctx.pfx.s6_addr16[i] =3D cpu_to_be16(addr[i] & 0xffff);
> +
> +	spin_lock_bh(&t->lock);
> +	memcpy(&t->table[ctx.id], &ctx, sizeof(ctx));
> +	spin_unlock_bh(&t->lock);
> +
> +out:
> +	return status;
> +}
> +
> +const struct file_operations lowpan_context_fops =3D {
> +	.open		=3D lowpan_context_dbgfs_open,
> +	.read		=3D seq_read,
> +	.write		=3D lowpan_context_dbgfs_write,
> +	.llseek		=3D seq_lseek,
> +	.release	=3D single_release,
> +};
> +
>  int lowpan_dev_debugfs_init(struct net_device *dev)  {
>  	struct lowpan_priv *lpriv =3D lowpan_priv(dev);
> +	static struct dentry *dentry;
>=20
>  	/* creating the root */
>  	lpriv->iface_debugfs =3D debugfs_create_dir(dev->name,
> lowpan_debugfs);
>  	if (!lpriv->iface_debugfs)
>  		goto fail;
>=20
> +	dentry =3D debugfs_create_file("ctx_table", 0644, lpriv->iface_debu=
gfs,
> +				     &lowpan_priv(dev)->ctx,
> +				     &lowpan_context_fops);
> +	if (!dentry)
> +		goto remove_root;
> +
>  	return 0;
>=20
> +remove_root:
> +	lowpan_dev_debugfs_exit(dev);
>  fail:
>  	return -EINVAL;
>  }
> diff --git a/net/6lowpan/iphc.c b/net/6lowpan/iphc.c index
> 346b5c1..909e0e8 100644
> --- a/net/6lowpan/iphc.c
> +++ b/net/6lowpan/iphc.c
> @@ -56,6 +56,7 @@
>  /* special link-layer handling */
>  #include <net/mac802154.h>
>=20
> +#include "6lowpan_i.h"
>  #include "nhc.h"
>=20
>  /* Values of fields within the IPHC encoding first byte */ @@ -147,6=
 +148,9
> @@
>  	 (((a)->s6_addr16[6]) =3D=3D 0) &&		\
>  	 (((a)->s6_addr[14]) =3D=3D 0))
>=20
> +#define LOWPAN_IPHC_CID_DCI(cid)	(cid & 0x0f)
> +#define LOWPAN_IPHC_CID_SCI(cid)	((cid & 0xf0) >> 4)
> +
>  static inline void iphc_uncompress_eui64_lladdr(struct in6_addr *ipa=
ddr,
>  						const void *lladdr)
>  {
> @@ -195,6 +199,104 @@ static inline void
> iphc_uncompress_802154_lladdr(struct in6_addr *ipaddr,
>  	}
>  }
>=20
> +static struct lowpan_iphc_ctx *
> +lowpan_iphc_ctx_get_by_id(const struct net_device *dev, u8 id) {
> +	struct lowpan_iphc_ctx *ret =3D &lowpan_priv(dev)->ctx.table[id];
> +
> +	WARN_ON_ONCE(id > LOWPAN_IPHC_CI_TABLE_SIZE);
> +
> +	if (!lowpan_iphc_ctx_is_active(ret))
> +		return NULL;
> +
> +	/* Don't need to check the compression flag here. Context SHOULD
> be used
> +	 * in decompression case another compressor has not yet received
> the
> +	 * updated context information.
> +	 */
> +	return ret;
> +}
> +
> +static struct lowpan_iphc_ctx *
> +lowpan_iphc_ctx_get_by_addr(const struct net_device *dev,
> +			    const struct in6_addr *addr)
> +{
> +	struct lowpan_iphc_ctx *table =3D lowpan_priv(dev)->ctx.table;
> +	struct lowpan_iphc_ctx *ret =3D NULL;
> +	struct in6_addr addr_pfx;
> +	u8 addr_plen;
> +	int i;
> +
> +	for (i =3D 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++) {
> +		/* Check if context is valid. A context that is not valid
> +		 * MUST NOT be used for compression.
> +		 */
> +		if (!lowpan_iphc_ctx_is_active(&table[i]) ||
> +		    !lowpan_iphc_ctx_is_c(&table[i]))
> +			continue;
> +
> +		ipv6_addr_prefix(&addr_pfx, addr, table[i].plen);
> +
> +		/* if prefix len < 64, the remaining bits until 64th bit is
> +		 * zero. Otherwise we use table[i]->plen.
> +		 */
> +		if (table[i].plen < 64)
> +			addr_plen =3D 64;
> +		else
> +			addr_plen =3D table[i].plen;
> +
> +		if (ipv6_prefix_equal(&addr_pfx, &table[i].pfx, addr_plen)) {
> +			/* remember first match */
> +			if (!ret) {
> +				ret =3D &table[i];
> +				continue;
> +			}
> +
> +			/* get the context with longest prefix len */
> +			if (table[i].plen > ret->plen)
> +				ret =3D &table[i];
> +		}
> +	}
> +
> +	return ret;
> +}
> +
> +static struct lowpan_iphc_ctx *
> +lowpan_iphc_ctx_get_by_mcast_addr(const struct net_device *dev,
> +				  const struct in6_addr *addr)
> +{
> +	struct lowpan_iphc_ctx *table =3D lowpan_priv(dev)->ctx.table;
> +	struct lowpan_iphc_ctx *ret =3D NULL;
> +	struct in6_addr addr_mcast, network_pfx =3D {};
> +	int i;
> +
> +	/* init mcast address with  */
> +	memcpy(&addr_mcast, addr, sizeof(*addr));
> +
> +	for (i =3D 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++) {
> +		/* Check if context is valid. A context that is not valid
> +		 * MUST NOT be used for compression.
> +		 */
> +		if (!lowpan_iphc_ctx_is_active(&table[i]) ||
> +		    !lowpan_iphc_ctx_is_c(&table[i]))
> +			continue;
> +
> +		/* setting plen */
> +		addr_mcast.s6_addr[3] =3D table[i].plen;
> +		/* get network prefix to copy into multicast address */
> +		ipv6_addr_prefix(&network_pfx, &table[i].pfx,
> +				 table[i].plen);
> +		/* setting network prefix */
> +		memcpy(&addr_mcast.s6_addr[4], &network_pfx, 8);
> +
> +		if (ipv6_addr_equal(addr, &addr_mcast)) {
> +			ret =3D &table[i];
> +			break;
> +		}
> +	}
> +
> +	return ret;
> +}
> +
>  /* Uncompress address function for source and
>   * destination address(non-multicast).
>   *
> @@ -259,30 +361,59 @@ static int uncompress_addr(struct sk_buff *skb,
> const struct net_device *dev,
>  /* Uncompress address function for source context
>   * based address(non-multicast).
>   */
> -static int uncompress_context_based_src_addr(struct sk_buff *skb,
> -					     struct in6_addr *ipaddr,
> -					     u8 address_mode)
> +static int uncompress_ctx_addr(struct sk_buff *skb,
> +			       const struct net_device *dev,
> +			       const struct lowpan_iphc_ctx *ctx,
> +			       struct in6_addr *ipaddr, u8 address_mode,
> +			       const void *lladdr)
>  {
> +	bool fail;
> +
>  	switch (address_mode) {
> -	case LOWPAN_IPHC_SAM_00:
> -		/* unspec address ::
> +	/* SAM and DAM are the same here */
> +	case LOWPAN_IPHC_DAM_00:
> +		fail =3D false;
> +		/* SAM_00 -> unspec address ::
>  		 * Do nothing, address is already ::
> +		 *
> +		 * DAM 00 -> reserved should never occur.
>  		 */
>  		break;
>  	case LOWPAN_IPHC_SAM_01:
> -		/* TODO */
> +	case LOWPAN_IPHC_DAM_01:
> +		fail =3D lowpan_fetch_skb(skb, &ipaddr->s6_addr[8], 8);
> +		ipv6_addr_prefix_copy(ipaddr, &ctx->pfx, ctx->plen);
> +		break;
>  	case LOWPAN_IPHC_SAM_10:
> -		/* TODO */
> +	case LOWPAN_IPHC_DAM_10:
> +		ipaddr->s6_addr[11] =3D 0xFF;
> +		ipaddr->s6_addr[12] =3D 0xFE;
> +		fail =3D lowpan_fetch_skb(skb, &ipaddr->s6_addr[14], 2);
> +		ipv6_addr_prefix_copy(ipaddr, &ctx->pfx, ctx->plen);
> +		break;
>  	case LOWPAN_IPHC_SAM_11:
> -		/* TODO */
> -		netdev_warn(skb->dev, "SAM value 0x%x not supported\n",
> -			    address_mode);
> -		return -EINVAL;
> +	case LOWPAN_IPHC_DAM_11:
> +		fail =3D false;
> +		switch (lowpan_priv(dev)->lltype) {
> +		case LOWPAN_LLTYPE_IEEE802154:
> +			iphc_uncompress_802154_lladdr(ipaddr, lladdr);
> +			break;
> +		default:
> +			iphc_uncompress_eui64_lladdr(ipaddr, lladdr);
> +			break;
> +		}
> +		ipv6_addr_prefix_copy(ipaddr, &ctx->pfx, ctx->plen);
> +		break;
>  	default:
>  		pr_debug("Invalid sam value: 0x%x\n", address_mode);
>  		return -EINVAL;
>  	}
>=20
> +	if (fail) {
> +		pr_debug("Failed to fetch skb data\n");
> +		return -EIO;
> +	}
> +
>  	raw_dump_inline(NULL,
>  			"Reconstructed context based ipv6 src addr is",
>  			ipaddr->s6_addr, 16);
> @@ -346,6 +477,30 @@ static int
> lowpan_uncompress_multicast_daddr(struct sk_buff *skb,
>  	return 0;
>  }
>=20
> +static int lowpan_uncompress_multicast_ctx_daddr(struct sk_buff *skb=
,
> +						 struct lowpan_iphc_ctx *ctx,
> +						 struct in6_addr *ipaddr,
> +						 u8 address_mode)
> +{
> +	struct in6_addr network_pfx =3D {};
> +	bool fail;
> +
> +	ipaddr->s6_addr[0] =3D 0xFF;
> +	fail =3D lowpan_fetch_skb(skb, &ipaddr->s6_addr[1], 2);
> +	fail |=3D lowpan_fetch_skb(skb, &ipaddr->s6_addr[12], 4);
> +	/* take prefix_len and network prefix from the context */
> +	ipaddr->s6_addr[3] =3D ctx->plen;
> +	/* get network prefix to copy into multicast address */
> +	ipv6_addr_prefix(&network_pfx, &ctx->pfx, ctx->plen);
> +	/* setting network prefix */
> +	memcpy(&ipaddr->s6_addr[4], &network_pfx, 8);
> +
> +	if (fail < 0)
> +		return -EIO;
> +
> +	return 0;
> +}
> +
>  /* get the ecn values from iphc tf format and set it to ipv6hdr */  =
static inline
> void lowpan_iphc_tf_set_ecn(struct ipv6hdr *hdr, const u8 *tf)  { @@ =
-459,7
> +614,8 @@ int lowpan_header_decompress(struct sk_buff *skb, const str=
uct
> net_device *dev,
>  			     const void *daddr, const void *saddr)  {
>  	struct ipv6hdr hdr =3D {};
> -	u8 iphc0, iphc1;
> +	struct lowpan_iphc_ctx *ci;
> +	u8 iphc0, iphc1, cid =3D 0;
>  	int err;
>=20
>  	raw_dump_table(__func__, "raw skb data dump uncompressed", @@
> -469,12 +625,14 @@ int lowpan_header_decompress(struct sk_buff *skb,
> const struct net_device *dev,
>  	    lowpan_fetch_skb(skb, &iphc1, sizeof(iphc1)))
>  		return -EINVAL;
>=20
> -	/* another if the CID flag is set */
> -	if (iphc1 & LOWPAN_IPHC_CID)
> -		return -ENOTSUPP;
> -
>  	hdr.version =3D 6;
>=20
> +	/* default CID =3D 0, another if the CID flag is set */
> +	if (iphc1 & LOWPAN_IPHC_CID) {
> +		if (lowpan_fetch_skb(skb, &cid, sizeof(cid)))
> +			return -EINVAL;
> +	}
> +
>  	err =3D lowpan_iphc_tf_decompress(skb, &hdr,
>  					iphc0 & LOWPAN_IPHC_TF_MASK);
>  	if (err < 0)
> @@ -500,10 +658,17 @@ int lowpan_header_decompress(struct sk_buff
> *skb, const struct net_device *dev,
>  	}
>=20
>  	if (iphc1 & LOWPAN_IPHC_SAC) {
> -		/* Source address context based uncompression */
> +		spin_lock_bh(&lowpan_priv(dev)->ctx.lock);
> +		ci =3D lowpan_iphc_ctx_get_by_id(dev,
> LOWPAN_IPHC_CID_SCI(cid));
> +		if (!ci) {
> +			spin_unlock_bh(&lowpan_priv(dev)->ctx.lock);
> +			return -EINVAL;
> +		}
> +
>  		pr_debug("SAC bit is set. Handle context based source
> address.\n");
> -		err =3D uncompress_context_based_src_addr(skb, &hdr.saddr,
> -							iphc1 &
> LOWPAN_IPHC_SAM_MASK);
> +		err =3D uncompress_ctx_addr(skb, dev, ci, &hdr.saddr,
> +					  iphc1 &
> LOWPAN_IPHC_SAM_MASK, saddr);
> +		spin_unlock_bh(&lowpan_priv(dev)->ctx.lock);
>  	} else {
>  		/* Source address uncompression */
>  		pr_debug("source address stateless compression\n"); @@ -
> 515,27 +680,52 @@ int lowpan_header_decompress(struct sk_buff *skb,
> const struct net_device *dev,
>  	if (err)
>  		return -EINVAL;
>=20
> -	/* check for Multicast Compression */
> -	if (iphc1 & LOWPAN_IPHC_M) {
> -		if (iphc1 & LOWPAN_IPHC_DAC) {
> -			pr_debug("dest: context-based mcast
> compression\n");
> -			/* TODO: implement this */
> -		} else {
> -			err =3D lowpan_uncompress_multicast_daddr(skb,
> &hdr.daddr,
> -								iphc1 &
> LOWPAN_IPHC_DAM_MASK);
> +	switch (iphc1 & (LOWPAN_IPHC_M | LOWPAN_IPHC_DAC)) {
> +	case LOWPAN_IPHC_M | LOWPAN_IPHC_DAC:
> +		spin_lock_bh(&lowpan_priv(dev)->ctx.lock);
> +		ci =3D lowpan_iphc_ctx_get_by_id(dev,
> LOWPAN_IPHC_CID_DCI(cid));
> +		if (!ci) {
> +			spin_unlock_bh(&lowpan_priv(dev)->ctx.lock);
> +			return -EINVAL;
> +		}
>=20
> -			if (err)
> -				return -EINVAL;
> +		/* multicast with context */
> +		pr_debug("dest: context-based mcast compression\n");
> +		err =3D lowpan_uncompress_multicast_ctx_daddr(skb, ci,
> +							    &hdr.daddr,
> +							    iphc1 &
> LOWPAN_IPHC_DAM_MASK);
> +		spin_unlock_bh(&lowpan_priv(dev)->ctx.lock);
> +		break;
> +	case LOWPAN_IPHC_M:
> +		/* multicast */
> +		err =3D lowpan_uncompress_multicast_daddr(skb, &hdr.daddr,
> +							iphc1 &
> LOWPAN_IPHC_DAM_MASK);
> +		break;
> +	case LOWPAN_IPHC_DAC:
> +		spin_lock_bh(&lowpan_priv(dev)->ctx.lock);
> +		ci =3D lowpan_iphc_ctx_get_by_id(dev,
> LOWPAN_IPHC_CID_DCI(cid));
> +		if (!ci) {
> +			spin_unlock_bh(&lowpan_priv(dev)->ctx.lock);
> +			return -EINVAL;
>  		}
> -	} else {
> +
> +		/* Destination address context based uncompression */
> +		pr_debug("DAC bit is set. Handle context based destination
> address.\n");
> +		err =3D uncompress_ctx_addr(skb, dev, ci, &hdr.daddr,
> +					  iphc1 &
> LOWPAN_IPHC_DAM_MASK, daddr);
> +		spin_unlock_bh(&lowpan_priv(dev)->ctx.lock);
> +		break;
> +	default:
>  		err =3D uncompress_addr(skb, dev, &hdr.daddr,
>  				      iphc1 & LOWPAN_IPHC_DAM_MASK,
> daddr);
>  		pr_debug("dest: stateless compression mode %d dest
> %pI6c\n",
>  			 iphc1 & LOWPAN_IPHC_DAM_MASK, &hdr.daddr);
> -		if (err)
> -			return -EINVAL;
> +		break;
>  	}
>=20
> +	if (err)
> +		return -EINVAL;
> +
>  	/* Next header data uncompression */
>  	if (iphc0 & LOWPAN_IPHC_NH) {
>  		err =3D lowpan_nhc_do_uncompression(skb, dev, &hdr); @@ -
> 585,6 +775,58 @@ static const u8 lowpan_iphc_dam_to_sam_value[] =3D {
>  	[LOWPAN_IPHC_DAM_11] =3D LOWPAN_IPHC_SAM_11,  };
>=20
> +static u8 lowpan_compress_ctx_addr(u8 **hc_ptr, const struct in6_add=
r
> *ipaddr,
> +				   const struct lowpan_iphc_ctx *ctx,
> +				   const unsigned char *lladdr, bool sam) {
> +	struct in6_addr tmp =3D {};
> +	u8 dam;
> +
> +	/* check for SAM/DAM =3D 11 */
> +	memcpy(&tmp.s6_addr[8], lladdr, 8);
> +	/* second bit-flip (Universe/Local) is done according RFC2464 */
> +	tmp.s6_addr[8] ^=3D 0x02;
> +	/* context information are always used */
> +	ipv6_addr_prefix_copy(&tmp, &ctx->pfx, ctx->plen);
> +	if (ipv6_addr_equal(&tmp, ipaddr)) {
> +		dam =3D LOWPAN_IPHC_DAM_11;
> +		goto out;
> +	}
> +
> +	memset(&tmp, 0, sizeof(tmp));
> +	/* check for SAM/DAM =3D 01 */
> +	tmp.s6_addr[11] =3D 0xFF;
> +	tmp.s6_addr[12] =3D 0xFE;
> +	memcpy(&tmp.s6_addr[14], &ipaddr->s6_addr[14], 2);
> +	/* context information are always used */
> +	ipv6_addr_prefix_copy(&tmp, &ctx->pfx, ctx->plen);
> +	if (ipv6_addr_equal(&tmp, ipaddr)) {
> +		lowpan_push_hc_data(hc_ptr, &ipaddr->s6_addr[14], 2);
> +		dam =3D LOWPAN_IPHC_DAM_10;
> +		goto out;
> +	}
> +
> +	memset(&tmp, 0, sizeof(tmp));
> +	/* check for SAM/DAM =3D 10, should always match */
> +	memcpy(&tmp.s6_addr[8], &ipaddr->s6_addr[8], 8);
> +	/* context information are always used */
> +	ipv6_addr_prefix_copy(&tmp, &ctx->pfx, ctx->plen);
> +	if (ipv6_addr_equal(&tmp, ipaddr)) {
> +		lowpan_push_hc_data(hc_ptr, &ipaddr->s6_addr[8], 8);
> +		dam =3D LOWPAN_IPHC_DAM_01;
> +		goto out;
> +	}
> +
> +	WARN_ON_ONCE("context found but no address mode matched\n");
> +	return -EINVAL;
> +out:
> +
> +	if (sam)
> +		return lowpan_iphc_dam_to_sam_value[dam];
> +	else
> +		return dam;
> +}
> +
>  static u8 lowpan_compress_addr_64(u8 **hc_ptr, const struct in6_addr
> *ipaddr,
>  				  const unsigned char *lladdr, bool sam)  {
> @@ -708,6 +950,21 @@ static u8 lowpan_iphc_tf_compress(u8 **hc_ptr,
> const struct ipv6hdr *hdr)
>  	return val;
>  }
>=20
> +static u8 lowpan_iphc_mcast_ctx_addr_compress(u8 **hc_ptr,
> +					      const struct lowpan_iphc_ctx *ctx,
> +					      const struct in6_addr *ipaddr) {
> +	u8 data[6];
> +
> +	/* flags/scope, reserved (RIID) */
> +	memcpy(data, &ipaddr->s6_addr[1], 2);
> +	/* group ID */
> +	memcpy(&data[1], &ipaddr->s6_addr[11], 4);
> +	lowpan_push_hc_data(hc_ptr, data, 6);
> +
> +	return LOWPAN_IPHC_DAM_00;
> +}
> +
>  static u8 lowpan_iphc_mcast_addr_compress(u8 **hc_ptr,
>  					  const struct in6_addr *ipaddr)
>  {
> @@ -742,10 +999,11 @@ static u8 lowpan_iphc_mcast_addr_compress(u8
> **hc_ptr,  int lowpan_header_compress(struct sk_buff *skb, const stru=
ct
> net_device *dev,
>  			   const void *daddr, const void *saddr)  {
> -	u8 iphc0, iphc1, *hc_ptr;
> +	u8 iphc0, iphc1, *hc_ptr, cid =3D 0;
>  	struct ipv6hdr *hdr;
>  	u8 head[LOWPAN_IPHC_MAX_HC_BUF_LEN] =3D {};
> -	int ret, addr_type;
> +	struct lowpan_iphc_ctx *dci, *sci, dci_entry, sci_entry;
> +	int ret, ipv6_daddr_type, ipv6_saddr_type;
>=20
>  	if (skb->protocol !=3D htons(ETH_P_IPV6))
>  		return -EINVAL;
> @@ -769,14 +1027,38 @@ int lowpan_header_compress(struct sk_buff
> *skb, const struct net_device *dev,
>  	iphc0 =3D LOWPAN_DISPATCH_IPHC;
>  	iphc1 =3D 0;
>=20
> -	/* TODO: context lookup */
> -
>  	raw_dump_inline(__func__, "saddr", saddr, EUI64_ADDR_LEN);
>  	raw_dump_inline(__func__, "daddr", daddr, EUI64_ADDR_LEN);
>=20
>  	raw_dump_table(__func__, "sending raw skb network uncompressed
> packet",
>  		       skb->data, skb->len);
>=20
> +	ipv6_daddr_type =3D ipv6_addr_type(&hdr->daddr);
> +	spin_lock_bh(&lowpan_priv(dev)->ctx.lock);
> +	if (ipv6_daddr_type & IPV6_ADDR_MULTICAST)
> +		dci =3D lowpan_iphc_ctx_get_by_mcast_addr(dev, &hdr-
> >daddr);
> +	else
> +		dci =3D lowpan_iphc_ctx_get_by_addr(dev, &hdr->daddr);
> +	if (dci) {
> +		memcpy(&dci_entry, dci, sizeof(*dci));
> +		cid |=3D dci->id;
> +	}
> +	spin_unlock_bh(&lowpan_priv(dev)->ctx.lock);
> +
> +	spin_lock_bh(&lowpan_priv(dev)->ctx.lock);
> +	sci =3D lowpan_iphc_ctx_get_by_addr(dev, &hdr->saddr);
> +	if (sci) {
> +		memcpy(&sci_entry, sci, sizeof(*sci));
> +		cid |=3D (sci->id << 4);
> +	}
> +	spin_unlock_bh(&lowpan_priv(dev)->ctx.lock);
> +
> +	/* if cid is zero it will be compressed */
> +	if (cid) {
> +		iphc1 |=3D LOWPAN_IPHC_CID;
> +		lowpan_push_hc_data(&hc_ptr, &cid, sizeof(cid));
> +	}
> +
>  	/* Traffic Class, Flow Label compression */
>  	iphc0 |=3D lowpan_iphc_tf_compress(&hc_ptr, hdr);
>=20
> @@ -813,39 +1095,63 @@ int lowpan_header_compress(struct sk_buff
> *skb, const struct net_device *dev,
>  				    sizeof(hdr->hop_limit));
>  	}
>=20
> -	addr_type =3D ipv6_addr_type(&hdr->saddr);
> +	ipv6_saddr_type =3D ipv6_addr_type(&hdr->saddr);
>  	/* source address compression */
> -	if (addr_type =3D=3D IPV6_ADDR_ANY) {
> +	if (ipv6_saddr_type =3D=3D IPV6_ADDR_ANY) {
>  		pr_debug("source address is unspecified, setting SAC\n");
>  		iphc1 |=3D LOWPAN_IPHC_SAC;
>  	} else {
> -		if (addr_type & IPV6_ADDR_LINKLOCAL) {
> -			iphc1 |=3D lowpan_compress_addr_64(&hc_ptr, &hdr-
> >saddr,
> -							 saddr, true);
> -			pr_debug("source address unicast link-local %pI6c
> iphc1 0x%02x\n",
> -				 &hdr->saddr, iphc1);
> +		if (sci) {
> +			iphc1 |=3D lowpan_compress_ctx_addr(&hc_ptr, &hdr-
> >saddr,
> +							  &sci_entry, saddr,
> +							  true);
> +			iphc1 |=3D LOWPAN_IPHC_SAC;
>  		} else {
> -			pr_debug("send the full source address\n");
> -			lowpan_push_hc_data(&hc_ptr, hdr->saddr.s6_addr,
> 16);
> +			if (ipv6_saddr_type & IPV6_ADDR_LINKLOCAL) {
> +				iphc1 |=3D
> lowpan_compress_addr_64(&hc_ptr,
> +								 &hdr->saddr,
> +								 saddr, true);
> +				pr_debug("source address unicast link-local
> %pI6c iphc1 0x%02x\n",
> +					 &hdr->saddr, iphc1);
> +			} else {
> +				pr_debug("send the full source address\n");
> +				lowpan_push_hc_data(&hc_ptr,
> +						    hdr->saddr.s6_addr, 16);
> +			}
>  		}
>  	}
>=20
> -	addr_type =3D ipv6_addr_type(&hdr->daddr);
>  	/* destination address compression */
> -	if (addr_type & IPV6_ADDR_MULTICAST) {
> +	if (ipv6_daddr_type & IPV6_ADDR_MULTICAST) {
>  		pr_debug("destination address is multicast: ");
> -		iphc1 |=3D LOWPAN_IPHC_M;
> -		iphc1 |=3D lowpan_iphc_mcast_addr_compress(&hc_ptr, &hdr-
> >daddr);
> +		if (dci) {
> +			iphc1 |=3D
> lowpan_iphc_mcast_ctx_addr_compress(&hc_ptr,
> +
> &dci_entry,
> +								     &hdr-
> >daddr);
> +		} else {
> +			iphc1 |=3D LOWPAN_IPHC_M;
> +			iphc1 |=3D
> lowpan_iphc_mcast_addr_compress(&hc_ptr,
> +								 &hdr-
> >daddr);
> +		}
>  	} else {
> -		if (addr_type & IPV6_ADDR_LINKLOCAL) {
> -			/* TODO: context lookup */
> -			iphc1 |=3D lowpan_compress_addr_64(&hc_ptr, &hdr-
> >daddr,
> -							 daddr, false);
> -			pr_debug("dest address unicast link-local %pI6c "
> -				 "iphc1 0x%02x\n", &hdr->daddr, iphc1);
> +		if (dci) {
> +			iphc1 |=3D lowpan_compress_ctx_addr(&hc_ptr, &hdr-
> >daddr,
> +							  &dci_entry, daddr,
> +							  false);
> +			iphc1 |=3D LOWPAN_IPHC_DAC;
>  		} else {
> -			pr_debug("dest address unicast %pI6c\n", &hdr-
> >daddr);
> -			lowpan_push_hc_data(&hc_ptr, hdr->daddr.s6_addr,
> 16);
> +			if (ipv6_daddr_type & IPV6_ADDR_LINKLOCAL) {
> +				iphc1 |=3D
> lowpan_compress_addr_64(&hc_ptr,
> +								 &hdr->daddr,
> +								 daddr, false);
> +				pr_debug("dest address unicast link-local
> %pI6c iphc1 0x%02x\n",
> +					 &hdr->daddr, iphc1);
> +			} else {
> +				pr_debug("dest address unicast %pI6c\n",
> +					 &hdr->daddr);
> +				lowpan_push_hc_data(&hc_ptr,
> +						    hdr->daddr.s6_addr, 16);
> +			}
>  		}
>  	}
>=20
> --
> 2.6.1

=46irst of all great work for your series of patches on 6lowpan improve=
ments and
stateful compression!=20

I have just done some testing of this patch (without RADVD modification=
s), and
I can share my experiments using 6LoWPAN over BT-LE by sending simple I=
CMPv6
messages. Contexts for BTLE device has been added manually.

Experiment 1:

Router: 2001:db8::1/64 BTLE: 2001:db8::211:22FF:FE33:4455/64
CID 1: 2001:db8::/64

Works fine, I see that CID 1 is used for both addresses. Router has 64 =
bits of
IID inline and BTLE node has 0.

Experiment 2:

Router: 2001:db8::1/64 BTLE: 2001:db8::211:22FF:FE33:4455/64
CID 3: 2001:db8::/64 CID 5: 2001:db8::1/128

Works also fine, I see that both CID 3 and 5 are used, as well as both =
sides
compress its IID in the best possible way. So the patch appears to work=
 fine on
6LoWPAN over BT-LE.


However, I notice that the folder created in the sys/kernel/debug/6lowp=
an/ for
my bluetooth network interface is called "bt%d". And I would imagine th=
is
should be "bt0", "bt1", ... and not the template?

Also, I notice that the compression for Flow Control and Traffic Label =
in IPv6
header has been modified, these fields are no longer compressed in any =
packets
(0b11 value) that comes from Linux Kernel (e.g. ICMP Echo Request,
Router Advertisement), instead I get three extra bytes (0b01 value).
I would like to understand reason for this modification a little better=
=2E

Best regards,
=A3ukasz Duda
