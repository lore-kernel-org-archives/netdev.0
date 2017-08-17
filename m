From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH 1/6] bridge: learn dst metadata in FDB
Date: Thu, 17 Aug 2017 15:19:59 +0300
Message-ID: <c904f967-a536-5398-dc48-8adb4866ef51@cumulusnetworks.com>
References: <20170816170202.456851-1-equinox@diac24.net>
	<20170816170202.456851-2-equinox@diac24.net>
	<1fbaa432-6241-fad0-5407-8b87abb965ae@cumulusnetworks.com>
	<20170817110324.GK773745@eidolon>
	<4d4c8d17-1e0b-b78f-983b-e419e153b2bf@cumulusnetworks.com>
	<d4265b8d-93bb-630f-8d39-5eb0a3a259b8@cumulusnetworks.com>
	<20170817121020.GL773745@eidolon>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	amine.kherbouche@6wind.com
To: David Lamparter <equinox@diac24.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170817121020.GL773745@eidolon>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 17/08/17 15:10, David Lamparter wrote:
> On Thu, Aug 17, 2017 at 02:51:12PM +0300, Nikolay Aleksandrov wrote:
>> On 17/08/17 14:39, Nikolay Aleksandrov wrote:
>>> On 17/08/17 14:03, David Lamparter wrote:
>>>> On Wed, Aug 16, 2017 at 11:38:06PM +0300, Nikolay Aleksandrov wrote:
> [cut]
>>>>> and hitting the fast path for everyone in a few different places for a
>>>>> feature that the majority will not use does not sound acceptable to
>>>>> me. We've been trying hard to optimize it, trying to avoid additional
>>>>> cache lines, removing tests and keeping special cases to a minimum. 
>>>>
>>>> skb->dst is on the same cacheline as skb->len.
>>>> fdb->md_dst is on the same cacheline as fdb->dst.
>>>> Both will be 0 in a lot of cases, so this should be two null checks on
>>>> data that is hot in the cache.  Are you sure this is an actual problem?
>>>>
>>>
>>> Sure - no, I haven't benchmarked it, but I don't see skb->len being on
>>> the same cache line as _skb_refdst assuming 64 byte cache lines.
>>
>> I should've been clearer - that obviously depends on the kernel config, but
>> in order for them to be in the same line you need to disable either one of 
>> conntrack, bridge_netfilter or xfrm, these are almost always enabled (at
>> least in all major distributions).
> 
> Did I miscount somewhere?  This is what I counted:
> offs    size
> 00      16      next/prev/other union bits
> 16      8       sk
> 24      8       dev
> 32	32      cb (first 32 bytes)
> ---- boundary @ 64
> 64      16      cb (last 16 bytes)
> 80      8       _skb_refdst
> 88      8       destructor
> 96      8 (0)   sp
> 104     8 (0)   _nfct
> 112     8 (0)   nf_bridge
> 120     4       len
> 124     4       data_len
> ---- boundary @ 128
> 128     2       mac_len
> 130     2       hdr_len
> 
> 
> -David
> 
What kernel ?

pahole -C sk_buff 

struct sk_buff {
	union {
		struct {
			struct sk_buff * next;           /*     0     8 */
			struct sk_buff * prev;           /*     8     8 */
			union {
				ktime_t tstamp;          /*           8 */
				u64 skb_mstamp;          /*           8 */
			};                               /*    16     8 */
		};                                       /*          24 */
		struct rb_node     rbnode;               /*          24 */
	};                                               /*     0    24 */
	struct sock *              sk;                   /*    24     8 */
	union {
		struct net_device * dev;                 /*           8 */
		long unsigned int  dev_scratch;          /*           8 */
	};                                               /*    32     8 */
	char                       cb[48];               /*    40    48 */
	/* --- cacheline 1 boundary (64 bytes) was 24 bytes ago --- */
	long unsigned int          _skb_refdst;          /*    88     8 */
	void                       (*destructor)(struct sk_buff *); /*    96     8 */
	struct sec_path *          sp;                   /*   104     8 */
	long unsigned int          _nfct;                /*   112     8 */
	struct nf_bridge_info *    nf_bridge;            /*   120     8 */
	/* --- cacheline 2 boundary (128 bytes) --- */
	unsigned int               len;                  /*   128     4 */
	unsigned int               data_len;             /*   132     4 */
