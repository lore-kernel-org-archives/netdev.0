From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/14] Mellanox mlx5e Fail-safe config
Date: Mon, 27 Mar 2017 23:48:56 +0300
Message-ID: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44884 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751801AbdC0Ut5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:49:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series provides a fail-safe mechanism to allow safely re-configuring
mlx5e netdevice and provides a resiliency against sporadic
configuration failures.

For additional information please see below.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit 88275ed0cb3ac89ed869a925337b951801b154d7:

  Merge branch 'netvsc-next' (2017-03-25 20:15:56 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5e-failsafe

for you to fetch changes up to 2e20a151205be8e7efa9644cdb942381e7bec787:

  net/mlx5e: Fail safe mtu and lro setting (2017-03-27 15:08:24 +0300)

----------------------------------------------------------------
mlx5e-failsafe 27-03-2017

This series provides a fail-safe mechanism to allow safely re-configuring
mlx5e netdevice and provides a resiliency against sporadic
configuration failures.

To enable this we do some refactoring and code reorganizing to allow
breaking the drivers open/close flows to stages:
      open -> activate -> deactivate -> close.

In addition we need to allow creating fresh HW ring resources
(mlx5e_channels) with their own "new" set of parameters, while keeping
the current ones running and active until the new channels are
successfully created with the new configuration, and only then we can
safly replace (switch) old channels with new ones.

For that we introduce mlx5e_channels object and an API to manage it:
 - channels = open_channels(new_params):
   open fresh TX/RX channels
 - activate_channels(channels):
   redirect traffic to them and attach them to the netdev
 - deactivate_channes(channels)
   stop traffic and detach from netdev
 - close(channels)
   Free the TX/RX HW resources of those channels

With the above strategy it is straightforward to achieve the desired
behavior of fail-safe configuration.  In pseudo code:

make_new_config(new_params)
{
	old_channels = current_active_channels;
	new_channels = create_channels(new_params);
	if (!new_channels)
		return "Failed, but current channels are still active :)"

	deactivate_channels(old_channels); /* Can't fail */
	set_hw_new_state();                /* If needed  */
	activate_channels(new_channels);   /* Can't fail */
	close_channels(old_channels);
	current_active_channels = new_channels;

        return "SUCCESS";
}

At the top of this series, we change the following flows to be fail-safe:
ethtool:
   - ring parameters
   - coalesce parameters
   - tx copy break parameters
   - cqe compressing/moderation mode setting (priv flags)
ndos:
   - tc setup
   - set features: LRO
   - change mtu

----------------------------------------------------------------
Saeed Mahameed (14):
      net/mlx5e: Set SQ max rate on mlx5e_open_txqsq rather on open_channel
      net/mlx5e: Set netdev->rx_cpu_rmap on netdev creation
      net/mlx5e: Introduce mlx5e_channels
      net/mlx5e: Redirect RQT refactoring
      net/mlx5e: Refactor refresh TIRs
      net/mlx5e: Split open/close channels to stages
      net/mlx5e: Isolate open_channels from priv->params
      net/mlx5e: CQ and RQ don't need priv pointer
      net/mlx5e: Minimize mlx5e_{open/close}_locked
      net/mlx5e: Introduce switch channels
      net/mlx5e: Fail safe ethtool settings
      net/mlx5e: Fail safe cqe compressing/moderation mode setting
      net/mlx5e: Fail safe tc setup
      net/mlx5e: Fail safe mtu and lro setting

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  106 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |   10 +-
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |   17 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  336 +++---
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 1172 +++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |   83 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   22 -
 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c |    2 +-
 .../net/ethernet/mellanox/mlx5/core/en_selftest.c  |    9 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   11 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |    3 +-
 12 files changed, 984 insertions(+), 789 deletions(-)
