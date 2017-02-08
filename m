From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: KASAN+netlink, was: [PATCH] [net-next?] hns: avoid stack overflow
 with CONFIG_KASAN
Date: Wed, 8 Feb 2017 14:10:52 +0100
Message-ID: <CAK8P3a2fHm9j7roYjTAXJ_zsdXF88p_6Y-hCF6aWjJzcAaQ3Uw@mail.gmail.com>
References: <20170203163607.3488037-1-arnd@arndb.de> <20170206.120318.1268240226202516488.davem@davemloft.net>
 <4910112.l20yySyWnA@wuerfel> <1486556665.24745.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, stable@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Andrey Ryabinin <a.ryabinin@samsung.com>,
        nikolay@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        adobriyan@gmail.com,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486556665.24745.6.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 8, 2017 at 1:24 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Wed, 2017-02-08 at 13:03 +0100, Arnd Bergmann wrote:
>>
>> - Moving nla_put_{u8,u16,u32} out of line is probably uncontroversial
>> and
>>   it helps enough with br_netlink.c, but nl820211 is worse and needs
>> some
>>   additional fiddling.
>
> Why would that not be sufficient by itself for nl80211?

Oddly enough, it seems that it is now. I don't know what I was testing earlier,
but now I don't see any difference between this simple change, and the
modifications
I did on nl820211.c. I started out trying to fix this in nl820211.c
originally and then
later tried the extern nla_put_*(), but didn't think it helped all
that much then.

I'll just submit the simple patch then. ;-)

a) current mainline, arm64 allmodconfig+KASAN,
    CONFIG_FRAME_WARN=1024

../net/wireless/nl80211.c: In function 'nl80211_get_mesh_config':
../net/wireless/nl80211.c:5689:1: warning: the frame size of 2336
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_send_iface':
../net/wireless/nl80211.c:2591:1: warning: the frame size of 1120
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_add_commands_unsplit.isra.2':
../net/wireless/nl80211.c:1410:1: warning: the frame size of 2272
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_set_wiphy':
../net/wireless/nl80211.c:2491:1: warning: the frame size of 1376
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_send_wiphy':
../net/wireless/nl80211.c:1895:1: warning: the frame size of 4288
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_send_station.isra.44':
../net/wireless/nl80211.c:4389:1: warning: the frame size of 2240
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_dump_station':
../net/wireless/nl80211.c:4441:1: warning: the frame size of 1456
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_get_station':
../net/wireless/nl80211.c:4478:1: warning: the frame size of 1232
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'cfg80211_del_sta_sinfo':
../net/wireless/nl80211.c:13611:1: warning: the frame size of 1072
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_send_bss.isra.43.constprop':
../net/wireless/nl80211.c:7588:1: warning: the frame size of 1296
bytes is larger than 1024 bytes

b) with patch to move nla_put_* functions out of line:
../net/wireless/nl80211.c: In function 'nl80211_set_wiphy':
../net/wireless/nl80211.c:2491:1: warning: the frame size of 1376
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_dump_station':
../net/wireless/nl80211.c:4441:1: warning: the frame size of 1456
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_get_station':
../net/wireless/nl80211.c:4478:1: warning: the frame size of 1232
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'cfg80211_del_sta_sinfo':
../net/wireless/nl80211.c:13611:1: warning: the frame size of 1072
bytes is larger than 1024 bytes
../net/wireless/nl80211.c: In function 'nl80211_dump_survey':
../net/wireless/nl80211.c:7753:1: warning: the frame size of 1136
bytes is larger than 1024 bytes

c) without --param asan-stack=1, checking just the functions above
against 100 bytes

../net/wireless/nl80211.c: In function 'nl80211_set_wiphy':
../net/wireless/nl80211.c:2491:1: warning: the frame size of 144 bytes
is larger than 100 bytes [-Wframe-larger-than=]
../net/wireless/nl80211.c: In function 'nl80211_send_wiphy':
../net/wireless/nl80211.c:1895:1: warning: the frame size of 224 bytes
is larger than 100 bytes [-Wframe-larger-than=]
../net/wireless/nl80211.c: In function 'nl80211_send_station.isra.44':
../net/wireless/nl80211.c:4389:1: warning: the frame size of 144 bytes
is larger than 100 bytes [-Wframe-larger-than=]
../net/wireless/nl80211.c: In function 'nl80211_dump_station':
../net/wireless/nl80211.c:4441:1: warning: the frame size of 912 bytes
is larger than 100 bytes [-Wframe-larger-than=]
../net/wireless/nl80211.c: In function 'nl80211_get_station':
../net/wireless/nl80211.c:4478:1: warning: the frame size of 864 bytes
is larger than 100 bytes [-Wframe-larger-than=]
../net/wireless/nl80211.c: In function 'cfg80211_del_sta_sinfo':
../net/wireless/nl80211.c:13611:1: warning: the frame size of 864
bytes is larger than 100 bytes [-Wframe-larger-than=]
../net/wireless/nl80211.c: In function 'nl80211_dump_survey':
../net/wireless/nl80211.c:7753:1: warning: the frame size of 112 bytes
is larger than 100 bytes [-Wframe-larger-than=]


> Btw, what's causing this to start with? Can't the compiler reuse the
> stack places?

I have no idea. It's trying to find out of bounds accesses for
objects on the stack, so maybe it gives each variable a separate
stack location in order to see which one caused problems?

     Arnd
