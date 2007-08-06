From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH 1/1] lro: Generic Large Receive Offload for TCP traffic
Date: Mon, 6 Aug 2007 09:51:11 +0200
Message-ID: <200708060951.12408.ossthema@de.ibm.com>
References: <200708031441.20632.ossthema@de.ibm.com> <20070803134150.GH19344@lazybastard.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Andrew Gallatin <gallatin@myri.com>,
	Jeff Garzik <jeff@garzik.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: =?utf-8?q?J=C3=B6rn_Engel?= <joern@logfs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:19428 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754896AbXHFIVG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 04:21:06 -0400
In-Reply-To: <20070803134150.GH19344@lazybastard.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi J=C3=B6rn

On Friday 03 August 2007 15:41, J=C3=B6rn Engel wrote:
> On Fri, 3 August 2007 14:41:19 +0200, Jan-Bernd Themann wrote:
> >=20
> > This patch provides generic Large Receive Offload (LRO) functionali=
ty
> > for IPv4/TCP traffic.
> >=20
> > LRO combines received tcp packets to a single larger tcp packet and=
=20
> > passes them then to the network stack in order to increase performa=
nce
> > (throughput). The interface supports two modes: Drivers can either =
pass
> > SKBs or fragment lists to the LRO engine.=20
>=20
> Maybe this is a stupid question, but why is LRO done at the device
> driver level?
>=20
> If it is a unversal performance benefit, I would have expected it to =
be
> done generically, i.e. have all packets moved into network layer pass
> through LRO instead.

The driver seems to be the right place:
-  There is the "page mode" interface that accepts fragment lists inste=
ad of
   SKBs and does generate SKBs only in the end (see Andrew Gallatins=20
   mails where he described the advantages of this approach)

-  Some drivers (in particular for 10G NICs which actually could benefi=
t
   from LRO) have multiple HW receive queues that do some sort of sorti=
ng,
   thus using one lro_mgr per queue increases the likelyhood of beeing =
able
   to do efficient LRO.
  =20

> > +void lro_flush_pkt(struct net_lro_mgr *lro_mgr,
> > +		   struct iphdr *iph, struct tcphdr *tcph);

> In particular this bit looks like it should be driven by a timeout,
> which would be settable via /proc/sys/net/core/lro_timeout or similar=
=2E

No, this function is needed for "page mode" as some HW provides
extra handling for small packets where packets are not stored in preall=
ocated=20
pages but in extra queues. Thus the driver needs a way to flush old ses=
sions
for this connection and handle these packets in a different way (for ex=
ample=20
create a SKB and copy the data there).

Timeouts are not used at all. Experiments showed that flushing at the e=
nd=20
of a NAPI poll round seems to be sufficient (see Andrew's test results)
and does not affect the latency too badly.

Regards,
Jan-Bernd
