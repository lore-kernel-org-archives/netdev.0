From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 1/2] netxen: fix error handling in netxen_get_flash_block()
Date: Thu, 5 May 2016 16:18:46 +0300
Message-ID: <20160505131846.GB3038@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My static checker complained that "v" can be used unintialized if
netxen_rom_fast_read() returns -EIO.  That function never actually
returns -1.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index db80eb1..a320541 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -1015,20 +1015,24 @@ static int netxen_get_flash_block(struct netxen_adapter *adapter, int base,
 {
 	int i, v, addr;
 	__le32 *ptr32;
+	int ret;
 
 	addr = base;
 	ptr32 = buf;
 	for (i = 0; i < size / sizeof(u32); i++) {
-		if (netxen_rom_fast_read(adapter, addr, &v) == -1)
-			return -1;
+		ret = netxen_rom_fast_read(adapter, addr, &v);
+		if (ret)
+			return ret;
+
 		*ptr32 = cpu_to_le32(v);
 		ptr32++;
 		addr += sizeof(u32);
 	}
 	if ((char *)buf + size > (char *)ptr32) {
 		__le32 local;
-		if (netxen_rom_fast_read(adapter, addr, &v) == -1)
-			return -1;
+		ret = netxen_rom_fast_read(adapter, addr, &v);
+		if (ret)
+			return ret;
 		local = cpu_to_le32(v);
 		memcpy(ptr32, &local, (char *)buf + size - (char *)ptr32);
 	}
