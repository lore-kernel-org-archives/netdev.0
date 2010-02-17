From: "Benjamin Li" <benli@broadcom.com>
Subject: [RFC] Large Ethtool Register Dumps
Date: Tue, 16 Feb 2010 22:38:24 -0800
Message-ID: <1266388704.3048.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>,
	"David Miller" <davem@davemloft.net>,
	"Amir Frankel" <amirf@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1303 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827Ab0BQGik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 01:38:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Amir and I were planning to include a routine to dump out relevant
register and memory contents from the hardware driven by the bnx2x
driver.  This is so we can be better prepared for debugging issues out
in the field.  The problem with this is that for an entire
register/memory dump it is about 6MB.  Because in the
net/core/ethtool.c:ethtool_get_regs() function, kmalloc() is used to
allocate space for the register dump, sometimes this will fail because
it can't get 6MB of contiguous space.  

Currently, we have a patch to the bnx2x driver which will break each
part of the dump into multiple chunks and a chunk would be returned with
every `ethtool -d` call.  (This is to get around the memory limiation)
But this is not a very friendly user experience.  I was wondering what
would be the preferred way in handling this situation.

1.  Modify the user space utility ethtool to call the ethtool ioctl with
the ethtool command, ETHTOOL_GREGS, mutiliple times under the covers in
the routine ethtool.c:do_gregs() only for the bnx2x driver.  For
example, the user would only have to run `ethtool -d <eth#>` once; and
underneath if using strace we would see multiple ethool ioctl's being
called for getting the registers. This way none of the kernel code
changes and bnx2x driver would be the first to call the ethool ioctl to
get a register dump multiple times.

2.  Modify net/core/ethtool.c:ethtool_get_regs() to use vmalloc() so
that we can allocate enough memory to keep all the register contents at
once?  Is it critical that contiguous space be allocated for where the
register dump is going to be stored?

3.  Add an additionial ethtool cmd so that there is a new ethtool
command to just read a single register rather then the current ethtool
registers dump.  All the business logic in formatting the register dump
is placed in the driver specific user space ethtool application.

4.  From Jeff Garzik:

> If we start talking about arbitrarily large outputs, it gets 
> increasingly hard to stuff via an ioctl.
> 
> I would rather see userspace open a file descriptor that can be
read(2) 
> or mmap(2)'d, to access large regions of EEPROM or register space.
> 
> Also, it would be preferred to ask this sort of question on 
> netdev@vger.kernel.org (cc'ing me if you'd like), so that we all can 
> collaborate on design.
> 
> 	Jeff
> 

Any guidance anyone could give would be greatly appreciated.

Thanks again.

-Ben



