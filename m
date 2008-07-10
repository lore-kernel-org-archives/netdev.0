From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: e1000e "Detected Tx Unit Hang"
Date: Thu, 10 Jul 2008 22:25:41 +0000 (UTC)
Message-ID: <489E193C.4040804@embedded-sol.com>
References: <4866211E.6040704@embedded-sol.com> <36D9DB17C6DE9E40B059440DB8D95F5205953CF7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:56772 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790AbYGJWZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:25:23 -0400
Date: Sun, 10 Aug 2008 01:25:00 +0300
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5205953CF7@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jesse

I can ping through this card without a problem. Also, doing dd over NFS 
with block size
up to 512 bytes works fine.

I'll apply the patch you've mentioned and report back.

Thanks.

Felix

Brandeburg, Jesse wrote:
> Felix Radensky wrote:
>   
>> Hi, Jesse
>>
>> I can confirm that I'm also getting these errors with 2.6.26-rc8 on
>> PowerPC platform (AMCC 460EX CPU). The Intel adapter is (as reported
>> by lspci -vv) 
>>     
>
> Interesting, I haven't heard back from Herbert, but thanks for the
> reply.
>
> are you getting the NETDEV WATCHDOG messages in your log?  does ethtool
> -S show any tx_timeout?
>
> can you try applying a patch similar to
> https://sourceforge.net/tracker/download.php?group_id=42302&atid=447449&
> file_id=283326&aid=2007017
>
> aka http://tinyurl.com/5vl5g4
>
>
>  
>   
>> 41:00.0 Ethernet controller: Intel Corporation 82572EI Gigabit
>> Ethernet Controller (Copper) (rev 06)
>>         Subsystem: Intel Corporation PRO/1000 PT Desktop Adapter
>>     
>
> x1 PCIe adapter
>
>   
>> Some relevant output from dmesg:
>>
>> e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
>> e1000e: Copyright (c) 1999-2008 Intel Corporation.
>> e1000e 0000:41:00.0: enabling device (0006 -> 0007)
>> eth2: (PCI Express:2.5GB/s:Width x1) 00:1b:21:1e:2d:2a
>> eth2: Intel(R) PRO/1000 Network Connection
>> eth2: MAC: 1, PHY: 4, PBA No: d50854-003
>> eth2: Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX
>> eth2: 10/100 speed: disabling TSO
>>
>> I can reliably reproduce the  problem  by running
>>
>> dd=/dev/zero of=/mnt/1M bs=1024 count=1024
>>
>> where /mnt is mounted over NFS  with the following options (default
>> ones)
>>
>>     
> rw,vers=3,rsize=32768,wsize=32768,namlen=255,hard,nointr,nolock,proto=ud
> p,timeo=7,retrans=3,sec=sys,mountproto=udp,addr
>   
>> Below is register dump produced by patched driver.
>>
>> eth2: Detected Tx Unit Hang:
>>   TDH                  <25>
>>   TDT                  <25>
>>     
>
> Hardware completed all the packets, but no writebacks made it back to
> main memory.
>
>   
>> TX Desc ring0 dump
>> Tl[0x000]    0000000000000000 0000000000000000 000000001D734802 0022
>> 2 00000000FFFFD0FE 00000000 NTC
>>     
>
> Ewww, even worse, it seems that something zeroed out the memory in the
> tx descriptor ring.  I strongly suspect something bad at your
> system/chipset level. 
>
>
>   
>> Tl[0x001]    0000000000000000 0000000000000000 0000000015FE2A84 057C
>> 1 00000000FFFFD0FE 00000000
>> Tl[0x002]    0000000000000000 0000000000000000 0000000015FA1000 004C
>> 2 00000000FFFFD0FE dd739f00
>> Tl[0x003]    0000000000000000 0000000000000000 000000001D734A02 0022
>> 4 00000000FFFFD0FE 00000000
>> Tl[0x004]    0000000000000000 0000000000000000 0000000015FA104C 05C8
>> 4 00000000FFFFD0FE dd739c80
>> Tl[0x005]    0000000000000000 0000000000000000 000000001D734C02 0022
>> 6 00000000FFFFD0FE 00000000
>> Tl[0x006]    0000000000000000 0000000000000000 0000000015FA1614 05C8
>> 6 00000000FFFFD0FE dd739280
>> Tl[0x007]    0000000000000000 0000000000000000 000000001D734E02 0022
>> 9 00000000FFFFD0FE 00000000
>> Tl[0x008]    0000000000000000 0000000000000000 0000000015FA1BDC 0424
>> 8 00000000FFFFD0FE 00000000
>> Tl[0x009]    0000000000000000 0000000000000000 0000000015EC6000 01A4
>> 9 00000000FFFFD0FE dd7390a0
>> Tl[0x00A]    0000000000000000 0000000000000000 000000001D73A002 0022
>> B 00000000FFFFD0FE 00000000
>> Tl[0x00B]    0000000000000000 0000000000000000 0000000015EC61A4 05C8
>> B 00000000FFFFD0FE dd739e60
>> Tl[0x00C]    000000001D73A202 0000000002000022 000000001D73A202 0022
>> D 00000000FFFFD0FE 00000000
>>     
>
> Either the driver is half done cleaning up, which doesn't seem likely
> due to the driver not ZEROING all the first two 64 bit columns, but the
> last column which contains an skb pointer still indicates cleanup hasn't
> completed.
>
> Does this card work at all in your system?
>
> Jesse
>   
