From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 04/15] wimax/i2400m: don't write to memory allocated by request_firmware()
Date: Wed,  4 Nov 2009 13:39:45 -0800
Message-ID: <8d8fe198c6a756ae96617548af4776e7a86c0d3e.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20702 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932707AbZKDVl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:59 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

In kernel 2.6.31, the firmware requested to ram could be marked
with read only attribute, and we can't write any thing directly
to the memory when setting up the last JUMP brh cmd.

Changed so that the scratch buffer is used.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 0018cdb..92d4d60 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -533,6 +533,10 @@ int i2400m_dnload_finalize(struct i2400m *i2400m,
 		struct i2400m_bootrom_header jump_ack;
 		d_printf(1, dev, "unsecure boot, jumping to 0x%08x\n",
 			le32_to_cpu(cmd->target_addr));
+		cmd_buf = i2400m->bm_cmd_buf;
+		memcpy(&cmd_buf->cmd, cmd, sizeof(*cmd));
+		cmd = &cmd_buf->cmd;
+		/* now cmd points to the actual bootrom_header in cmd_buf */
 		i2400m_brh_set_opcode(cmd, I2400M_BRH_JUMP);
 		cmd->data_size = 0;
 		ret = i2400m_bm_cmd(i2400m, cmd, sizeof(*cmd),
-- 
1.6.2.5

