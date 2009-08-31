From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Mon, 31 Aug 2009 14:09:50 +0200
Message-ID: <4A9BBD8E.2010303@gmail.com>
References: <4A97F2B4.7030900@gmail.com>	<alpine.DEB.1.10.0908281211150.7317@gentwo.org>	<4A98132C.8090105@gmail.com> <20090828.233858.256193304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cl@linux-foundation.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com,
	mtk.manpages@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44461 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbZHaMJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 08:09:56 -0400
In-Reply-To: <20090828.233858.256193304.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 28 Aug 2009 19:26:04 +0200
>=20
>> [PATCH] ip: Report qdisc packet drops
>>
>> Christoph Lameter pointed out that packet drops at qdisc level where=
 not
>> accounted in SNMP counters. Only if application sets IP_RECVERR, dro=
ps
>> are reported to user and SNMP counters updated.
>>
>> IP_RECVERR is used to enable extended reliable error message passing=
=2E
>> In case of tx drops at qdisc level, no error packet will be generate=
d.
>> It seems un-necessary to hide the qdisc drops for non IP_RECVERR ena=
bled
>> sockets (as probably most sockets are)
>>
>> By removing the check of IP_RECVERR enabled sockets in ip_push_pendi=
ng_frames()/
>> raw_send_hdrinc() / ip6_push_pending_frames() / rawv6_send_hdrinc(),
>> we can properly update IPSTATS_MIB_OUTDISCARDS, and in case of UDP, =
update
>> UDP_MIB_SNDBUFERRORS SNMP counters.
>>
>> Application send() syscalls, instead of returning an OK status (thus=
 lying),
>> will return -ENOBUFS error.
>>
>> Note : send() manual page explicitly says for -ENOBUFS error :
>>
>>  "The output queue for a network interface was full.
>>   This generally indicates that the interface has stopped sending,
>>   but may be caused by transient congestion.
>>   (Normally, this does not occur in Linux. Packets are just silently
>>   dropped when a device queue overflows.) "
>>
>> This was not true for IP_RECVERR enabled sockets for < 2.6.32 linuxe=
s,
>> and starting from linux 2.6.32, last part wont be true at all.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
>=20
> The core question in all of this is what IP_RECVERR means.
>=20
> As far as I remember Alexey Kuznetsov's intentions, it means that the
> application is interested in learning about errors caused by the
> infrastructure of the network between local and remote stacks.
>=20
> Reporting a qdisc level drop to the application by default has the
> potential to break applications, because BSD and other stacks do not
> do this.
>=20
> I can see why we might be able to get away with making this change
> now.  And I also can see the benefits of it, for sure.
>=20
> Let me think about this some more.

Yes I do agree this is risky.

Re-reading again this stuff, I realized ip6_push_pending_frames()
was not updating IPSTATS_MIB_OUTDISCARDS, even if IP_RECVERR was set.

May I suggest following path :

1) Correct ip6_push_pending_frames() to properly
account for dropped-by-qdisc frames when IP_RECVERR is set

2) Submit a patch to account for qdisc-dropped frames in SNMP counters
but still return a OK to user application, to not break them ?

Thanks

[PATCH] ipv6: ip6_push_pending_frames() should increment IPSTATS_MIB_OU=
TDISCARDS

qdisc drops should be notified to IP_RECVERR enabled sockets, as done i=
n IPV4.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6ad5aad..a931229 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1520,6 +1520,7 @@ out:
 	ip6_cork_release(inet, np);
 	return err;
 error:
+	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	goto out;
 }
=20
