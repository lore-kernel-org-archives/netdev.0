From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with no
 group
Date: Thu, 20 Mar 2014 14:47:25 -0600
Message-ID: <OFA209BE80.4610C3E5-ON87257CA1.00723468-87257CA1.0072346C@us.ibm.com>
References: <20140320.160229.857536522237793124.davem@davemloft.net>,
	<1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mike.rapoport@ravellosystems.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:51152 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932328AbaCTUra convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:47:30 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 20 Mar 2014 14:47:30 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A31D33E40026
	for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 14:47:27 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2KKkjpk3997972
	for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 21:46:45 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2KKlQcA010262
	for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 14:47:27 -0600
In-Reply-To: <20140320.160229.857536522237793124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>From: David Miller=20

>Any objections to this? I think it maintains the pre-ipv6-support
>behavior. I know there may be some concerns about supporting
>multiple
>families on the same socket, but I'm not so sure the code is able to
>support that right now anyways.

I'm ok with the idea of determining the AF from the socket -- mixed
support, if useful, can be added later. But the patch needs to then
check and drop packets encapsulated with the wrong address family.

And it still shouldn't assume !v4 means v6.

[apologies for spacing; doing this from a web browser...]
So, I think we need something like:

=A0 =A0 =A0if (vs->family =3D=3D AF_INET && skb->protocol =3D=3D ntohs(=
ETH_P_IP)) {
=A0 =A0 =A0 =A0 ....
=A0 =A0 =A0} else if (vs->family =3D=3D AF_INET6 && skb->protocol =3D=3D=
 ntohs(ETH_P_IPV6)) {
=A0 =A0 =A0 =A0 ...
=A0 =A0 =A0} else
=A0 =A0 =A0 =A0 =A0 =A0goto drop


=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 +-DLS
