From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next] bridge: ability to disable forwarding on a port
Date: Sat, 17 Jan 2015 17:05:08 -0800
Message-ID: <CAE4R7bBeNojtj3Zyd6+zSJFGRjG4vejBObnS1XUFAfJDZJZYow@mail.gmail.com>
References: <1421479975-62049-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Wilson Kok <wkok@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:50382 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbbARBFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 20:05:10 -0500
Received: by mail-wg0-f43.google.com with SMTP id k14so26250837wgh.2
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2015 17:05:08 -0800 (PST)
In-Reply-To: <1421479975-62049-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2015 at 11:32 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> On a Linux bridge with bridge forwarding offloaded to a switch ASIC,
> there is a need to not re-forward the frames that come up to the
> kernel in software.
>
> Typically these are broadcast or multicast packets forwarded by the
> hardware to multiple destination ports including sending a copy of
> the packet to the kernel (e.g. an arp broadcast).
> The bridge driver will try to forward the packet again, resulting in
> two copies of the same packet.
>
> These packets can also come up to the kernel for logging when they hit
> a LOG acl in hardware.
>
> This patch makes forwarding a flag on the port similar to
> learn and flood and drops the packet just before forwarding.
> (The forwarding disable on a bridge is tested to work on our boxes.
> The bridge port flag addition is only compile tested.
> This will need to be further refined to cover cases where a non-switch port
> is bridged to a switch port etc. We will submit more patches to cover
> all cases if we agree on this approach).

Good topic to bring up, thanks for proposing a patch.  There is indeed
duplicate pkts sent out in the case where both the bridge and the
offloaded device are flooding these non-unicast pkts, such as ARP
requests.  We do have per-port control today over unicast flooding
using BR_FLOOD (IFLA_BRPORT_UNICAST_FLOOD).

As you point out, this doesn't solve the case for non-offloaded ports
bridged with switch ports.  If this port setting is enabled on an
offloaded switch port, for example, the non-offloaded port can't get
an ARP request resolved, if the MAC is behind the offloaded switch
port.  But do we care?  Is there a use-case for this one, mixing
offloaded and non-offloaded ports in a bridge?

>
> Other ways to solve the same problem could be to:
> - use the offload feature flag on these switch ports to avoid the
> re-forward:
> https://www.marc.info/?l=linux-netdev&m=141820235010603&w=2
>
> - Or the switch driver can mark or set a flag in the skb, which the bridge
> driver can use to avoid a re-forward.
>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  include/linux/if_bridge.h    |    3 ++-
>  include/uapi/linux/if_link.h |    1 +
>  net/bridge/br_forward.c      |   13 +++++++++++++
>  net/bridge/br_if.c           |    2 +-
>  net/bridge/br_netlink.c      |    4 +++-
>  net/bridge/br_sysfs_if.c     |    1 +
>  net/core/rtnetlink.c         |    4 +++-
>  7 files changed, 24 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
> index 0a8ce76..c79f4eb 100644
> --- a/include/linux/if_bridge.h
> +++ b/include/linux/if_bridge.h
> @@ -40,10 +40,11 @@ struct br_ip_list {
>  #define BR_ADMIN_COST          BIT(4)
>  #define BR_LEARNING            BIT(5)
>  #define BR_FLOOD               BIT(6)
> -#define BR_AUTO_MASK           (BR_FLOOD | BR_LEARNING)
>  #define BR_PROMISC             BIT(7)
>  #define BR_PROXYARP            BIT(8)
>  #define BR_LEARNING_SYNC       BIT(9)
> +#define BR_FORWARD             BIT(10)

The name BR_FORWARD might confuse people thinking this is related to
STP FORWARDING state.  We have BR_FLOOD for unknown unicast flooding.
How about renaming BR_FLOOD to BR_FLOOD_UNICAST and add
BR_FLOOD_BROADCAST?  So you would have:

  IFLA_BRPORT_UNICAST_FLOOD           BR_FLOOD_UNICAST        /* flood
unknown unicast traffic to port */
  IFLA_BRPORT_BROADCAST_FLOOD    BR_FLOOD_BROADCAST  /* flood
bcast/mcast traffic to port */

> +#define BR_AUTO_MASK           (BR_FLOOD | BR_LEARNING | BR_FORWARD)
>
>  extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
>
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index f7d0d2d..d394625 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -246,6 +246,7 @@ enum {
>         IFLA_BRPORT_UNICAST_FLOOD, /* flood unicast traffic */
>         IFLA_BRPORT_PROXYARP,   /* proxy ARP */
>         IFLA_BRPORT_LEARNING_SYNC, /* mac learning sync from device */
> +       IFLA_BRPORT_FORWARD,    /* enable forwarding on a device */
>         __IFLA_BRPORT_MAX
>  };
>  #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> index f96933a..98c41c8 100644
> --- a/net/bridge/br_forward.c
> +++ b/net/bridge/br_forward.c
> @@ -81,10 +81,23 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
>                 br_forward_finish);
>  }
>
> +int br_hw_forward_finish(struct sk_buff *skb)
> +{
> +       kfree_skb(skb);
> +
> +       return 0;
> +}
> +
>  static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
>  {
>         struct net_device *indev;
>
> +       if (!(to->flags & BR_FORWARD)) {
> +               NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, skb->dev, to->dev,
> +                       br_hw_forward_finish);
> +               return;
> +       }
> +

Seems you should make the (flags & BR_FORWARD) check earlier, before
skb cloning, in br_flood(), alongside the (flags & BR_FLOOD) check.

Also, the above code is skipping some vlan checks (br_handle_vlan).

-scott
