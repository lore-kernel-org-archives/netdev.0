From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: Add VST QinQ support
Date: Thu, 7 Jul 2016 22:22:14 +0300
Message-ID: <CAJ3xEMhnoZHKL93Mwv4MKe_S106xgDmnYyKCtf7JjKxoWHO4Vg@mail.gmail.com>
References: <1467808146-29573-1-git-send-email-tariqt@mellanox.com> <1467808146-29573-4-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Moshe Shemesh <moshe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36827 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbcGGTWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 15:22:15 -0400
Received: by mail-oi0-f53.google.com with SMTP id f189so36729749oig.3
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 12:22:15 -0700 (PDT)
In-Reply-To: <1467808146-29573-4-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 3:29 PM, Tariq Toukan <tariqt@mellanox.com> wrote:
> From: Moshe Shemesh <moshe@mellanox.com>

> Enable activating VST QinQ mode by IP Link tool.
> Add parameter vlan protocol to the function ndo_set_vf_vlan.
> Vlan protocol by default is 802.1Q, setting vf vlan protocol to
> 802.1ad sets the vf to VST QinQ mode.
> Add IFLA_VF_VLAN_INFO in addition to IFLA_VF_VLAN to keep backward
> compatibility with older versions of IP Link tool.

Looking on the code, I understand that you are adding a knob to set
the vlan protocol for VST mode.

What I am not clear about, is why you call it QinQ? is that targeted
for a mixed VGT/VST mode where the guest put CVLAN and the HW
adds/strips SVLAN?

Is there anything in the API that actually is dealing/provisioning the
guest side of things? if not, why call it QinQ?

>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  3 ++-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |  9 +++++--
>  drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c    |  6 ++++-
>  drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h    |  2 +-
>  drivers/net/ethernet/emulex/benet/be_main.c        |  6 ++++-
>  drivers/net/ethernet/intel/fm10k/fm10k.h           |  2 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_iov.c       |  6 ++++-
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 11 +++++++--
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  4 ++--
>  drivers/net/ethernet/intel/igb/igb_main.c          |  9 ++++---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |  5 +++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |  2 +-

>  drivers/net/ethernet/mellanox/mlx4/cmd.c           | 25 +++++++++++++++++--
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  5 ++--
>  include/linux/mlx4/cmd.h                           |  3 ++-

The patch does few logical changes

1. introduce new rtnl UAPI that adds the ability for user-space to
specify vlan protocol for the VF

2. enhances the existing set_vf_vlan ndo to use that

3. adds the actual mlx4 implementation for using the vlan proto
(nothing about that is documented in the change log)

You better put the mlx4 part into a downstream patch, so things are
robust and well bisectable.

>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  6 ++++-
>  drivers/net/ethernet/qlogic/qede/qede_main.c       |  6 ++++-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |  2 +-
>  .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |  5 +++-
>  drivers/net/ethernet/sfc/sriov.c                   |  5 +++-
>  drivers/net/ethernet/sfc/sriov.h                   |  2 +-
>  include/linux/if_link.h                            |  1 +
>  include/linux/netdevice.h                          |  6 +++--
>  include/uapi/linux/if_link.h                       | 10 +++++++-
>  net/core/rtnetlink.c                               | 28 ++++++++++++++++++++--
>  25 files changed, 136 insertions(+), 33 deletions(-)
