From: "Goel, Sameer" <sgoel@codeaurora.org>
Subject: [BUG] ethernet:mellanox:mlx5: Oops in health_recover
 get_nic_state(dev)
Date: Mon, 27 Mar 2017 17:45:44 -0600
Message-ID: <4a3539ba-6ce0-8ecf-1b1b-3c70cace6c2a@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        shankerd@codeaurora.org, rruigrok@codeaurora.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51544 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753546AbdC0Xww (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 19:52:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stack frame:
[ 1744.418958] [<ffff00000328936c>] get_nic_state+0x24/0x40 [mlx5_core]
[ 1744.425273] [<ffff0000032899c0>] health_recover+0x28/0x80 [mlx5_core]
[ 1744.431496] [<ffff0000080e3280>] process_one_work+0x150/0x460
[ 1744.437218] [<ffff0000080e35e0>] worker_thread+0x50/0x4b8
[ 1744.442609] [<ffff0000080e9b98>] kthread+0xd8/0xf0
[ 1744.447377] [<ffff000008083330>] ret_from_fork+0x10/0x20

Summary:
This issue was seen on QDF2400 system 30 mins after while running speccpu 2006. During the test a recoverable PCIe error was seen that gave the following log:
[ 1673.170969] pcieport 0002:00:00.0: aer_status: 0x00004000, aer_mask: 0x00400000
[ 1673.177961] pcieport 0002:00:00.0: aer_layer=Transaction Layer, aer_agent=Requester ID
[ 1673.185832] pcieport 0002:00:00.0: aer_uncor_severity: 0x00462030
[ 1675.536391] mlx5_core 0002:01:00.0: assert_var[0] 0xffffffff
[ 1675.541093] mlx5_core 0002:01:00.0: assert_var[1] 0xffffffff
[ 1675.546750] mlx5_core 0002:01:00.0: assert_var[2] 0xffffffff
[ 1675.552377] mlx5_core 0002:01:00.0: assert_var[3] 0xffffffff
[ 1675.558040] mlx5_core 0002:01:00.0: assert_var[4] 0xffffffff
[ 1675.563661] mlx5_core 0002:01:00.0: assert_exit_ptr 0xffffffff
[ 1675.569488] mlx5_core 0002:01:00.0: assert_callra 0xffffffff
[ 1675.575120] mlx5_core 0002:01:00.0: fw_ver 15.4095.65535
[ 1675.580426] mlx5_core 0002:01:00.0: hw_id 0xffffffff
[ 1675.585363] mlx5_core 0002:01:00.0: irisc_index 255
[ 1675.590242] mlx5_core 0002:01:00.0: synd 0xff: unrecognized error
[ 1675.596301] mlx5_core 0002:01:00.0: ext_synd 0xffff
[ 1675.601209] mlx5_core 0002:01:00.0: mlx5_enter_error_state:120:(pid 7205): start
[ 1675.608613] mlx5_core 0002:01:00.0: mlx5_enter_error_state:127:(pid 7205): end

After the above log we see the above stackframe and a page fault due to invalid dev pointer.

So the the recovery work is queued and the timer is stopped. Somehow the workqueue is not cleared and when it runs the dev pointer is invalid.

This issue was difficult to repro and was seen only once in multiple runs on a specific device.

Thanks,
Sameer 
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
