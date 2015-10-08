From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: Fix bug in __mlxsw_item_bit_array_offset
Date: Thu,  8 Oct 2015 15:17:38 +0200
Message-ID: <1444310258-6563-3-git-send-email-jiri@resnulli.us>
References: <1444310258-6563-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36129 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757530AbbJHNRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 09:17:43 -0400
Received: by wicgb1 with SMTP id gb1so25275973wic.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 06:17:42 -0700 (PDT)
In-Reply-To: <1444310258-6563-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When calculating the shift needed in order to access a bit array element
in a byte, we should multiply the index by the element size and not
assume it is fixed at 2-bits.

Fixes: 93c1edb27f9e ("mlxsw: Introduce Mellanox switch driver core")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/item.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/item.h b/drivers/net/ethernet/mellanox/mlxsw/item.h
index ffd55d0..36fb1ce 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/item.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/item.h
@@ -187,6 +187,7 @@ __mlxsw_item_bit_array_offset(struct mlxsw_item *item, u16 index, u8 *shift)
 {
 	u16 max_index, be_index;
 	u16 offset;		/* byte offset inside the array */
+	u8 in_byte_index;
 
 	BUG_ON(index && !item->element_size);
 	if (item->offset % sizeof(u32) != 0 ||
@@ -199,7 +200,8 @@ __mlxsw_item_bit_array_offset(struct mlxsw_item *item, u16 index, u8 *shift)
 	max_index = (item->size.bytes << 3) / item->element_size - 1;
 	be_index = max_index - index;
 	offset = be_index * item->element_size >> 3;
-	*shift = index % (BITS_PER_BYTE / item->element_size) << 1;
+	in_byte_index  = index % (BITS_PER_BYTE / item->element_size);
+	*shift = in_byte_index * item->element_size;
 
 	return item->offset + offset;
 }
-- 
1.9.3
