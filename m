From: Brian Rak <brak@vultr.com>
Subject: Re: Missing IPv4 routes
Date: Mon, 26 Oct 2015 12:57:13 -0400
Message-ID: <562E5B69.6080108@vultr.com>
References: <562AA7D3.9030905@vultr.com> <562AB578.9090107@gmail.com>
 <562B8856.6070501@vultr.com> <562E46BA.7060904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2015.choopa.net ([208.167.225.251]:13611 "EHLO
	mail2015.choopa.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbbJZQ5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 12:57:16 -0400
In-Reply-To: <562E46BA.7060904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/26/2015 11:28 AM, Alexander Duyck wrote:
> On 10/24/2015 06:32 AM, Brian Rak wrote:
>>
>>
>> On 10/23/2015 6:32 PM, Alexander Duyck wrote:
>>> On 10/23/2015 02:34 PM, Brian Rak wrote:
>>>> I've got a weird situation here.  I have a route that the kernel knows
>>>> about, but won't display via the general RTM_GETROUTE call, but will
>>>> display if I query for that particular route:
>>>>
>>>> # ip -4 route show | grep 108.61.171.x
>>>
>>> The use of 'x' here is going to make things confusing.  I assume you
>>> are using a value of 0 here, or is this a route to a specific IP
>>> address that you have.  If not you should be using a 0 for all bits
>>> that would be outside of your subnet mask.
>>>
>> This is a route to a particular IP address:
>>
>> # ip route show | grep  108.61.171.247
>> # ip route get  108.61.171.247
>> 108.61.171.247 dev SRVID630287
>>      cache
>
> Okay, makes sense.
>
>>>> # ip route get 108.61.171.x
>>>> 108.61.171.x dev MYIF
>>>>      cache
>>>
>>> The 'x' being the actual value here should work as this will perform a
>>> lookup as I recall.
>>>
>>>> # cat /proc/net/route | grep 108.61.171.x
>>>
>>> The IPs are in network order and as just hex so this won't work.
>>>
>>>> # cat /proc/net/route  | grep -i 6c3dac
>>>
>>> The byte ordering you are using is backwards here from what I can
>>> tell.  So it should be ac3d6c you are checking for, not the other way
>>> around.  So for example if I was using 192.168.1.x I would want to
>>> look for 01A8C0.
>> Oops.  This also doesn't show the route, which it should:
>>
>> # cat /proc/net/route  | grep SRVID630287
>> #
>>
>
> So does this device have no routes on it then?  I'm just wanting to 
> confirm the behaviour you are seeing since my concern was mostly about 
> a bug I had introduced where we were losing one route if a dump was 
> broken up over multiple pages.  It seems like that isn't the case.
These devices only usually have a single IPv4 route, so seeing no other 
routes there is what I'd expect.

>
>>>
>>>> # ip route add 108.61.171.x dev MYIF
>>>> RTNETLINK answers: File exists
>>>> # ip route del 108.61.171.x  <---- it deletes successfully once
>>>> # ip route del 108.61.171.x
>>>> RTNETLINK answers: No such process
>>>>
>>>
>>> So at least we have the routes in the FIB.  It looks like this just
>>> might be a display issue.
>>>
>>>> This is on a machine running 4.1.3, but I have seen it on earlier
>>>> versions in the past.
>>>>
>>>> I don't have great reproduction steps here, I've seen this 4-5 
>>>> times in
>>>> the past few months (on different hardware).  So far, I haven't really
>>>> found any way of fixing it (deleting and readding the route has no
>>>> effect).  I thought at first this might be related to
>>>> e55ffaf457bcc8ec4e9d9f56f955971f834d65b3, but as far as I can tell 
>>>> that
>>>> only relates to /proc/net/route.
>>>>
>>>> Any suggestions on further troubleshooting here?  I'm all out of ideas
>>>> (and since I can't easily reproduce it yet, I can't reboot to a newer
>>>> kernel to see if it goes away)
>>>
>>> How many routes do you have on your system?  I'm just wondering if it
>>> might be possible that the route could be at a boundary for the dump
>>> call and if it might be possibly losing the data there. Although I
>>> would expect
>> ip -4 route show | wc -l shows 67
>>>
>>> Also have you tried double checking to verify that grep isn't somehow
>>> missing the line?
>> Yes, so we noticed this issue because BIRD stopped picking up the
>> route.  BIRD's trying to grab these via netlink:
>> https://github.com/BIRD/bird/blob/master/sysdep/linux/netlink.c#L1045 ,
>> so I don't believe this is just an issue with grep missing the route.  I
>> also wrote a simple  python script with pyroute2, which also missed the
>> route.
>>
>> I was doing some testing to see if I could add routes for nearby IPs,
>> and ended up somehow correcting the issue:
>>
>> # ip route show | grep SRVID630287
>> # ip route add 108.61.171.200/32 dev SRVID630287
>> # ip route show | grep SRVID630287
>> 108.61.171.200 dev SRVID630287  scope link
>> 108.61.171.247 dev SRVID630287  scope link
>> # ip route del 108.61.171.200/32 dev SRVID630287
>> # ip route show | grep SRVID630287
>> 108.61.171.247 dev SRVID630287  scope link
>>
>> Does that make any sense?
>
> It might if there is a hole in what is being displayed.  One thing you 
> might try doing is to generate two dumps, one with your additional 
> route and one without and then try doing a diff between the two.  Then 
> you might look at adding a few more routes to see if that forces the 
> missing route to appear but perhaps causes another route to disappear 
> from the dump.
>
> With that test we should be able to identify the behaviour since it 
> sounds like an issue where the route is there in memory, but for 
> whatever reason it isn't being displayed.  If we can identify a hole 
> that these routes are falling into we might be able to determine what 
> is causing the issue.

I had added some other routes randomly here (1.1.1.1/32, 
200.200.200.200/32, 108.61.172.249/32).  I didn't see this route 
reappear until I added one in the same /24, but I wasn't checking for 
other routes going missing.

I'm not entirely sure how, but adding that one extra route 
(108.61.171.200/32 dev SRVID630287) appears to have permanently fixed 
the issue.  Even after removing that extra route, the original route 
still appears.

I've been able to come up with some reproduction steps here, and 
verified that this still happens on 4.2.4:

# ip route show
default via 45.63.12.1 dev eth0  proto static
45.63.12.0/23 dev eth0  proto kernel  scope link  src 45.63.13.197
169.254.0.0/16 dev eth0  scope link
169.254.0.0/16 dev eth0  scope link  metric 1002
# ip link add veth0 type veth peer name veth1
# ip link set veth0 up
# ip link set veth1 up
#
# ip route add 108.61.171.119/32 dev veth0  scope link
# ip route add 108.61.171.141/32 dev veth1  scope link
# ip route add 108.61.171.223/32 dev veth1  scope link
# ip route add 108.61.171.250/32 dev veth1  scope link
# ip route add 108.61.171.247/32 dev veth1  scope link
# ip route show
default via 45.63.12.1 dev eth0  proto static
45.63.12.0/23 dev eth0  proto kernel  scope link  src 45.63.13.197
108.61.171.119 dev veth0  scope link
108.61.171.141 dev veth1  scope link
108.61.171.223 dev veth1  scope link
<--- ROUTES MISSING!
169.254.0.0/16 dev eth0  scope link
169.254.0.0/16 dev eth0  scope link  metric 1002
# ip route get 108.61.171.250/32
108.61.171.250 dev veth1  src 45.63.13.197
     cache
# ip route get 108.61.171.247/32
108.61.171.247 dev veth1  src 45.63.13.197
     cache
# ip route del 108.61.171.250/32
# ip route show
default via 45.63.12.1 dev eth0  proto static
45.63.12.0/23 dev eth0  proto kernel  scope link  src 45.63.13.197
108.61.171.119 dev veth0  scope link
108.61.171.141 dev veth1  scope link
108.61.171.223 dev veth1  scope link
108.61.171.247 dev veth1  scope link <----- comes back
169.254.0.0/16 dev eth0  scope link
169.254.0.0/16 dev eth0  scope link  metric 1002
# ip route add 108.61.171.250/32 dev veth1
# ip route show
default via 45.63.12.1 dev eth0  proto static
45.63.12.0/23 dev eth0  proto kernel  scope link  src 45.63.13.197
108.61.171.119 dev veth0  scope link
108.61.171.141 dev veth1  scope link
108.61.171.223 dev veth1  scope link
<--- gone again
169.254.0.0/16 dev eth0  scope link
169.254.0.0/16 dev eth0  scope link  metric 1002
