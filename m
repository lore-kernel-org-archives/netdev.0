From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] forcedeth: new backoff implementation
Date: Tue, 08 Apr 2008 18:15:32 +0200
Message-ID: <47FB9A24.7030709@colorfullife.com>
References: <47FA94CC.7070300@nvidia.com> <20080408011425.ff2dc98a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:8407 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbYDHQPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 12:15:40 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1961583fgb.17
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2008 09:15:39 -0700 (PDT)
In-Reply-To: <20080408011425.ff2dc98a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Mon, 07 Apr 2008 17:40:28 -0400 Ayaz Abdulla <aabdulla@nvidia.com> wrote:
>   
>> +static void nv_gear_backoff_reseed(struct net_device *dev)
>> +{
>> +	u8 __iomem *base = get_hwbase(dev);
>> +	u32 miniseed1, miniseed2, miniseed2_reversed, miniseed3, miniseed3_reversed;
>> +	u32 temp, seedset, combinedSeed;
>> +	int i;
>> +
>> +	/* Setup seed for free running LFSR */
>> +	/* We are going to read the time stamp counter 3 times and swizzle bits around to increase randomness */
>>     
>
> I see this driver rigorously observes the 800-column-xterm convention.
>
>   
>> +	rdtscl(miniseed1);
>>     
>
> err, no.  We don't have sufficient Kconfig dependencies in place to be able
> to do this.  You just broke all non-x86.
>
> Suitable fixes would be
>
> a) add #ifdef CONFIG_X86 all over the place
>
> b) use do_gettimeofday() (might be tricky if called from interrupt)
>
> c) use cpu_clock().
>
>   
d) use get_random_bytes()?
It's irq-safe, used e.g. by the network code for the TCP sequence numbers.
>> +	/* Ensure seeds are not the same */
>> +	if ((combinedSeed & NVREG_BKOFFCTRL_SEED_MASK) ==
>> +	    (combinedSeed & (NVREG_BKOFFCTRL_SEED_MASK << NVREG_BKOFFCTRL_GEAR)))
>> +		combinedSeed = 0x3FF3FF;
>> +
>>     
I don't understand this block: The seed consists of two parts, each 12 bits.
Both parts mustn't be identical. If both parts are identical, then both 
are set to 0x3ff.
But if both are 0x3ff, then they are identical. Is that intentional?

--
    Manfred
