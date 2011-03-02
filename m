From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: txqueuelen has wrong units; should be time
Date: Wed, 2 Mar 2011 04:10:02 +0100 (CET)
Message-ID: <alpine.DEB.1.10.1103020358010.7942@uplift.swm.pp.se>
References: <20110228165501.GC2515@tuxdriver.com>  <AANLkTinj5szpStmA+fZ1xggdyTS+sd8Y9jXaYquDNEjs@mail.gmail.com>  <AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>  <20110228.201852.193726064.davem@davemloft.net>
 <AANLkTi=eDQh9Kvr9N_dTC5Cnbcfb+DbO-6tLxkZiEp9v@mail.gmail.com> <1298964381.2676.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Albert Cahalan <acahalan@gmail.com>,
	David Miller <davem@davemloft.net>, johnwheffner@gmail.com,
	linville@tuxdriver.com, jussi.kivilinna@mbnet.fi,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298964381.2676.58.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Mar 2011, Eric Dumazet wrote:

> We should allow some trafic spikes, or many applications will stop
> working. Unless all applications are fixed, we are stuck.
>
> Only if the queue stay loaded a long time (yet another parameter) we can
> try to drop packets.

Are we talking forwarding of packets or originating them ourselves, or 
trying to use the same mechanism for both?

In the case of routing a packet, I envision a WRED kind of behaviour is 
the most efficient.

<http://www.cisco.com/en/US/docs/ios/12_0s/feature/guide/12stbwr.html>

"QoS: Time-Based Thresholds for WRED and Queue Limit for the Cisco 12000 
Series Router" You can set the drop probabilites in milliseconds. 
Unfortunately ECN isn't supported on this platform but on other platforms 
it can be configured and used instead of WRED dropping packets.

For the case when we're ourselves originating the traffic (for instance to 
a wifi card with varying speed and jitter due to retransmits on the wifi 
layer), I think it's taking the too easy way out to use the same 
mechanisms (dropping packets or marking ECN for our own originated packets 
seems really weird), here we should be able to pushback information to the 
applications somehow and do prioritization between flows since we're 
sitting on all information ourselves including the application.

For this case, I think there is something to be learnt from:

<http://www.cisco.com/en/US/tech/tk39/tk824/technologies_tech_note09186a00800fbafc.shtml>

Here you have the IP part and the ATM part, and you can limit the number 
of cells/packets sent to the ATM hardware at any given time (this queue is 
FIFO so no AQM when the packet has been sent here). We need the same here, 
to properly keep latency down and make AQM work, the hardware FIFO queue 
needs to be kept low.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
