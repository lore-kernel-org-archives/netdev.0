From: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [RFCv2 bluetooth-next 3/3] 6lowpan: iphc: add support for
 stateful compression
Date: Thu, 26 Nov 2015 12:19:24 +0100
Message-ID: <5656EABC.5090909@osg.samsung.com>
References: <1447799594-6050-1-git-send-email-alex.aring@gmail.com>
 <1447799594-6050-4-git-send-email-alex.aring@gmail.com>
 <5655EBF9.7060102@osg.samsung.com> <20151125180716.GB4652@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org,
	lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org, martin.gergeleit-6wGqcYweBVc@public.gmane.org
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151125180716.GB4652@omega>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 25/11/15 19:07, Alexander Aring wrote:
> Hi,
>
> On Wed, Nov 25, 2015 at 06:12:25PM +0100, Stefan Schmidt wrote:
>> Helllo.
>>
>> On 17/11/15 23:33, Alexander Aring wrote:
>>> This patch introduce support for IPHC stateful address compression. It
>>> will offer three debugfs per interface entries, which are:
>>>
>>>   - dci_table: destination context indentifier table
>>>   - sci_table: source context indentifier table
>>>   - mcast_sci_table: multicast context identifier table
>>>
>>> Example to setup a context id:
>>>
>>> A "cat /sys/kernel/debug/6lowpan/lowpan0/dci_table" will display all
>>> contexts which are available. Example:
>>>
>>> ID ipv6-address/prefix-length                  state
>>> 0  0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 1  0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 2  0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 3  0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 4  0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 5  0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 6  0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 7  0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 8  0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 9  0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 10 0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 11 0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 12 0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 13 0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 14 0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>> 15 0000:0000:0000:0000:0000:0000:0000:0000/000 0
>>>
>>> For setting a context e.g. context id 0, context 2001::, prefix-length
>>> 64.
>>>
>>> Hint: Simple copy one line and then maniuplate it.
>>>
>>> echo "0 2001:0000:0000:0000:0000:0000:0000:0000/64 1" >
>>> /sys/kernel/debug/6lowpan/lowpan0/dci_table
>>>
>>> The state will display currently if the context is disabled(0) or
>>> enabled(1).
>>>
>>> On transmit side:
>>>
>>> The IPHC code will automatically search for a context which would be
>>> match for the address. Then it will be use the context which the
>>> best compression, means the longest prefix which match will be used.
>>>
>>> Example:
>>>
>>> 2001::/126 vs 2001::/127 - the 2001::/127 can be full compressed if the
>>> last bit of the address which has the prefix 2001::/127 is the same like
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
>>>   include/net/6lowpan.h   |  62 ++++++
>>>   net/6lowpan/6lowpan_i.h |   3 +
>>>   net/6lowpan/Kconfig     |   1 +
>>>   net/6lowpan/core.c      |  17 ++
>>>   net/6lowpan/debugfs.c   | 109 +++++++++++
>>>   net/6lowpan/iphc.c      | 500 ++++++++++++++++++++++++++++++++++++++++++------
>>>   6 files changed, 635 insertions(+), 57 deletions(-)
>>>
>>> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
>>> index e484898..6e8d30e 100644
>>> --- a/include/net/6lowpan.h
>>> +++ b/include/net/6lowpan.h
>>> @@ -75,6 +75,8 @@
>>>   #define LOWPAN_IPHC_MAX_HC_BUF_LEN	(sizeof(struct ipv6hdr) +	\
>>>   					 LOWPAN_IPHC_MAX_HEADER_LEN +	\
>>>   					 LOWPAN_NHC_MAX_HDR_LEN)
>>> +/* SCI/DCI is 4 bit width, so we have maximum 16 entries */
>>> +#define LOWPAN_IPHC_CI_TABLE_SIZE	(1 << 4)
>>>   #define LOWPAN_DISPATCH_IPV6		0x41 /* 01000001 = 65 */
>>>   #define LOWPAN_DISPATCH_IPHC		0x60 /* 011xxxxx = ... */
>>> @@ -98,9 +100,45 @@ enum lowpan_lltypes {
>>>   	LOWPAN_LLTYPE_IEEE802154,
>>>   };
>>> +enum lowpan_iphc_ctx_states {
>>> +	LOWPAN_IPHC_CTX_STATE_DISABLED,
>>> +	LOWPAN_IPHC_CTX_STATE_ENABLED,
>>> +
>>> +	__LOWPAN_IPHC_CTX_STATE_INVALID,
>>> +	LOWPAN_IPHC_CTX_STATE_MAX = __LOWPAN_IPHC_CTX_STATE_INVALID - 1,
>>> +};
>>> +
>> You are expecting more states here besides enabled and disabled? Because
>> normally a bool would be fine here and an enum overkill. If you have more
>> states pending it makes sense to have the enum though.
>>
> Yea, I thought about more states than just these ones. E.g. from which
> sources came the context which was set, from ICMPv6 option field, manually
> added from debugfs/netlink? Such things...

Hmm, the states would still need to show if it is enabled or disabled. 
Your plan was to interpret this state as a bitfield with bits for 
enabled/disabled, set my ICMP, set manually?

To me this looks a bit overloaded for a state field. Though I agree that 
the information where the context came from is interesting for the 
debugfs entry.

> Nevertheless I will change it to bool here, we can still change it if we
> want that. But then we need to talk about that again if doing userspace
> API for that.

Yeah, stay with bool for now. We can always have another column in the 
debugfs table.
Not sure the information where the context was coming from is of 
interest for normal userspace. The debugging case would be covered with 
the debugfs entry once we come to it.

>>> +struct lowpan_iphc_ctx {
>>> +	enum lowpan_iphc_ctx_states state;
>>> +	u8 id;
>>> +	struct in6_addr addr;
>>> +	u8 prefix_len;
>>> +};
>>> +
> ...
>>>   #include <linux/netdevice.h>
>>> +extern const struct lowpan_iphc_ctx_ops iphc_ctx_unicast_ops;
>>> +extern const struct lowpan_iphc_ctx_ops iphc_ctx_mcast_ops;
>>> +
>>>   #ifdef CONFIG_6LOWPAN_DEBUGFS
>>>   int lowpan_dev_debugfs_init(struct net_device *dev);
>>>   void lowpan_dev_debugfs_uninit(struct net_device *dev);
>>> diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
>>> index 01c901c..7ecedd7 100644
>>> --- a/net/6lowpan/Kconfig
>>> +++ b/net/6lowpan/Kconfig
>>> @@ -8,6 +8,7 @@ menuconfig 6LOWPAN
>>>   config 6LOWPAN_DEBUGFS
>>>   	bool "6LoWPAN debugfs support"
>>>   	depends on 6LOWPAN
>>> +	depends on DEBUG_FS
>> This looks like a fix that should be merged into the first patch, no?
> yes. I will fix that.

Thanks.

>>>   	---help---
>>>   	  This enables 6LoWPAN debugfs support. For example to manipulate
>>>   	  IPHC context information at runtime.
>>> diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
>>> index fe58509..d354c5b 100644
>>> --- a/net/6lowpan/core.c
>>> +++ b/net/6lowpan/core.c
>>> @@ -19,6 +19,8 @@
>>>   int lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype)
>>>   {
>>> +	int i;
>>> +
>>>   	dev->addr_len = EUI64_ADDR_LEN;
>>>   	dev->type = ARPHRD_6LOWPAN;
>>>   	dev->mtu = IPV6_MIN_MTU;
> ...
>>> +static ssize_t lowpan_context_dbgfs_write(struct file *fp,
>>> +					  const char __user *user_buf,
>>> +					  size_t count, loff_t *ppos)
>>> +{
>>> +	char buf[128] = { };
>>> +	struct seq_file *file = fp->private_data;
>>> +	struct lowpan_iphc_ctx_table *t = file->private;
>>> +	struct lowpan_iphc_ctx ctx;
>>> +	int status = count, n, id, state, i, prefix_len, ret;
>>> +	unsigned int addr[8];
>>> +
>>> +	if (copy_from_user(&buf, user_buf, min_t(size_t, sizeof(buf) - 1,
>>> +						 count))) {
>>> +		status = -EFAULT;
>>> +		goto out;
>>> +	}
>>> +
>>> +	n = sscanf(buf, "%d %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x/%d %d",
>>> +		   &id, &addr[0], &addr[1], &addr[2], &addr[3], &addr[4],
>>> +		   &addr[5], &addr[6], &addr[7], &prefix_len, &state);
>>> +	if (n != 11) {
>> 11 more like a magic number here. Not to bad, but a define could be nice.
> ok.
>
> ...
>>> +
>>> +const struct lowpan_iphc_ctx_ops iphc_ctx_mcast_ops = {
>>> +	.valid_prefix = lowpan_iphc_mcast_ctx_valid_prefix,
>>> +	.update = lowpan_iphc_ctx_update,
>>> +	.get_by_id = lowpan_iphc_ctx_get_by_id,
>>> +	.get_by_addr = lowpan_iphc_ctx_get_by_mcast_addr,
>>> +};
>> These are the comments from a first look over it. I will have a more
>> detailed review and actual testing once you are happy enough with it to move
>> it from RFC to PATCH.
>>
> ok.
>
> - Alex

regards
Stefan Schmidt
