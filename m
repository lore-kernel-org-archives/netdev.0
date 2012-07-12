From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] bonding: debugfs and network namespaces are incompatible
Date: Wed, 11 Jul 2012 17:18:00 -0700
Message-ID: <877gu9omrr.fsf@xmission.com>
References: <20120706194741.GA22113@mail.hallyn.com>
	<87y5ms3bfi.fsf_-_@xmission.com> <87sjd03bdw.fsf_-_@xmission.com>
	<20120709.144932.243254122059983829.davem@davemloft.net>
	<15459.1341941772@death.nxdomain>
	<367b470c-c3f5-4555-be11-02223125b741@email.android.com>
	<16903.1341947581@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:43458 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030529Ab2GLASH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 20:18:07 -0400
In-Reply-To: <16903.1341947581@death.nxdomain> (Jay Vosburgh's message of
	"Tue, 10 Jul 2012 12:13:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:

>>I haven't run across any of those network devices, but if they create a
>>debugfs entry that embeds the device name it will be a problem.
>
> 	A quick grep suggests that cxgb4, skge, sky2, stmmac, ipoib and
> half a dozen of the wireless drivers all create files in debugfs.  I did
> not check exhaustively, but at least some of them include the device
> name.

Yep.  It looks like imperfect habits are common.

>>Last I looked any custom user space interface from network devices was
>>rare and bonding using debugfs is the first instance of using debugfs
>>from networking devices I have seen.
>>
>>I think the problem will be a little less severe for physical network
>>devices as they all start in the initial network namespace and so start
>>with distinct names.
>>
>>With bonding I can do "ip link add type bond" in any network namespace
>>and get another bond0.  So name conflicts are very much expeted with all
>>virtual networking devices.
>
> 	Fair enough, although it is trivial to rename any network device
> such that a conflict would occur.

Actually for userspace and administrative reasons frequently it isn't
trivial to rename devices.

>>But if you know of any other networking devices using debugsfs that
>>code should probably get the same treatment as the bonding debugfs code.
>
> 	Is there no alternative than simply disabling debugfs whenever
> network namespaces are enabled?  The information bonding displays via
> debugfs is useful, and having it unavailable on all distro kernels seems
> a bit harsh.


I took a good hard look at debugfs while writing this reply and debufs
scares me.  It is the kind of code that just about wants to me to throw
in the towel seeing no hope of a good solid kernel. 

I can definitely open a /sys/kernel/debug/bonding/bond0/rlb_hash_table
and delete the bond and then read the file.  On a bad day that will oops
the kernel, as there is nothing holding a reference to the network
device.  I think only the BOND_MODE_ALB check makes keeps the kernel
from oopsing in my quick tests.

The fact that debugfs is enabled in distro kernels is actually apalling
to me.  debugfs makes it easy to oops the kernel.

There are lots of alternatives to debugfs on where to put information
and the bonding driver already uses most of them.

> 	Why is the logic already in the driver not sufficient?  If the
> attempt to create the debugfs directory with the interface name fails,
> then it merely prints a warning and continues without the debugfs for
> that interface.

All I know for certain is the existing logic will eventually cause
someone doing something reasonable to send me a bug report.

I can see where you are coming from in that the bonding driver debugfs
code really was built to gracefully fail and ignore problems of instead
of just hapharzardly and sloppily ignore problems.  At the same time
I can oops the kernel if I try with your debugfs in the bonding driver.

But it causes the code to fail and issue a warning.  So if I don't
disable the code now, I expect I will get a bug report, and who
knows how many sill files in bonding will have in debugfs by then.
what silly things bonding may be doing in debugfs by then.

Eric
