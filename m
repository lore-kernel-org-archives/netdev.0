From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net v2] i40e: Fix limit imprecise of the
 number of MAC/VLAN that can be added for VFs
Date: Thu, 28 Sep 2017 08:44:04 -0700
Message-ID: <CAKgT0UcsnLUWU8qedNrv+bhbgJ6SC9zWyc7oR9gObcYo2atN5g@mail.gmail.com>
References: <1506564064-10740-1-git-send-email-wangyunjian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Netdev <netdev@vger.kernel.org>, caihe@huawei.com,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: w00273186 <wangyunjian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35004 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753297AbdI1PoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 11:44:05 -0400
Received: by mail-qk0-f194.google.com with SMTP id o77so1262163qke.2
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 08:44:05 -0700 (PDT)
In-Reply-To: <1506564064-10740-1-git-send-email-wangyunjian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 7:01 PM, w00273186 <wangyunjian@huawei.com> wrote:
> From: Yunjian Wang <wangyunjian@huawei.com>
>
> Now it doesn't limit the number of MAC/VLAN strictly. When there is more
> elements in the virtchnl MAC/VLAN list, it can still add successfully.

You could still add but should you. I'm not clear from this patch
description what this is supposed to be addressing. If you enable the
"trust" flag for a VF via the "ip link set dev <iface> vf <vfnum>
trust on" it can make use of any resources on the device, but without
that there is an upper limit that is supposed to be enforced to
prevent the VF from making use of an excessive amount of resources.
That is what is being enforced by the code you are moving out of the
way below.

> Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 27 +++++++++++++---------
>  1 file changed, 16 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> index 4d1e670..285b96a 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> @@ -2065,11 +2065,6 @@ static inline int i40e_check_vf_permission(struct i40e_vf *vf, u8 *macaddr)
>                 dev_err(&pf->pdev->dev,
>                         "VF attempting to override administratively set MAC address, reload the VF driver to resume normal operation\n");
>                 ret = -EPERM;
> -       } else if ((vf->num_mac >= I40E_VC_MAX_MAC_ADDR_PER_VF) &&
> -                  !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
> -               dev_err(&pf->pdev->dev,
> -                       "VF is not trusted, switch the VF to trusted to add more functionality\n");
> -               ret = -EPERM;
>         }
>         return ret;
>  }
> @@ -2128,6 +2123,15 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
>                 } else {
>                         vf->num_mac++;
>                 }
> +
> +               if ((vf->num_mac >= I40E_VC_MAX_MAC_ADDR_PER_VF) &&
> +                   !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
> +                       dev_err(&pf->pdev->dev,
> +                               "VF is not trusted, switch the VF to trusted to add more functionality\n");
> +                       ret = -EPERM;
> +                       spin_unlock_bh(&vsi->mac_filter_hash_lock);
> +                       goto error_param;
> +               }
>         }
>         spin_unlock_bh(&vsi->mac_filter_hash_lock);
>

This doesn't make any sense. You are doing the checks after you have
already added the MAC. The only part you aren't doing is sending the
message to the VF indicating that the request was successful.

> @@ -2221,12 +2225,6 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
>         i40e_status aq_ret = 0;
>         int i;
>
> -       if ((vf->num_vlan >= I40E_VC_MAX_VLAN_PER_VF) &&
> -           !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
> -               dev_err(&pf->pdev->dev,
> -                       "VF is not trusted, switch the VF to trusted to add more VLAN addresses\n");
> -               goto error_param;
> -       }
>         if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
>             !i40e_vc_isvalid_vsi_id(vf, vsi_id)) {
>                 aq_ret = I40E_ERR_PARAM;
> @@ -2269,6 +2267,13 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
>                         dev_err(&pf->pdev->dev,
>                                 "Unable to add VLAN filter %d for VF %d, error %d\n",
>                                 vfl->vlan_id[i], vf->vf_id, ret);
> +               if ((vf->num_vlan >= I40E_VC_MAX_VLAN_PER_VF) &&
> +                   !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
> +                       dev_err(&pf->pdev->dev,
> +                               "VF is not trusted, switch the VF to trusted to add more VLAN addresses\n");
> +                       aq_ret = -EPERM;
> +                       goto error_param;
> +               }
>         }
>
>  error_param:

Same here. You are doing this after the call to i40e_vsi_add_vlan. The
code makes no sense here. This bit of code is supposed to be
preventing a VF from abusing resources if the VF is not privelaged.
