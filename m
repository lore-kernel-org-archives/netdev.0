From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 10/21] e1000: force register write flushes to circumvent
 broken platforms
Date: Tue, 27 Jun 2006 07:36:51 -0700
Message-ID: <44A14283.50301@intel.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052027.25497.51513.stgit@gitlost.site> <44A08E33.3020501@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23067 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1161070AbWF0OhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:37:00 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44A08E33.3020501@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> A certain AMD64 bridge (8132) has an option to turn on write combining
>> which breaks our adapter. To circumvent this we need to flush every 
>> write.
>>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/e1000/e1000_hw.c   |   24 ++++++++++++++++++++++--
>>  drivers/net/e1000/e1000_main.c |   18 +++++++++++-------
>>  2 files changed, 33 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
>> index 3959039..749d621 100644
>> --- a/drivers/net/e1000/e1000_hw.c
>> +++ b/drivers/net/e1000/e1000_hw.c
>> @@ -705,8 +705,12 @@ e1000_init_hw(struct e1000_hw *hw)
>>      /* Zero out the Multicast HASH table */
>>      DEBUGOUT("Zeroing the MTA\n");
>>      mta_size = E1000_MC_TBL_SIZE;
>> -    for(i = 0; i < mta_size; i++)
>> +    for(i = 0; i < mta_size; i++) {
>>          E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
>> +        /* use write flush to prevent Memory Write Block (MWB) from
>> +         * occuring when accessing our register space */
>> +        E1000_WRITE_FLUSH(hw);
>> +    }
> 
> NAK.  We can't crap up every driver just for one weird piece of hardware.
> 
> If this problem falls outside the grounds of mmiowb() [see 
> Documentation/memory-barriers.txt], then other solutions need to be 
> looked into... ioremap_nocache() ?  Tweaking the MTRR for this region? 
> Chipset quirk?  ...

If there is an in-kernel fix for this that would make these flushes obsolete I 
would certainly prefer it too, unfortunately we can't fix already released 
kernels and our driver still needs to work there too, so that's why I queued 
it. It can be dropped from this series if that's preferred.

Cheers,

Auke
