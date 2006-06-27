From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 11/21] e1000: disable CRC stripping workaround
Date: Tue, 27 Jun 2006 07:29:03 -0700
Message-ID: <44A140AF.5080003@intel.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052029.25497.67575.stgit@gitlost.site> <44A08E84.1000902@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10765 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1161069AbWF0O3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:29:21 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44A08E84.1000902@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> CRC stripping is breaking SMBUS-connected BMC's. We disable this
>> feature to make it work. This fixes related bugs regarding SOL.
>>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/e1000/e1000_main.c |    7 ++++++-
>>  1 files changed, 6 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/e1000/e1000_main.c 
>> b/drivers/net/e1000/e1000_main.c
>> index c44ed6f..7787299 100644
>> --- a/drivers/net/e1000/e1000_main.c
>> +++ b/drivers/net/e1000/e1000_main.c
>> @@ -1628,8 +1628,11 @@ e1000_setup_rctl(struct e1000_adapter *a
>>          E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
>>          (adapter->hw.mc_filter_type << E1000_RCTL_MO_SHIFT);
>>  
>> +    /* disable hardware stripping of CRC because it breaks
>> +     * BMC firmware connected over SMBUS
>>      if (adapter->hw.mac_type > e1000_82543)
>>          rctl |= E1000_RCTL_SECRC;
>> +     */
>>  
>>      if (adapter->hw.tbi_compatibility_on == 1)
>>          rctl |= E1000_RCTL_SBP;
>> @@ -1696,7 +1699,9 @@ e1000_setup_rctl(struct e1000_adapter *a
>>          rfctl |= E1000_RFCTL_IPV6_DIS;
>>          E1000_WRITE_REG(&adapter->hw, RFCTL, rfctl);
>>  
>> -        rctl |= E1000_RCTL_DTYP_PS | E1000_RCTL_SECRC;
>> +        /* disable the stripping of CRC because it breaks
>> +         * BMC firmware connected over SMBUS */
>> +        rctl |= E1000_RCTL_DTYP_PS /* | E1000_RCTL_SECRC */;
> 
> This is quite ugly.  You are basically bloating the code with historic, 
> dead code, no different than filling the e1000/*.c with '#if 0' regions.
> 
> Just delete it, and explain why in the patch description.


Adjusted the patch on our git server to this:


diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c44ed6f..a9e55dc 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1628,9 +1628,6 @@ e1000_setup_rctl(struct e1000_adapter *a
                 E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
                 (adapter->hw.mc_filter_type << E1000_RCTL_MO_SHIFT);

-       if (adapter->hw.mac_type > e1000_82543)
-               rctl |= E1000_RCTL_SECRC;
-
         if (adapter->hw.tbi_compatibility_on == 1)
                 rctl |= E1000_RCTL_SBP;
         else
@@ -1696,7 +1693,7 @@ e1000_setup_rctl(struct e1000_adapter *a
                 rfctl |= E1000_RFCTL_IPV6_DIS;
                 E1000_WRITE_REG(&adapter->hw, RFCTL, rfctl);

-               rctl |= E1000_RCTL_DTYP_PS | E1000_RCTL_SECRC;
+               rctl |= E1000_RCTL_DTYP_PS;

                 psrctl |= adapter->rx_ps_bsize0 >>
                         E1000_PSRCTL_BSIZE0_SHIFT;

Cheers,

Auke
