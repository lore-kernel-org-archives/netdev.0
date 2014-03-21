From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with no
 group
Date: Fri, 21 Mar 2014 05:22:06 -0600
Message-ID: <OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
References: <CAF1J0HPE9L1Z4xst9ap_Z8nQ9k-N-UAbW7yre0S-wvQF5+NznA@mail.gmail.com>,
	<1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>	<20140320.160229.857536522237793124.davem@davemloft.net>
	<OFA209BE80.4610C3E5-ON87257CA1.00723468-87257CA1.0072346C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:35146 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759943AbaCULWL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 07:22:11 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 21 Mar 2014 05:22:11 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 32CAB3E40026
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 05:22:08 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2LBLY394719040
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 12:21:34 +0100
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2LBM7o0012802
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 05:22:07 -0600
In-Reply-To: <CAF1J0HPE9L1Z4xst9ap_Z8nQ9k-N-UAbW7yre0S-wvQF5+NznA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Mike Rapoport <mike.rapoport@ravellosystems.com> wrote: -----


>Checking skb->protocol will drop ARP requests. What about using
>ip_hdr(skb)->version?

Mike, ip_hdr() here is the outer packet, so it's got to be a UDP packet=
--
we just don't know if it's UDP/IP or UDP/IPv6 when it is bound to INADD=
R_ANY,
since both can be delivered. It could use version in this case, because
both possible protocols have version in the same place, but I think it'=
s
more correct to use the MAC layer protocol rather than relying on the
fact that IPv4 and IPv6 have "version" in the same spot. "It could be A=
RP"
would be the argument for NOT using the version in places where it real=
ly
could be ARP, even though that isn't the case here.

vxlan_rcv() is only called for VXLAN encapsulated packets sent to the b=
ound
UDP port.

So, if "vs->family" holds the one we want to support, we can't just bli=
ndly
assume the received packet is IPv4, for example, and start accessing
IPv4 fields, because it could be an IPv6 packet. We have to check the
packet type too. And if it's not the one we bound to, drop it.

That's what the code snippet I outlined is trying to do.

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0+-DLS
