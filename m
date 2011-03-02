From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Tue, 1 Mar 2011 22:25:31 -0800
Message-ID: <20110301222531.24832a93@nehalam>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	<alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	<1298793252.8726.45.camel@edumazet-laptop>
	<AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
	<20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
	<AANLkTimofhhH5omyk=HhkyaNG+MGqoac4rDf=dPuR7K-@mail.gmail.com>
	<cbb9e1113901f1a324359b6ed3f1a611@localhost>
	<AANLkTikje6rvjSfEA3CvUjdgFwzk-SBZDdO5kQvi6LZy@mail.gmail.com>
	<AANLkTin_jY_J7tJseMLVmrQVVRezOVQTGCgB_6tefgXJ@mail.gmail.com>
	<alpine.DEB.1.10.1103010137400.7942@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Heffner <johnwheffner@gmail.com>,
	Bill Sommerfeld <wsommerfeld@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Albert Cahalan <acahalan@gmail.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1103010137400.7942@uplift.swm.pp.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Mar 2011 01:46:51 +0100 (CET)
Mikael Abrahamsson <swmike@swm.pp.se> wrote:

> On Mon, 28 Feb 2011, John Heffner wrote:
> 
> > Right... while I generally agree that a fixed-length drop-tail queue 
> > isn't optimal, isn't this problem what the various AQM schemes try to 
> > solve?
> 
> I am not an expert on exactly how Linux does this, but for Cisco and for 
> instance ATM interfaces, there are two stages of queuing. One is the 
> "hardware queue", which is a FIFO queue going into the ATM framer. If one 
> wants low CPU usage, then this needs to be high so multiple packets can be 
> put there per interrupt. Since AQM is working before this, it also means 
> the low-latency-queue will have a higher latency as it ends up behind 
> larger packets in the hw queue.
> 
> So on what level does the AQM work in Linux? Does it work similarily, that 
> txqueuelen is a FIFO queue to the hardware that AQM feeds packets into?
> 
> Also, when one uses WRED the thinking is generally to keep the average 
> queue len down, but still allow for bursts by dynamically changing the 
> drop probability and where it happens. When there is no queuing, allow for 
> big queue (so it can fill up if needed), but if the queue is large for 
> several seconds, start to apply WRED to bring it down.
> 
> There is generally no need at all to constantly buffer > 50 ms of data, 
> then it's better to just start selectively dropping it. In time of 
> burstyness (perhaps when re-routing traffic) there is need to buffer 
> 200-500ms of during perhaps 1-2 seconds before things stabilize.
> 
> So one queuing scheme and one queue limit isn't going to solve this, there 
> need to be some dynamic built into the system for it to work well.
> 
> AQM needs to feed into a relatively short hw queue and AQM needs to exist 
> on output also when the traffic is sourced from the box itself, no tonly 
> routed. It would also help if the default would be to use let's say 25% of 
> the bandwidth for smaller packets (< 200 bytes or so) which generally are 
> for interactive uses or are ACKs.
> 

It is possible to build an equivalent to WRED out existing GRED queuing
discipline but it does require a lot of tc knowledge to get right.
The inventor of RED (Van Jacobsen) has issues with WRED because of
the added complexity of queue selection. RED requires some parameters
which the average user has no idea how to set.

There are several problems with RED that prevent prevent VJ from
recommending it in the current form.

  http://gettys.wordpress.com/2010/12/17/red-in-a-different-light/


-- 
