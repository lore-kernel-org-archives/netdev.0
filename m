From: Joe Jin <joe.jin@oracle.com>
Subject: Re: Unable to handle kernel NULL pointer dereference at 0000000000000088
 RIP:  [<ffffffff881ba167>] :bnx2:bnx2_poll_work+0xc7/0x1253
Date: Wed, 15 Oct 2014 11:29:14 +0800
Message-ID: <543DEA0A.3080609@oracle.com>
References: <5438F6C6.4040309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "zheng.li" <zheng.x.li@oracle.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Dept-HSGLinuxNICDev@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45162 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755643AbaJOD3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 23:29:25 -0400
In-Reply-To: <5438F6C6.4040309@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Copy to new maintainer from QLogic and netdev.

Thanks,
Joe
On 10/11/14 17:22, zheng.li wrote:
> Hi Michael,
> I encounter a null pointer in bnx2_poll_work=A3=AC
> after analyzed the vmcore found:
> tx_prod =3D 27708 and hw_cons =3D bnx2_get_hw_tx_cons(bnapi) =3D 2772=
2;
> hw_cons > tx_prod;
> so the root cause is mostly HW sent data count is larger than stack
> provide in bnx2_start_xmit to cause memory override, normally HW just
> can sent data maximum is tx_prod, but don't know why HW sent data mor=
e
> than tx_prod 14 data.
>=20
> Can you help to look at the issue? we encounter several times.
> bnx2 driver is 2.1.11,
> #define DRV_MODULE_VERSION	"2.1.11"
> #define DRV_MODULE_RELDATE	"July 20, 2011"
> Kernel version is : 2.6.18-371.1.2.0.1
>=20
>=20
> vmcore show infor is below:
>=20
> crash64> bnx2 ffff81122c650500
> struct bnx2 {
>   regview =3D 0xffffc200100e0000,
>   dev =3D 0xffff81122c650000,
>   pdev =3D 0xffff81122f0c9000,
>   intr_sem =3D {
>     counter =3D 0
>   },
>   flags =3D 22404,
>   bnx2_napi =3D {{
>       dummy_netdev =3D 0xffff81242ae3e800,
>       bp =3D 0xffff81122c650500,
>       status_blk =3D {
>         msi =3D 0xffff81122391b000,
>         msix =3D 0xffff81122391b000
>       },
>       hw_tx_cons_ptr =3D 0xffff81122391b00a,
>       hw_rx_cons_ptr =3D 0xffff81122391b012,
>       last_status_idx =3D 65048,
>       int_num =3D 0,
>       cnic_tag =3D 0,
>       cnic_present =3D 0,
>       rx_ring =3D {
>         rx_prod_bseq =3D 1540471240,
>         rx_prod =3D 21188,
>         rx_cons =3D 20932,
>         rx_bidx_addr =3D 65540,
>         rx_bseq_addr =3D 65544,
>         rx_pg_bidx_addr =3D 65604,
>         rx_pg_prod =3D 0,
>         rx_pg_cons =3D 0,
>         rx_buf_ring =3D 0xffffc20014a7b000,
>         rx_desc_ring =3D {0xffff81122b8a0000, 0x0, 0x0, 0x0, 0x0, 0x0=
,
> 0x0, 0x0},
>         rx_pg_ring =3D 0x0,
>         rx_pg_desc_ring =3D {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, =
0x0,
> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0},
>         rx_desc_mapping =3D {78039875584, 0, 0, 0, 0, 0, 0, 0},
>         rx_pg_desc_mapping =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0=
, 0,
> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
>       },
>       tx_ring =3D {
>         tx_prod_bseq =3D 3702584042,
>         tx_prod =3D 27708,
>         tx_bidx_addr =3D 69768,
>         tx_bseq_addr =3D 69776,
>         tx_desc_ring =3D 0xffff811227890000,
>         tx_buf_ring =3D 0xffff81242f510000,
>         tx_cons =3D 27603,
>         hw_tx_cons =3D 27603,
>         tx_desc_mapping =3D 77972701184
>       }
>     },
>=20
> crash64> rd 0xffff81122391b00a
> ffff81122391b00a:  0000000000006c4a
> hw_cons =3D 6c4a =3D 27722;
>=20
> usr/src/debug/kernel-2.6.18/linux-2.6.18-371.1.2.0.1.el5.x86_64/inclu=
de/linux/skbuff.h:
> 921
> 0xffffffff881ba167 <bnx2_poll_work+199>:921>:   mov    0x88(%r13),%ed=
x
> R13: 0000000000000000
> R13 is skb which is NULL at that moment.
>=20
> Had refer https://access.redhat.com/solutions/341183
> and
> http://kernel.opensuse.org/cgit/kernel/commit/?id=3Dc1f5163de417dab01=
fa9daaf09a74bbb19303f3c
> but can't exactly know which case our bug hit.
>=20
> Thanks,
> James Li
>=20
