From: "Josef Meser" <josef.meser@frequentis.com>
Subject: [PATCH] drivers/net/e100.c: fix eeprom writes > 1 byte
Date: Tue, 19 Jan 2010 16:32:28 +0100
Message-ID: <891F39F12F3D4F119108C75F3626A035@frequentis.frq>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="x-user-defined";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <jesse.brandeburg@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.frequentis.com ([212.186.194.131]:22314 "EHLO
	mail1.frequentis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753850Ab0ASPoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 10:44:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As requested by Jesse on e1000-devel I repost my patch for e100 here:

Hi,

ethtool is able to program the eeprom with one byte per invocation.
When I tried to use a patched version of ethtool (see e.g.
http://kerneltrap.org/mailarchive/linux-netdev/2008/6/18/2162964)
to program the whole eeprom (connected to an 82551ER) at once,
the e100 driver refuses to program the 128 bytes.

This patch fixes 2 eeprom word address handlings, to make e100
work correct for eeprom writes with size > 1 byte.

@line 814:
When called with the values
start = 0;
count = 64; (number of u16 words to be written)
eeprom_wc = 64; (length of the eeprom in words)

the eeprom was not written, because this condition was true:
- if (start + count >= nic->eeprom_wc)
  return -EINVAL;

but it should be:
+ if (start + count > nic->eeprom_wc)
   return -EINVAL;

I think it never showed up, because ethtool normaly only writes
1 byte (/-> 1 word).

@line 2478:
The 3rd argument of eeprom_save() should hand over the number of words
to be written. (eeprom->len holds the number of bytes to be written).

So when trying to write 128 bytes with
 return e100_eeprom_save(nic, eeprom->offset >> 1,
-  (eeprom->len >> 1) + 1);

(128 >> 1) + 1 = 65 words were requested
-> which is wrong, and rejected by eeprom_save(),
because it is larger than the size of the eeprom.

It just never showed up, because ethtool only writes 1 byte:
(1 >> 1) + 1 = 1 word requested -> ok by chance.

Correct is:
+  (eeprom->len + 1) >> 1);

which results for programming 1 byte:
(1 + 1) >> 1 = 1 word requested, ok.

and programming 128 bytes:
(128 + 1) >> 1 = 64 words requested, ok.

Regards,
Josef

Signed-off-by: Josef Meser <j... at frequentis dot com>
---
 drivers/net/e100.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 3c29a20..7c9597e 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -811,7 +811,7 @@ static int e100_eeprom_save(struct nic *nic, u16 start, u16 count)
  e100_eeprom_read(nic, &addr_len, 0);
  nic->eeprom_wc = 1 << addr_len;

- if (start + count >= nic->eeprom_wc)
+ if (start + count > nic->eeprom_wc)
   return -EINVAL;

  for (addr = start; addr < start + count; addr++)
@@ -2475,7 +2475,7 @@ static int e100_set_eeprom(struct net_device *netdev,
  memcpy(&((u8 *)nic->eeprom)[eeprom->offset], bytes, eeprom->len);

  return e100_eeprom_save(nic, eeprom->offset >> 1,
-  (eeprom->len >> 1) + 1);
+  (eeprom->len + 1) >> 1);
 }

 static void e100_get_ringparam(struct net_device *netdev,
--
1.5.4.3

