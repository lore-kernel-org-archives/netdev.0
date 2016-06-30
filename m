From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH net] bonding: prevent out of bound accesses
Date: Thu, 30 Jun 2016 15:35:51 +0200
Message-ID: <CACT4Y+YdOi1-z1pPJaYBybyHZ=MXzHPGjGU+UJWJf-N3pgGzeg@mail.gmail.com>
References: <1467291379.11238.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+aAVS+oYg62hftq7RMb2QM9wiPCK-Vf33c2PaG2Sm6R6g@mail.gmail.com> <1467293149.11238.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:36366 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbcF3Nmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 09:42:40 -0400
Received: by mail-lf0-f43.google.com with SMTP id q132so55741781lfe.3
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 06:42:39 -0700 (PDT)
In-Reply-To: <1467293149.11238.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 3:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-06-30 at 15:04 +0200, Dmitry Vyukov wrote:
>> On Thu, Jun 30, 2016 at 2:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > ether_addr_equal_64bits() requires some care about its arguments,
>> > namely that 8 bytes might be read, even if last 2 byte values are not
>> > used.
>> >
>> > KASan detected a violation with null_mac_addr and lacpdu_mcast_addr
>> > in bond_3ad.c
>> >
>> > Fixes: 815117adaf5b ("bonding: use ether_addr_equal_unaligned for bond addr compare")
>> > Fixes: bb54e58929f3 ("bonding: Verify RX LACPDU has proper dest mac-addr")
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> > Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> > ---
>> >  drivers/net/bonding/bond_3ad.c |   11 +++++++----
>> >  drivers/net/bonding/bond_alb.c |    3 ---
>> >  include/net/bonding.h          |    7 ++++++-
>> >  3 files changed, 13 insertions(+), 8 deletions(-)
>> >
>> > diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> > index ca81f46ea1aa..8ad491ab1d01 100644
>> > --- a/drivers/net/bonding/bond_3ad.c
>> > +++ b/drivers/net/bonding/bond_3ad.c
>> > @@ -101,11 +101,14 @@ enum ad_link_speed_type {
>> >  #define MAC_ADDRESS_EQUAL(A, B)        \
>> >         ether_addr_equal_64bits((const u8 *)A, (const u8 *)B)
>> >
>> > -static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };
>> > +static const u8 null_mac_addr[ETH_ALEN] __long_aligned = {
>> > +       0, 0, 0, 0, 0, 0
>> > +};
>>
>> __long_aligned won't prevent KASAN from barking, it's still 6 bytes
>> but we are reading 8.
>> Can we please do "ETH_ALEN + 2" as below?
>
> Really ?
>
> sizeof(null_mac_addr) is 8, how KASan would decide it is 6 bytes ?
>
> nm -v drivers/net/bonding/bonding.ko|grep -3 null_mac_addr
>
> 000000000000084a r __UNIQUE_ID_mode17
> 0000000000000850 r tmpl.46263
> 0000000000000860 r lacpdu_mcast_addr
> 0000000000000868 r null_mac_addr
> 0000000000000870 r mac_v6_allmcast
> 0000000000000878 r mac_bcast
> 0000000000000880 r slave_sysfs_ops


What does nm -S say?
I've tried to compile a sample program with gcc6 and
__attribute__((aligned(8))) does in fact force alignment of start of
the symbol, but size still stays 6. (and asan still barks on my test
program).
