From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] net/ieee802154/6lowpan.c:
	reuse eth_mac_addr()
Date: Sat, 12 May 2012 12:38:01 +0400
Message-ID: <CAJmB2rAA8rgzFNvju9XHjo5Xxo2v=Q2stGtMJ7YYer0ayM3h+g@mail.gmail.com>
References: <1329914199-30862-1-git-send-email-danny.kukawka@bisect.de>
	<1329914199-30862-3-git-send-email-danny.kukawka@bisect.de>
	<92f4dc09fca1e6ec54f12ca61b8b8e55@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Danny Kukawka <danny.kukawka-2YacvwyR+KOzQB+pC5nmwQ@public.gmane.org>, Danny Kukawka <dkukawka-l3A5Bk7waGM@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tony Cheneau <tony.cheneau+zigbeedev-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <92f4dc09fca1e6ec54f12ca61b8b8e55-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tony,

2012/4/28 Tony Cheneau <tony.cheneau+zigbeedev-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>:
> Hello,
>
> I believe the following patch should not have been applied and should
> now be reverted.
> The reason is because eth_mac_addr() is not functionally equivalent to
> lowpan_set_address() that it replaces:
> - lowpan_set_address() copies dev->addr_len bytes, where dev->addr_len
> is set to 8 bytes for IEEE802154 devices (this is an IEEE EUI-64
> address). Hence, the function copies the full 8 bytes of the address.
> - eth_mac_addr() copies ETH_ALEN bytes, where ETH_ALEN is set to 6.
> Hence, the function copies only 6 bytes of the 8 bytes address. So, 2
> bytes of the address are never copied.
>
> Does this sound reasonable?
>

Yeah, you are definitely right. I don't exactly know where did this
patch arrive from, looks like I wasn't in Cc. I'm going to create
reverted patch.

Thanks

> Regards,
> Tony
>
>
> Le 22.02.2012 14:36, Danny Kukawka a =E9crit=A0:
>> Use eth_mac_addr() for .ndo_set_mac_address, remove
>> lowpan_set_address since it do currently the same as
>> eth_mac_addr(). Additional advantage: eth_mac_addr() already
>> checks if the given address is valid
>>
>> Signed-off-by: Danny Kukawka <danny.kukawka-2YacvwyR+KOzQB+pC5nmwQ@public.gmane.org>
>> ---
>> =A0net/ieee802154/6lowpan.c | =A0 16 ++--------------
>> =A01 files changed, 2 insertions(+), 14 deletions(-)
>>
>> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
>> index e4ecc1e..3685158 100644
>> --- a/net/ieee802154/6lowpan.c
>> +++ b/net/ieee802154/6lowpan.c
>> @@ -55,6 +55,7 @@
>> =A0#include <linux/module.h>
>> =A0#include <linux/moduleparam.h>
>> =A0#include <linux/netdevice.h>
>> +#include <linux/etherdevice.h>
>> =A0#include <net/af_ieee802154.h>
>> =A0#include <net/ieee802154.h>
>> =A0#include <net/ieee802154_netdev.h>
>> @@ -924,19 +925,6 @@ drop:
>> =A0 =A0 =A0 return -EINVAL;
>> =A0}
>>
>> -static int lowpan_set_address(struct net_device *dev, void *p)
>> -{
>> - =A0 =A0 struct sockaddr *sa =3D p;
>> -
>> - =A0 =A0 if (netif_running(dev))
>> - =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
>> -
>> - =A0 =A0 /* TODO: validate addr */
>> - =A0 =A0 memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
>> -
>> - =A0 =A0 return 0;
>> -}
>> -
>> =A0static int lowpan_get_mac_header_length(struct sk_buff *skb)
>> =A0{
>> =A0 =A0 =A0 /*
>> @@ -1062,7 +1050,7 @@ static struct header_ops lowpan_header_ops =3D {
>>
>> =A0static const struct net_device_ops lowpan_netdev_ops =3D {
>> =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =A0 =A0 =3D lowpan_xmit,
>> - =A0 =A0 .ndo_set_mac_address =A0 =A0=3D lowpan_set_address,
>> + =A0 =A0 .ndo_set_mac_address =A0 =A0=3D eth_mac_addr,
>> =A0};
>>
>> =A0static void lowpan_setup(struct net_device *dev)
>
>
> -------------------------------------------------------------------------=
-----
> Live Security Virtual Conference
> Exclusive live event will cover all the ways today's security and
> threat landscape has changed and how IT managers can respond. Discussions
> will include endpoint security, mobile security and the latest in malware
> threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
> _______________________________________________
> Linux-zigbee-devel mailing list
> Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

---------------------------------------------------------------------------=
---
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and =

threat landscape has changed and how IT managers can respond. Discussions =

will include endpoint security, mobile security and the latest in malware =

threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
