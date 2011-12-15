From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: mlx4: smatch stuff: saving error codes in u8
Date: Thu, 15 Dec 2011 11:48:13 +0300
Message-ID: <20111215084812.GA20924@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:44157 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550Ab1LOIsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 03:48:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yevgeny,

Smatch complains about some recent changes to the mlx4 driver:
drivers/net/ethernet/mellanox/mlx4/cmd.c +364 mlx4_slave_cmd(27)
	warn: assigning -22 to unsigned variable 'vhcr->status'


   361                                          mlx4_err(dev, "response expected while"
   362                                                   "output mailbox is NULL for "
   363                                                   "command 0x%x\n", op);
   364                                          vhcr->status = -EINVAL;
                                                ^^^^^^^^^^^^^^^^^^^^^^^
This is supposed to store some hardware specific error codes.  -EINVAL
should be CMD_STAT_BAD_PARAM.  Saving negative numbers to unsigned char
doesn't work.

   365                                  }
   366                          }
   367                          ret = vhcr->status;
                                ^^^^^^^^^^^^^^^^^^^
We should be using the mlx4_status_to_errno() function here to translate
the hardware error codes to linux error codes.

Also "ret" here gets passed to the the callers who again save it to
vhcr_cmd->status = __mlx4_cmd() in mlx4_master_process_vhcr().  The
__mlx4_cmd() function only returns linux error codes, not hardware error
codes.

Also the mlx4_master_process_vhcr() function sets vhcr_cmd->status to
linux error codes (which is a mistake) but it doesn't set "ret" on all
paths so it sometimes returns success even though an error occured
(which is a second separate mistake).

regards,
dan carpenter
