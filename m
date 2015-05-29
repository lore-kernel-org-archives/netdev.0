From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [Xen-devel] [RFC PATCH 00/13] Persistent grant maps for xen net
	drivers
Date: Fri, 29 May 2015 14:51:16 +0000
Message-ID: <C3D9308A-BFC0-464E-9D17-AFE5C952A376@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <20150519153901.GH26335@zion.uk.xensource.com>
 <191EF54A-D8DE-4BAA-B15D-41B2BA35353F@neclab.eu>
 <47498F109986134D9A5B42B82F405EBBA3244CB6@SZXEMA502-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Liu <wei.liu2@citrix.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"Luohao (brian)" <brian.luohao@huawei.com>,
	"Zhangleiqiang (Trump)" <zhangleiqiang@huawei.com>,
	Zhuangyuxin <zhuangyuxin@huawei.com>,
	"Xiaoding (B)" <xiaoding1@huawei.com>
To: "Yuzhou (C)" <vitas.yuzhou@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:40257 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030211AbbE2Ovm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 10:51:42 -0400
In-Reply-To: <47498F109986134D9A5B42B82F405EBBA3244CB6@SZXEMA502-MBX.china.huawei.com>
Content-Language: en-US
Content-ID: <5AFF09D819276E488D2837A323C8C039@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 29 May 2015, at 08:53, Yuzhou (C) <vitas.yuzhou@huawei.com> wrote:
> Hi,
>=20
> 	About rx zerocopy, I have a question:
>=20
> 	If some application make a socket, then listen and accept, the clien=
t sends packets to it, but it doesn't recv from this socket right now, =
all persistent grant page would be in used.
> So other application cannot receive any packets.  Is my guess right o=
r wrong?

I believe that doesn=92t happen: before the skb gets delivered to the p=
rotocol stack,
skb_orphan_frags gets called which releases the original pages (i.e. th=
e persistent
grants) and memcpy to new ones (if the skb is fragmented). This happens=
 because I
previously set the flag SKBTX_DEV_ZEROCOPY, which also invokes a callba=
ck
in such event.

Once the callback is invoked, the released pages are added a pool withi=
n
xen-netfront which later will use for new requests to the backend. Note=
 that part
of the data is previously copied on pskb_pull_tail and may unref the in=
itial frag
before skb_orphan_frags is called. The callback is still invoked and th=
is page is added
to the pool as well.

Joao

> YuZhou
>=20
> -----Original Message-----
> From: xen-devel-bounces@lists.xen.org [mailto:xen-devel-bounces@lists=
=2Exen.org] On Behalf Of Joao Martins
> Sent: Friday, May 22, 2015 6:27 PM
> To: Wei Liu
> Cc: ian.campbell@citrix.com; netdev@vger.kernel.org; david.vrabel@cit=
rix.com; xen-devel@lists.xenproject.org;boris.ostrovsky@oracle.com
> Subject: Re: [Xen-devel] [RFC PATCH 00/13] Persistent grant maps for =
xen net drivers
>=20
>=20
> On 19 May 2015, at 17:39, Wei Liu <wei.liu2@citrix.com> wrote:
>=20
>> On Tue, May 12, 2015 at 07:18:24PM +0200, Joao Martins wrote:
>>=20
>>> There have been recently[3] some discussions and issues raised on=20
>>> persistent grants for the block layer, though the numbers above sho=
w=20
>>> some significant improvements specially on more network intensive=20
>>> workloads and provide a margin for comparison against future=20
>>> map/unmap improvements.
>>>=20
>>> Any comments or suggestions are welcome, Thanks!
>>=20
>> Thanks, the numbers certainly look interesting.
>>=20
>> I'm just a bit concerned about the complexity of netback. I've=20
>> commented on individual patches, we can discuss the issues there.
>=20
> Thanks a lot for the review! It does add more complexity, mainly for =
the TX path, but I also would like to mention that a portion of this ch=
angeset is also the persistent grants ops that could potentially live o=
utside.
>=20
> Joao
>=20
>>> [1] http://article.gmane.org/gmane.linux.network/249383
>>> [2] http://bit.ly/1IhJfXD
>>> [3]=20
>>> http://lists.xen.org/archives/html/xen-devel/2015-02/msg02292.html
>>>=20
>>> Joao Martins (13):
>>> xen-netback: add persistent grant tree ops
>>> xen-netback: xenbus feature persistent support
>>> xen-netback: implement TX persistent grants
>>> xen-netback: implement RX persistent grants
>>> xen-netback: refactor xenvif_rx_action
>>> xen-netback: copy buffer on xenvif_start_xmit()
>>> xen-netback: add persistent tree counters to debugfs
>>> xen-netback: clone skb if skb->xmit_more is set
>>> xen-netfront: move grant_{ref,page} to struct grant
>>> xen-netfront: refactor claim/release grant
>>> xen-netfront: feature-persistent xenbus support
>>> xen-netfront: implement TX persistent grants
>>> xen-netfront: implement RX persistent grants
>>>=20
>>> drivers/net/xen-netback/common.h    |  79 ++++
>>> drivers/net/xen-netback/interface.c |  78 +++-
>>> drivers/net/xen-netback/netback.c   | 873 +++++++++++++++++++++++++=
+++++------
>>> drivers/net/xen-netback/xenbus.c    |  24 +
>>> drivers/net/xen-netfront.c          | 362 ++++++++++++---
>>> 5 files changed, 1216 insertions(+), 200 deletions(-)
>>>=20
>>> --
>>> 2.1.3
>=20
>=20
>=20
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Jo=E3o Martins
Research Scientist, Networked Systems and Data Analytics Group

NEC Laboratories Europe
Kurfuerstenanlage 36
D-69115 Heidelberg

Tel.     +49 (0)6221 4342-208
=46ax:     +49 (0)6221 4342-155
e-mail:  joao.martins@neclab.eu
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
NEC Europe Ltd | Registered Office: Athene, Odyssey Business Park,
West End Road, London, HA4 6QE, GB | Registered in England 2832014
