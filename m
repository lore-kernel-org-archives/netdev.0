From: Haicheng Li <haicheng.li@linux.intel.com>
Subject: Re: [net:master 1/9] pch_gbe_main.c:(.text+0x510370): undefined reference
 to `pch_ch_control_write'
Date: Sun, 07 Oct 2012 01:21:09 +0800
Message-ID: <50706885.1030908@linux.intel.com>
References: <50701EEC.7080805@linux.intel.com>	<20121006.092207.1280541690613202532.davem@davemloft.net>	<50703B1B.2040705@linux.intel.com> <20121006.102132.1497404004255213029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14739 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755081Ab2JFRVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2012 13:21:11 -0400
In-Reply-To: <20121006.102132.1497404004255213029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/06/2012 10:21 PM, David Miller wrote:
> From: Haicheng Li<haicheng.li@linux.intel.com>
> Date: Sat, 06 Oct 2012 22:07:23 +0800
>
>> On 10/06/2012 09:22 PM, David Miller wrote:
>>> From: Haicheng Li<haicheng.li@linux.intel.com>
>>> Date: Sat, 06 Oct 2012 20:07:08 +0800
>>>
>>>> The failure is due to the CONFIG_PPS is not set there, consequently
>>>> CONFIG_PTP_1588_CLOCK can not be set as =y anyway.
>>>>
>>>> So David's patch of "da1586461e53a4dd045738cce309ab488970f0ef [1/9]
>>>> pch_gbe: Fix PTP dependencies" is buggy. Furthermore, I think using
>>>> "selects" to resolve such dependency issue is not good idea as it
>>>> won't visit the dependencies.
>>>>
>>>> David, I would still suggest to take my original patch:
>>>> https://lkml.org/lkml/2012/9/28/70
>>>>
>>>> + depends on PTP_1588_CLOCK_PCH&&   (PCH_GBE=m || PTP_1588_CLOCK_PCH=y)
>>>>
>>>> or simply like:
>>>
>>> This is all very rediculous if you ask me.
>>>
>>> Why should the user have to know a detail like the underlying
>>> PTP chip type just to enable PTP on his networking card?
>>>
>>> Because that is what you are making him do with your change.
>>>
>>> Select removed the necessity of the user having to know these
>>> things.
>> However it possibly breaks the build...
>>
>> IMHO, the reason why the dependency of PCH_PTP becomes so tricky is
>> that the code of these two modules call the functions of each other
>> (bad code structure?). To fix it neatly, either we restructure the
>> code or just simply make it:
>> + depends on PTP_1588_CLOCK_PCH=y
>>
>> For PCH_GBE=m case, it does be able to pass the build test, but I'm
>> afraid it won't be smoothly workable via "insmod" due to the
>> codependency of these two when PCH_PTP is enabled.
>
> Then why does it work for IXGBE and others who use select?

They explicitly select all the possible dependencies if they are bug-free (I 
didn't strictly check them).

Take IXGBE_PTP as example, it explicitly selects PPS, and also depends on 
EXPERIMENTAL:
config IXGBE_PTP
         bool "PTP Clock Support"
         default n
         depends on IXGBE && EXPERIMENTAL
         select PPS
         select PTP_1588_CLOCK

So if you stick to use "select" as the convention of such build issue fixing, 
fengguang's build failure would be fixed by:
	+ depends on EXPERIMENTAL
	+ select PPS
	+ select PTP_1588_CLOCK

would you prefer this way?
