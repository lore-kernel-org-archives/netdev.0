From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Thu, 18 Aug 2016 10:18:00 -0600
Message-ID: <1191bc4f-fca3-1f41-0f65-2cb5581f3582@cumulusnetworks.com>
References: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com>
 <1471470587-24813-3-git-send-email-dsa@cumulusnetworks.com>
 <CAKgT0UfmWpeNsjH+dtYewiVSuxapck2zyczJGP7WvE30irJcmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Lennert Buytenhek <buytenh@wantstofly.org>,
        Simon Horman <simon.horman@netronome.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
        Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        olivier.dugeon@orange.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35389 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753890AbcHSAwg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 20:52:36 -0400
Received: by mail-it0-f41.google.com with SMTP id x131so14116688ite.0
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 17:51:59 -0700 (PDT)
In-Reply-To: <CAKgT0UfmWpeNsjH+dtYewiVSuxapck2zyczJGP7WvE30irJcmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/16 8:37 AM, Alexander Duyck wrote:
> Thought I would go through and do a second pass since it sounds like
> the inner_mac_header idea isn't going to fly.  If we can't push this
> as an L2 encapsulation there are few tweaks we probably need in order
> to make this work as an L3.  I have included comments inline below.
> 
> Also I haven't worked with MPLS much before.  Is there a simple way to
> setup an MPLS tunnel between two hosts connected back to back so that
> I could try testing a few things related to this patch?

Here commands that I use for VMs - copy and paste. It is an adaptation of Lennert's namespace script. VM id's are local to my host. Network addresses are 10.100.1.x/24 and 2100:1::x/120 on eth1 of the respective node. Includes MPLS encap, IP-IP encap and none to compare performances.

VM2
===
modprobe mpls_router
modprobe mpls_gso
modprobe mpls_iptunnel

sysctl -w net.mpls.platform_labels=1000
ip route add 10.10.10.10/32 encap mpls 100 via inet 10.100.1.3
ip -6 route add 3000:1::1/128 encap mpls 101 via inet6 2100:1::3

ip tunnel add tun0 mode ipip remote 10.100.1.3
ip link set dev tun0 up
ip route add 10.10.10.11/32 dev tun0

ip route add 10.10.10.12/32 via inet 10.100.1.3
ip -6 route add 3000:1::3/128 via inet6 2100:1::3


VM3
===
modprobe mpls_router
modprobe mpls_gso
modprobe mpls_iptunnel

sysctl -w net.mpls.conf.eth1.input=1
sysctl -w net.mpls.platform_labels=1000
ip -f mpls route add 100 via inet 10.100.2.4
ip -f mpls route add 101 via inet6 2100:2::4

ip tunnel add tun0 mode ipip remote 10.100.1.2
ip link set dev tun0 up
ip ro add 10.10.10.11/32 via 10.100.2.4

ip ro add 10.10.10.12/32 via 10.100.2.4
ip -6 route add 3000:1::3/128 via inet6 2100:2::4


VM4
===
ip addr add 10.10.10.10/32 dev lo
ip addr add 10.10.10.11/32 dev lo
ip addr add 10.10.10.12/32 dev lo

ip -6 addr add 3000:1::1/128 dev lo
ip -6 addr add 3000:1::2/128 dev lo
ip -6 addr add 3000:1::3/128 dev lo

netserver


Go back to VM2:

ping -c 1 10.10.10.10
ping -c 1 10.10.10.11
ping -c 1 10.10.10.12

netperf -c -C -H 10.10.10.10  -l 10 -t TCP_STREAM
netperf -c -C -H 10.10.10.11  -l 10 -t TCP_STREAM
netperf -c -C -H 10.10.10.12  -l 10 -t TCP_STREAM


I'll take a look at your other comments today.
