From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Tue, 22 Sep 2015 23:39:37 -0500
Message-ID: <87zj0d92ba.fsf@x220.int.ebiederm.org>
References: <cover.1442936392.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:42076 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbbIWErS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 00:47:18 -0400
In-Reply-To: <cover.1442936392.git.jbenc@redhat.com> (Jiri Benc's message of
	"Tue, 22 Sep 2015 18:12:10 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Benc <jbenc@redhat.com> writes:

> One of the selling points of lwtunnel was the ability to specify the tunnel
> destination using routes. However, this doesn't really work currently, as
> ARP and ndisc replies are not handled correctly. ARP and ndisc replies won't
> have tunnel metadata attached, thus they will be sent out with the default
> parameters or not sent at all, either way never reaching the requester.
>
> Most of the egress tunnel parameters can be inferred from the ingress
> metada. The only and important exception is UDP ports. This patchset infers
> the egress data from the ingress data and disallow settings of UDP ports in
> tunnel routes. If there's a need for different UDP ports, a new interface
> needs to be created for each port combination. Note that it's still possible
> to specify the UDP ports to use, it just needs to be done while creating the
> vxlan/geneve interface.
>
> This covers only ARPs. IPv6 ndisc has the same problem but is harder to
> solve, as there's already dst attached to outgoing skbs. Ideas to solve this
> are welcome.

What distinguishes a skb received from a tunnel as opposed to a skb
received on from a network device is that a skb recevied on a tunnel
has a socket.

I could be easily missing something but couldn't you look at skb->sk
on the input path and if a socket is present use the socket to compute
the outgoing route?

I expect it would just need to be something like:
dst = sk_dst_check(sk, 0);

Eric

> Jiri Benc (2):
>   ipv4: send arp replies to the correct tunnel
>   lwtunnel: remove source and destination UDP port config option
>
>  include/net/ip_tunnels.h      |  2 ++
>  include/uapi/linux/lwtunnel.h |  4 ----
>  net/ipv4/arp.c                | 39 ++++++++++++++++++++------------
>  net/ipv4/ip_tunnel_core.c     | 52 +++++++++++++++++++++++--------------------
>  4 files changed, 55 insertions(+), 42 deletions(-)
