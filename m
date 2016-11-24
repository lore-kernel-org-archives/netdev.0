From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 0/2] tc/cls_flower: Support for ip tunnel
 metadata set/release/classify
Date: Thu, 24 Nov 2016 14:38:56 +0100
Message-ID: <20161124143856.43fa54d6@griffin>
References: <20161121102056.13468-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32940 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936137AbcKXNjB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 08:39:01 -0500
In-Reply-To: <20161121102056.13468-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Nov 2016 12:20:54 +0200, Amir Vadai wrote:
> $ tc filter add dev vxlan0 protocol ip parent ffff: \
>     flower \
>       enc_src_ip 11.11.0.2 \
>       enc_dst_ip 11.11.0.1 \
>       enc_key_id 11 \
>       dst_ip 11.11.11.1 \
>     action tunnel_key release \
>     action mirred egress redirect dev vnet0

I really hate the "action tunnel_key release". This just exposes the
kernel internal implementation detail (dst_metadata) to the user. Why
should the user care about explicit releasing of the tunnel key? This
should happen automatically. Users do not care about our internal
implementation.

> $ tc filter add dev net0 protocol ip parent ffff: \
>     flower \
>       ip_proto 1 \
>       dst_ip 11.11.11.2 \
>     action tunnel_key set \
>       src_ip 11.11.0.1 \
>       dst_ip 11.11.0.2 \
>       id 11 \
>     action mirred egress redirect dev vxlan0

Do you see the asymmetry? This is not called "alloc tunnel_key", and
rightly so. It's very reasonable to call this "set", as it is what the
action looks like to the user.

The only argument for the existence of an explicit "release" (we should
rather call it "unset" in such case, though) is forwarding between two
tunnels, where metadata from the first tunnel will be used for
encapsulation done by the second tunnel. Or a similar case when there's
classification based on the tunnel metadata done on the mirred
interface. Somewhat corner cases, though. If we want to support them,
then let's call the action "unset" and not "release". And in any case,
it should not be mandatory to specify it, which should be made clear
in the documentation (including examples where it is needed - basically
only when forwarding between tunnels).

 Jiri
