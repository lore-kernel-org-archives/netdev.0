From: Zachary Amsden <zach@vmware.com>
Subject: RE: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to -mm
	tree
Date: Tue, 02 Sep 2008 16:31:44 -0700
Message-ID: <1220398304.32688.163.camel@bodhitayantram.eng.vmware.com>
References: <200809021919.m82JJweC008488@imap1.linux-foundation.org>
	 <36D9DB17C6DE9E40B059440DB8D95F52060519D7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Qicheng Christopher Li <chrisl@vmware.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"arvidjaar@mail.ru" <arvidjaar@mail.ru>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Pratap Subrahmanyam <pratap@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:60516 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753679AbYIBXdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 19:33:18 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52060519D7@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-09-02 at 14:58 -0700, Brandeburg, Jesse wrote:
> First, off, added netdev..., someone else can add lkml if they so
> choose.
> 
> akpm@linux-foundation.org wrote:
> > The patch titled
> >      e1000e: prevent corruption of EEPROM/NVM
> > has been added to the -mm tree.  Its filename is
> >      e1000e-prevent-corruption-of-eeprom-nvm.patch
> 
> This is disturbing, where did this come from? Personal email?  I now
> have a spate of *FIVE* reports similar to this, but I haven't see any
> other messages on this issue from this user besides andrew's commit.  I
> think it may be a real problem, it is same problem as:
> http://bugzilla.kernel.org/show_bug.cgi?id=11382
> 
> <snip>
> > Subject: e1000e: prevent corruption of EEPROM/NVM
> > From: Christopher Li <chrisl@vmware.com>
> >
> > Andrey reports e1000e corruption, and that a patch in vmware's ESX
> > fixed
> > it.
> >
> > The EEPROM corruption is triggered by concurrent access of the EEPROM
> > read/write. Putting a lock around it solve the problem.
> >
> <snip>  I'd like to know how this actually solves a problem outside
> vmware.

Yes.  This was observed on a physical E1000 device.

> VMWare issues really do not apply to the Linux kernel, and unless the
> architecture of ethtool->ioctl->rtnl->e1000e has changed without me
> noticing.  In that case every driver that used ethtool would be broken.

No, any drivers that have a state machine consisting of a base register
that is used to index which datum is read from device EEPROM by the data
register would be broken.

This is not a VMware issue, its a fundamental hardware synchronization
issue caused by the dependence of data read/write on a device register.
Does the net layer protect against e1000 issuing simultaneous EEPROM
read / write?  I have no idea.  It probably should.  Should the driver
take extra precautions of its own to ensure this on non hot-paths, to
avoid corrupting EEPROM memory and resulting in a non-functional NIC?

Absolutely.

>From casual inspection it looks like set_mtu is done under dev_baselock, while ethtool is done under rtnl_lock.

Setting the MTU internally reads the EEPROM, which could contend with and corrupt and eeprom operations.

Zach

