From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to -mmtree
Date: Tue, 2 Sep 2008 17:32:26 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5206051BF7@orsmsx418.amr.corp.intel.com>
References: <200809021919.m82JJweC008488@imap1.linux-foundation.org> <36D9DB17C6DE9E40B059440DB8D95F52060519D7@orsmsx418.amr.corp.intel.com> <1220398304.32688.163.camel@bodhitayantram.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Qicheng Christopher Li" <chrisl@vmware.com>,
	<akpm@linux-foundation.org>, <arvidjaar@mail.ru>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Pratap Subrahmanyam" <pratap@vmware.com>,
	<netdev@vger.kernel.org>, <mm-commits@vger.kernel.org>
To: "Zachary Amsden" <zach@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42186 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399AbYICAcd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 20:32:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1220398304.32688.163.camel@bodhitayantram.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zachary Amsden wrote:
>>> The EEPROM corruption is triggered by concurrent access of the
>>> EEPROM read/write. Putting a lock around it solve the problem.
>>> 
>> <snip>  I'd like to know how this actually solves a problem outside
>> vmware.
> 
> Yes.  This was observed on a physical E1000 device.

Hi Zach, thanks for the reply, can you give me a reproduction test so
that we can verify this fix internally?  We are extremely interested.

<long explanation follows>
 
>> VMWare issues really do not apply to the Linux kernel, and unless the
>> architecture of ethtool->ioctl->rtnl->e1000e has changed without me
>> noticing.  In that case every driver that used ethtool would be
>> broken. 
> 
> No, any drivers that have a state machine consisting of a base
> register 
> that is used to index which datum is read from device EEPROM by the
> data 
> register would be broken.

we are (supposed to be) protected by the eeprom semaphore in a hardware
register, so as long as we are not acquiring that hardware semaphore at
different priority levels (a classic deadlock which I think we don't
have) I'm still missing the bug.
 
> This is not a VMware issue, its a fundamental hardware synchronization
> issue caused by the dependence of data read/write on a device
> register. 
> Does the net layer protect against e1000 issuing simultaneous EEPROM
> read / write?  I have no idea.  It probably should.  Should the driver
> take extra precautions of its own to ensure this on non hot-paths, to
> avoid corrupting EEPROM memory and resulting in a non-functional NIC?
> 
> Absolutely.

I totally agree, which is why the driver / hardware synchronizes access
to the eeprom with a hardware semaphore ( in this case SWFLAG on
82566/567), because in reality we have multiple consumers accessing the
eeprom:
1) on a dual port (like 82571), both ports share the same eeprom
2) the hardware asynchronously auto-reads the eeprom on hw-reset
(CTRL.RST bit) while the driver continues init.
3) ethtool (as you've noted)
4) the manageability engine firmware (aka the ME) may be doing eeprom
operations as well.

If what you claim is true (and I don't doubt it, I just need help
reproducing it) then we have a lower level problem with the eeprom
semaphore/SWFLAG.
 
>> From casual inspection it looks like set_mtu is done under
>> dev_baselock, while ethtool is done under rtnl_lock. 
> 
> Setting the MTU internally reads the EEPROM, which could contend with
> and corrupt and eeprom operations. 

yes, since we issue a full reset and at least 2) above executes.  The
corruption really shouldn't be writing to the eeprom in any way shape or
form, but if it is we really need to fix the root cause of the bug, not
just lock on either side of one of the cases which appears to cause the
problem.

We are definitely investigating, please help us reproduce it if you can.

Jesse
