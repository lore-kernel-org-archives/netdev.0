From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug #14378] Problems with net/core/skbuff.c
Date: Tue, 13 Oct 2009 12:19:51 +0200
Message-ID: <4AD45447.7030705@gmail.com>
References: <zJ_pXHNwoHC.A.akB.Aal0KB@chimera>	<r-4Wjt4coy.A.CwC.Wal0KB@chimera> <20091012.034224.64980795.davem@davemloft.net> <4AD44435.3050703@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: Massimo Cetra <ctrixk@navynet.it>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759361AbZJMKVH@vger.kernel.org>
In-Reply-To: <4AD44435.3050703@navynet.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Massimo Cetra a =E9crit :
> David Miller ha scritto:
>> From: "Rafael J. Wysocki" <rjw@sisk.pl>
>> Date: Mon, 12 Oct 2009 00:22:04 +0200 (CEST)
>>
>> =20
>>> Bug-Entry    : http://bugzilla.kernel.org/show_bug.cgi?id=3D14378
>>> Subject        : Problems with net/core/skbuff.c
>>> Submitter    : Massimo Cetra <mcetra@navynet.it>
>>> Date        : 2009-10-08 14:51 (4 days old)
>>> References    : http://marc.info/?l=3Dlinux-kernel&m=3D125501488220=
358&w=3D4
>>>    =20
>>
>> I don't know what to do about this one.
>>
>> The user indicates that they have the vserver patches applied,
>> so maybe there is some interaction with that stuff.
>>  =20
> Actually i found another oops which is very similar to the previous o=
ne.
> Here, vserver is not involved, and the problem starts at drbd which
> lives in kernel space (the other oops started at ocfs2).
>=20
> Both ocfs2 and drbd make heavy use of network I/O so i guess the prob=
lem
> is something in the network layer.
>=20
> Anything i can do to help to debugging and solving this issue ?
>=20
> Thanks
> Max
>=20

Problem is kfree_skb() is called from irq context, wich is not allowed.

static void skb_release_head_state(struct sk_buff *skb)
{
=2E..
if (skb->destructor) {
	WARN_ON(in_irq());
	skb->destructor();
}
=2E..
}

virtio_net start_xmit() function calls free_old_xmit_skbs() and=20
free_old_xmit_skbs() ultimately calls kfree_skb()

Quick fix would be to use dev_kfree_skb_any() instead,
because netpoll can definitly calls start_xmit()
with irq disabled.

Could you please following patch ?

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 8d00976..54bf091 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -454,7 +454,7 @@ static unsigned int free_old_xmit_skbs(struct virtn=
et_info *vi)
 		vi->dev->stats.tx_bytes +=3D skb->len;
 		vi->dev->stats.tx_packets++;
 		tot_sgs +=3D skb_vnet_hdr(skb)->num_sg;
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 	}
 	return tot_sgs;
 }
