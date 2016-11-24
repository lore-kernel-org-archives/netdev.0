From: David Miller <davem@davemloft.net>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Thu, 24 Nov 2016 11:04:16 -0500 (EST)
Message-ID: <20161124.110416.198867271899443489.davem@davemloft.net>
References: <20161123105125.GA26394@amd>
        <20161124085506.GA25007@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: pavel@ucw.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161124085506.GA25007@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel@ucw.cz>
Date: Thu, 24 Nov 2016 09:55:06 +0100

> Hi!
> 
>> I'm debugging strange delays during transmit in stmmac driver. They
>> seem to be present in 4.4 kernel (and older kernels, too). Workload is
>> burst of udp packets being sent, pause, burst of udp packets, ...
>> 
>> Test code is attached, I use these parameters for testing:
>> 
>> ./udp-test raw 10.0.0.6 1234 1000 100 30
>> 
>> The delays seem to be related to coalescing:
>> 
>> drivers/net/ethernet/stmicro/stmmac/common.h
>> #define STMMAC_COAL_TX_TIMER    40000
>> #define STMMAC_MAX_COAL_TX_TICK 100000
>> #define STMMAC_TX_MAX_FRAMES    256
>> 
>> If I lower the parameters, delays are gone, but I get netdev watchdog
>> backtrace followed by broken driver.
>> 
>> Any ideas what is going on there?
> 
> 4.9-rc6 still has the delays. With the
> 
> #define STMMAC_COAL_TX_TIMER 1000
> #define STMMAC_TX_MAX_FRAMES 2
> 
> settings, delays go away, and driver still works. (It fails fairly
> fast in 4.4). Good news. But the question still is: what is going on
> there?

256 packets looks way too large for being a trigger for aborting the
TX coalescing timer.

Looking more deeply into this, the driver is using non-highres timers
to implement the TX coalescing.  This simply cannot work.

1 HZ, which is the lowest granularity of non-highres timers in the
kernel, is variable as well as already too large of a delay for
effective TX coalescing.

I seriously think that the TX coalescing support should be ripped out
or disabled entirely until it is implemented properly in this driver.
