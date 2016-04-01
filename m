From: santosh shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] RDS: sync congestion map updating
Date: Fri, 1 Apr 2016 12:47:24 -0700
Message-ID: <56FED04C.2060806@oracle.com>
References: <1459328902-31968-1-git-send-email-wen.gang.wang@oracle.com>
 <20160330161952.GA2670@leon.nu> <56FC09D6.7090602@oracle.com>
 <56FC82B7.3070504@oracle.com> <56FC927E.9090404@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, leon-2ukJVAZIZ/Y@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56FC927E.9090404-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(cc-ing netdev)
On 3/30/2016 7:59 PM, Wengang Wang wrote:
>
>
> =E5=9C=A8 2016=E5=B9=B403=E6=9C=8831=E6=97=A5 09:51, Wengang Wang =E5=
=86=99=E9=81=93:
>>
>>
>> =E5=9C=A8 2016=E5=B9=B403=E6=9C=8831=E6=97=A5 01:16, santosh shilimk=
ar =E5=86=99=E9=81=93:
>>> Hi Wengang,
>>>
>>> On 3/30/2016 9:19 AM, Leon Romanovsky wrote:
>>>> On Wed, Mar 30, 2016 at 05:08:22PM +0800, Wengang Wang wrote:
>>>>> Problem is found that some among a lot of parallel RDS
>>>>> communications hang.
>>>>> In my test ten or so among 33 communications hang. The send
>>>>> requests got
>>>>> -ENOBUF error meaning the peer socket (port) is congested. But
>>>>> meanwhile,
>>>>> peer socket (port) is not congested.
>>>>>
>>>>> The congestion map updating can happen in two paths: one is in
>>>>> rds_recvmsg path
>>>>> and the other is when it receives packets from the hardware. Ther=
e
>>>>> is no
>>>>> synchronization when updating the congestion map. So a bit
>>>>> operation (clearing)
>>>>> in the rds_recvmsg path can be skipped by another bit operation
>>>>> (setting) in
>>>>> hardware packet receving path.
>>>>>
>
> To be more detailed.  Here, the two paths (user calls recvmsg and
> hardware receives data) are for different rds socks. thus the
> rds_sock->rs_recv_lock is not helpful to sync the updating on congest=
ion
> map.
>
=46or archive purpose, let me try to conclude the thread. I synced
with Wengang offlist and came up with below fix. I was under
impression that __set_bit_le() was atmoic version. After fixing
it like patch(end of the email), the bug gets addressed.

I will probably send this as fix for stable as well.


 From 5614b61f6fdcd6ae0c04e50b97efd13201762294 Mon Sep 17 00:00:00 2001
=46rom: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Wed, 30 Mar 2016 23:26:47 -0700
Subject: [PATCH] RDS: Fix the atomicity for congestion map update

Two different threads with different rds sockets may be in
rds_recv_rcvbuf_delta() via receive path. If their ports
both map to the same word in the congestion map, then
using non-atomic ops to update it could cause the map to
be incorrect. Lets use atomics to avoid such an issue.

=46ull credit to Wengang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> for
finding the issue, analysing it and also pointing out
to offending code with spin lock based fix.

Signed-off-by: Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
  net/rds/cong.c |    4 ++--
  1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/cong.c b/net/rds/cong.c
index e6144b8..6641bcf 100644
--- a/net/rds/cong.c
+++ b/net/rds/cong.c
@@ -299,7 +299,7 @@ void rds_cong_set_bit(struct rds_cong_map *map,=20
__be16 port)
  	i =3D be16_to_cpu(port) / RDS_CONG_MAP_PAGE_BITS;
  	off =3D be16_to_cpu(port) % RDS_CONG_MAP_PAGE_BITS;

-	__set_bit_le(off, (void *)map->m_page_addrs[i]);
+	set_bit_le(off, (void *)map->m_page_addrs[i]);
  }

  void rds_cong_clear_bit(struct rds_cong_map *map, __be16 port)
@@ -313,7 +313,7 @@ void rds_cong_clear_bit(struct rds_cong_map *map,=20
__be16 port)
  	i =3D be16_to_cpu(port) / RDS_CONG_MAP_PAGE_BITS;
  	off =3D be16_to_cpu(port) % RDS_CONG_MAP_PAGE_BITS;

-	__clear_bit_le(off, (void *)map->m_page_addrs[i]);
+	clear_bit_le(off, (void *)map->m_page_addrs[i]);
  }

  static int rds_cong_test_bit(struct rds_cong_map *map, __be16 port)
--=20
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
