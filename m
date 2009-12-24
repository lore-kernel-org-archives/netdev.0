From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2] llc enhancements
Date: Thu, 24 Dec 2009 09:35:31 +0100
Message-ID: <4B3327D3.7080704@gmail.com>
References: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54703 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754737AbZLXIfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 03:35:38 -0500
In-Reply-To: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/12/2009 00:45, Octavian Purdila a =E9crit :
> This patch modifies the LLC code to scale the socket lookup code for =
a
> large number of interfaces and large number of sockets bound to the
> same SAP. We use it for STP traffic generation from a large number of
> virtual STP ports, via virtual network interfaces.
>=20
> In the process we converted the socket lookup code and sap list to us=
e
> RCU. It also contains some general cleanups (use dev_hard_header
> instead of handcrafting the headers) and enhancements (LLC_OPT_PKTINF=
O).
>=20
> This is the 2nd version. Changes from the previous version:
>=20
> - added SO_BINDTODEVICE support for faster bind operations
> - converted the socket lookup code and sap list to RCU
> - optimized multicast delivery ala Eric
> - remove some unused APIs (which should be private anyway)
>=20
> Many thanks to Eric Dumazet for his continuous guidance and to Jarek
> Poplawski for spotting a locking bug in the previous version.
>=20
>=20

Pretty impressive work Octavian !

My only concerns (before drinking my coffee, I might be wrong...) are :

1) Patch 7/9 : __llc_lookup_established()
   Checking slot number is not enough I am afraid. A socket can be free=
d,
   re-allocated, inserted in another sap hash list on _same_ slot numbe=
r.
   We dont have this problem with UDP/TCP since we have only
   one hash table on machine, but with llc, we might have many sap hash=
 tables.

   So before if (llc_estab_match(sap, daddr, laddr, rc)) test, you prob=
ably
   need to check if we found a socket hashed on a different hash table =
and
   restart the lookup.

2) the WARN_ON() removal in patch 7/9 :

 void llc_sap_close(struct llc_sap *sap)
 {
-	WARN_ON(!hlist_nulls_empty(&sap->sk_list));
 	llc_del_sap(sap);
 	kfree(sap);
 }

I believe we should keep the sanity test some time, converted to sk_lad=
dr_hash[] variant.

Thanks
