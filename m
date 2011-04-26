From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH] igb: restore EEPROM 16kB access limit
Date: Tue, 26 Apr 2011 08:12:20 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F016AF39010@orsmsx508.amr.corp.intel.com>
References: <1302269695-27188-1-git-send-email-sassmann@kpanic.de>
 <EDC0E76513226749BFBC9C3FB031318F0137E85A8E@orsmsx508.amr.corp.intel.com>
 <4D9F6A44.7060809@kpanic.de>
 <EDC0E76513226749BFBC9C3FB031318F0137E85E47@orsmsx508.amr.corp.intel.com>
 <20110426150659.GA21309@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stefan Assmann <sassmann@kpanic.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4950 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756753Ab1DZPMV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 11:12:21 -0400
In-Reply-To: <20110426150659.GA21309@gospo.rdu.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Andy Gospodarek [mailto:andy@greyhouse.net]
>Sent: Tuesday, April 26, 2011 8:07 AM
>To: Wyborny, Carolyn
>Cc: Stefan Assmann; netdev@vger.kernel.org; e1000-
>devel@lists.sourceforge.net; Kirsher, Jeffrey T; Pieper, Jeffrey E;
>Ronciak, John
>Subject: Re: [PATCH] igb: restore EEPROM 16kB access limit
>
>On Fri, Apr 08, 2011 at 01:10:30PM -0700, Wyborny, Carolyn wrote:
>[...]
>>
>> Yes, there's more code changed than just the removal of what you're
>trying to add back.  The snip is the replacement but those function need
>to exist as well.  I believe that the commit referenced did not
>completely apply and you're missing some critical code.  The problem you
>are seeing should not occur with full patch.
>>
>> The version of e1000_82575.c in 2.6.39-rc2 has all the changes needed
>for this to work correctly.
>>
>
>I'm still seeing failures with today's net-next-2.6 ('git describe'
>shows v2.6.39-rc1-1283-g64cad2a), so it would be really nice to get this
>fixed.  I would rather not have to carry a patch like the one Stefan
>posted or one like this crazy one I hacked up to try all sizes until
>valid NVRAM is found.
>
>It applies cleanly net-next-2.6, net-2.6, and linux-2.6 as all exhibit
>the exact same problem.
>
>diff --git a/drivers/net/igb/e1000_82575.c
>b/drivers/net/igb/e1000_82575.c
>index 0cd41c4..f8677f2 100644
>--- a/drivers/net/igb/e1000_82575.c
>+++ b/drivers/net/igb/e1000_82575.c
>@@ -243,7 +243,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw
>*hw)
> 	 * for setting word_size.
> 	 */
> 	size += NVM_WORD_SIZE_BASE_SHIFT;
>-
>+err_eeprom:
> 	nvm->word_size = 1 << size;
> 	if (nvm->word_size == (1 << 15))
> 		nvm->page_size = 128;
>@@ -271,6 +271,17 @@ static s32 igb_get_invariants_82575(struct e1000_hw
>*hw)
> 	}
> 	nvm->ops.write = igb_write_nvm_spi;
>
>+        /* make sure the NVM is good */
>+        if (hw->nvm.ops.validate(hw) < 0) {
>+		if (size > 14)  {
>+			size--;
>+			printk(KERN_ERR "igb: The NVM size is not valid,
>trying %d\n", 1<<size);
>+			goto err_eeprom;
>+		}
>+		printk(KERN_ERR "The NVM Checksum Is Not Valid\n");
>+		return -E1000_ERR_MAC_INIT;
>+        }
>+
> 	/* if part supports SR-IOV then initialize mailbox parameters */
> 	switch (mac->type) {
> 	case e1000_82576:
>diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
>index cdfd572..8e23ca2 100644
>--- a/drivers/net/igb/igb_main.c
>+++ b/drivers/net/igb/igb_main.c
>@@ -1940,13 +1940,6 @@ static int __devinit igb_probe(struct pci_dev
>*pdev,
> 	 * known good starting state */
> 	hw->mac.ops.reset_hw(hw);
>
>-	/* make sure the NVM is good */
>-	if (hw->nvm.ops.validate(hw) < 0) {
>-		dev_err(&pdev->dev, "The NVM Checksum Is Not Valid\n");
>-		err = -EIO;
>-		goto err_eeprom;
>-	}
>-
> 	/* copy the MAC address out of the NVM */
> 	if (hw->mac.ops.read_mac_addr(hw))
> 		dev_err(&pdev->dev, "NVM Read Error\n");
>
Part of the problem you are seeing is an apparently widespread EEPROM problem where the size word in the EEPROM is invalid.  Since we didn't really check it before it didn't cause a problem.  I have a patch coming that addresses this by messaging the user that the size is invalid but setting it to a default and continuing.  

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation



