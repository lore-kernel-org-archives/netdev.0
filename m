From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH 1/8][BNX2X] resubmit as attachments: add bnx2x to
 Kconfig and Makefile
Date: Tue, 09 Oct 2007 18:20:01 +0200
Message-ID: <1191946801.29746.89.camel@eliezer>
References: <470A5795.2000809@broadcom.com>
 <20071008.174603.55855492.davem@davemloft.net>
 <470AFFE3.100@broadcom.com>
 <20071008.212931.82537619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, mchan@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4065 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753020AbXJIQSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 12:18:49 -0400
In-Reply-To: <20071008.212931.82537619.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-10-08 at 21:29 -0700, David Miller wrote:
> From: "Eliezer Tamir" <eliezert@broadcom.com>
> Date: Tue, 09 Oct 2007 06:13:23 +0200
> 
> > Due to the size of the patch I can not post it to the list.
> 
> Understood
> 
> > Here is an FTP link.
> > ftp://Net_sys_anon@ftp1.broadcom.com/bnx2x-0.40.10-net-2.6.24-one.patch.txt
> > 
> > Or if you prefer, I can post it gzipped.
> 
> I took a look at what takes up so much space and it's the firmware and
> this register init stuff.
> 
> The firmware is unavoidable, but wrt. the register init tables there
> appears to be a ton of superfluous information in that header file.

First, I must admit that looking over the file again I noticed an error
on my part in generating the file, all the data that initializes FPGA or
EMULATION should not be there. fixed. 
(This reduced about half of the lines but only a third in size.)


> It seem extreme overkill and I would guess it exists purely to
> simplify your in-house chip validation.  I would really wish you
> wouldn't do this as these tables take up unswappable kernel memory.
> 
> No other driver goes about initializing the chip registers using
> tables like this.  Many of them are sequences of nothing but zeros or
> the same value repeated over and over!  The non-zero values that are
> specific are "magic constants" with no macros to describe up the
> meaning of the bits being set in these registers.

Almost all of the zero-filled tables will be removed.
The rest of the registers do need to be initialized.

I agree that the number of registers that needs to be initialized is
huge, but that is caused by the way the hardware was designed.

The values for the initialization come from several sources:
Some are derived from HW code (the XML files used to derive the verilog
code),
Others (along with much of the machine generated .h files) are generated
at microcode build time, adding a microcode routine will cause the init
values to change, using a new variable can cause an .h file to change.
In the last group which is very small, are registers that are controlled
by the driver.

The values in this file really are machine generated, they really are
not meant to be modified directly by editing the file.

The registers that are under the driver's control are in the main .c
and .h files.


> 
> Huge functions like bnx2x_idle_chk() that just validate register
> values with hundreds of lines of C code are not appropriate for
> submission into a Linux kernel network driver.  Again, this looks
> like code that assists you with in-house chip validation.

The idle check code is not a manufacturing test, it is meant to help
debug the driver and microcode.
If the driver sends an invalid command to one of the CPUs which then
chokes on it, this will tell you which one of them died and the general
whereabouts of the problem. (ingress CPU X is stuck because output queue
Y is full)

I agree that it is not a clean implementation.
I will remove it and it will be re-written. 


> I'm open to putting self tests into the driver, but this adds so much
> bloat it really takes things beyond reasonable.
> 
> Please remove this self-test code and compress the register
> initialization information, preferrably into foo_hw_init() C functions
> as is done traditionally in drivers.  It will take up less space,
> remove the magic values, and make the hardware easier to understand
> for other developers.

> This should get the driver under the posting limit of 400K, which to
> be honest no driver's should be larger than.  Unfortunately that
> firmware file is 350K so you won't have much left to work with :-)
> 
> What we could do is post the driver without the firmware, so that
> people can review the actual C-code by just replying to this posting
> and it won't go over the posting size limit.

( Michael has showed me the trick of how to post with evolution, so I
hope that the mangled patch problem is behind us and I think that I can
now post everything without a problem, Hallelujah!)
> 
> Thanks!
> 


