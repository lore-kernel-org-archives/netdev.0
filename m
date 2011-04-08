From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH] igb: restore EEPROM 16kB access limit
Date: Fri, 8 Apr 2011 09:40:43 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F0137E85A8E@orsmsx508.amr.corp.intel.com>
References: <1302269695-27188-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Stefan Assmann <sassmann@kpanic.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:50308 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757635Ab1DHQkq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 12:40:46 -0400
In-Reply-To: <1302269695-27188-1-git-send-email-sassmann@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Stefan Assmann [mailto:sassmann@kpanic.de]
>Sent: Friday, April 08, 2011 6:35 AM
>To: netdev@vger.kernel.org
>Cc: e1000-devel@lists.sourceforge.net; Kirsher, Jeffrey T; Pieper,
>Jeffrey E; Wyborny, Carolyn; Ronciak, John
>Subject: [PATCH] igb: restore EEPROM 16kB access limit
>
>The check limiting the EEPROM access up to 16kB was removed by
>commit 4322e561a93ec7ee034b603a6c610e7be90d4e8a. Without this check
>the kernel will try to checksum the EEPROM up to 2MB (observed with
>a 8086:10c9 NIC) and fail.
>
>igb 0000:03:00.0: 0 vfs allocated
>igb 0000:03:00.0: The NVM Checksum Is Not Valid
>ACPI: PCI interrupt for device 0000:03:00.0 disabled
>igb: probe of 0000:03:00.0 failed with error -5
>
>Reason for that being an overflow in u16 e1000_nvm_info->nvm
>while doing "nvm->word_size = 1 << size;" with size == 21.
>Putting the check back in place.
>
>Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
>---
> drivers/net/igb/e1000_82575.c |    4 ++++
> 1 files changed, 4 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/igb/e1000_82575.c
>b/drivers/net/igb/e1000_82575.c
>index 6b256c2..5cfa37f 100644
>--- a/drivers/net/igb/e1000_82575.c
>+++ b/drivers/net/igb/e1000_82575.c
>@@ -244,6 +244,10 @@ static s32 igb_get_invariants_82575(struct e1000_hw
>*hw)
> 	 */
> 	size += NVM_WORD_SIZE_BASE_SHIFT;
>
>+	/* EEPROM access above 16k is unsupported */
>+	if (size > 14)
>+		size = 14;
>+
> 	nvm->word_size = 1 << size;
> 	if (nvm->word_size == (1 << 15))
> 		nvm->page_size = 128;
>--
>1.7.4
NACK

This doesn't apply against current upstream RC kernel.  There was more changed in that commit than just the removal of this.  There is a missing section of code that is needed, but not this.  This starts at line 251 in e1000_82575.c

--snip--
        /* NVM Function Pointers */
        nvm->ops.acquire = igb_acquire_nvm_82575;
        if (nvm->word_size < (1 << 15))
                nvm->ops.read = igb_read_nvm_eerd;
        else
                nvm->ops.read = igb_read_nvm_spi;
--snip--

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation


