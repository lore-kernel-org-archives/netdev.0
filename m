From: Hangbin Liu <haliu@redhat.com>
Subject: Re: [PATCH net] ip6_tunnel: remove unreachable ICMP_REDIRECT code
Date: Tue, 9 May 2017 21:09:07 +0800
Message-ID: <20170509130907.GA20757@leo.usersys.redhat.com>
References: <1494241863-32549-1-git-send-email-liuhangbin@gmail.com>
 <CAM_iQpWAdKve_ZxG3n+uoz_We65RV95CaKydPFYobo+pQWvjjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34136 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753872AbdEINJM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 09:09:12 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpWAdKve_ZxG3n+uoz_We65RV95CaKydPFYobo+pQWvjjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 08, 2017 at 01:26:48PM -0700, Cong Wang wrote:
> On Mon, May 8, 2017 at 4:11 AM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> > After call ip6_tnl_err(), the rel_type will be ether ICMPV6_DEST_UNREACH
> > or ICMPV6_PKT_TOOBIG. We will never reach ICMP_REDIRECT. So remove it.
> 
> Are you sure we really don't need to handle NDISC_REDIRECT here?

Hi Cong,

I have no intend to remove any handler if we need it.

Just from the code path, after call ip6_tnl_err() without error, the rel_type
will be set to either ICMPV6_DEST_UNREACH or ICMPV6_PKT_TOOBIG. Which mean the
NDISC_REDIRECT check will never be reached. That's the reason I removed it.

So if we still want to handle it, I think we need a check in ip6_tnl_err().

Please correct me if I missed anything. You know I'm a fresher here.
> 
> I can't find anything in RFC 2473 explictly, but I am feeling we should handle
> it rather than ignoring it according to:
> 
>    To report a problem detected inside the tunnel to the source of an
>    original packet, the tunnel entry point node must relay the ICMP
>    message received from inside the tunnel to the source of that
>    original IPv6 packet.


As I understand, the problem is detected inside the tunnel and should
reply to the source of original packet.

In section 8.1 Tunnel ICMP Messages

The tunnel ICMP messages that are reported to the source of the
original packet are:
hop limit exceeded
unreachable node
parameter problem
packet too big

Also what I understand that a redirect msg may happen looks like

A: Original Packet Source Node
B: Tunnel Entry-Point Node
C: Tunnel Exit-Point Node
D: Original Packet Destination Node

A   --  B  -- Node 1 -- C -- D
           \- Node 2 -/

When B send msg to C, there may have a redirect from Node 1 to B, which
should be a ICMP error inside the tunnel. Not tunnel entry point to original
souce.


Or looks like

A: Original Packet Source Node
BE: Tunnel Entry-Point Node
CF: Tunnel Exit-Point Node
D: Original Packet Destination Node

A  --  B  --  C  --  D
   \-  E  --  F  -/

When A send pkt to D, and B reply a redirect msg to A. But I think this
problem is not detected _inside_ tunnel.

Thanks
Hangbin
