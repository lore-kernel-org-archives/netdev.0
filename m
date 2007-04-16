From: John Heffner <jheffner@psc.edu>
Subject: Re: TCP connection stops after high load.
Date: Mon, 16 Apr 2007 14:07:55 -0400
Message-ID: <4623BB7B.3010705@psc.edu>
References: <7e63f56c0704121411w6faea114g756d780b5a011463@mail.gmail.com>	 <20070412.141550.133265618.davem@davemloft.net>	 <7e63f56c0704150514q3b1271e8lcc9e8f30387d7540@mail.gmail.com>	 <46224561.9010801@psc.edu> <7e63f56c0704150849r5b019962v296b4266021a6fe1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	greearb@candelatech.com
To: Robert Iakobashvili <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:57484 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251AbXDPSH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 14:07:59 -0400
In-Reply-To: <7e63f56c0704150849r5b019962v296b4266021a6fe1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Iakobashvili wrote:
> Hi John,
> 
> On 4/15/07, John Heffner <jheffner@psc.edu> wrote:
>> Robert Iakobashvili wrote:
>> > Vanilla 2.6.18.3 works for me perfectly, whereas 2.6.19.5 and
>> > 2.6.20.6 do not.
>> >
>> > Looking into the tcp /proc entries of 2.6.18.3 versus 2.6.19.5
>> > tcp_rmem and tcp_wmem are the same, whereas tcp_mem are
>> > much different:
>> >
>> > kernel                  tcp_mem
>> > ---------------------------------------
>> > 2.6.18.3    12288 16384 24576
>> > 2.6.19.5      3072    4096   6144
> 
>> Another patch that went in right around that time:
>>
>> commit 52bf376c63eebe72e862a1a6e713976b038c3f50
>> Author: John Heffner <jheffner@psc.edu>
>> Date:   Tue Nov 14 20:25:17 2006 -0800
>>
>>      [TCP]: Fix up sysctl_tcp_mem initialization.
>> (This has been changed again for 2.6.21.)
>>
>> In the dmesg, there should be some messages like this:
>> IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
>> TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
>> TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
>> TCP: Hash tables configured (established 131072 bind 65536)
>>
>> What do yours say?
> 
> For the 2.6.19.5, where we have this problem:
>> From dmsg:
> IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
> TCP established hash table entries: 16384 (order: 5, 131072 bytes)
> TCP bind hash table entries: 8192 (order: 4, 65536 bytes)
> 
> #cat /proc/sys/net/ipv4/tcp_mem
> 3072    4096    6144
> 
> MemTotal:       484368 kB
> CONFIG_HIGHMEM4G=y


Yes, this difference is caused by the commit above.  The old way didn't 
really make a lot of sense, since it was different based on smp/non-smp 
and page size, and had large discontinuities at 512MB and every power of 
two.  It was hard to make the limit never larger than the memory pool 
but never too small either, when based on the hash table size.

The current net-2.6 (2.6.21) has a redesigned tcp_mem initialization 
that should give you more appropriate values, something like 45408 60546 
90816.  For reference:

Commit: 53cdcc04c1e85d4e423b2822b66149b6f2e52c2c
Author: John Heffner <jheffner@psc.edu> Fri, 16 Mar 2007 15:04:03 -0700

     [TCP]: Fix tcp_mem[] initialization.

     Change tcp_mem initialization function.  The fraction of total memory
     is now a continuous function of memory size, and independent of page
     size.

     Signed-off-by: John Heffner <jheffner@psc.edu>
     Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks,
   -John
