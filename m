From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next:master 1557/1566] :undefined reference to `__get_hash_from_flowi6'
Date: Tue, 1 Sep 2015 20:37:48 -0700
Message-ID: <CALx6S36ha-mqAgt447=39qbvZBnKLqmBmzW4jtotXwtEjQZn=g@mail.gmail.com>
References: <201509020753.wkuP0ucx%fengguang.wu@intel.com>
	<20150901.170110.1874105615918834240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: fengguang.wu@intel.com, kbuild-all@01.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34683 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbbIBDht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 23:37:49 -0400
Received: by iofb144 with SMTP id b144so6316377iof.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 20:37:48 -0700 (PDT)
In-Reply-To: <20150901.170110.1874105615918834240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 1, 2015 at 5:01 PM, David Miller <davem@davemloft.net> wrote:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Wed, 2 Sep 2015 07:50:55 +0800
>
>> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
>> head:   41ecc3d390266acc1aa911d2ec477928a5248f75
>> commit: c6cc1ca7f4d70cbb3ea3a5ca163c5dabaf155cdb [1557/1566] flowi: Abstract out functions to get flow hash based on flowi
>> config: arm-at91_dt_defconfig (attached as .config)
>> reproduce:
>>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>   chmod +x ~/bin/make.cross
>>   git checkout c6cc1ca7f4d70cbb3ea3a5ca163c5dabaf155cdb
>>   # save the attached .config to linux build tree
>>   make.cross ARCH=arm
>>
>> All error/warnings (new ones prefixed by >>):
>>
>>    net/built-in.o: In function `ip6_xmit':
>>>> :(.text+0x7e18c): undefined reference to `__get_hash_from_flowi6'
>>    net/built-in.o: In function `__ip6_make_skb':
>>    :(.text+0x81340): undefined reference to `__get_hash_from_flowi6'
>
> I am so regretting applying this patch series.
>
> Tom, test things more thoroughly in the future.
>
Sorry, I missed that. Thanks for fixing it up.

Tom

> I'll fix it with the following change:
>
> ====================
> [PATCH] flow: Move __get_hash_from_flowi{4,6} into flow_dissector.c
>
> These cannot live in net/core/flow.c which only builds when XFRM is
> enabled.
>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/flow.c           | 36 ------------------------------------
>  net/core/flow_dissector.c | 35 +++++++++++++++++++++++++++++++++++
>  2 files changed, 35 insertions(+), 36 deletions(-)
>
> diff --git a/net/core/flow.c b/net/core/flow.c
> index 61930bb..1033725 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -22,7 +22,6 @@
>  #include <linux/cpumask.h>
>  #include <linux/mutex.h>
>  #include <net/flow.h>
> -#include <net/flow_dissector.h>
>  #include <linux/atomic.h>
>  #include <linux/security.h>
>  #include <net/net_namespace.h>
> @@ -510,38 +509,3 @@ void flow_cache_fini(struct net *net)
>         fc->percpu = NULL;
>  }
>  EXPORT_SYMBOL(flow_cache_fini);
> -
> -__u32 __get_hash_from_flowi6(struct flowi6 *fl6, struct flow_keys *keys)
> -{
> -       memset(keys, 0, sizeof(*keys));
> -
> -       memcpy(&keys->addrs.v6addrs.src, &fl6->saddr,
> -           sizeof(keys->addrs.v6addrs.src));
> -       memcpy(&keys->addrs.v6addrs.dst, &fl6->daddr,
> -           sizeof(keys->addrs.v6addrs.dst));
> -       keys->control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
> -       keys->ports.src = fl6->fl6_sport;
> -       keys->ports.dst = fl6->fl6_dport;
> -       keys->keyid.keyid = fl6->fl6_gre_key;
> -       keys->tags.flow_label = (__force u32)fl6->flowlabel;
> -       keys->basic.ip_proto = fl6->flowi6_proto;
> -
> -       return flow_hash_from_keys(keys);
> -}
> -EXPORT_SYMBOL(__get_hash_from_flowi6);
> -
> -__u32 __get_hash_from_flowi4(struct flowi4 *fl4, struct flow_keys *keys)
> -{
> -       memset(keys, 0, sizeof(*keys));
> -
> -       keys->addrs.v4addrs.src = fl4->saddr;
> -       keys->addrs.v4addrs.dst = fl4->daddr;
> -       keys->control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
> -       keys->ports.src = fl4->fl4_sport;
> -       keys->ports.dst = fl4->fl4_dport;
> -       keys->keyid.keyid = fl4->fl4_gre_key;
> -       keys->basic.ip_proto = fl4->flowi4_proto;
> -
> -       return flow_hash_from_keys(keys);
> -}
> -EXPORT_SYMBOL(__get_hash_from_flowi4);
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 8d32020..345a040 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -787,6 +787,41 @@ u32 skb_get_poff(const struct sk_buff *skb)
>         return __skb_get_poff(skb, skb->data, &keys, skb_headlen(skb));
>  }
>
> +__u32 __get_hash_from_flowi6(struct flowi6 *fl6, struct flow_keys *keys)
> +{
> +       memset(keys, 0, sizeof(*keys));
> +
> +       memcpy(&keys->addrs.v6addrs.src, &fl6->saddr,
> +           sizeof(keys->addrs.v6addrs.src));
> +       memcpy(&keys->addrs.v6addrs.dst, &fl6->daddr,
> +           sizeof(keys->addrs.v6addrs.dst));
> +       keys->control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
> +       keys->ports.src = fl6->fl6_sport;
> +       keys->ports.dst = fl6->fl6_dport;
> +       keys->keyid.keyid = fl6->fl6_gre_key;
> +       keys->tags.flow_label = (__force u32)fl6->flowlabel;
> +       keys->basic.ip_proto = fl6->flowi6_proto;
> +
> +       return flow_hash_from_keys(keys);
> +}
> +EXPORT_SYMBOL(__get_hash_from_flowi6);
> +
> +__u32 __get_hash_from_flowi4(struct flowi4 *fl4, struct flow_keys *keys)
> +{
> +       memset(keys, 0, sizeof(*keys));
> +
> +       keys->addrs.v4addrs.src = fl4->saddr;
> +       keys->addrs.v4addrs.dst = fl4->daddr;
> +       keys->control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
> +       keys->ports.src = fl4->fl4_sport;
> +       keys->ports.dst = fl4->fl4_dport;
> +       keys->keyid.keyid = fl4->fl4_gre_key;
> +       keys->basic.ip_proto = fl4->flowi4_proto;
> +
> +       return flow_hash_from_keys(keys);
> +}
> +EXPORT_SYMBOL(__get_hash_from_flowi4);
> +
>  static const struct flow_dissector_key flow_keys_dissector_keys[] = {
>         {
>                 .key_id = FLOW_DISSECTOR_KEY_CONTROL,
> --
> 2.1.0
>
