From: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [RFCv3 bluetooth-next 4/4] 6lowpan: iphc: add support for
 stateful compression
Date: Fri, 4 Dec 2015 13:13:02 +0100
Message-ID: <5661834E.9030306@osg.samsung.com>
References: <1448796882-316-1-git-send-email-alex.aring@gmail.com>
 <1448796882-316-5-git-send-email-alex.aring@gmail.com>
 <565EFD9E.9020908@osg.samsung.com> <20151203142253.GA2553@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org,
	lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org, martin.gergeleit-6wGqcYweBVc@public.gmane.org
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151203142253.GA2553@omega>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/12/15 15:22, Alexander Aring wrote:
> Hi,
>
> On Wed, Dec 02, 2015 at 03:18:06PM +0100, Stefan Schmidt wrote:
>> Hello.
>>
>> A bit more review here. Still haven't tested the code.
>>
>> On 29/11/15 12:34, Alexander Aring wrote:
>>> This patch introduce support for IPHC stateful address compression.=
 It
>>> will offer three debugfs per interface entries, which are:
>>>
>>>   - dci_table: destination context indentifier table
>>>   - sci_table: source context indentifier table
>>>   - mcast_sci_table: multicast context identifier table
>>>
>>> Example to setup a context id:
>>>
>>> A "cat /sys/kernel/debug/6lowpan/lowpan0/dci_table" will display al=
l
>>> contexts which are available. Example:
>>>
>>> ID ipv6-address/prefix-length                  enabled
>>> 0  0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 1  0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 2  0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 3  0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 4  0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 5  0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 6  0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 7  0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 8  0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 9  0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 10 0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 11 0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 12 0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 13 0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 14 0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>> 15 0000:0000:0000:0000:0000:0000:0000:0000/0   0
>>>
>>> For setting a context e.g. context id 0, context 2001::, prefix-len=
gth
>>> 64.
>>>
>>> Hint: Simple copy one line and then maniuplate it.
>>>
>>> echo "0 2001:0000:0000:0000:0000:0000:0000:0000/64 1" >
>>> /sys/kernel/debug/6lowpan/lowpan0/dci_table
>>>
>>> The enabled column will display currently if the context is disable=
d(0) or
>>> enabled(1).
>>>
>>> On transmit side:
>>>
>>> The IPHC code will automatically search for a context which would b=
e
>>> match for the address. Then it will be use the context with the
>>> best compression method. Means the longest prefix which match will =
be
>>> used.
>>>
>>> Example:
>>>
>>> 2001::/126 vs 2001::/127 - the 2001::/127 can be full compressed if=
 the
>>> last bit of the address which has the prefix 2001::/127 is the same=
 like
>>> the IID from the Encapsulating Header. A context ID can also be a
>>> 2001::1/128, which is then a full ipv6 address.
>>>
>>> On Receive side:
>>>
>>> If there is a context defined (when CID not available then it's the
>>> default context 0) then it will be used, if the header doesn't set
>>> SAC or DAC bit thens, it will be dropped.
>>>
>>> Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> ---
>>>   include/net/6lowpan.h   |  54 ++++++
>>>   net/6lowpan/6lowpan_i.h |   3 +
>>>   net/6lowpan/core.c      |  17 +-
>>>   net/6lowpan/debugfs.c   | 113 ++++++++++++
>>>   net/6lowpan/iphc.c      | 479 +++++++++++++++++++++++++++++++++++=
+++++++------
>>>   5 files changed, 608 insertions(+), 58 deletions(-)
>>>
>>> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
>>> index 2f6a3f2..dec5427 100644
>>> --- a/include/net/6lowpan.h
>>> +++ b/include/net/6lowpan.h
>>> @@ -75,6 +75,8 @@
>>>   #define LOWPAN_IPHC_MAX_HC_BUF_LEN	(sizeof(struct ipv6hdr) +	\
>>>   					 LOWPAN_IPHC_MAX_HEADER_LEN +	\
>>>   					 LOWPAN_NHC_MAX_HDR_LEN)
>>> +/* SCI/DCI is 4 bit width, so we have maximum 16 entries */
>>> +#define LOWPAN_IPHC_CI_TABLE_SIZE	(1 << 4)
>>>   #define LOWPAN_DISPATCH_IPV6		0x41 /* 01000001 =3D 65 */
>>>   #define LOWPAN_DISPATCH_IPHC		0x60 /* 011xxxxx =3D ... */
>>> @@ -98,9 +100,37 @@ enum lowpan_lltypes {
>>>   	LOWPAN_LLTYPE_IEEE802154,
>>>   };
>>> +struct lowpan_iphc_ctx {
>>> +	u8 id;
>>> +	struct in6_addr addr;
>>> +	u8 prefix_len;
>>> +	bool enabled;
>>> +};
>>> +
>>> +struct lowpan_iphc_ctx_ops {
>>> +	bool (*valid_prefix)(const struct lowpan_iphc_ctx *ctx);
>>> +	int (*update)(struct lowpan_iphc_ctx *table,
>>> +		      const struct lowpan_iphc_ctx *ctx);
>>> +	struct lowpan_iphc_ctx *(*get_by_id)(const struct net_device *dev=
,
>>> +					     struct lowpan_iphc_ctx *table,
>>> +					     u8 id);
>>> +	struct lowpan_iphc_ctx *(*get_by_addr)(const struct net_device *d=
ev,
>>> +					       struct lowpan_iphc_ctx *table,
>>> +					       const struct in6_addr *addr);
>>> +};
>>> +
>>> +struct lowpan_iphc_ctx_table {
>>> +	spinlock_t lock;
>>> +	const struct lowpan_iphc_ctx_ops *ops;
>>> +	struct lowpan_iphc_ctx table[LOWPAN_IPHC_CI_TABLE_SIZE];
>>> +};
>>> +
>>>   struct lowpan_priv {
>>>   	enum lowpan_lltypes lltype;
>>>   	struct dentry *iface_debugfs;
>>> +	struct lowpan_iphc_ctx_table iphc_dci;
>>> +	struct lowpan_iphc_ctx_table iphc_sci;
>>> +	struct lowpan_iphc_ctx_table iphc_mcast_dci;
>>>   	/* must be last */
>>>   	u8 priv[0] __aligned(sizeof(void *));
>>> @@ -125,6 +155,30 @@ struct lowpan_802154_cb *lowpan_802154_cb(cons=
t struct sk_buff *skb)
>>>   	return (struct lowpan_802154_cb *)skb->cb;
>>>   }
>>> +static inline int lowpan_ctx_update(struct lowpan_iphc_ctx_table *=
t,
>>> +				    const struct lowpan_iphc_ctx *ctx)
>>> +{
>>> +	if (!t->ops->valid_prefix(ctx))
>>> +		return -EINVAL;
>>> +
>>> +	return t->ops->update(t->table, ctx);
>>> +}
>>> +
>>> +static inline struct lowpan_iphc_ctx *
>>> +lowpan_ctx_by_id(const struct net_device *dev, struct lowpan_iphc_=
ctx_table *t,
>>> +		 u8 id)
>>> +{
>>> +	return t->ops->get_by_id(dev, t->table, id);
>>> +}
>>> +
>>> +static inline struct lowpan_iphc_ctx *
>>> +lowpan_ctx_by_addr(const struct net_device *dev,
>>> +		   struct lowpan_iphc_ctx_table *t,
>>> +		   const struct in6_addr *addr)
>>> +{
>>> +	return t->ops->get_by_addr(dev, t->table, addr);
>>> +}
>>> +
>>>   #ifdef DEBUG
>>>   /* print data in line */
>>>   static inline void raw_dump_inline(const char *caller, char *msg,
>>> diff --git a/net/6lowpan/6lowpan_i.h b/net/6lowpan/6lowpan_i.h
>>> index d16bb4b..2c275be 100644
>>> --- a/net/6lowpan/6lowpan_i.h
>>> +++ b/net/6lowpan/6lowpan_i.h
>>> @@ -3,6 +3,9 @@
>>>   #include <linux/netdevice.h>
>>> +extern const struct lowpan_iphc_ctx_ops iphc_ctx_unicast_ops;
>>> +extern const struct lowpan_iphc_ctx_ops iphc_ctx_mcast_ops;
>>> +
>>>   #ifdef CONFIG_6LOWPAN_DEBUGFS
>>>   int lowpan_dev_debugfs_init(struct net_device *dev);
>>>   void lowpan_dev_debugfs_exit(struct net_device *dev);
>>> diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
>>> index c7f06f5..f3dbd18 100644
>>> --- a/net/6lowpan/core.c
>>> +++ b/net/6lowpan/core.c
>>> @@ -20,7 +20,7 @@
>>>   int lowpan_register_netdevice(struct net_device *dev,
>>>   			      enum lowpan_lltypes lltype)
>>>   {
>>> -	int ret;
>>> +	int i, ret;
>>>   	dev->addr_len =3D EUI64_ADDR_LEN;
>>>   	dev->type =3D ARPHRD_6LOWPAN;
>>> @@ -29,6 +29,21 @@ int lowpan_register_netdevice(struct net_device =
*dev,
>>>   	lowpan_priv(dev)->lltype =3D lltype;
>>> +	spin_lock_init(&lowpan_priv(dev)->iphc_dci.lock);
>>> +	lowpan_priv(dev)->iphc_dci.ops =3D &iphc_ctx_unicast_ops;
>>> +
>>> +	spin_lock_init(&lowpan_priv(dev)->iphc_sci.lock);
>>> +	lowpan_priv(dev)->iphc_sci.ops =3D &iphc_ctx_unicast_ops;
>>> +
>>> +	spin_lock_init(&lowpan_priv(dev)->iphc_mcast_dci.lock);
>>> +	lowpan_priv(dev)->iphc_mcast_dci.ops =3D &iphc_ctx_mcast_ops;
>>> +
>>> +	for (i =3D 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++) {
>>> +		lowpan_priv(dev)->iphc_dci.table[i].id =3D i;
>>> +		lowpan_priv(dev)->iphc_sci.table[i].id =3D i;
>>> +		lowpan_priv(dev)->iphc_mcast_dci.table[i].id =3D i;
>>> +	}
>>> +
>>>   	ret =3D lowpan_dev_debugfs_init(dev);
>>>   	if (ret < 0)
>>>   		return ret;
>>> diff --git a/net/6lowpan/debugfs.c b/net/6lowpan/debugfs.c
>>> index 88eef84..24f94ac 100644
>>> --- a/net/6lowpan/debugfs.c
>>> +++ b/net/6lowpan/debugfs.c
>>> @@ -16,19 +16,132 @@
>>>   #include "6lowpan_i.h"
>>> +#define LOWPAN_DEBUGFS_CTX_NUM_ARGS	11
>>> +
>>>   static struct dentry *lowpan_debugfs;
>>> +static int lowpan_context_show(struct seq_file *file, void *offset=
)
>>> +{
>>> +	struct lowpan_iphc_ctx_table *t =3D file->private;
>>> +	int i;
>>> +
>>> +	seq_printf(file, "%-2s %-43s %s\n", "ID", "ipv6-address/prefix-le=
ngth",
>>> +		   "enabled");
>>> +
>>> +	spin_lock_bh(&t->lock);
>>> +	for (i =3D 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++) {
>>> +		seq_printf(file,
>>> +			   "%-2d %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x/%-3d %d\n",
>>> +			   t->table[i].id,
>>> +			   be16_to_cpu(t->table[i].addr.s6_addr16[0]),
>>> +			   be16_to_cpu(t->table[i].addr.s6_addr16[1]),
>>> +			   be16_to_cpu(t->table[i].addr.s6_addr16[2]),
>>> +			   be16_to_cpu(t->table[i].addr.s6_addr16[3]),
>>> +			   be16_to_cpu(t->table[i].addr.s6_addr16[4]),
>>> +			   be16_to_cpu(t->table[i].addr.s6_addr16[5]),
>>> +			   be16_to_cpu(t->table[i].addr.s6_addr16[6]),
>>> +			   be16_to_cpu(t->table[i].addr.s6_addr16[7]),
>>> +			   t->table[i].prefix_len, t->table[i].enabled);
>>> +	}
>>> +	spin_unlock_bh(&t->lock);
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +static int lowpan_context_dbgfs_open(struct inode *inode, struct f=
ile *file)
>>> +{
>>> +	return single_open(file, lowpan_context_show, inode->i_private);
>>> +}
>>> +
>>> +static ssize_t lowpan_context_dbgfs_write(struct file *fp,
>>> +					  const char __user *user_buf,
>>> +					  size_t count, loff_t *ppos)
>>> +{
>>> +	char buf[128] =3D { };
>> Do we enforce the 128 char limit somewhere?
>>
>>> +	struct seq_file *file =3D fp->private_data;
>>> +	struct lowpan_iphc_ctx_table *t =3D file->private;
>>> +	struct lowpan_iphc_ctx ctx;
>>> +	int status =3D count, n, id, enabled, i, prefix_len, ret;
>>> +	unsigned int addr[8];
>>> +
>>> +	if (copy_from_user(&buf, user_buf, min_t(size_t, sizeof(buf) - 1,
>>> +						 count))) {
>> I see we do here, ok.
>>
>>> +		status =3D -EFAULT;
>>> +		goto out;
>>> +	}
>>> +
>>> +	n =3D sscanf(buf, "%d %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x/%d =
%d",
>>> +		   &id, &addr[0], &addr[1], &addr[2], &addr[3], &addr[4],
>>> +		   &addr[5], &addr[6], &addr[7], &prefix_len, &enabled);
>>> +	if (n !=3D LOWPAN_DEBUGFS_CTX_NUM_ARGS) {
>>> +		status =3D -EIO;
>>> +		goto out;
>>> +	}
>>> +
>>> +	if (id > LOWPAN_IPHC_CI_TABLE_SIZE - 1 ||
>>> +	    (enabled !=3D 0 && enabled !=3D 1) || prefix_len > 128) {
>> Hmm, if you would use a bool for enabled here instead of an int the =
check on
>> enabled would not be needed.
>>
> This is because sscanf format string excepts an int here to parsing t=
he
> "%d" argument.
>
> I adapt the same mechanism here what we have for "bools" for nl802154=
=2E
>
> When I change it to bool, I will get:
>
> net/6lowpan/debugfs.c: In function 'lowpan_context_dbgfs_write':
> net/6lowpan/debugfs.c:76:6: warning: format '%d' expects argument of
> type 'int *', but argument 13 has type 'bool *' [-Wformat=3D]
>        &addr[5], &addr[6], &addr[7], &prefix_len, &enabled);

Ah, right, scanf has no support for bool. :( Guess we keep it as int.

>
>>> +		status =3D -EINVAL;
>>> +		goto out;
>>> +	}
>>> +
>>> +	ctx.id =3D id;
>>> +	ctx.enabled =3D enabled;
> conversion to bool is here, I could do "!!enabled" and remove the che=
ck
> above, but then is 1 <-> MAX_INT and -1 <-> MIN_INT also true.

Nah, leave it as is. I was under the imp=C3=BCression we could use scan=
f for=20
bool directly. That not being the case we can keep it as is.

>
>>> +	ctx.prefix_len =3D prefix_len;
>>> +
>>> +	for (i =3D 0; i < 8; i++)
>>> +		ctx.addr.s6_addr16[i] =3D cpu_to_be16(addr[i] & 0xffff);
>>> +
>>> +	spin_lock_bh(&t->lock);
>>> +	ret =3D lowpan_ctx_update(t, &ctx);
>>> +	if (ret < 0)
>>> +		status =3D ret;
>>> +	spin_unlock_bh(&t->lock);
>>> +
>>> +out:
>>> +	return status;
>>> +}
>>> +
>>> +const struct file_operations lowpan_context_fops =3D {
>>> +	.open		=3D lowpan_context_dbgfs_open,
>>> +	.read		=3D seq_read,
>>> +	.write		=3D lowpan_context_dbgfs_write,
>>> +	.llseek		=3D seq_lseek,
>>> +	.release	=3D single_release,
>>> +};
>>> +
>>>   int lowpan_dev_debugfs_init(struct net_device *dev)
>>>   {
>>>   	struct lowpan_priv *lpriv =3D lowpan_priv(dev);
>>> +	static struct dentry *dentry;
>>>   	/* creating the root */
>>>   	lpriv->iface_debugfs =3D debugfs_create_dir(dev->name, lowpan_de=
bugfs);
>>>   	if (!lpriv->iface_debugfs)
>>>   		goto fail;
>>> +	dentry =3D debugfs_create_file("dci_table", 0664, lpriv->iface_de=
bugfs,
>> Any special reason you want the group have write permissions? I woul=
d expect
>> a 644 here. Same for the other two.
>>
> No, I will change it to 0644.

Great, thanks.

>
>>> +				     &lowpan_priv(dev)->iphc_dci,
>>> +				     &lowpan_context_fops);
>>> +	if (!dentry)
>>> +		goto remove_root;
>>> +
>>> +	dentry =3D debugfs_create_file("sci_table", 0664, lpriv->iface_de=
bugfs,
>>> +				     &lowpan_priv(dev)->iphc_sci,
>>> +				     &lowpan_context_fops);
>>> +	if (!dentry)
>>> +		goto remove_root;
>>> +
>>> +	dentry =3D debugfs_create_file("mcast_dci_table", 0664,
>>> +				     lpriv->iface_debugfs,
>>> +				     &lowpan_priv(dev)->iphc_mcast_dci,
>>> +				     &lowpan_context_fops);
>>> +	if (!dentry)
>>> +		goto remove_root;
>>> +
>>>   	return 0;
>>> +remove_root:
>>> +	lowpan_dev_debugfs_exit(dev);
>> Just to check here. This one is calling debugfs_remove_recursive(). =
This
>> will cleanup states where we might have been able to create dci_tabl=
e and
>> sci_table but not mcast_dci_table, right?
> Yes, should. I will remove the whole interface related debugfs entry
> inclusive all sub-entries which was created under the interface relat=
ed
> directory entry which is in this case sci/dci/mcast_dci tables.

OK

>>>   fail:
>>>   	return -EINVAL;
>>>   }
>>> diff --git a/net/6lowpan/iphc.c b/net/6lowpan/iphc.c
>>> index 346b5c1..2c5004b 100644
>>> --- a/net/6lowpan/iphc.c
>>> +++ b/net/6lowpan/iphc.c
>>> @@ -56,6 +56,7 @@
>>>   /* special link-layer handling */
>>>   #include <net/mac802154.h>
>>> +#include "6lowpan_i.h"
>>>   #include "nhc.h"
>>>   /* Values of fields within the IPHC encoding first byte */
>>> @@ -147,6 +148,9 @@
>>>   	 (((a)->s6_addr16[6]) =3D=3D 0) &&		\
>>>   	 (((a)->s6_addr[14]) =3D=3D 0))
>>> +#define LOWPAN_IPHC_CID_DCI(cid)	(cid & 0x0f)
>>> +#define LOWPAN_IPHC_CID_SCI(cid)	((cid & 0xf0) >> 4)
>>> +
>>>   static inline void iphc_uncompress_eui64_lladdr(struct in6_addr *=
ipaddr,
>>>   						const void *lladdr)
>>>   {
>>> @@ -259,30 +263,59 @@ static int uncompress_addr(struct sk_buff *sk=
b, const struct net_device *dev,
>>>   /* Uncompress address function for source context
>>>    * based address(non-multicast).
>>>    */
>>> -static int uncompress_context_based_src_addr(struct sk_buff *skb,
>>> -					     struct in6_addr *ipaddr,
>>> -					     u8 address_mode)
>>> +static int uncompress_ctx_addr(struct sk_buff *skb,
>>> +			       const struct net_device *dev,
>>> +			       const struct lowpan_iphc_ctx *ctx,
>>> +			       struct in6_addr *ipaddr, u8 address_mode,
>>> +			       const void *lladdr)
>>>   {
>>> +	bool fail;
>>> +
>>>   	switch (address_mode) {
>>> -	case LOWPAN_IPHC_SAM_00:
>>> -		/* unspec address ::
>>> +	/* SAM and DAM are the same here */
>>> +	case LOWPAN_IPHC_DAM_00:
>>> +		fail =3D false;
>>> +		/* SAM_00 -> unspec address ::
>>>   		 * Do nothing, address is already ::
>>> +		 *
>>> +		 * DAM 00 -> reserved should never occur.
>>>   		 */
>>>   		break;
>>>   	case LOWPAN_IPHC_SAM_01:
>>> -		/* TODO */
>>> +	case LOWPAN_IPHC_DAM_01:
>>> +		fail =3D lowpan_fetch_skb(skb, &ipaddr->s6_addr[8], 8);
>>> +		ipv6_addr_prefix_copy(ipaddr, &ctx->addr, ctx->prefix_len);
>>> +		break;
>>>   	case LOWPAN_IPHC_SAM_10:
>>> -		/* TODO */
>>> +	case LOWPAN_IPHC_DAM_10:
>>> +		ipaddr->s6_addr[11] =3D 0xFF;
>>> +		ipaddr->s6_addr[12] =3D 0xFE;
>>> +		fail =3D lowpan_fetch_skb(skb, &ipaddr->s6_addr[14], 2);
>>> +		ipv6_addr_prefix_copy(ipaddr, &ctx->addr, ctx->prefix_len);
>>> +		break;
>>>   	case LOWPAN_IPHC_SAM_11:
>>> -		/* TODO */
>>> -		netdev_warn(skb->dev, "SAM value 0x%x not supported\n",
>>> -			    address_mode);
>>> -		return -EINVAL;
>>> +	case LOWPAN_IPHC_DAM_11:
>>> +		fail =3D false;
>>> +		switch (lowpan_priv(dev)->lltype) {
>>> +		case LOWPAN_LLTYPE_IEEE802154:
>>> +			iphc_uncompress_802154_lladdr(ipaddr, lladdr);
>>> +			break;
>>> +		default:
>>> +			iphc_uncompress_eui64_lladdr(ipaddr, lladdr);
>>> +			break;
>>> +		}
>>> +		ipv6_addr_prefix_copy(ipaddr, &ctx->addr, ctx->prefix_len);
>>> +		break;
>>>   	default:
>>>   		pr_debug("Invalid sam value: 0x%x\n", address_mode);
>>>   		return -EINVAL;
>>>   	}
>>> +	if (fail) {
>>> +		pr_debug("Failed to fetch skb data\n");
>>> +		return -EIO;
>>> +	}
>>> +
>>>   	raw_dump_inline(NULL,
>>>   			"Reconstructed context based ipv6 src addr is",
>>>   			ipaddr->s6_addr, 16);
>>> @@ -346,6 +379,33 @@ static int lowpan_uncompress_multicast_daddr(s=
truct sk_buff *skb,
>>>   	return 0;
>>>   }
>>> +static int lowpan_uncompress_multicast_ctx_daddr(struct sk_buff *s=
kb,
>>> +						 struct lowpan_iphc_ctx *ctx,
>>> +						 struct in6_addr *ipaddr,
>>> +						 u8 address_mode)
>>> +{
>>> +	struct in6_addr network_pfx =3D {};
>>> +	bool fail;
>>> +
>>> +	if (address_mode !=3D LOWPAN_IPHC_DAM_00)
>>> +		return -EINVAL;
>>> +
>>> +	ipaddr->s6_addr[0] =3D 0xFF;
>>> +	fail =3D lowpan_fetch_skb(skb, &ipaddr->s6_addr[1], 2);
>>> +	fail |=3D lowpan_fetch_skb(skb, &ipaddr->s6_addr[12], 4);
>>> +	/* take prefix_len and network prefix from the context */
>>> +	ipaddr->s6_addr[3] =3D ctx->prefix_len;
>>> +	/* get network prefix to copy into multicast address */
>>> +	ipv6_addr_prefix(&network_pfx, &ctx->addr, ctx->prefix_len);
>>> +	/* setting network prefix */
>>> +	memcpy(&ipaddr->s6_addr[4], &network_pfx, 8);
>>> +
>>> +	if (fail < 0)
>>> +		return -EIO;
>>> +
>>> +	return 0;
>>> +}
>>> +
>>>   /* get the ecn values from iphc tf format and set it to ipv6hdr *=
/
>>>   static inline void lowpan_iphc_tf_set_ecn(struct ipv6hdr *hdr, co=
nst u8 *tf)
>>>   {
>>> @@ -459,7 +519,8 @@ int lowpan_header_decompress(struct sk_buff *sk=
b, const struct net_device *dev,
>>>   			     const void *daddr, const void *saddr)
>>>   {
>>>   	struct ipv6hdr hdr =3D {};
>>> -	u8 iphc0, iphc1;
>>> +	struct lowpan_iphc_ctx *ci;
>>> +	u8 iphc0, iphc1, cid =3D 0;
>>>   	int err;
>>>   	raw_dump_table(__func__, "raw skb data dump uncompressed",
>>> @@ -469,12 +530,14 @@ int lowpan_header_decompress(struct sk_buff *=
skb, const struct net_device *dev,
>>>   	    lowpan_fetch_skb(skb, &iphc1, sizeof(iphc1)))
>>>   		return -EINVAL;
>>> -	/* another if the CID flag is set */
>>> -	if (iphc1 & LOWPAN_IPHC_CID)
>>> -		return -ENOTSUPP;
>>> -
>>>   	hdr.version =3D 6;
>>> +	/* default CID =3D 0, another if the CID flag is set */
>>> +	if (iphc1 & LOWPAN_IPHC_CID) {
>>> +		if (lowpan_fetch_skb(skb, &cid, sizeof(cid)))
>>> +			return -EINVAL;
>>> +	}
>>> +
>>>   	err =3D lowpan_iphc_tf_decompress(skb, &hdr,
>>>   					iphc0 & LOWPAN_IPHC_TF_MASK);
>>>   	if (err < 0)
>>> @@ -500,10 +563,18 @@ int lowpan_header_decompress(struct sk_buff *=
skb, const struct net_device *dev,
>>>   	}
>>>   	if (iphc1 & LOWPAN_IPHC_SAC) {
>>> -		/* Source address context based uncompression */
>>> +		spin_lock_bh(&lowpan_priv(dev)->iphc_sci.lock);
>>> +		ci =3D lowpan_ctx_by_id(dev, &lowpan_priv(dev)->iphc_sci,
>>> +				      LOWPAN_IPHC_CID_SCI(cid));
>>> +		if (!ci) {
>>> +			spin_unlock_bh(&lowpan_priv(dev)->iphc_sci.lock);
>>> +			return -EINVAL;
>>> +		}
>>> +
>>>   		pr_debug("SAC bit is set. Handle context based source address.\=
n");
>>> -		err =3D uncompress_context_based_src_addr(skb, &hdr.saddr,
>>> -							iphc1 & LOWPAN_IPHC_SAM_MASK);
>>> +		err =3D uncompress_ctx_addr(skb, dev, ci, &hdr.saddr,
>>> +					  iphc1 & LOWPAN_IPHC_SAM_MASK, saddr);
>>> +		spin_unlock_bh(&lowpan_priv(dev)->iphc_sci.lock);
>>>   	} else {
>>>   		/* Source address uncompression */
>>>   		pr_debug("source address stateless compression\n");
>>> @@ -515,27 +586,54 @@ int lowpan_header_decompress(struct sk_buff *=
skb, const struct net_device *dev,
>>>   	if (err)
>>>   		return -EINVAL;
>>> -	/* check for Multicast Compression */
>>> -	if (iphc1 & LOWPAN_IPHC_M) {
>>> -		if (iphc1 & LOWPAN_IPHC_DAC) {
>>> -			pr_debug("dest: context-based mcast compression\n");
>>> -			/* TODO: implement this */
>>> -		} else {
>>> -			err =3D lowpan_uncompress_multicast_daddr(skb, &hdr.daddr,
>>> -								iphc1 & LOWPAN_IPHC_DAM_MASK);
>>> +	switch (iphc1 & (LOWPAN_IPHC_M | LOWPAN_IPHC_DAC)) {
>>> +	case LOWPAN_IPHC_M | LOWPAN_IPHC_DAC:
>>> +		spin_lock_bh(&lowpan_priv(dev)->iphc_mcast_dci.lock);
>>> +		ci =3D lowpan_ctx_by_id(dev, &lowpan_priv(dev)->iphc_mcast_dci,
>>> +				      LOWPAN_IPHC_CID_DCI(cid));
>>> +		if (!ci) {
>>> +			spin_unlock_bh(&lowpan_priv(dev)->iphc_mcast_dci.lock);
>>> +			return -EINVAL;
>>> +		}
>>> -			if (err)
>>> -				return -EINVAL;
>>> +		/* multicast with context */
>>> +		pr_debug("dest: context-based mcast compression\n");
>>> +		err =3D lowpan_uncompress_multicast_ctx_daddr(skb, ci,
>>> +							    &hdr.daddr,
>>> +							    iphc1 & LOWPAN_IPHC_DAM_MASK);
>>> +		spin_unlock_bh(&lowpan_priv(dev)->iphc_mcast_dci.lock);
>>> +		break;
>>> +	case LOWPAN_IPHC_M:
>>> +		/* multicast */
>>> +		err =3D lowpan_uncompress_multicast_daddr(skb, &hdr.daddr,
>>> +							iphc1 & LOWPAN_IPHC_DAM_MASK);
>>> +		break;
>>> +	case LOWPAN_IPHC_DAC:
>>> +		spin_lock_bh(&lowpan_priv(dev)->iphc_dci.lock);
>>> +		ci =3D lowpan_ctx_by_id(dev, &lowpan_priv(dev)->iphc_dci,
>>> +				      LOWPAN_IPHC_CID_DCI(cid));
>>> +		if (!ci) {
>>> +			spin_unlock_bh(&lowpan_priv(dev)->iphc_dci.lock);
>>> +			return -EINVAL;
>>>   		}
>>> -	} else {
>>> +
>>> +		/* Destination address context based uncompression */
>>> +		pr_debug("DAC bit is set. Handle context based destination addre=
ss.\n");
>>> +		err =3D uncompress_ctx_addr(skb, dev, ci, &hdr.daddr,
>>> +					  iphc1 & LOWPAN_IPHC_DAM_MASK, daddr);
>>> +		spin_unlock_bh(&lowpan_priv(dev)->iphc_dci.lock);
>>> +		break;
>>> +	default:
>>>   		err =3D uncompress_addr(skb, dev, &hdr.daddr,
>>>   				      iphc1 & LOWPAN_IPHC_DAM_MASK, daddr);
>>>   		pr_debug("dest: stateless compression mode %d dest %pI6c\n",
>>>   			 iphc1 & LOWPAN_IPHC_DAM_MASK, &hdr.daddr);
>>> -		if (err)
>>> -			return -EINVAL;
>>> +		break;
>>>   	}
>>> +	if (err)
>>> +		return -EINVAL;
>>> +
>>>   	/* Next header data uncompression */
>>>   	if (iphc0 & LOWPAN_IPHC_NH) {
>>>   		err =3D lowpan_nhc_do_uncompression(skb, dev, &hdr);
>>> @@ -585,6 +683,60 @@ static const u8 lowpan_iphc_dam_to_sam_value[]=
 =3D {
>>>   	[LOWPAN_IPHC_DAM_11] =3D LOWPAN_IPHC_SAM_11,
>>>   };
>>> +static u8 lowpan_compress_ctx_addr(u8 **hc_ptr, const struct in6_a=
ddr *ipaddr,
>>> +				   const struct lowpan_iphc_ctx *ctx,
>>> +				   const unsigned char *lladdr, bool sam)
>>> +{
>>> +	struct in6_addr tmp =3D {};
>>> +	u8 dam;
>>> +
>>> +	/* check for SAM/DAM =3D 11 */
>>> +	memcpy(&tmp.s6_addr[8], lladdr, 8);
>>> +	/* second bit-flip (Universe/Local)
>>> +	 * is done according RFC2464
>>> +	 */
>> Maybe put this comment on line. It should be short enough.
>>
> ok.
>
>>> +	tmp.s6_addr[8] ^=3D 0x02;
>>> +	/* context information are always used */
>>> +	ipv6_addr_prefix_copy(&tmp, &ctx->addr, ctx->prefix_len);
>>> +	if (ipv6_addr_equal(&tmp, ipaddr)) {
>>> +		dam =3D LOWPAN_IPHC_DAM_11;
>>> +		goto out;
>>> +	}
>>> +
>>> +	memset(&tmp, 0, sizeof(tmp));
>>> +	/* check for SAM/DAM =3D 01 */
>>> +	tmp.s6_addr[11] =3D 0xFF;
>>> +	tmp.s6_addr[12] =3D 0xFE;
>>> +	memcpy(&tmp.s6_addr[14], &ipaddr->s6_addr[14], 2);
>>> +	/* context information are always used */
>>> +	ipv6_addr_prefix_copy(&tmp, &ctx->addr, ctx->prefix_len);
>>> +	if (ipv6_addr_equal(&tmp, ipaddr)) {
>>> +		lowpan_push_hc_data(hc_ptr, &ipaddr->s6_addr[14], 2);
>>> +		dam =3D LOWPAN_IPHC_DAM_10;
>>> +		goto out;
>>> +	}
>>> +
>>> +	memset(&tmp, 0, sizeof(tmp));
>>> +	/* check for SAM/DAM =3D 10, should always match */
>>> +	memcpy(&tmp.s6_addr[8], &ipaddr->s6_addr[8], 8);
>>> +	/* context information are always used */
>>> +	ipv6_addr_prefix_copy(&tmp, &ctx->addr, ctx->prefix_len);
>>> +	if (ipv6_addr_equal(&tmp, ipaddr)) {
>>> +		lowpan_push_hc_data(hc_ptr, &ipaddr->s6_addr[8], 8);
>>> +		dam =3D LOWPAN_IPHC_DAM_01;
>>> +		goto out;
>>> +	}
>>> +
>>> +	WARN_ON_ONCE("context found but no address mode matched\n");
>>> +	return -EINVAL;
>>> +out:
>>> +
>>> +	if (sam)
>>> +		return lowpan_iphc_dam_to_sam_value[dam];
>>> +	else
>>> +		return dam;
>>> +}
>>> +
>>>   static u8 lowpan_compress_addr_64(u8 **hc_ptr, const struct in6_a=
ddr *ipaddr,
>>>   				  const unsigned char *lladdr, bool sam)
>>>   {
>>> @@ -708,6 +860,21 @@ static u8 lowpan_iphc_tf_compress(u8 **hc_ptr,=
 const struct ipv6hdr *hdr)
>>>   	return val;
>>>   }
>>> +static u8 lowpan_iphc_mcast_ctx_addr_compress(u8 **hc_ptr,
>>> +					      const struct lowpan_iphc_ctx *ctx,
>>> +					      const struct in6_addr *ipaddr)
>>> +{
>>> +	u8 data[6];
>>> +
>>> +	/* flags/scope, reserved (RIID) */
>>> +	memcpy(data, &ipaddr->s6_addr[1], 2);
>>> +	/* group ID */
>>> +	memcpy(&data[1], &ipaddr->s6_addr[11], 4);
>>> +	lowpan_push_hc_data(hc_ptr, data, 6);
>>> +
>>> +	return LOWPAN_IPHC_DAM_00;
>>> +}
>>> +
>>>   static u8 lowpan_iphc_mcast_addr_compress(u8 **hc_ptr,
>>>   					  const struct in6_addr *ipaddr)
>>>   {
>>> @@ -742,10 +909,11 @@ static u8 lowpan_iphc_mcast_addr_compress(u8 =
**hc_ptr,
>>>   int lowpan_header_compress(struct sk_buff *skb, const struct net_=
device *dev,
>>>   			   const void *daddr, const void *saddr)
>>>   {
>>> -	u8 iphc0, iphc1, *hc_ptr;
>>> +	u8 iphc0, iphc1, *hc_ptr, cid =3D 0;
>>>   	struct ipv6hdr *hdr;
>>>   	u8 head[LOWPAN_IPHC_MAX_HC_BUF_LEN] =3D {};
>>> -	int ret, addr_type;
>>> +	struct lowpan_iphc_ctx *dci, *sci, dci_entry, sci_entry;
>>> +	int ret, ipv6_daddr_type, ipv6_saddr_type;
>>>   	if (skb->protocol !=3D htons(ETH_P_IPV6))
>>>   		return -EINVAL;
>>> @@ -769,14 +937,47 @@ int lowpan_header_compress(struct sk_buff *sk=
b, const struct net_device *dev,
>>>   	iphc0 =3D LOWPAN_DISPATCH_IPHC;
>>>   	iphc1 =3D 0;
>>> -	/* TODO: context lookup */
>>> -
>>>   	raw_dump_inline(__func__, "saddr", saddr, EUI64_ADDR_LEN);
>>>   	raw_dump_inline(__func__, "daddr", daddr, EUI64_ADDR_LEN);
>>>   	raw_dump_table(__func__, "sending raw skb network uncompressed p=
acket",
>>>   		       skb->data, skb->len);
>>> +	ipv6_daddr_type =3D ipv6_addr_type(&hdr->daddr);
>>> +	if (ipv6_daddr_type & IPV6_ADDR_MULTICAST) {
>>> +		spin_lock_bh(&lowpan_priv(dev)->iphc_mcast_dci.lock);
>>> +		dci =3D lowpan_ctx_by_addr(dev, &lowpan_priv(dev)->iphc_mcast_dc=
i,
>>> +					 &hdr->daddr);
>>> +		if (dci) {
>>> +			memcpy(&dci_entry, dci, sizeof(*dci));
>>> +			cid |=3D dci->id;
>>> +		}
>>> +		spin_unlock_bh(&lowpan_priv(dev)->iphc_mcast_dci.lock);
>>> +	} else {
>>> +		spin_lock_bh(&lowpan_priv(dev)->iphc_dci.lock);
>>> +		dci =3D lowpan_ctx_by_addr(dev, &lowpan_priv(dev)->iphc_dci,
>>> +					 &hdr->daddr);
>>> +		if (dci) {
>>> +			memcpy(&dci_entry, dci, sizeof(*dci));
>>> +			cid |=3D dci->id;
>>> +		}
>>> +		spin_unlock_bh(&lowpan_priv(dev)->iphc_dci.lock);
>>> +	}
>>> +
>>> +	spin_lock_bh(&lowpan_priv(dev)->iphc_sci.lock);
>>> +	sci =3D lowpan_ctx_by_addr(dev, &lowpan_priv(dev)->iphc_sci,
>>> +				 &hdr->saddr);
>>> +	if (sci) {
>>> +		memcpy(&sci_entry, sci, sizeof(*sci));
>>> +		cid |=3D (sci->id << 4);
>>> +	}
>>> +	spin_unlock_bh(&lowpan_priv(dev)->iphc_sci.lock);
>>> +
>>> +	if (sci || dci) {
>>> +		iphc1 |=3D LOWPAN_IPHC_CID;
>>> +		lowpan_push_hc_data(&hc_ptr, &cid, sizeof(cid));
>>> +	}
>>> +
>>>   	/* Traffic Class, Flow Label compression */
>>>   	iphc0 |=3D lowpan_iphc_tf_compress(&hc_ptr, hdr);
>>> @@ -813,39 +1014,63 @@ int lowpan_header_compress(struct sk_buff *s=
kb, const struct net_device *dev,
>>>   				    sizeof(hdr->hop_limit));
>>>   	}
>>> -	addr_type =3D ipv6_addr_type(&hdr->saddr);
>>> +	ipv6_saddr_type =3D ipv6_addr_type(&hdr->saddr);
>>>   	/* source address compression */
>>> -	if (addr_type =3D=3D IPV6_ADDR_ANY) {
>>> +	if (ipv6_saddr_type =3D=3D IPV6_ADDR_ANY) {
>>>   		pr_debug("source address is unspecified, setting SAC\n");
>>>   		iphc1 |=3D LOWPAN_IPHC_SAC;
>>>   	} else {
>>> -		if (addr_type & IPV6_ADDR_LINKLOCAL) {
>>> -			iphc1 |=3D lowpan_compress_addr_64(&hc_ptr, &hdr->saddr,
>>> -							 saddr, true);
>>> -			pr_debug("source address unicast link-local %pI6c iphc1 0x%02x\=
n",
>>> -				 &hdr->saddr, iphc1);
>>> +		if (sci) {
>>> +			iphc1 |=3D lowpan_compress_ctx_addr(&hc_ptr, &hdr->saddr,
>>> +							  &sci_entry, saddr,
>>> +							  true);
>>> +			iphc1 |=3D LOWPAN_IPHC_SAC;
>>>   		} else {
>>> -			pr_debug("send the full source address\n");
>>> -			lowpan_push_hc_data(&hc_ptr, hdr->saddr.s6_addr, 16);
>>> +			if (ipv6_saddr_type & IPV6_ADDR_LINKLOCAL) {
>>> +				iphc1 |=3D lowpan_compress_addr_64(&hc_ptr,
>>> +								 &hdr->saddr,
>>> +								 saddr, true);
>>> +				pr_debug("source address unicast link-local %pI6c iphc1 0x%02x=
\n",
>>> +					 &hdr->saddr, iphc1);
>>> +			} else {
>>> +				pr_debug("send the full source address\n");
>>> +				lowpan_push_hc_data(&hc_ptr,
>>> +						    hdr->saddr.s6_addr, 16);
>>> +			}
>>>   		}
>>>   	}
>>> -	addr_type =3D ipv6_addr_type(&hdr->daddr);
>>>   	/* destination address compression */
>>> -	if (addr_type & IPV6_ADDR_MULTICAST) {
>>> +	if (ipv6_daddr_type & IPV6_ADDR_MULTICAST) {
>>>   		pr_debug("destination address is multicast: ");
>>> -		iphc1 |=3D LOWPAN_IPHC_M;
>>> -		iphc1 |=3D lowpan_iphc_mcast_addr_compress(&hc_ptr, &hdr->daddr)=
;
>>> +		if (dci) {
>>> +			iphc1 |=3D lowpan_iphc_mcast_ctx_addr_compress(&hc_ptr,
>>> +								     &dci_entry,
>>> +								     &hdr->daddr);
>>> +		} else {
>>> +			iphc1 |=3D LOWPAN_IPHC_M;
>>> +			iphc1 |=3D lowpan_iphc_mcast_addr_compress(&hc_ptr,
>>> +								 &hdr->daddr);
>>> +		}
>>>   	} else {
>>> -		if (addr_type & IPV6_ADDR_LINKLOCAL) {
>>> -			/* TODO: context lookup */
>>> -			iphc1 |=3D lowpan_compress_addr_64(&hc_ptr, &hdr->daddr,
>>> -							 daddr, false);
>>> -			pr_debug("dest address unicast link-local %pI6c "
>>> -				 "iphc1 0x%02x\n", &hdr->daddr, iphc1);
>>> +		if (dci) {
>>> +			iphc1 |=3D lowpan_compress_ctx_addr(&hc_ptr, &hdr->daddr,
>>> +							  &dci_entry, daddr,
>>> +							  false);
>>> +			iphc1 |=3D LOWPAN_IPHC_DAC;
>>>   		} else {
>>> -			pr_debug("dest address unicast %pI6c\n", &hdr->daddr);
>>> -			lowpan_push_hc_data(&hc_ptr, hdr->daddr.s6_addr, 16);
>>> +			if (ipv6_daddr_type & IPV6_ADDR_LINKLOCAL) {
>>> +				iphc1 |=3D lowpan_compress_addr_64(&hc_ptr,
>>> +								 &hdr->daddr,
>>> +								 daddr, false);
>>> +				pr_debug("dest address unicast link-local %pI6c iphc1 0x%02x\n=
",
>>> +					 &hdr->daddr, iphc1);
>>> +			} else {
>>> +				pr_debug("dest address unicast %pI6c\n",
>>> +					 &hdr->daddr);
>>> +				lowpan_push_hc_data(&hc_ptr,
>>> +						    hdr->daddr.s6_addr, 16);
>>> +			}
>>>   		}
>>>   	}
>>> @@ -871,3 +1096,143 @@ int lowpan_header_compress(struct sk_buff *s=
kb, const struct net_device *dev,
>>>   	return 0;
>>>   }
>>>   EXPORT_SYMBOL_GPL(lowpan_header_compress);
>>> +
>>> +static bool lowpan_iphc_ctx_valid_prefix(const struct lowpan_iphc_=
ctx *ctx)
>>> +{
>>> +	/* prefix which are smaller than 64 bits are not valid, users
>>> +	 * may mean than a prefix which is filled with zero until 64th bi=
t.
>>> +	 * Refere rfc6282 "Any remaining bits are zero." The remaining bi=
ts
>>> +	 * in this case where are the prefix(< 64) ends until IID starts.
>>> +	 */
>>> +	if (ctx->prefix_len < 64)
>>> +		return false;
>>> +
>>> +	return true;
>>> +}
>>> +
> I will remove this check, the prefix_len should be any length, from 0
> until 128. We need to care about the zero bits if prefix_len < 64 dur=
ing
> lookup.
>
> I think a "valid" test would be to check on multicast address scope
> which should not a valid prefix for dci/sci table. There might be mor=
e
> addresses which should not valid here. At the moment I would say a
> multicast address should be invalid. I will add this as well.
>
>>> +static bool
>>> +lowpan_iphc_mcast_ctx_valid_prefix(const struct lowpan_iphc_ctx *c=
tx)
>>> +{
>>> +	/* network prefix for multicast is at maximum 64 bits long */
>>> +	if (ctx->prefix_len > 64)
>>> +		return false;
>>> +
>>> +	return true;
>>> +}
>>> +
>>> +static int lowpan_iphc_ctx_update(struct lowpan_iphc_ctx *table,
>>> +				  const struct lowpan_iphc_ctx *ctx)
>>> +{
>>> +	int ret =3D 0, i;
>>> +
>>> +	if (ctx->enabled) {
>>> +		for (i =3D 0; i < LOWPAN_IPHC_CI_TABLE_SIZE; i++) {
>>> +			if (ctx->prefix_len !=3D table[i].prefix_len)
>>> +				continue;
>>> +
>>> +			if (ipv6_prefix_equal(&ctx->addr, &table[i].addr,
>>> +					      ctx->prefix_len)) {
>>> +				if (table[i].enabled) {
>>> +					ret =3D -EEXIST;
>>> +					goto out;
>>> +				}
>>> +			}
>>> +		}
>>> +	}
>>> +
>>> +	memcpy(&table[ctx->id], ctx, sizeof(*ctx));
>>> +
>>> +out:
>>> +	return ret;
>>> +}
>>> +
>> In what cases should the update succeed? I'm wondering about some co=
rner
>> cases here:
>>
>> o If the new ctx is disabled it would update the table on its cid no=
 matter
>> what.
>> o If the new ctx is enabled we would update it only if we do not fin=
d the
>> same prefix in an enabled state already.
>>
>> To put it differently, the only case we do  not update the table wit=
h the
>> context is if it already exists and is enabled. This is how you want=
 it?
>>
> yes. If we don't check if it's enabled (inside the table), then we co=
uld
> not simple copy one line (by doing cat and echo) with a context which
> is disabled, then simple replace the disabled(0) to enabled(1). Then =
it
> would fail because the same prefix is already there, but when it's
> disabled then we ignore if the prefix is already exists. It will not
> used then anyway.

ok

regards
Stefan Schmidt
