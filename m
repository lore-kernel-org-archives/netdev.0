From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2] openvswitch: Allocate memory for ovs internal
 device stats.
Date: Fri, 16 Oct 2015 12:20:29 -0700
Message-ID: <CALnjE+qqB1rJSy6XmGjSAjHHDNwL=x3rc0RK-D259ru1LfNGTA@mail.gmail.com>
References: <1444993620-19562-1-git-send-email-james.morse@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: James Morse <james.morse@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:32877 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbbJPTU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 15:20:29 -0400
Received: by igbkq10 with SMTP id kq10so20511187igb.0
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 12:20:29 -0700 (PDT)
In-Reply-To: <1444993620-19562-1-git-send-email-james.morse@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2015 at 4:07 AM, James Morse <james.morse@arm.com> wrote:
> "openvswitch: Remove vport stats" removed the per-vport statistics, in
> order to use the netdev's statistics fields.
> "openvswitch: Fix ovs_vport_get_stats()" fixed the export of these stats
> to user-space, by using the provided netdev_ops to collate them - but ovs
> internal devices still use an unallocated dev->tstats field to count
> packets, which are no longer exported by this api.
>
> Allocate the dev->tstats field for ovs internal devices, and wire up
> ndo_get_stats64 with the original implementation of
> ovs_vport_get_stats().
>
> On its own, "openvswitch: Fix ovs_vport_get_stats()" fixes the OOPs,
> unmasking a full-on panic on arm64:
> =============%<==============
> [<ffffffbffc00ce4c>] internal_dev_recv+0xa8/0x170 [openvswitch]
> [<ffffffbffc0008b4>] do_output.isra.31+0x60/0x19c [openvswitch]
> [<ffffffbffc000bf8>] do_execute_actions+0x208/0x11c0 [openvswitch]
> [<ffffffbffc001c78>] ovs_execute_actions+0xc8/0x238 [openvswitch]
> [<ffffffbffc003dfc>] ovs_packet_cmd_execute+0x21c/0x288 [openvswitch]
> [<ffffffc0005e8c5c>] genl_family_rcv_msg+0x1b0/0x310
> [<ffffffc0005e8e60>] genl_rcv_msg+0xa4/0xe4
> [<ffffffc0005e7ddc>] netlink_rcv_skb+0xb0/0xdc
> [<ffffffc0005e8a94>] genl_rcv+0x38/0x50
> [<ffffffc0005e76c0>] netlink_unicast+0x164/0x210
> [<ffffffc0005e7b70>] netlink_sendmsg+0x304/0x368
> [<ffffffc0005a21c0>] sock_sendmsg+0x30/0x4c
> [SNIP]
> Kernel panic - not syncing: Fatal exception in interrupt
> =============%<==============
>
> Fixes: 8c876639c985 ("openvswitch: Remove vport stats.")
> Signed-off-by: James Morse <james.morse@arm.com>
>
> ---
> Hi netdev,
>
> "openvswitch: Fix ovs_vport_get_stats()" [0], is an incomplete fix for the
> issue in "openvswitch: Remove vport stats.". Use of an unallocated
> dev->tstats remains for ovs internal devices, which causes a panic on arm64.
>
> Change since v1:
> * Removed superfluous rx/tx_dropped increment, already done by dev_get_stats().
>
> Thanks!
>
> James Morse
>
> [0] https://patchwork.ozlabs.org/patch/525827/
>
>  net/openvswitch/vport-internal_dev.c | 40 +++++++++++++++++++++++++++++++++++-
>  1 file changed, 39 insertions(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
> index 388b8a6bf112..957fe715b544 100644
> --- a/net/openvswitch/vport-internal_dev.c
> +++ b/net/openvswitch/vport-internal_dev.c
> @@ -106,12 +106,45 @@ static void internal_dev_destructor(struct net_device *dev)
>         free_netdev(dev);
>  }
>
...

>  static const struct net_device_ops internal_dev_netdev_ops = {
>         .ndo_open = internal_dev_open,
>         .ndo_stop = internal_dev_stop,
>         .ndo_start_xmit = internal_dev_xmit,
>         .ndo_set_mac_address = eth_mac_addr,
>         .ndo_change_mtu = internal_dev_change_mtu,
> +       .ndo_get_stats64 = internal_get_stats,
>  };
>
>  static struct rtnl_link_ops internal_dev_link_ops __read_mostly = {
> @@ -161,6 +194,11 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
>                 err = -ENOMEM;
>                 goto error_free_vport;
>         }
> +       vport->dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
> +       if (!vport->dev->tstats) {
> +               err = -ENOMEM;
> +               goto error_free_vport;
> +       }
>
Exception handling code is not correct, needs to free netdev here.
