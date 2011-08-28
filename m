From: HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com>
Subject: Re: [PATCH net-next ] Fix time-lag of IFF_RUNNING flag consistency
 between vlan and real devices
Date: Sun, 28 Aug 2011 22:20:41 +0900
Message-ID: <4E5A40A9.2000404@hitachi.com>
References: <20110826060257.5304.62723.stgit@ltc219.sdl.hitachi.co.jp> <20110825230859.11b2b132@nehalam.ftrdhcpuser.net> <20110826064553.GA5874@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?TWljaGHFgk1pcm9zxYJhdw==?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:59316 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab1H1NUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 09:20:47 -0400
In-Reply-To: <20110826064553.GA5874@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen and Herbert

Thank you for your comments.

(2011/08/26 15:08), Stephen Hemminger wrote:
> I don't think this is the right way to solve the problem.
>
> The flags are supposed to propagate back from real device to vlan
> via network notifications.
>
> Just doing this for ioctl is not enough, API's other than user space depend on this.
> Also the user may have manually set different flags on vlan than on
> the real device.

I agreed.
I will try another way to solve this problem, as you said.


(2011/08/26 15:45), Herbert Xu wrote:
> On Thu, Aug 25, 2011 at 11:08:59PM -0700, Stephen Hemminger wrote:
>> Just doing this for ioctl is not enough, API's other than user space depend on this.
>> Also the user may have manually set different flags on vlan than on
>> the real device.
> Right, anything that tests netif_carrier_ok directly on the VLAN
> device will still be delayed.
>
> Now I remember discussing this issue in Japan.  However, I can't
> recall the exact scenario in which the delay occured.
>
> Is the issue with the link status going down on the real device,
> or the real device coming up?
>
> IIRC we already have mechanisms in place to ensure that down events
> are not delayed by linkwatch.  Of course it is possible that this
> isn't working for some reason, or some other part of the system is
> causing the delay.
>
> So please clarify the scenario for us Hayasaka-san.  Also please
> let us know how you measured the delay.
>
> Thanks,

This issue happens when the link status is going down on the real 
device.

ex) A cable is broken, or is unplugged from a NIC.

I measured the delay using ioctl with SIOCGIFFLAGS from userspace 
in order to check if there is a time-lag of the flag between vlan 
and real devices.

Also, you can check it using a script below.

-------------------------
#!/bin/sh
t=0
while :
do
	echo $t; t=$((t+1))
	echo -n real; ifconfig RealDev | grep UP
	echo -n vlan; ifconfig VlanDev | grep UP
	sleep 0.2
done
-------------------------

The result is shown as follows.
It is observed that there is a time-lag of RUNNING status between 
real and vlan devices.


....

19
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
20
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1  * A cable is unplugged from NIC.
21
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
22
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
23
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
24
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
25
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
26
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
27
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
28
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
29
real          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
30
real          UP BROADCAST MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
31
real          UP BROADCAST MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
32
real          UP BROADCAST MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
33
real          UP BROADCAST MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
34
real          UP BROADCAST MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
35
real          UP BROADCAST MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST MULTICAST  MTU:1500  Metric:1
36
real          UP BROADCAST MULTICAST  MTU:1500  Metric:1
vlan          UP BROADCAST MULTICAST  MTU:1500  Metric:1


Thanks.
