From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 2/4] ip_tunnels: record IP version in tunnel info
Date: Fri, 28 Aug 2015 10:32:15 -0700
Message-ID: <CALnjE+og0n18p6_BwHfUudHDLPA5_WtT2TmqCM+FhGFtzj+FKg@mail.gmail.com>
References: <cover.1440771116.git.jbenc@redhat.com>
	<224503f4a3232da1664f1eca58b7bce87cfb3cc2.1440771116.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35634 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643AbbH1RcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 13:32:16 -0400
Received: by ioed140 with SMTP id d140so13205304ioe.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 10:32:15 -0700 (PDT)
In-Reply-To: <224503f4a3232da1664f1eca58b7bce87cfb3cc2.1440771116.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 28, 2015 at 7:27 AM, Jiri Benc <jbenc@redhat.com> wrote:
> There's currently nothing preventing directing packets with IPv6
> encapsulation data to IPv4 tunnels (and vice versa). If this happens,
> IPv6 addresses are incorrectly interpreted as IPv4 ones.
>
> Track whether the given ip_tunnel_key contains IPv4 or IPv6 data. Store this
> in ip_tunnel_info. Reject packets at appropriate places if they are supposed
> to be encapsulated into an incompatible protocol.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  drivers/net/geneve.c       |  3 +++
>  drivers/net/vxlan.c        |  2 ++
>  include/net/dst_metadata.h |  1 +
>  include/net/ip_tunnels.h   | 10 ++++++++++
>  net/core/filter.c          |  2 ++
>  net/ipv4/ip_gre.c          |  3 ++-
>  net/ipv4/ip_tunnel_core.c  |  2 +-
>  net/openvswitch/flow.c     |  2 ++
>  net/openvswitch/vport.c    |  2 ++
>  9 files changed, 25 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 4357bae732d7..d4882d7904f6 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -644,6 +644,9 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
>                 u8 *opts = NULL;
>                 u8 vni[3];
>
> +               if (ip_tunnel_info_af(info) != AF_INET)
> +                       goto err;
> +
geneve_get_rt() already interpreted the info as ipv4 tunnel info.

We can avoid such bugs by introducing separate API to retrieve ipv4
and ipv6 tunnel info. Something like
skb_tunnel_info_v4()/skb_tunnel_info_v6() for ipv4 and ipv6.
