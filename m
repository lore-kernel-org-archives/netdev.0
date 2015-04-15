From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 03/14] i40e: Add support to program FDir SB rules for
 VF from PF through ethtool
Date: Wed, 15 Apr 2015 11:58:19 +0300
Message-ID: <CAJ3xEMiKw2DBWhF5UQZ8yfCpPKAMuyZk18sQm9Z=QgPhG_DPqg@mail.gmail.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1429073511-27664-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Matan Barak <matanb@mellanox.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34236 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbbDOI6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 04:58:20 -0400
Received: by qkca135 with SMTP id a135so8262302qkc.1
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 01:58:20 -0700 (PDT)
In-Reply-To: <1429073511-27664-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2015 at 7:51 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Anjali Singhai Jain <anjali.singhai@intel.com>

> With this patch we can now add Flow director Sideband rules for a VF from
> it's PF. Here is an example on how it can be done when VF id = 5 and
> queue = 2:
>
> "ethtool -N ethx flow-type udp4 src-ip x.x.x.x dst-ip y.y.y.y src-port p1 dst-port p2 action 2 user-def 5"
>
> User-def specifies VF id and action specifies queue.

Hi Jeff,

We're too eager to have support for PF controlled ACL / over-ruling VF traffic.

I don't think the way to go here is just go an use the user-defined
"data" field of struct ethtool_flow_ext to represent a VF -- since VF
is well defined multiple vendor supported construct. At least in the
command line would be better to see "vf 5" and not "user-def 5" -- and
maybe also down into the user-kernel API somehow enhance the ethtool
flow related structures such that VF ID is specified?

Or.


> Change-ID: Ib37d6dff3823a4d85caffde638473891c38c2b89
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Tested-by: Jim Young <james.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 26 ++++++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> index c848b18..7d60587 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -1914,6 +1914,16 @@ static int i40e_get_ethtool_fdir_entry(struct i40e_pf *pf,
>         else
>                 fsp->ring_cookie = rule->q_index;
>
> +       if (rule->dest_vsi != pf->vsi[pf->lan_vsi]->id) {
> +               struct i40e_vsi *vsi;
> +
> +               vsi = i40e_find_vsi_from_id(pf, rule->dest_vsi);
> +               if (vsi && vsi->type == I40E_VSI_SRIOV) {
> +                       fsp->h_ext.data[1] = htonl(vsi->vf_id);
> +                       fsp->m_ext.data[1] = htonl(0x1);
> +               }
> +       }
> +
>         return 0;
>  }
>
> @@ -2207,6 +2217,7 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
>         struct i40e_fdir_filter *input;
>         struct i40e_pf *pf;
>         int ret = -EINVAL;
> +       u16 vf_id;
>
>         if (!vsi)
>                 return -EINVAL;
> @@ -2267,7 +2278,22 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
>         input->dst_ip[0] = fsp->h_u.tcp_ip4_spec.ip4src;
>         input->src_ip[0] = fsp->h_u.tcp_ip4_spec.ip4dst;
>
> +       if (ntohl(fsp->m_ext.data[1])) {
> +               if (ntohl(fsp->h_ext.data[1]) >= pf->num_alloc_vfs) {
> +                       netif_info(pf, drv, vsi->netdev, "Invalid VF id\n");
> +                       goto free_input;
> +               }
> +               vf_id = ntohl(fsp->h_ext.data[1]);
> +               /* Find vsi id from vf id and override dest vsi */
> +               input->dest_vsi = pf->vf[vf_id].lan_vsi_id;
> +               if (input->q_index >= pf->vf[vf_id].num_queue_pairs) {
> +                       netif_info(pf, drv, vsi->netdev, "Invalid queue id\n");
> +                       goto free_input;
> +               }
> +       }
> +
>         ret = i40e_add_del_fdir(vsi, input, true);
> +free_input:
>         if (ret)
>                 kfree(input);
>         else
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
