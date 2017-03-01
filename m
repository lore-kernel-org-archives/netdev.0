From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH v5 4/6] ipv6: addrconf: fix 48 bit 6lowpan autoconfiguration
Date: Wed, 1 Mar 2017 13:09:40 +0200
Message-ID: <CABBYNZLtDxRmgA7=MErctZyTdxtcBD-QKjd4MxMbK81K7s8UAg@mail.gmail.com>
References: <20170224121440.32269-1-luiz.dentz@gmail.com> <20170224121440.32269-5-luiz.dentz@gmail.com>
 <973f0299-54ee-3625-6c96-98fa0daeba1b@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
        Patrik Flykt <patrik.flykt@linux.intel.com>,
        Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        linux-wpan@vger.kernel.org,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Alexander Aring <aar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:35983 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752323AbdCALLR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 06:11:17 -0500
In-Reply-To: <973f0299-54ee-3625-6c96-98fa0daeba1b@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

On Sun, Feb 26, 2017 at 8:38 AM, Alexander Aring <aar@pengutronix.de> wrote:
>
> Hi,
>
> okay now I am finally confused.
>
> On 02/24/2017 01:14 PM, Luiz Augusto von Dentz wrote:
>> From: Alexander Aring <aar@pengutronix.de>
>>
>> This patch adds support for 48 bit 6LoWPAN address length
>> autoconfiguration which is the case for BTLE 6LoWPAN.
>>
>> Signed-off-by: Alexander Aring <aar@pengutronix.de>
>> Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
>> Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
>> ---
>>  net/ipv6/addrconf.c | 17 ++++++++++++-----
>>  1 file changed, 12 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 3a2025f..7756640 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -2052,12 +2052,19 @@ static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
>>       __ipv6_dev_ac_dec(ifp->idev, &addr);
>>  }
>>
>> -static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
>> +static int addrconf_ifid_6lowpan(u8 *eui, struct net_device *dev)
>>  {
>> -     if (dev->addr_len != EUI64_ADDR_LEN)
>> +     switch (dev->addr_len) {
>> +     case ETH_ALEN:
>> +             return addrconf_ifid_eui48(eui, dev);
>
> You need to make the same thing here like what we discusss in antoher
> mail.
>
>    In the figure, letter 'b' represents a bit from the
>    Bluetooth device address, copied as is without any changes on any
>    bit.  This means that no bit in the IID indicates whether the
>    underlying Bluetooth device address is public or random.
>
>    |0              1|1              3|3              4|4              6|
>    |0              5|6              1|2              7|8              3|
>    +----------------+----------------+----------------+----------------+
>    |bbbbbbbbbbbbbbbb|bbbbbbbb11111111|11111110bbbbbbbb|bbbbbbbbbbbbbbbb|
>    +----------------+----------------+----------------+----------------+
>
> The function addrconf_ifid_eui48 will do a u/l bitflip. You need to change
> that otherwise transparent 6lowpan adaptiation will not match on your
> local address.
>
> Making u/l bit here, but not in IPHC code -> will not work together.
>
> ---
>
> btw: That's why I think we should provide some function _once_ to
> generate the IID for iphc code and ipv6. Then such mistakes will not
> happen.
>
> So we don't want to have some module dependency of 6lowpan in ipv6.
> My first idea is to make a callback in 6lowpan private data of
> netdevice. :-/

Well if we will be introducing new fields why not introduce an iid
field directly into net_device? That way we don't need to keep
generating it in several places.

-- 
Luiz Augusto von Dentz
