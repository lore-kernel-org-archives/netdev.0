From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: Re: [PATCH net] be2net: fix initial MAC setting
Date: Fri, 27 Jan 2017 18:08:00 +0530
Message-ID: <CAHHeUGXitTaXqQk8zDymcCX09vFq3CtM20FHJPL6AeVhc2iBPQ@mail.gmail.com>
References: <20170126102801.18914-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Ivan Vecera <cera@cera.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:35181 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932801AbdA0MiC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 07:38:02 -0500
Received: by mail-oi0-f47.google.com with SMTP id j15so156074062oih.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 04:38:01 -0800 (PST)
In-Reply-To: <20170126102801.18914-1-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ivan,

This patch is a bit involved. We need some time to review and test
this to make sure it works with other (non-BE3/VF - Skyhawk, Lancer)
devices. Also, IIRC we shouldn't see this issue with the latest FW.

Thanks,
-Harsha

On Thu, Jan 26, 2017 at 3:58 PM, Ivan Vecera <cera@cera.cz> wrote:
> Recent commit 34393529163a ("be2net: fix MAC addr setting on privileged
> BE3 VFs") allows privileged BE3 VFs to set its MAC address during
> initialization. Although the initial MAC for such VFs is already
> programmed by parent PF the subsequent setting performed by VF is OK,
> but in certain cases (after fresh boot) this command in VF can fail.
>
> The MAC should be initialized only when:
> 1) no MAC is programmed (always except BE3 VFs during first init)
> 2) programmed MAC is different from requested (e.g. MAC is set when
>    interface is down). In this case the initial MAC programmed by PF
>    needs to be deleted.
>
> The adapter->dev_mac contains MAC address currently programmed in HW so
> it should be zeroed when the MAC is deleted from HW and should not be
> filled when MAC is set when interface is down in be_mac_addr_set() as
> no programming is performed in this case.
>
> Example of failure without the fix (immediately after fresh boot):
>
> # ip link set eth0 up  <- eth0 is BE3 PF
> be2net 0000:01:00.0 eth0: Link is Up
>
> # echo 1 > /sys/class/net/eth0/device/sriov_numvfs  <- Create 1 VF
> ...
> be2net 0000:01:04.0: Emulex OneConnect(be3): VF  port 0
>
> # ip link set eth8 up  <- eth8 is created privileged VF
> be2net 0000:01:04.0: opcode 59-1 failed:status 1-76
> RTNETLINK answers: Input/output error
>
> # echo 0 > /sys/class/net/eth0/device/sriov_numvfs  <- Delete VF
> iommu: Removing device 0000:01:04.0 from group 33
> ...
>
> # echo 1 > /sys/class/net/eth0/device/sriov_numvfs  <- Create it again
> iommu: Removing device 0000:01:04.0 from group 33
> ...
>
> # ip link set eth8 up
> be2net 0000:01:04.0 eth8: Link is Up
>
> Initialization is now OK.
>
> Fixes: 34393529163a ("be2net: fix MAC addr setting on privileged BE3 VFs")
> Cc: Sathya Perla <sathya.perla@broadcom.com>
> Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Cc: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Ivan Vecera <cera@cera.cz>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c | 31 ++++++++++++++++++++++++-----
>  1 file changed, 26 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index 1a7f8ad7b9c6..cf13b99b8551 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -362,8 +362,10 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
>                 status = -EPERM;
>                 goto err;
>         }
> -done:
> +
> +       /* Remember currently programmed MAC */
>         ether_addr_copy(adapter->dev_mac, addr->sa_data);
> +done:
>         ether_addr_copy(netdev->dev_addr, addr->sa_data);
>         dev_info(dev, "MAC address changed to %pM\n", addr->sa_data);
>         return 0;
> @@ -3618,8 +3620,10 @@ static void be_disable_if_filters(struct be_adapter *adapter)
>  {
>         /* Don't delete MAC on BE3 VFs without FILTMGMT privilege  */
>         if (!BEx_chip(adapter) || !be_virtfn(adapter) ||
> -           check_privilege(adapter, BE_PRIV_FILTMGMT))
> +           check_privilege(adapter, BE_PRIV_FILTMGMT)) {
>                 be_dev_mac_del(adapter, adapter->pmac_id[0]);
> +               eth_zero_addr(adapter->dev_mac);
> +       }
>
>         be_clear_uc_list(adapter);
>         be_clear_mc_list(adapter);
> @@ -3773,12 +3777,25 @@ static int be_enable_if_filters(struct be_adapter *adapter)
>         if (status)
>                 return status;
>
> -       /* Don't add MAC on BE3 VFs without FILTMGMT privilege */
> -       if (!BEx_chip(adapter) || !be_virtfn(adapter) ||
> -           check_privilege(adapter, BE_PRIV_FILTMGMT)) {
> +       /* Normally this condition usually true as the ->dev_mac is zeroed.
> +        * But on BE3 VFs the initial MAC is pre-programmed by PF and
> +        * subsequent be_dev_mac_add() can fail (after fresh boot)
> +        */
> +       if (!ether_addr_equal(adapter->dev_mac, adapter->netdev->dev_addr)) {
> +               int old_pmac_id = -1;
> +
> +               /* Remember old programmed MAC if any - can happen on BE3 VF */
> +               if (!is_zero_ether_addr(adapter->dev_mac))
> +                       old_pmac_id = adapter->pmac_id[0];
> +
>                 status = be_dev_mac_add(adapter, adapter->netdev->dev_addr);
>                 if (status)
>                         return status;
> +
> +               /* Delete old programmed MAC if necessary */
> +               if (old_pmac_id > 0 && old_pmac_id != adapter->pmac_id[0])
> +                       be_dev_mac_del(adapter, old_pmac_id);
> +
>                 ether_addr_copy(adapter->dev_mac, adapter->netdev->dev_addr);
>         }
>
> @@ -4552,6 +4569,10 @@ static int be_mac_setup(struct be_adapter *adapter)
>
>                 memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
>                 memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
> +
> +               /* Initial MAC for BE3 VFs is already programmed by PF */
> +               if (BEx_chip(adapter) && be_virtfn(adapter))
> +                       memcpy(adapter->dev_mac, mac, ETH_ALEN);
>         }
>
>         return 0;
> --
> 2.10.2
>
