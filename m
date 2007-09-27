From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP Spike
Date: Thu, 27 Sep 2007 22:34:53 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709271827170.5141@kivilampi-30.cs.helsinki.fi>
References: <F444CAE5E62A714C9F45AA292785BED3223F7283@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>
To: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35910 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757615AbXI0Tey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 15:34:54 -0400
In-Reply-To: <F444CAE5E62A714C9F45AA292785BED3223F7283@esng11p33001.sg.csfb.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Sep 2007, Majumder, Rajib wrote:

> We have observed 40ms latency spikes in TCP connections in "burst" type of traffic.
> This affects regular TCP sockets.

Are segments being sent full-sized, or is there perhaps some Nagle 
component in it as well? I.e., are the applications using TCP_NODELAY?

> We observed this issue in kernels of 2.4.21 and kernel 2.6.5.  
> 
> Aparently, this seems to be fixed in 2.6.19.  
>
> Can someone throw some light on this? 

I think somebody, probably Alexey, enabled sending of ACK on every 2nd 
segment. Previously small segment senders playing with Nagle were 
complaining every now and then about performance because two small 
segments did not generate ACKs but one had to accumulate, IIRC, half MSS 
worth of data before ACK was sent. Could this be related to your case?

...In case you're having too much time, you can always try bisecting it
which finds out the causing commit... :-)

> Is this a congestion control/avoidance issue?

Congestion control is basically ACK clocked math for cwnd, ssthresh, etc.
state, which then results in permission to send new segments out etc. 
(except for RTO part of course, which I'll ignore in the next statement). 
Any delay gaps to sent packet after ACK receival, which triggered the 
state changing math, isn't there due to congestion control but due to 
other factors! 40ms is much below MIN_RTO (200ms), so it shouldn't be due 
to RTO either... Note that also delayed ACKs are exception to the general 
rule.

Congestion control is controlled like your CPU is. In your CPU there's 
this whatever GHz clock which determines when the state changing events 
take place, state changes don't just happen arbitarily but are _clocked_ 
(ACK _clocked_ in case of congestion control). Of course there will be 
some propagation delay after the change to put in effect all the state 
changes that are result of what occurred at clock edge (and this delay 
assimilating to processing delay in the context of congestion control).


-- 
 i.
