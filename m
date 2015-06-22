From: GMAIL <ranamazharp@gmail.com>
Subject: Re: [PATCH ipv6 0/1] ipv6: addrconf: routes are not deleted if last
 ipv6 address is removed
Date: Mon, 22 Jun 2015 10:07:16 +0530
Message-ID: <558790FC.9040404@gmail.com>
References: <1434619742-10423-1-git-send-email-ranamazharp@gmail.com> <1434626598.7926.27.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, Sanket Shah <sanket.shah@cyberoam.com>,
	mazhar.rana@cyberoam.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434626598.7926.27.camel@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 18 June 2015 04:53 PM, Hannes Frederic Sowa wrote:
> On Thu, 2015-06-18 at 14:59 +0530, Mazhar Rana wrote:
>> Hi,
>>
>> After 'commit 876fd05ddbae03166e7037fca957b55bb3be6594
>> ("ipv6: don't disable interface if last ipv6 address is removed")'
>> it is not clearing ipv6 interface configurations(routes, neighbours,
>> etc) when last ipv6 address of interface is removed.
>>
>> This is now creating functionality issue with below deployment.
>>
>> On ubuntu 14.04 (upgraded with linux kernel 3.19)
>> eth1 GW1: 2604:2000:7000:2::102
>> eth0 GW2: 2001:df7:6000:101::1b:102
>>
>> HostA: 3804:3000:1406:2::102 (reachable via GW1 and GW2 both)
>>
>> In this deployment, HostA is reachable via eth0 and eth1. I prefer
>> that all traffic for HostA should go via GW1 which is available on
>> link eth1.
>>
>> $ ip -6 ro s
>> 2001:df7:6000:101::/64 dev eth0  proto kernel  metric 256
>> 2604:2000:7000:2::/64 dev eth1  proto kernel  metric 256
>> 3804:3000:1406:2::/64 via 2604:2000:7000:2::102 dev eth1  metric 1024
>> fe80::/64 dev eth0  proto kernel  metric 256
>> fe80::/64 dev eth1  proto kernel  metric 256
>> default via 2001:df7:6000:101::1b:102 dev eth0  proto static  metric 1
>>
>> On failure of GW1 I removed all ipv6 address of eth1 so all traffic
>> should go through default gateway 'GW2'.
>>
>> $ sudo ip -6 addr flush dev eth1
>> $ ip -6 ro s
>> 2001:df7:6000:101::/64 dev eth0  proto kernel  metric 256
>> 3804:3000:1406:2::/64 via 2604:2000:7000:2::102 dev eth1  metric 1024
>> fe80::/64 dev eth0  proto kernel  metric 256
>> fe80::/64 dev eth0.100  proto kernel  metric 256
>> default via 2001:df7:6000:101::1b:102 dev eth0  proto static  metric 1
>>
>> But here, route for HostA is not deleted, so traffic for HostA is
>> still trying to go through GW1 which is not reachable anymore.
>>
>> If 'commit 876fd05ddbae03166e7037fca957b55bb3be6594
>> ("ipv6: don't disable interface if last ipv6 address is removed")'
>> is taken only for problem mention on changlog of that commit then
>> here I have alternate proposal which will overcome both issue.
>>
>> Do you see any side effect of this proposal?
> In theory IPv6 mandates that on-link information (which subnet is available on
> which link) and address specific connected routes should not depend on each
> other. That said, your initial assumption that clearing addresses from an
> interface to shut it down for IPv6 operation is wrong.
>
> I guess the check was there to make sure each link has an LL address.
>
> As we changed backwards compatibility here I am a bit ambivalent.
>
> Another glitch I noticed with your patch: We don't set disable_ipv6 bit on
> addrconf_ifdown with how==0, so we cannot easily bring the interface up without
> disturbing IPv4 operations, could you check, that the disable_ipv6 switch works
> to at least bring the ipv6 part of the interface up again?
>
> Bye,
> Hannes
>
Hi Hannes,

Thanks for quick review and reply.

I agree with you. With my patch we can not bring the interface up
without disturbing IPv4 operations. I am working on it to fix it, will
update you once it is done.

Here I want to share behaviour observed in above deployment:

After flushing ipv6 addresses from interface eth1, it is sending
traffic for HostA via GW1 until GW1's neighbour entry become failed.
Once neighbour entry got failed, default route is selected for all
traffic including traffic for HostA. I have not tested behaviour with
interface based routes yet.

Regards,
Mazhar Rana
