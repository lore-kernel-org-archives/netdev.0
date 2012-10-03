From: Ken Savage <kens1835@shaw.ca>
Subject: Re: RED tc qdisc not dropping?
Date: Wed, 3 Oct 2012 16:16:53 -0600 (MDT)
Message-ID: <1531959073.11965570.1349302613640.JavaMail.root@cds046>
References: <1349298766.10199.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:53692 "EHLO
	idcmail-mo1so.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755342Ab2JCWQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 18:16:56 -0400
In-Reply-To: <1349298766.10199.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

I'm guessing there were some improvements in the kernel associated
to this area since 2.6...  ;)

I did manage to chain together a 10ms delay with the netem qdisc at
the root, with RED underneath it, and this has at least resulted in
SOME packets being dropped -- and hence a bandwidth "cap" that forms
(naturally, due to queue fill and drop rates) and congestion control
kicking in, to get below this flow's natural tendency to operate
between 25Mbps and 30.

With the 2.6 kernel and tc tools, this chaining has a lot more
effect -- hence why I said there were probably some improvements in
3.4. (Of course there were, that's the whole point of Linux :)

So perhaps you can offer a better way of setting up basic wansim...

eth1: connected to server that generates data.
eth0: connected to client that receives said data.

Ideally, packets egressing out of eth0 can have some latency delay
and/or loss applied to them, to simulate travel time and loss:

# tc .... netem delay 10ms loss 0.001

AND, to simulate being passed through a company's Cisco router, set
up with WRED:

# tc .... red  ... harddrop probability 0.1

AND, be rate limited to some physical value, such what would happen
if we inadvertently used some old 10Mbps switch, or exceeded some
home employees's ADSL modem's internal speed limit:

# tc ... tbf rate 10mbit burst 50kb 

-----

I noticed 'gred' seems to have a bw rate/limit option present now, but
for the life of me I couldn't get gred to actually WORK: it always
seemed to generate errors.  I'm not interested in multiple classes of
service, or prioritizing some traffic over others.  Just treat all my
outbound packets the same, and I'll be happy.


Any ideas how this could best be set up?


Ken






----- Original Message -----
From: "Eric Dumazet" <eric.dumazet@gmail.com>
To: "Ken Savage" <kens1835@shaw.ca>
Cc: netdev@vger.kernel.org
Sent: Wednesday, October 3, 2012 2:12:46 PM
Subject: Re: RED tc qdisc not dropping?

On Wed, 2012-10-03 at 14:14 -0600, Ken Savage wrote:
> Hi there,
> 
> I'm running openSUSE 12.2, using the machine as a router/WANsim device.
> 
> Previously, I was running an older CentOS installation with a 2.6 kernel,
> and my tc-red commands ran just fine, and imposed some bandwidth constraint
> to the packets upon egress.  In 3.4.6, this doesn't seem to be the case
> any longer.
> 
> Without any restrictions, there would be 25-30Mbps of traffic flowing out
> the interface -- this is to give you a sense of the data rate.
> 
> 
> Now, this said, I did notice that the latest RED code has the 'harddrop'
> option that I didn't have under CentOS with kernel 2.6.  So in my attempt
> to see ANYTHING happening with 3.4.6, I entered:
> 
> tc qdisc add dev eth0 root red limit 40000 min 3000 max 9000 avpkt 1000 burst 5 harddrop probability 1
> 
> 
> Issuing 'tc -s -d qdisc show dev eth0', I obtain:
> 
> qdisc red 8006: root refcnt 2 limit 40000b min 3000b max 9000b harddrop ewma 2 probability 0.73242 Scell_log 12
>  Sent 254028472 bytes 207494 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   marked 0 early 0 pdrop 0 other 0
> 
> 
> All those zeroes seem a little amiss to me  ;)
> 

Not sure I understand...

Why RED should drop a packet if there is no backlog ?

if you NIC has Gigabit speed, RED will allow Gigabit speed as well.
