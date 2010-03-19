From: "yucheng.wang" <yucheng.wang@windriver.com>
Subject: Re: Help: the 82577 network driver can't work
Date: Fri, 19 Mar 2010 19:10:02 +0800
Message-ID: <4BA35B8A.6030803@windriver.com>
References: <4BA1BCC9.1080401@windriver.com>
	<8DD2590731AB5D4C9DBF71A877482A90619CAAC4@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A90619CAAC4@orsmsx509.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Allan, Bruce W wrote:
> On Wednesday, March 17, 2010 10:40 PM, yucheng.wang wrote:
>> Hi all,
>>
>> I need some help for intel 82577 network card driver, named
>> CONFIG_E1000E in the kernel config.
>>
>> In the kernel 2.6.31 and 2.6.32, the patch works well, but in the
>> kernel 
>> 2.6.33 and 2.6.34-rc1 the dmesg shows some problem below,and the
>> network card can't work.
>> **********************************************************************
>> e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
>> e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
>> e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
>> 0000:00:19.0: 0000:00:19.0: Write-protect NVM Disabled
>> 0000:00:19.0: 0000:00:19.0: Failed to initialize MSI interrupts.
>> Falling back to legacy interrupts.
>> ata4: SATA link down (SStatus 0 SControl 300)
>> ata3: SATA link down (SStatus 0 SControl 300)
>> ata2.00: SATA link down (SStatus 0 SControl 300)
>> ata2.01: SATA link down (SStatus 0 SControl 300)
>> ata1.00: SATA link down (SStatus 0 SControl 0)
>> ata1.01: SATA link down (SStatus 0 SControl 300)
>> e1000e 0000:00:19.0: PCI INT A disabled
>> e1000e: probe of 0000:00:19.0 failed with error -3
>> ********************************************************************
>> I read the source code using 2.6.34-rc-1 kernel.
>> When calling e1000e_git_phy_id(), the function returns a wrong value
>> "-3". The kernel 2.6.31 and 2.6.32 ignores this error, and the kernel
>> run well. The function e1000_acquire_swflag_ich8lan( ), called by
>> e1000e_get_phy_id(), return "-3".
>>   ************************** The code
>>        ********************************* extcnf_ctrl |=
>>        E1000_EXTCNF_CTRL_SWFLAG; ew32(EXTCNF_CTRL, extcnf_ctrl);
>>
>>        while (timeout) {
>>            extcnf_ctrl = er32(EXTCNF_CTRL);
>>            if (extcnf_ctrl&  E1000_EXTCNF_CTRL_SWFLAG)
>>                break;
>>
>>            mdelay(1);
>>            timeout--;
>>        }
>>
>>        if (!timeout) {
>>            e_dbg("Failed to acquire the semaphore.\n");
>>            extcnf_ctrl&= ~E1000_EXTCNF_CTRL_SWFLAG;
>>            ew32(EXTCNF_CTRL, extcnf_ctrl);
>>            ret_val = -E1000_ERR_CONFIG;
>>            goto out;
>>        }
>>   ************************** The code
>> ********************************* The kernel can't set the bit
>> E1000_EXTCNF_CTRL_SWFLAG of the register EXTCNF_CTRL.
>>
>> We found the information in the 82577 user manual:
>> In the Extended Configuration Control Register.
>>   Software Semaphore FLAG (SWFLAG). This bit is set by the device
>> driver to gain access permission to shared CSR registers with the
>> firmware and hardware. The bit is initialized on power up PCI reset
>> and software reset. and the default value when Reset is "0b".
>>
>> I don't know why the bit E1000_EXTCNF_CTRL_SWFLAG is not right, and
>> not find any information about writing the bit. Due to the bit
>> returns 0 when reset the controller, we wrote the patch below.
>> *****************************The
>> patch********************************** diff --git
>> a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c index
>> 8b6ecd1..b3e20f4 100644 --- a/drivers/net/e1000e/ich8lan.c
>> +++ b/drivers/net/e1000e/ich8lan.c
>> @@ -224,6 +224,7 @@ static void
>> e1000_power_down_phy_copper_ich8lan(struct e1000_hw *hw);
>>   static void e1000_lan_init_done_ich8lan(struct e1000_hw *hw);
>>   static s32  e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool
>>   link); static s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw);
>> +static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw);
>>
>>   static inline u16 __er16flash(struct e1000_hw *hw, unsigned long
>>   reg) {
>> @@ -276,8 +277,12 @@ static s32 e1000_init_phy_params_pchlan(struct
>> e1000_hw *hw)
>>
>>       phy->id = e1000_phy_unknown;
>>       ret_val = e1000e_get_phy_id(hw);
>> -    if (ret_val)
>> -        goto out;
>> +    if (ret_val) {
>> +        e1000_reset_hw_ich8lan(hw);
>> +        ret_val = e1000e_get_phy_id(hw);
>> +        if (ret_val)
>> +            goto out;
>> +    }
>>       if ((phy->id == 0) || (phy->id == PHY_REVISION_MASK)) {
>>           /*
>>            * In case the PHY needs to be in mdio slow mode (eg.
>> 82577), 
>> ****************************************************************************
>> I'm not sure it's right, but using the patch, 82577 network can work
>> well.I need more eyes about this, how can I make the patch better?
>> Any suggestion would be helped me make the patch better.
>>
>> By the way, we find 3 patches make it not well.
>>
>>  From 0be8401051c716be4533272e983b7eed3d83946d Mon Sep 17 00:00:00
>> 2001 From: Bruce Allan <bruce.w.allan@intel.com>
>> Date: Wed, 2 Dec 2009 17:03:18 +0000
>> Subject:  e1000e: correct ICH/PCH PHY operations function pointers
>>
>>  From fddaa1aff881c98f524221236af98ce70dcd04cf Mon Sep 17 00:00:00
>> 2001 
>>
>> From: Bruce Allan <bruce.w.allan@intel.com>
>> Date: Wed, 13 Jan 2010 01:52:49 +0000
>> Subject: e1000e: MDIO slow mode should always be done for 82577
>>
>>  From baf86c9d36826fab0160251bbc87dfab3af48a21 Mon Sep 17 00:00:00
>> 2001 
>>
>> From: Bruce Allan <bruce.w.allan@intel.com>
>> Date: Wed, 13 Jan 2010 01:53:08 +0000
>> Subject: e1000e: workaround link issues on busy hub in half duplex on
>> 82577/82578
>>
>> thanks,
>> Yucheng.Wang
> 
> [Adding e1000-devel@lists.sf.net (the mailing list for Intel wired GbE drivers)]
> 
> Thanks for reporting the issue.  The 3 patches you list that appear to break e1000e on 82577 are necessary.  The patch you suggest to resolve the issue is almost exactly the same as one we have been working on in-house here at Intel and will be pushed upstream shortly.  There are still a couple unresolved issues with it however so it will be another couple days.
Thanks for giving me the info. but there are some problems I want to 
understand it for the issue. Would you like to telling me why? All the 
problems happens in the kenel 2.6.34-rc-1.

1. When I insmod the module e1000e, the network card can work well. But 
when I build the driver in the kernel the "-3" error happens. 
theoretically, there is no difference of driver between in the kernel 
and modules. The problem is strange to me, so I'm interested to know who 
did this?

2. If I use my patch to resolve the issue, which problem would happens 
when reset the hardware of network like me to do? And the e1000e problem 
is not only support 82577, so the workaround would impact other card 
using e1000e, which time and when to reset the hardware is best?

3. I read the source code, and find the function "e1000_read_phy_reg_hv" 
cannot return the correct value when execute "file:ich8lan.c,line:290 
       ret_val = e1000_set_mdio_slow_mode_hv(hw);", so which register 
impact this?

4. If the patch from Intel finished, about when I can read the patch?

5. The version of e1000e is "e1000e: Intel(R) PRO/1000 Network Driver - 
1.0.2-k2" in the official kernel 2.6.34-rc-1, but in the Intel's 
website, the version is "1.1.2.1a", the webpage is 
http://downloadcenter.intel.com/SearchResult.aspx?lang=eng&keyword=%22e1000e%22 
which difference between the two version of e1000e driver? And I noticed 
that in the sourceforge's maillist, the intel's e1000e driver 1.1.2.1a 
has some problem when build in 2.6.34-rc-1, which I have been encountered.

I think you were crazy when you see so many questions, and cost you too 
much time to answer it. But I'm still want to know the answer of these 
questions. Hope you can reply me to understand the e100e network.

Thanks a lot.
yucheng.wang
> 
> Thanks again,
> Bruce.


------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
