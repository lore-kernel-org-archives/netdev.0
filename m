From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to -mm tree
Date: Tue, 2 Sep 2008 14:58:52 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52060519D7@orsmsx418.amr.corp.intel.com>
References: <200809021919.m82JJweC008488@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <arvidjaar@mail.ru>, "Allan, Bruce W" <bruce.w.allan@intel.com>,
	<jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	<pratap@vmware.com>, <zach@vmware.com>, <netdev@vger.kernel.org>,
	<mm-commits@vger.kernel.org>
To: <chrisl@vmware.com>, <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:19481 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754765AbYIBV6z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 17:58:55 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200809021919.m82JJweC008488@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First, off, added netdev..., someone else can add lkml if they so
choose.

akpm@linux-foundation.org wrote:
> The patch titled
>      e1000e: prevent corruption of EEPROM/NVM
> has been added to the -mm tree.  Its filename is
>      e1000e-prevent-corruption-of-eeprom-nvm.patch

This is disturbing, where did this come from? Personal email?  I now
have a spate of *FIVE* reports similar to this, but I haven't see any
other messages on this issue from this user besides andrew's commit.  I
think it may be a real problem, it is same problem as:
http://bugzilla.kernel.org/show_bug.cgi?id=11382

<snip>
> Subject: e1000e: prevent corruption of EEPROM/NVM
> From: Christopher Li <chrisl@vmware.com>
> 
> Andrey reports e1000e corruption, and that a patch in vmware's ESX
> fixed 
> it.
> 
> The EEPROM corruption is triggered by concurrent access of the EEPROM
> read/write. Putting a lock around it solve the problem.
> 
<snip>  I'd like to know how this actually solves a problem outside
vmware.

> +static spinlock_t e1000_eeprom_lock = SPIN_LOCK_UNLOCKED;
> +

note this line changed in andrew's next patch.

>
/***********************************************************************
*******
>   * Set the phy type member in the hw struct.
>   *
> @@ -4904,6 +4908,15 @@ static s32 e1000_spi_eeprom_ready(struct
>  
>
************************************************************************
*****/
>  s32 e1000_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
> u16 *data) { +    s32 ret;
> +    spin_lock(&e1000_eeprom_lock);
> +    ret = e1000_do_read_eeprom(hw, offset, words, data);
> +    spin_unlock(&e1000_eeprom_lock);
> +    return ret;
> +}

spacing issues will be fixed when/if we push this to Jeff/Dave.

That is beside the point, why do we need to lock inside something that
is guaranteed to be inside the RTNL lock?

VMWare issues really do not apply to the Linux kernel, and unless the
architecture of ethtool->ioctl->rtnl->e1000e has changed without me
noticing.  In that case every driver that used ethtool would be broken.


> +
> +static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16
> words, u16 *data) +{
>      struct e1000_eeprom_info *eeprom = &hw->eeprom;
>      u32 i = 0;
> 
> @@ -5236,6 +5249,16 @@ s32 e1000_update_eeprom_checksum(struct
>  
>
************************************************************************
*****/
>  s32 e1000_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
> u16 *data) { +    s32 ret;
> +    spin_lock(&e1000_eeprom_lock);
> +    ret = e1000_do_write_eeprom(hw, offset, words, data);
> +    spin_unlock(&e1000_eeprom_lock);
> +    return ret;
> +}

preventing concurrent writes should be guaranteed by the caller (which
should be calling ioctl interfaces under RTNL)

someone please correct me if I'm wrong.

I believe there may actually be a problem, but I actually doubt it is
with e1000e and would be glad to drop eeprom write capability from the
driver in the kernel to prove it.

All signs currently point to some issue introduced with 2.6.27-rc, but
we have no solid reproduction steps or even a local repro.  All the
users with this problem have a shared non-volatile memory(NVM) for the
system which the e1000e's data is just a part of, so something like the
ME (management engine) could be corrupting the area for the LAN.

We are trying to reproduce locally, because 

BTW, anyone who reads this far, DON'T RUN IBAUTIL.EXE to try to fix
this!  It will (somehow) remove your LAN adapter from pci config space.
