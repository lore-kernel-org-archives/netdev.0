From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 21:48:51 -0400 (EDT)
Message-ID: <20160418.214851.122286645854721047.davem@davemloft.net>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
	<1461015356.10638.124.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160418.205755.87909888849343438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737AbcDSBsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 21:48:55 -0400
In-Reply-To: <20160418.205755.87909888849343438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 18 Apr 2016 20:57:55 -0400 (EDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 18 Apr 2016 14:35:56 -0700
> 
>> On Mon, 2016-04-18 at 14:10 -0700, Roopa Prabhu wrote:
>> 
>>> +	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64)) {
>>> +		struct rtnl_link_stats64 *sp;
>>> +
>>> +		attr = nla_reserve(skb, IFLA_STATS_LINK_64,
>>> +				   sizeof(struct rtnl_link_stats64));
>>> +		if (!attr)
>>> +			goto nla_put_failure;
>>> +
>>> +		sp = nla_data(attr);
>> 
>> Are you sure we have a guarantee that sp is aligned to u64 fields ?
>> 
>> x86 does not care, but some arches would have a potential misalign
>> access here.
> 
> I'll do some testing on sparc and deal with any fallout.

Just thinking out loud before I start testing, yeah I think you are
right.  nlmsghdr is 64-bit aligned, but the nlattr header is 32-bit
which will thus make the attribute data area not be aligned.

I think the time has probably come to have a new netlink attribute
format that doesn't have this multi-decade old problem.

There are a lot of bits left in nla_type, we can use one to indicate
that the nlattr struct is another 4 bytes in length in order to
archieve proper alignment of the payload data.

+struct nlattr64 {
+	__u16           nla_len;
+	__u16           nla_type;
+	__u32		nla_pad;
+};
 ...
+#define NLA_F_64BIT_ALIGNED	(1 << 13)
-#define NLA_TYPE_MASK		~(NLA_F_NESTED | NLA_F_NET_BYTEORDER)
+#define NLA_TYPE_MASK		~(NLA_F_NESTED | NLA_F_NET_BYTEORDER |
				  NLA_F_64BIT_ALIGNED)
 ...
#define NLA64_ALIGNTO		8
#define NLA64_ALIGN(len)	(((len) + NLA64_ALIGNTO - 1) & ~(NLA64_ALIGNTO - 1))
#define NLA64_HDRLEN		((int) NLA64_ALIGN(sizeof(struct nlattr64)))

We're going to need some new nla64_*() helpers and code added to some
of the existing ones to test that new bit.

For example, nla_data would now be:

static inline void *nla_data(const struct nlattr *nla)
{
	if (nla->nla_type & NLA_F_64BIT_ALIGNED)
		return (char *) nla + NLA64_HDRLEN;
	else
		return (char *) nla + NLA_HDRLEN;
}

nla_len would be:

static inline int nla_len(const struct nlattr *nla)
{
	int hdrlen = NLA_HDRLEN;

	if (nla->nla_type & NLA_F_64BIT_ALIGNED)
		hdrlen = NLA64_hdrlen;
	return nla->nla_len - hdrlen;
}

etc. etc.

And anyways, I get unaligned accesses without Roopa's changes :-/

davem@patience:~$ ip l l
[3391066.656729] Kernel unaligned access at TPC[7d6c14] loopback_get_stats64+0x74/0xa0
[3391066.672020] Kernel unaligned access at TPC[7d6c18] loopback_get_stats64+0x78/0xa0
[3391066.687282] Kernel unaligned access at TPC[7d6c1c] loopback_get_stats64+0x7c/0xa0
[3391066.702573] Kernel unaligned access at TPC[7d6c20] loopback_get_stats64+0x80/0xa0
[3391066.717858] Kernel unaligned access at TPC[8609dc] dev_get_stats+0x3c/0xe0
