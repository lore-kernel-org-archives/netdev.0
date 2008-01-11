From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: doubt in e1000_io_write()
Date: Fri, 11 Jan 2008 17:35:05 -0200
Message-ID: <1200080105.9349.47.camel@cafe>
References: <1200064410.1351.3.camel@vglwks010.vgl2.office.vaioni.com>
	 <4787B861.9060203@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeba Anandhan <jeba.anandhan@vaioni.com>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.br.ibm.com ([32.104.18.25]:43367 "EHLO igw2.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760323AbYAKTfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 14:35:17 -0500
Received: from mailhub1.br.ibm.com (mailhub1 [9.18.232.109])
	by igw2.br.ibm.com (Postfix) with ESMTP id 0E24717F4CD
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:29:30 -0200 (BRDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0BJZDdN3854396
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:35:13 -0200
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0BJZCQY020763
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:35:13 -0200
In-Reply-To: <4787B861.9060203@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Auke, 
On Fri, 2008-01-11 at 10:41 -0800, Kok, Auke wrote:
> > Even hw structure has not been used, why it has been passed into
> > e1000_io_write function?
> 
> 2.6.12.3? why do you care? that code is probably long gone... was that function
> even used?

I noticed that this also happens on upstream netdev-2.6 branch. 
Moreover the function e1000_write_reg_io() from e1000_hw.c is the only
function that calls e1000_io_write().

I write a small patch that fixes it.

diff -uNp e1000.old/e1000_hw.c e1000/e1000_hw.c
--- e1000.old/e1000_hw.c        2008-01-11 14:14:36.000000000 -0500
+++ e1000/e1000_hw.c    2008-01-11 14:13:36.000000000 -0500
@@ -6654,8 +6654,8 @@ e1000_write_reg_io(struct e1000_hw *hw,
     unsigned long io_addr = hw->io_base;
     unsigned long io_data = hw->io_base + 4;
 
-    e1000_io_write(hw, io_addr, offset);
-    e1000_io_write(hw, io_data, value);
+    e1000_io_write(io_addr, offset);
+    e1000_io_write(io_data, value);
 }
 
 /******************************************************************************
diff -uNp e1000.old/e1000_hw.h e1000/e1000_hw.h
--- e1000.old/e1000_hw.h        2008-01-11 14:13:00.000000000 -0500
+++ e1000/e1000_hw.h    2008-01-11 14:15:47.000000000 -0500
@@ -427,7 +427,7 @@ int32_t e1000_read_pcie_cap_reg(struct e
 void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc);
 int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
 /* Port I/O is only supported on 82544 and newer */
-void e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value);
+void e1000_io_write(unsigned long port, uint32_t value);
 int32_t e1000_disable_pciex_master(struct e1000_hw *hw);
 int32_t e1000_check_phy_reset_block(struct e1000_hw *hw);
 
diff -uNp e1000.old/e1000_main.c e1000/e1000_main.c
--- e1000.old/e1000_main.c      2008-01-11 14:14:36.000000000 -0500
+++ e1000/e1000_main.c  2008-01-11 14:13:23.000000000 -0500
@@ -4919,7 +4919,7 @@ e1000_read_pcie_cap_reg(struct e1000_hw 
 }
 
 void
-e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value)
+e1000_io_write(unsigned long port, uint32_t value)
 {
        outl(value, port);
 }

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

