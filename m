From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Sun, 23 Mar 2014 22:09:33 -0700
Message-ID: <CALnjE+r9kXBjpDdm07pbo6NSd37sgJzn9S8d7KZ188Zdmoc6Ng@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<20140320.160229.857536522237793124.davem@davemloft.net>
	<OFA209BE80.4610C3E5-ON87257CA1.00723468-87257CA1.0072346C@us.ibm.com>
	<CAF1J0HPE9L1Z4xst9ap_Z8nQ9k-N-UAbW7yre0S-wvQF5+NznA@mail.gmail.com>
	<OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
	<CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:34357 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750760AbaCXFJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 01:09:34 -0400
Received: by mail-ve0-f178.google.com with SMTP id jw12so5105223veb.37
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 22:09:34 -0700 (PDT)
In-Reply-To: <CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 23, 2014 at 2:27 AM, Mike Rapoport
<mike.rapoport@ravellosystems.com> wrote:
> On Fri, Mar 21, 2014 at 05:22:06AM -0600, David Stevens wrote:
>> -----Mike Rapoport <mike.rapoport@ravellosystems.com> wrote: -----
>>
>> >Checking skb->protocol will drop ARP requests. What about using
>> >ip_hdr(skb)->version?
>>
>> Mike, ip_hdr() here is the outer packet, so it's got to be a UDP packet--
>> we just don't know if it's UDP/IP or UDP/IPv6 when it is bound to INADDR_ANY,
>> since both can be delivered. It could use version in this case, because
>> both possible protocols have version in the same place, but I think it's
>> more correct to use the MAC layer protocol rather than relying on the
>> fact that IPv4 and IPv6 have "version" in the same spot. "It could be ARP"
>> would be the argument for NOT using the version in places where it really
>> could be ARP, even though that isn't the case here.
>>
>> vxlan_rcv() is only called for VXLAN encapsulated packets sent to the bound
>> UDP port.
>>
>> So, if "vs->family" holds the one we want to support, we can't just blindly
>> assume the received packet is IPv4, for example, and start accessing
>> IPv4 fields, because it could be an IPv6 packet. We have to check the
>> packet type too. And if it's not the one we bound to, drop it.
>>
>> That's what the code snippet I outlined is trying to do.
>>
>>                                          +-DLS
>>
>
> I beleive I've groked what's going on in vxlan_udp_encap_recv and
> vxlan_rcv. There are actually two unrelated problems:
>
> 1) When the vxlan is configured with IPv4 group it crashes when it
> starts to receive IPv6 IGMP packets encapsulated into IPv4 vxlan
> packets. This happens because when ipv6_rcv handles the inner packet,
> the skb->dst still refernces outer IPv4 info. The very old vxlan code
> had skb_dst_drop call in vxlan_udp_encap_recv, which was removed when
> vxlan was refactored to use iptunnel_pull_header (commit
> 7ce04758279514ca1d8ebfe322508a4a430fe2c8: "vxlan: Restructure vxlan
> receive"). The iptunnel_pull_header called skb_dst_drop until recent
> commit 10ddceb22bab11dab10ba645c7df2e4a8e7a5db5 ("ip_tunnel:multicast
> process cause panic due to skb->_skb_refdst NULL pointer").
> The simplest fix, I think, would be to restore call to skb_dst_drop in
> vxlan_udp_encap_recv.
>
iptunnel_pull() is used in multiple tunnel implementation, therefore
we need drop dst in that function.
I send out fix : http://marc.info/?l=linux-netdev&m=139563761515707
