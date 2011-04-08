From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH] igb: restore EEPROM 16kB access limit
Date: Fri,  8 Apr 2011 15:34:55 +0200
Message-ID: <1302269695-27188-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, john.ronciak@intel.com
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The check limiting the EEPROM access up to 16kB was removed by
commit 4322e561a93ec7ee034b603a6c610e7be90d4e8a. Without this check
the kernel will try to checksum the EEPROM up to 2MB (observed with
a 8086:10c9 NIC) and fail.

igb 0000:03:00.0: 0 vfs allocated
igb 0000:03:00.0: The NVM Checksum Is Not Valid
ACPI: PCI interrupt for device 0000:03:00.0 disabled
igb: probe of 0000:03:00.0 failed with error -5

Reason for that being an overflow in u16 e1000_nvm_info->nvm
while doing "nvm->word_size = 1 << size;" with size == 21.
Putting the check back in place.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/igb/e1000_82575.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 6b256c2..5cfa37f 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -244,6 +244,10 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	 */
 	size += NVM_WORD_SIZE_BASE_SHIFT;
 
+	/* EEPROM access above 16k is unsupported */
+	if (size > 14)
+		size = 14;
+
 	nvm->word_size = 1 << size;
 	if (nvm->word_size == (1 << 15))
 		nvm->page_size = 128;
-- 
1.7.4


------------------------------------------------------------------------------
Xperia(TM) PLAY
It's a major breakthrough. An authentic gaming
smartphone on the nation's most reliable network.
And it wants your games.
http://p.sf.net/sfu/verizon-sfdev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
