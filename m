From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with no
 group
Date: Wed, 19 Mar 2014 08:08:14 -0600
Message-ID: <OF55200AFE.3F917127-ON87257CA0.004DA877-87257CA0.004DA87C@us.ibm.com>
References: <CAF1J0HOTLvyaWdmYLGLPn9AJLR6rQr4fk8EVFSzv5sckLuBwvw@mail.gmail.com>,
	<1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>	<OFEB1030F8.C147FA77-ON87257C9F.005CF370-87257C9F.005CF375@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:58385 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964992AbaCSOIR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 10:08:17 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 19 Mar 2014 08:08:17 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2027D19D8040
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 08:08:12 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2JE7g0a58130520
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 15:07:42 +0100
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2JE8EA4005437
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 08:08:14 -0600
In-Reply-To: <CAF1J0HOTLvyaWdmYLGLPn9AJLR6rQr4fk8EVFSzv5sckLuBwvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Mike Rapoport <mike.rapoport@ravellosystems.com> wrote: -----

>To: David Stevens/Beaverton/IBM@IBMUS
>From: Mike Rapoport <mike.rapoport@ravellosystems.com>
,,,
>However, for the particular case in vxlan_rcv, checking the packet
>version seems to me semantically more correct than comparing
>default_dst
>protocol family with AF_INET or AF_INET6.

No, that's saying that the sender should determine whether
you are using IPv4 or IPv6, but when the localhost is the
sender, it'll only be using one of those.

If the default_dst is an IPv4 group address, ordinary VXLAN
wouldn't interoperate with IPv6 because the group is not an IPv6
group, but with your patch, it'll still receive and accept IPv6-encapsu=
lated
packets. It just wouldn't send any, if all the fdb entries are also v4.

I think neither the receive packets nor the default_dst, which may
not be set, is the right way to determine this. vxlan_dev->saddr
makes more sense, but it, too, doesn't have to be set.

I'd suggest:
1) if vxlan_dev->saddr is set, use that. Any packets sent should use
=A0 =A0 =A0 =A0 =A0 this saddr, if set, so that determines the underlay=
 address family
=A0 =A0 =A0 =A0 =A0 and so also what IP version you'll receive.
2) if vxlan_dev->saddr is not set, and default_dst is a multicast group=
,
=A0 =A0 =A0 =A0 =A0 use that address family. For ordinary VXLAN, the gr=
oup is used
=A0 =A0 =A0 =A0 =A0 by all participants so it can't mix v4 and v6. Also=
, if saddr is set
=A0 =A0 =A0 =A0 =A0 and default_dst is a multicast group, the address f=
amily should
=A0 =A0 =A0 =A0 =A0 match.
3) if neither of those is set, then it isn't ordinary VXLAN, but rather=
 a
=A0 =A0 =A0 =A0 =A0custom configuration. In that case, we should allow =
both, by
=A0 =A0 =A0 =A0 =A0default, at least. fdb entries can use both v4 and v=
6, so we
=A0 =A0 =A0 =A0 =A0should receive both.

We could also (or instead) add flags to explicitly allow or disallow v4=
 and/or v6,
and then, of course, enforce those flag settings for saddr, default_dst
and fdb entries, too.

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 +-DLS
