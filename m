From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Fri, 28 Oct 2011 12:00:53 +0200
Message-ID: <1319796053.23112.92.camel@edumazet-laptop>
References: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903179@ESESSCMS0356.eemea.ericsson.se>
	 <4E972301.4030004@intel.com>
	 <CAEP_g=9dk_ERdnw4Hw_8RO8Z23E1g2Q9G=AxPkiaVhwbHvo47A@mail.gmail.com>
	 <20111018.234723.1235424375699917420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse@nicira.com, john.r.fastabend@intel.com,
	hans.schillstrom@ericsson.com, jpirko@redhat.com,
	mbizon@freebox.fr, netdev@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39753 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962Ab1J1KBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 06:01:09 -0400
Received: by wyg36 with SMTP id 36so3703083wyg.19
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2011 03:01:08 -0700 (PDT)
In-Reply-To: <20111018.234723.1235424375699917420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 23:47 -0400, David Miller a =C3=A9crit =
:
> From: Jesse Gross <jesse@nicira.com>
> Date: Thu, 13 Oct 2011 17:22:02 -0700
>=20
> > Actually, for most of 2.6.x the behavior was somewhat
> > non-deterministic since it depended on kernel version and the NIC. =
 As
> > a result, I think we can safely say that this wasn't a particularly
> > firm interface that we have to be wedded to.  Based on overwhelming
> > feedback, I think the interface in this patch is the preferred one =
and
> > what we should stabilize on.
>=20
> Agreed, and I've applied this patch to net-next, thanks everyone!

Hmm.

Oh well, this broke my setup, a very basic one.

eth1 and eth2 on a bonding device, bond0, active-backup

some vlans on top of bond0, say vlan.103

$ ip link show dev vlan.103
8: vlan.103@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
pfifo_fast state UP qlen 100
    link/ether 00:1e:0b:ec:d3:d2 brd ff:ff:ff:ff:ff:ff


arp_rcv() now gets packets with skb->type PACKET_OTHERHOST and drops
such packets.

     [000] 52870.115435: skb_gro_reset_offset <-napi_gro_receive
     [000] 52870.115435: dev_gro_receive <-napi_gro_receive
     [000] 52870.115435: napi_skb_finish <-napi_gro_receive
     [000] 52870.115435: netif_receive_skb <-napi_skb_finish
     [000] 52870.115435: get_rps_cpu <-netif_receive_skb
     [000] 52870.115435: __netif_receive_skb <-netif_receive_skb
     [000] 52870.115436: vlan_do_receive <-__netif_receive_skb
     [000] 52870.115436: bond_handle_frame <-__netif_receive_skb
     [000] 52870.115436: vlan_do_receive <-__netif_receive_skb
     [000] 52870.115436: arp_rcv <-__netif_receive_skb
     [000] 52870.115436: kfree_skb <-arp_rcv
     [000] 52870.115437: __kfree_skb <-kfree_skb
     [000] 52870.115437: skb_release_head_state <-__kfree_skb
     [000] 52870.115437: skb_release_data <-__kfree_skb
     [000] 52870.115437: kfree <-skb_release_data
     [000] 52870.115437: kmem_cache_free <-__kfree_skb


By the way, we have no SNMP counter here so I spent some time to track
this. I'll send a patch for this.

If this host initiates the trafic, all is well.

Please guys, can we get back ARP or revert this patch ?

Thanks
