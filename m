From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: loosing IPMI-card by loading netconsole
Date: Thu, 20 May 2010 08:01:08 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A900118AE59D9@orsmsx509.amr.corp.intel.com>
References: <4BEDCD87.4090602@kernel.org> <20100518131216.GA24750@localhost>
 <20100520101601.GA26235@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32525 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942Ab0ETPBN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 11:01:13 -0400
In-Reply-To: <20100520101601.GA26235@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those lines should not be removed as the default behavior should be to strip the CRC, there was a bug in previous versions of the kernel/driver that caused the default behavior to be reversed from what was intended.  For your particular BMC, however, the CRC appears to be required so you will need to use the CrcStripping=0 module parameter to reverse the default behavior.

-----Original Message-----
From: Henning Fehrmann [mailto:henning.fehrmann@aei.mpg.de] 
Sent: Thursday, May 20, 2010 3:16 AM
To: Tejun Heo
Cc: Ronciak, John; Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Waskiewicz Jr, Peter P; netdev@vger.kernel.org; Carsten Aulbert
Subject: Re: loosing IPMI-card by loading netconsole



Hello,
> 
> 
> Let me re-describe the symptoms.
> I am not loading any ipmi related modules and not the netconsole
> module.
> When booting out current 2.6.32 kernel we can not access the IPMI
> remotely.
> 
> We had one case where the IPMI card was accessible while using this
> kernel but probably due to the fact that eth0 was removed. We do not
> consider this case anymore. 
> 
> This problem does not occur when using an older kernel. 
> 
> It has likely nothing to do with netconsole.
> 
> Here is the bisecting result:
> 
> The sha1 sum of the first bad commit is: 
> 6e50912a442947d5fafd296ca6fdcbeb36b163ff
> 
> Hence, the last good commit has:
> b2f8f7525c8aa1fdd8ad8c72c832dfb571d5f768

I 'reverse patched' the changes: 

diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index e909f96..1342e0b 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -427,6 +427,8 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
                        e1000_validate_option(&crc_stripping, &opt, adapter);
                        if (crc_stripping == OPTION_ENABLED)
                                adapter->flags2 |= FLAG2_CRC_STRIPPING;
+               } else {
+                       adapter->flags2 |= FLAG2_CRC_STRIPPING;
                }
        }
        { /* Kumeran Lock Loss Workaround */


and compiled the kernel. This kernel works and the IPMI card is remotely accessible. 

Can we savely remove this two lines or are we running into other problems?

Cheers,
Henning
