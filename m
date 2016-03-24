From: Ben Greear <greearb@candelatech.com>
Subject: =?UTF-8?Q?veth_regression_with_=22don=e2=80=99t_modify_ip=5fsummed;?=
 =?UTF-8?Q?_doing_so_treats_packets_with_bad_checksums_as_good.=22?=
Date: Thu, 24 Mar 2016 15:01:58 -0700
Message-ID: <56F463D6.7080406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>
To: netdev <netdev@vger.kernel.org>, ej@evanjones.ca, vijayp@vijayp.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:54249 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbcCXWCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 18:02:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have an application that creates two pairs of veth devices.

a <-> b       c <-> d

b and c have a raw packet socket opened on them and I 'bridge' frames
between b and c to provide network emulation (ie, configurable delay).


I put IP 1.1.1.1/24 on a, 1.1.1.2/24 on d, and then create a UDP connec=
tion
(using policy based routing to ensure frames are sent on the appropriat=
e
interfaces).

This is user-space only app, and kernel in this case is completely unmo=
dified.

The commit below breaks this feature:  UDP frames are sniffed on both a=
 and d ports
(in both directions), but the UDP socket does not receive frames.

Using normal ethernet ports, this network emulation feature works fine,=
 so it is
specific to VETH.

A similar test with just sending UDP between a single veth pair:  e <->=
 f
works fine.  Maybe it has something to do with raw packets?


The patch below is the culprit:


[greearb@ben-dt3 linux-2.6]$ git bisect bad
ce8c839b74e3017996fad4e1b7ba2e2625ede82f is the first bad commit
commit ce8c839b74e3017996fad4e1b7ba2e2625ede82f
Author: Vijay Pandurangan <vijayp@vijayp.ca>
Date:   Fri Dec 18 14:34:59 2015 -0500

     veth: don=E2=80=99t modify ip_summed; doing so treats packets with=
 bad checksums as good.

     Packets that arrive from real hardware devices have ip_summed =3D=3D
     CHECKSUM_UNNECESSARY if the hardware verified the checksums, or
     CHECKSUM_NONE if the packet is bad or it was unable to verify it. =
The
     current version of veth will replace CHECKSUM_NONE with
     CHECKSUM_UNNECESSARY, which causes corrupt packets routed from har=
dware to
     a veth device to be delivered to the application. This caused appl=
ications
     at Twitter to receive corrupt data when network hardware was corru=
pting
     packets.

=2E..

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0ef4a5a..ba21d07 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -117,12 +117,6 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, =
struct net_device *dev)
                 kfree_skb(skb);
                 goto drop;
         }
-       /* don't change ip_summed =3D=3D CHECKSUM_PARTIAL, as that
-        * will cause bad checksum on forwarded packets
-        */
-       if (skb->ip_summed =3D=3D CHECKSUM_NONE &&
-           rcv->features & NETIF_F_RXCSUM)
-               skb->ip_summed =3D CHECKSUM_UNNECESSARY;

         if (likely(dev_forward_skb(rcv, skb) =3D=3D NET_RX_SUCCESS)) {
                 struct pcpu_vstats *stats =3D this_cpu_ptr(dev->vstats=
);


Any suggestions for how to fix this so that I get the old working behav=
iour and
the bug this patch was trying to fix is also resolved?

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
