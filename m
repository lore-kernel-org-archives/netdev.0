From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Fri, 20 Oct 2006 08:51:28 -0700
Message-ID: <4538F080.5020003@intel.com>
References: <45375135.5050206@cj.jp.nec.com> <45379C14.5050901@foo-projects.org> <4538BFF2.2040207@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51859 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1946265AbWJTPxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 11:53:39 -0400
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
In-Reply-To: <4538BFF2.2040207@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kenzo Iwami wrote:
> Hi,
> 
> Thank you for your comment.
> 
>>> A watchdog timeout panic occurred in e1000 driver (7.2.9-NAPI).
>> where's the panic message ?
> 
> attached the panic message (e1000_panic).
> 
> [...]
>>> This problem only occurs on a server using ethernet controller inside
>>> 631xESB/632xESB, and NMI watchdog enabled.
>> why only this system? have you seen/tried it on other machines?
> 
> This problem is caused by e1000_get_software_semaphore() being called from
> within the interrupt handler, while the interrupted code is still holding
> this semaphore.  e1000_get_software_semaphore() is called from
> e1000_get_hw_eeprom_semaphore() only when hw->mac_type is e1000_80003es2lan.
> This condition is true only for MACs inside 631xESB/632xESB.
> 
> When this problem happens e1000_get_software_semaphore() will wait for
> 16 seconds (inside the interrupt handler) before it fails, thus causing
> the watchdog timeout.
> 
> I haven't actually tried it on other machines, but theoretically, it will
> only happen on MAC inside 631xESB/632xESB chip set.
> 
> [...]
>> Reverting this could would not be a fix, but only a workaround that leaves the problem 
>> still in the code, and as such not progress in the right direction.
>>
>> I find this report extremely edgy, but I'll look into the fact that the driver attempts 
>> to sleep for 16384 + 1 msec, which seems overly long :)
>>
>> As a side note, most other e1000 NIC's use hardcoded word_size numbers, but esb2 systems 
>> read it from a register/eeprom. Can you send me the output of `ethtool -e ethX` ? 
>> off-list is OK, it might be large.
> 
> attached is the output of "ethtool -e ethX" (eeprom_eth0).

thanks.

This panic report falls in the category "how hard can I break my system as root". 
Explicitly abusing the system performing restricted calls depletes resources and 
harasses the sw lock (in this case). The reason that the driver attempts to wait that 
long is that in the case of ESB2 systems, the SPI interface to the EEPROM can be slow, 
thus taking a long time to complete certain commands.

We're looking into making this theoretical lock time shorter in the mean time, thanks 
for reporting this.

Cheers,

Auke
