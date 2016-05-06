From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [PATCHv2 bluetooth-next 02/10] 6lowpan: add 802.15.4 short addr
 slaac
Date: Fri, 6 May 2016 11:26:21 +0200
Message-ID: <042eb448-5f56-eaca-5c51-1386cc50edb6@pengutronix.de>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-3-git-send-email-aar@pengutronix.de>
 <5728EB0A.5080108@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Stefan Schmidt <stefan@osg.samsung.com>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48086 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751943AbcEFJ0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 05:26:39 -0400
In-Reply-To: <5728EB0A.5080108@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

On 05/03/2016 08:16 PM, Stefan Schmidt wrote:
> Hello.
> 
> On 20/04/16 10:19, Alexander Aring wrote:
>> This patch adds the autoconfiguration if a valid 802.15.4 short address
>> is available for 802.15.4 6LoWPAN interfaces.
>>
>> Cc: David S. Miller<davem@davemloft.net>
>> Cc: Alexey Kuznetsov<kuznet@ms2.inr.ac.ru>
>> Cc: James Morris<jmorris@namei.org>
>> Cc: Hideaki YOSHIFUJI<yoshfuji@linux-ipv6.org>
>> Cc: Patrick McHardy<kaber@trash.net>
>> Signed-off-by: Alexander Aring<aar@pengutronix.de>
>> ---
>>   include/net/addrconf.h |  3 +++
>>   net/6lowpan/core.c     | 46 ++++++++++++++++++++++++++++++++++++++++++++++
>>   net/ipv6/addrconf.c    |  5 +++--
>>   3 files changed, 52 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
>> index 730d856..b1774eb 100644
>> --- a/include/net/addrconf.h
>> +++ b/include/net/addrconf.h
>> @@ -94,6 +94,9 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
>>   void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr);
>>   void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr);
>>   +void addrconf_add_linklocal(struct inet6_dev *idev,
>> +                const struct in6_addr *addr, u32 flags);
>> +
>>   static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
>>   {
>>       if (dev->addr_len != ETH_ALEN)
>> diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
>> index 7a240b3..fbae31e 100644
>> --- a/net/6lowpan/core.c
>> +++ b/net/6lowpan/core.c
>> @@ -14,6 +14,7 @@
>>   #include <linux/module.h>
>>     #include <net/6lowpan.h>
>> +#include <net/addrconf.h>
>>     #include "6lowpan_i.h"
>>   @@ -72,16 +73,61 @@ void lowpan_unregister_netdev(struct net_device *dev)
>>   }
>>   EXPORT_SYMBOL(lowpan_unregister_netdev);
>>   +static int addrconf_ifid_802154_6lowpan(u8 *eui, struct net_device *dev)
>> +{
>> +    struct wpan_dev *wpan_dev = lowpan_802154_dev(dev)->wdev->ieee802154_ptr;
>> +
>> +    /* Set short_addr autoconfiguration if short_addr is present only */
>> +    if (!ieee802154_is_valid_src_short_addr(wpan_dev->short_addr))
>> +        return -1;
> 
> -EINVAL instead of -1?
> 

The ipv6 implementation do that for the "dev->addr" slaac the same here.
I think the reason is because here, if this fails for any reason then
this is simple not an error, we just don't add a link-local for short
addr slaac here and don't abort completely the CHANGE/UP of interface.

IPv6 also use "-1" return value only if parsing fails, I would to see
that also for iphc stuff where we mixed a lot of "-EIO" and "-EINVAL",
anyway nobody will really care about that return value.

It just means: 0 parsing successful and -1 parsing failed.

- Alex
