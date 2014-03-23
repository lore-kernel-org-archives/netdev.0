From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Sun, 23 Mar 2014 11:27:22 +0200
Message-ID: <CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<20140320.160229.857536522237793124.davem@davemloft.net>
	<OFA209BE80.4610C3E5-ON87257CA1.00723468-87257CA1.0072346C@us.ibm.com>
	<CAF1J0HPE9L1Z4xst9ap_Z8nQ9k-N-UAbW7yre0S-wvQF5+NznA@mail.gmail.com>
	<OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:41278 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbaCWJ1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 05:27:23 -0400
Received: by mail-oa0-f47.google.com with SMTP id i11so4507608oag.34
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 02:27:23 -0700 (PDT)
In-Reply-To: <OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2014 at 05:22:06AM -0600, David Stevens wrote:
> -----Mike Rapoport <mike.rapoport@ravellosystems.com> wrote: -----
>
> >Checking skb->protocol will drop ARP requests. What about using
> >ip_hdr(skb)->version?
>
> Mike, ip_hdr() here is the outer packet, so it's got to be a UDP packet--
> we just don't know if it's UDP/IP or UDP/IPv6 when it is bound to INADDR_ANY,
> since both can be delivered. It could use version in this case, because
> both possible protocols have version in the same place, but I think it's
> more correct to use the MAC layer protocol rather than relying on the
> fact that IPv4 and IPv6 have "version" in the same spot. "It could be ARP"
> would be the argument for NOT using the version in places where it really
> could be ARP, even though that isn't the case here.
>
> vxlan_rcv() is only called for VXLAN encapsulated packets sent to the bound
> UDP port.
>
> So, if "vs->family" holds the one we want to support, we can't just blindly
> assume the received packet is IPv4, for example, and start accessing
> IPv4 fields, because it could be an IPv6 packet. We have to check the
> packet type too. And if it's not the one we bound to, drop it.
>
> That's what the code snippet I outlined is trying to do.
>
>                                          +-DLS
>

I beleive I've groked what's going on in vxlan_udp_encap_recv and
vxlan_rcv. There are actually two unrelated problems:

1) When the vxlan is configured with IPv4 group it crashes when it
starts to receive IPv6 IGMP packets encapsulated into IPv4 vxlan
packets. This happens because when ipv6_rcv handles the inner packet,
the skb->dst still refernces outer IPv4 info. The very old vxlan code
had skb_dst_drop call in vxlan_udp_encap_recv, which was removed when
vxlan was refactored to use iptunnel_pull_header (commit
7ce04758279514ca1d8ebfe322508a4a430fe2c8: "vxlan: Restructure vxlan
receive"). The iptunnel_pull_header called skb_dst_drop until recent
commit 10ddceb22bab11dab10ba645c7df2e4a8e7a5db5 ("ip_tunnel:multicast
process cause panic due to skb->_skb_refdst NULL pointer").
The simplest fix, I think, would be to restore call to skb_dst_drop in
vxlan_udp_encap_recv.

2) When the vxlan is using custom configuration and the vxlan interface
is created without group definition, the vxlan_rcv always takes IPv6
path because the decision is based on default_dst.sa.sa_family which is
AF_UNSPEC in this case. The code snippet proposed by David S. is not
working because by the time vxlan_rcv checks the outer protocol the
skb->protocol is already set to that of the inner packet in
iptunnel_pull_header. So, to have proper check for packet type in
vxlan_rcv we can either check outer IP header version or pass outer
skb->protocol to vxlan_rcv.
I personally favor checking ip_hdr(skb)->version despite David S.
objection above. The version field is not coincidentally at the same
spot for both v4 and v6, and check for version keeps code simpler and
cleaner, IMHO.

Waiting for your comments,

Mike.

--
[1] http://www.spinics.net/lists/netdev/msg276490.html
