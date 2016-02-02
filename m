From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 3/7] net: sched: add cls_u32 offload hooks for netdevs
Date: Tue, 02 Feb 2016 08:42:46 -0800
Message-ID: <56B0DC86.7090402@gmail.com>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>	<20160201015023.13871.69865.stgit@john-Precision-Tower-5810> <CAJ3xEMjRRUgHo_J4yQr3Z9wSJA7aRAzHc1ZNoBVP5WRmDFTRjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>, ast@fb.com,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	horms@verge.net.au, Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36707 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401AbcBBQnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 11:43:04 -0500
Received: by mail-pf0-f181.google.com with SMTP id n128so107133226pfn.3
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 08:43:03 -0800 (PST)
In-Reply-To: <CAJ3xEMjRRUgHo_J4yQr3Z9wSJA7aRAzHc1ZNoBVP5WRmDFTRjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-02 08:25 AM, Or Gerlitz wrote:
> On Mon, Feb 1, 2016 at 3:50 AM, John Fastabend <john.fastabend@gmail.com> wrote:
>> This patch allows netdev drivers to consume cls_u32 offloads via
>> the ndo_setup_tc ndo op.
>>
>> This works aligns with how network drivers have been doing qdisc
>> offloads for mqprio.
> 
> [...]
> 
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -779,17 +779,21 @@ static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
>>  typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>>                                        struct sk_buff *skb);
>>
>> -/* This structure holds attributes of qdisc and classifiers
>> +/* These structures hold the attributes of qdisc and classifiers
>>   * that are being passed to the netdevice through the setup_tc op.
>>   */
>>  enum {
>>         TC_SETUP_MQPRIO,
>> +       TC_SETUP_CLSU32,
>>  };
>>
>> +struct tc_cls_u32_offload;
>> +
>>  struct tc_to_netdev {
>>         unsigned int type;
>>         union {
>>                 u8 tc;
>> +               struct tc_cls_u32_offload *cls_u32;
>>         };
>>  };
> 
> So under this approach we're making the HW driver u32 aware. Do we
> really want to go there?
> 

Yes, I'm not convinced writing the universal language X to arbitrary
hardware is worth the complexity/cost at the moment. I already started
writing this universal block of code and it gets a bit complex to do
it right. Anyways none of this is exposed via UAPI so it can be
conslidated reworked as needed. Also I'm not to keen on going from
tc/netfilter/etc to language X (hw IR) to hardware when the block of
code to jump from u32 or flower to hardware is so simple. I added
flower support to the driver with about 100lines of code fwiw I'll
send the patch out later today, sure I skipped populating all the
fields by breaking out of some case statements but not that many.

I don't mind opening up some helper functions if you like my backend
structures. But anyways most the hard work is programming the hardware
and hoping someone did silicon validation anyways imo.

> The flow-dissector + actions structure way of describing matching and
> actions maybe had some
> drawbacks but it's not affiliated with a specific networking component
> (here TC/U32). When we look
> fwd do we expect everything (netfilter offloads for example) to be
> expressed in u32 terms?

I'm a bit tired of speculating about what_ifs when we see the netfilter
offload code lets take a look at consolidating. For now I have code that
_works_.

> 
> Or.
> 
