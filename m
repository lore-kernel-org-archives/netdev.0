From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [next-queue v6 PATCH 5/7] i40e: Add TX and RX
 support over port netdev's in switchdev mode
Date: Fri, 14 Apr 2017 09:47:13 -0700
Message-ID: <CAKgT0UfE5LPb1YPEQpE76JFcGg8Ja_RHaUQDch6P4icyCpsbaQ@mail.gmail.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com> <1490833375-2788-6-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35136 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbdDNQrU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 12:47:20 -0400
Received: by mail-io0-f194.google.com with SMTP id d203so17195441iof.2
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 09:47:19 -0700 (PDT)
In-Reply-To: <1490833375-2788-6-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 29, 2017 at 5:22 PM, Sridhar Samudrala
<sridhar.samudrala@intel.com> wrote:
> In switchdev mode, broadcasts from VFs are received by the PF and passed
> to corresponding port representor netdev.
> Any frames sent via port netdevs are sent as directed transmits to the
> corresponding VFs. To enable directed transmit, skb metadata dst is used
> to pass the port id and the frame is requeued to call the PFs transmit
> routine. VF id is used as port id for VFs and PF port id is defined as
> I40_MAIN_VSI_PORT_ID.
>
> Small script to demonstrate inter VF and PF to VF pings in switchdev mode.
> PF: p4p1, VFs: p4p1_0,p4p1_1 VF Port Reps:p4p1-vf0, p4p1-vf1
> PF Port rep: p4p1-pf
>
> # rmmod i40e; modprobe i40e
> # devlink dev eswitch set pci/0000:05:00.0 mode switchdev
> # echo 2 > /sys/class/net/p4p1/device/sriov_numvfs
> # ip link set p4p1 vf 0 mac 00:11:22:33:44:55
> # ip link set p4p1 vf 1 mac 00:11:22:33:44:56
> # rmmod i40evf; modprobe i40evf
>
> /* Create 2 namespaces and move the VFs to the corresponding ns */
> # ip netns add ns0
> # ip link set p4p1_0 netns ns0
> # ip netns exec ns0 ip addr add 192.168.1.10/24 dev p4p1_0
> # ip netns exec ns0 ip link set p4p1_0 up
> # ip netns add ns1
> # ip link set p4p1_1 netns ns1
> # ip netns exec ns1 ip addr add 192.168.1.11/24 dev p4p1_1
> # ip netns exec ns1 ip link set p4p1_1 up
>
> /* bring up pf and port netdevs */
> # ip addr add 192.168.1.1/24 dev p4p1
> # ip link set p4p1 up
> # ip link set p4p1-vf0 up
> # ip link set p4p1-vf1 up
> # ip link set p4p1-pf up
>
> # ip netns exec ns0 ping -c3 192.168.1.11  /* VF0 -> VF1 */
> # ip netns exec ns1 ping -c3 192.168.1.10  /* VF1 -> VF0 */
> # ping -c3 192.168.1.10   /* PF -> VF0 */
> # ping -c3 192.168.1.11   /* PF -> VF1 */
>
> /* VF0 -> IP in same subnet - broadcasts will be seen on p4p1-vf0 & p4p1 */
> # ip netns exec ns0 ping -c1 -W1 192.168.1.200
> /* VF1 -> IP in same subnet -  broadcasts will be seen on p4p1-vf1 & p4p1*/
> # ip netns exec ns0 ping -c1 -W1 192.168.1.200
> /* port rep VF0 -> IP in same subnet - broadcasts will be seen on p4p1_0 */
> # ping -I p4p1-vf0 -c1 -W1 192.168.1.200
> /* port rep VF1 -> IP in same subnet  - broadcasts will be seen on p4p1_1 */
> # ping -I p4p1-vf1 -c1 -W1 192.168.1.200
>
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e.h             |   4 +
>  drivers/net/ethernet/intel/i40e/i40e_main.c        |  27 +++-
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 148 ++++++++++++++++++++-
>  drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   2 +
>  drivers/net/ethernet/intel/i40e/i40e_type.h        |   3 +
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   8 +-
>  6 files changed, 184 insertions(+), 8 deletions(-)
>

<snip>

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index ebffca0..86d2510 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -1302,20 +1302,64 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
>  }
>
>  /**
> + * i40e_handle_lpbk_skb - Update skb->dev of a loopback frame
> + * @rx_ring: rx ring in play
> + * @skb: packet to send up
> + **/
> +static void i40e_handle_lpbk_skb(struct i40e_ring *rx_ring, struct sk_buff *skb)
> +{
> +       struct i40e_q_vector *q_vector = rx_ring->q_vector;
> +       struct i40e_pf *pf = rx_ring->vsi->back;
> +       struct sk_buff *nskb;
> +       struct i40e_vf *vf;
> +       struct ethhdr *eth;
> +       int vf_id;
> +
> +       if ((skb->pkt_type != PACKET_BROADCAST) &&
> +           (skb->pkt_type != PACKET_MULTICAST) &&
> +           (skb->pkt_type != PACKET_OTHERHOST))
> +               return;
> +
> +       eth = (struct ethhdr *)skb_mac_header(skb);
> +
> +       /* If a loopback packet is received in switchdev mode, clone the skb
> +        * and pass it to the corresponding port netdev based on the source MAC.
> +        */
> +       for (vf_id = 0; vf_id < pf->num_alloc_vfs; vf_id++) {
> +               vf = &pf->vf[vf_id];
> +               if (ether_addr_equal(eth->h_source,
> +                                    vf->default_lan_addr.addr)) {
> +                       nskb = skb_clone(skb, GFP_ATOMIC);
> +                       if (!nskb)
> +                               break;
> +                       nskb->offload_fwd_mark = 1;

So this line is causing build errors when switchdev is not enabled.
This whole function should probably be wrapped in a check to see if
switchdev support is enabled or not.

> +                       nskb->dev = vf->port_netdev;
> +                       napi_gro_receive(&q_vector->napi, nskb);
> +                       break;
> +               }
> +       }
> +}
> +
> +/**
