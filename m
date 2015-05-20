From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Use a bus-global mutex to protect
 VPD operations
Date: Tue, 19 May 2015 18:02:12 -0700
Message-ID: <555BDD14.2080807@redhat.com>
References: <20150519000037.56109.68356.stgit@mdrustad-wks.jf.intel.com> <555B78F7.60908@redhat.com> <20150519160158.00002cd6@unknown> <555BD029.7050803@redhat.com> <F47DC49C-CCC5-4693-8905-20ABCE6F5993@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42548 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610AbbETBCT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 21:02:19 -0400
In-Reply-To: <F47DC49C-CCC5-4693-8905-20ABCE6F5993@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/19/2015 05:34 PM, Rustad, Mark D wrote:
>> On May 19, 2015, at 5:07 PM, Alexander Duyck <alexander.h.duyck@redhat.com> wrote:
>>
>>
>>
>> On 05/19/2015 04:01 PM, Jesse Brandeburg wrote:
>>> But Alex if you do this you're violating the principle of least
>>> surprise, not to mention changing a user-space interface which should
>>> not be done.
>> I'm willing to back off on dropping the VPD info for those functions entirely, but the lock should not be pushed to the bus.
> Yeah, I think suddenly dropping the VPD from non-0 functions would be disruptive.
>
>>> Mark's solution is pretty graceful and solves the issue at heart, which
>>> is that
>>> 1) several Intel chips have this issue
>>> 2) it appears that several other vendor's chips have this issue (or
>>> similar) as well, but even if they don't Mark's fix will not change
>>> their general operation, only make a small serializing effect when
>>> multiple simultaneous reads are made.
>> 2 is based on a false premise.  The "vpd r/w failed" error is about as common as dev_watchdog().  Just because it presents with a similar symptom doesn't mean it is the same issue.
> I don't know if it is false, but it is possible that other devices could have the same behavior. I didn't expect that it would fix them all by any means, but I figured there would be some fellow travelers.
>
>> If the bug is in Intel Ethernet with VPD then I would suggest tweaking the VPD logic and adding a Intel Ethernet PCI quirk.  It doesn't make sense to assume based on one common error message that all of creation has the same issue.
>> If anything I believe Mark's patches have revealed a bigger issue. That is the fact that the sysfs file is reading outside of the VPD area which the PCI spec doesn't have a defined behavior for.  I suspect this is the cause of a number of the issues being reported as Broadcom had to specifically quirk to prevent it, and I found one discussion that indicated something similar might be needed for Realtek.
> It turns out that I missed something very important here - the state of the F bit. Because of how that works, and how the kernel knows what the last access was, it is vital to know which address/data registers are shared and which ones aren't. This is going to result in a much bigger fix. It will be necessary to positively know when this register sharing is happening. This will result in significant changes to the VPD code in order to model the behavior right. Essentially, devices with this issue will need to have the vpd pointer point to the same structure. That automatically fixes the locking issue. I will look into what can be done for KVM while I am at it. It will be a big device table, but that is unavoidable.
>
> Doggone it. It seemed too good to be true yesterday and now I know that is because it is. So close. If only it weren't for VPD writes... I'm going to start over now.

My suspicion is that we have a number of bugs floating around out there 
like the Broadcom issue.  Specifically, one of the ones I found was that 
the r8169 seems to have a similar issue as called out in the email 
thread at http://permalink.gmane.org/gmane.linux.network/232260.  I'm 
wondering if we shouldn't add an initializer for the read/write 
functions that will go through and pull out the 3 or 4 headers from the 
VPD data needed to get the actual length.  Then it would lock down the 
VPD and save some serious time on reads since most devices don't have 
32K of VPD to read.

- Alex
