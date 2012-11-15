From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Thu, 15 Nov 2012 16:38:30 +0800
Message-ID: <50A4AA06.8080900@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com> <20121115074057.GO8912@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	konrad.wilk@oracle.com, Ian.Campbell@citrix.com
To: =?ISO-8859-1?Q?Pasi_K=E4rkk=E4inen?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30239 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756126Ab2KOIiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 03:38:46 -0500
In-Reply-To: <20121115074057.GO8912@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-15 15:40, Pasi K=E4rkk=E4inen wrote:
> Hello,
>
> On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
>> This patch implements persistent grants for xen-netfront/netback. Th=
is
>> mechanism maintains page pools in netback/netfront, these page pools=
 is used to
>> save grant pages which are mapped. This way improve performance whic=
h is wasted
>> when doing grant operations.
>>
>> Current netback/netfront does map/unmap grant operations frequently =
when
>> transmitting/receiving packets, and grant operations costs much cpu =
clock. In
>> this patch, netfront/netback maps grant pages when needed and then s=
aves them
>> into a page pool for future use. All these pages will be unmapped wh=
en
>> removing/releasing the net device.
>>
> Do you have performance numbers available already? with/without persi=
stent grants?
I have some simple netperf/netserver test result with/without persisten=
t=20
grants,

=46ollowing is result of with persistent grant patch,

Guests, Sum,      Avg,     Min,     Max
  1,  15106.4,  15106.4, 15106.36, 15106.36
  2,  13052.7,  6526.34,  6261.81,  6790.86
  3,  12675.1,  6337.53,  6220.24,  6454.83
  4,  13194,  6596.98,  6274.70,  6919.25


=46ollowing are result of without persistent patch

Guests, Sum,     Avg,    Min,        Max
  1,  10864.1,  10864.1, 10864.10, 10864.10
  2,  10898.5,  5449.24,  4862.08,  6036.40
  3,  10734.5,  5367.26,  5261.43,  5473.08
  4,  10924,    5461.99,  5314.84,  5609.14

>> In netfront, two pools are maintained for transmitting and receiving=
 packets.
>> When new grant pages are needed, the driver gets grant pages from th=
is pool
>> first. If no free grant page exists, it allocates new page, maps it =
and then
>> saves it into the pool. The pool size for transmit/receive is exactl=
y tx/rx
>> ring size. The driver uses memcpy(not grantcopy) to copy data grant =
pages.
>> Here, memcpy is copying the whole page size data. I tried to copy le=
n size data
>> from offset, but network does not seem work well. I am trying to fin=
d the root
>> cause now.
>>
>> In netback, it also maintains two page pools for tx/rx. When netback=
 gets a
>> request, it does a search first to find out whether the grant refere=
nce of
>> this request is already mapped into its page pool. If the grant ref =
is mapped,
>> the address of this mapped page is gotten and memcpy is used to copy=
 data
>> between grant pages. However, if the grant ref is not mapped, a new =
page is
>> allocated, mapped with this grant ref, and then saved into page pool=
 for
>> future use. Similarly, memcpy replaces grant copy to copy data betwe=
en grant
>> pages. In this implementation, two arrays(gnttab_tx_vif,gnttab_rx_vi=
f) are
>> used to save vif pointer for every request because current netback i=
s not
>> per-vif based. This would be changed after implementing 1:1 model in=
 netback.
>>
> Btw is xen-netback/xen-netfront multiqueue support something you're p=
lanning to implement aswell?
Currently, some patches exist for implementing 1:1 model in netback, bu=
t=20
this should be different from what you mentioned, and they are not read=
y=20
for upstream.
These patches make netback thread per VIF, and mainly implement some=20
concepts from netchannel2, such as multipage rings, seperate tx and rx=20
rings, seperate tx and rx event channels, etc.

Thanks
Annie

> multiqueue allows single vif scaling to multiple vcpus/cores.
>
>
> Thanks,
>
> -- Pasi
>
>
>> This patch supports both persistent-grant and non persistent grant. =
A new
>> xenstore key "feature-persistent-grants" is used to represent this f=
eature.
>>
>> This patch is based on linux3.4-rc3. I hit netperf/netserver failure=
 on
>> linux latest version v3.7-rc1, v3.7-rc2 and v3.7-rc4. Not sure wheth=
er this
>> netperf/netserver failure connects compound page commit in v3.7-rc1,=
 but I did
>> hit BUG_ON with debug patch from thread
>> http://lists.xen.org/archives/html/xen-devel/2012-10/msg00893.html
>>
>>
>> Annie Li (4):
>>    xen/netback: implements persistent grant with one page pool.
>>    xen/netback: Split one page pool into two(tx/rx) page pool.
>>    Xen/netfront: Implement persistent grant in netfront.
>>    fix code indent issue in xen-netfront.
>>
>>   drivers/net/xen-netback/common.h    |   24 ++-
>>   drivers/net/xen-netback/interface.c |   26 +++
>>   drivers/net/xen-netback/netback.c   |  215 ++++++++++++++++++--
>>   drivers/net/xen-netback/xenbus.c    |   14 ++-
>>   drivers/net/xen-netfront.c          |  378 +++++++++++++++++++++++=
++++++------
>>   5 files changed, 570 insertions(+), 87 deletions(-)
>>
>> --=20
>> 1.7.3.4
>>
>>
>> _______________________________________________
>> Xen-devel mailing list
>> Xen-devel@lists.xen.org
>> http://lists.xen.org/xen-devel
