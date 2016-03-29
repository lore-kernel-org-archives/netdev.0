From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 2/3] tunnels: Don't apply GRO to multiple layers of encapsulation.
Date: Mon, 28 Mar 2016 17:50:08 -0700
Message-ID: <CALx6S34VydaFDEVZD5Qv4ts7iGywx6PCGUy1oB4AkTF3Y+MB6w@mail.gmail.com>
References: <1458405122-12565-1-git-send-email-jesse@kernel.org>
	<1458405122-12565-3-git-send-email-jesse@kernel.org>
	<CALx6S36Zw+ky+u0XHROV1AE21H=EU5=SEoAj7+AskxLw6b0Odg@mail.gmail.com>
	<CAEh+42hbYUMK4WMZYDtzfynd1XFb7OxKkmdPOdT1Z7=n-kw4sA@mail.gmail.com>
	<CALx6S35WiXiKDJL6s_nW4xWNx8M6atZVQYEgb8kO5ty2WhjFyQ@mail.gmail.com>
	<CAKgT0UdiqecAMihYP=gfmBYp7-Ko54EkO23=GWg4jEAuHocKJQ@mail.gmail.com>
	<CALx6S37RPHwsWJOpNJ+8t1bBbJJ=5PKNwFUrh-yhwwXN63RFOA@mail.gmail.com>
	<CAKgT0Uf-mPK3xQuR+BdB5owfuJdQkZPE6Z0MQs9R-y3NRrC_9g@mail.gmail.com>
	<CALx6S37eOhZ+9rS8vk6FG9qyxpZ_1i5-hw4d4rnFdvEnBde3kg@mail.gmail.com>
	<CAKgT0UdaEodsDwSfKBDJqjRG-7xHEdJGpKsAAmfmgLDL8cT4zQ@mail.gmail.com>
	<CALx6S37oooS6_0rQr59E3qkcDu14eGFDYP4CKvc_Zv64zP4NqA@mail.gmail.com>
	<CAEh+42grm7dH8VQ6MJGPjp2Cpti8NcptORk+-9hyGp0MgSVZbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36560 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199AbcC2AuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 20:50:09 -0400
Received: by mail-ig0-f175.google.com with SMTP id nk17so64724333igb.1
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 17:50:09 -0700 (PDT)
In-Reply-To: <CAEh+42grm7dH8VQ6MJGPjp2Cpti8NcptORk+-9hyGp0MgSVZbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2016 at 4:34 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Mon, Mar 28, 2016 at 3:10 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Mon, Mar 28, 2016 at 1:34 PM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>> On Mon, Mar 28, 2016 at 1:03 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>> On Mon, Mar 28, 2016 at 12:31 PM, Alexander Duyck
>>>> <alexander.duyck@gmail.com> wrote:
>>>>> On Mon, Mar 28, 2016 at 11:47 AM, Tom Herbert <tom@herbertland.com> wrote:
>>>>>> On Mon, Mar 28, 2016 at 10:37 AM, Alexander Duyck
>>>>>> <alexander.duyck@gmail.com> wrote:
>>>>>>> On Mon, Mar 28, 2016 at 9:31 AM, Tom Herbert <tom@herbertland.com> wrote:
>>>>>>>> On Sun, Mar 27, 2016 at 9:38 PM, Jesse Gross <jesse@kernel.org> wrote:
>>>>>>>>> On Sat, Mar 26, 2016 at 12:41 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>>>>>>>> On Sat, Mar 19, 2016 at 9:32 AM, Jesse Gross <jesse@kernel.org> wrote:
>>>>>>>>>>> When drivers express support for TSO of encapsulated packets, they
>>>>>>>>>>> only mean that they can do it for one layer of encapsulation.
>>>>>>>>>>> Supporting additional levels would mean updating, at a minimum,
>>>>>>>>>>> more IP length fields and they are unaware of this.
>>>>>>>>>>>
>>>>>>>>>> This patch completely breaks GRO for FOU and GUE.
>>>>>>>>>>
>>>>>>>>>>> No encapsulation device expresses support for handling offloaded
>>>>>>>>>>> encapsulated packets, so we won't generate these types of frames
>>>>>>>>>>> in the transmit path. However, GRO doesn't have a check for
>>>>>>>>>>> multiple levels of encapsulation and will attempt to build them.
>>>>>>>>>>>
>>>>>>>>>>> UDP tunnel GRO actually does prevent this situation but it only
>>>>>>>>>>> handles multiple UDP tunnels stacked on top of each other. This
>>>>>>>>>>> generalizes that solution to prevent any kind of tunnel stacking
>>>>>>>>>>> that would cause problems.
>>>>>>>>>>>
>>>>>>>>>> GUE and FOU regularly create packets that will be both GSO UDP tunnels
>>>>>>>>>> and IPIP, SIT, GRE, etc. This is by design. There should be no
>>>>>>>>>> ambiguity in the drivers as to what this means. For instance, if
>>>>>>>>>> SKB_GSO_UDP_TUNNEL and SKB_GSO_GRE are set that is GRE/UDP packet, a
>>>>>>>>>> driver can use ndo_features_check to validate.
>>>>>>>>>>
>>>>>>>>>> So multiple levels of encapsulation with GRO is perfectly valid and I
>>>>>>>>>> would suggest to simply revert this patch. The one potential issue we
>>>>>>>>>> could have is the potential for GRO to construct a packet which is a
>>>>>>>>>> UDP-encapsulation inside another encapsulation, like UDP-encap in GRE.
>>>>>>>>>> In this case the GSO flags don't provide enough information to
>>>>>>>>>> distinguish say between GRE/UDP (common case) and UDP/GRE (uncommon
>>>>>>>>>> case). To make this clear we can set udp_mark in GRE, ipip, and sit
>>>>>>>>>> but *not* check for it.
>>>>>>>>>
>>>>>>>>> Generally speaking, multiple levels of encapsulation offload are not
>>>>>>>>> valid. I think this is pretty clear from the fact that none of the
>>>>>>>>> encapsulation drivers expose support for encapsulation offloads on
>>>>>>>>> transmit and the drivers supporting NETIF_F_GSO_GRE and
>>>>>>>>> NETIF_F_GSO_UDP_TUNNEL do not mean they can handle GRE in VXLAN.
>>>>>>>>>
>>>>>>>>
>>>>>>>> Kernel software offload does support this combination just fine.
>>>>>>>> Seriously, I've tested that more than a thousand times. This is a few
>>>>>>>> HW implementations you're referring to. The limitations of these
>>>>>>>> drivers should not dictate how we build the software-- it needs to
>>>>>>>> work the other way around.
>>>>>>>
>>>>>>> Jesse does have a point.  Drivers aren't checking for this kind of
>>>>>>> thing currently as the transmit side doesn't generate these kind of
>>>>>>> frames.  The fact that GRO is makes things a bit more messy as we will
>>>>>>> really need to restructure the GSO code in order to handle it.  As far
>>>>>>> as drivers testing for it I am pretty certain the i40e isn't.  I would
>>>>>>> wonder if we need to add yet another GSO bit to indicate that we
>>>>>>> support multiple layers of encapsulation.  I'm pretty sure the only
>>>>>>> way we could possibly handle it would be in software since what you
>>>>>>> are indicating is a indeterminate number of headers that all require
>>>>>>> updates.
>>>>>>>
>>>>>>>>> Asking drivers to assume that this combination of flags means FOU
>>>>>>>>> doesn't seem right to me. To the best of my knowledge, no driver uses
>>>>>>>>> ndo_feature_check to do validation of multiple tunnel offload flags
>>>>>>>>> since the assumption is that the stack will never try to do this.
>>>>>>>>> Since FOU is being treated as only a single level of encapsulation, I
>>>>>>>>> think it would be better to just advertise it that way on transmit
>>>>>>>>> (i.e. only set SKB_GSO_UDP_TUNNEL).
>>>>>>>>>
>>>>>>>> If it's not FOU it will be something else. Arbitrarily declaring
>>>>>>>> multi-levels of encapsulation invalid is simply the wrong direction,
>>>>>>>> we should be increasing generality and capabilities of the kernel not
>>>>>>>> holding it down with artificial limits. This is why the generic TSO
>>>>>>>> work that Alexander and Edward are looking at is so important-- if
>>>>>>>> this flies then we can offload any combination of encapsulations with
>>>>>>>> out protocol specific information.
>>>>>>>
>>>>>>> The segmentation code isn't designed to handle more than 2 layers of
>>>>>>> headers.  Currently we have the pointers for the inner headers and the
>>>>>>> outer headers.  If you are talking about adding yet another level we
>>>>>>> would need additional pointers in the skbuff to handle them and we
>>>>>>> currently don't have them at present.
>>>>>>>
>>>>>>>>> The change that you are suggesting would result in packets generated
>>>>>>>>> by GRO that cannot be handled properly on transmit in some cases and
>>>>>>>>> would likely end up being dropped or malformed. GRO is just an
>>>>>>>>> optimization and correctness must come first so we cannot use it if it
>>>>>>>>> might corrupt traffic.
>>>>>>>>
>>>>>>>> That's (a few) drivers problem. It's no different than if they had
>>>>>>>> decided that SKB_GSO_UDP_TUNNEL means vxlan, or they can support GRE
>>>>>>>> in IPv4 offload but not GRE in IPv6, or they can only handle headers
>>>>>>>> of a certain size, can't handle IPv6 ext. hdrs., etc. As I mentioned,
>>>>>>>> the long term solution is to eliminate the GSO_ flags and use a
>>>>>>>> generic segmentation offload interface. But in the interim, it is
>>>>>>>> *incumbent* on drivers to determine if they can handle a GSO packet
>>>>>>>> and the interfaces to do that exist. Restricting the capabilities of
>>>>>>>> GRO just to appease those drivers is not right. Breaking existing GRO
>>>>>>>> for their benefit is definitely not right.
>>>>>>>
>>>>>>> This isn't about if drivers can handle it.  It is about if the skbuff
>>>>>>> can handle it.  The problem as it stands right now is that we start
>>>>>>> losing data once we go past 1 level of encapsulation.  We only have
>>>>>>> the standard mac_header, network_header, transport_header, and then
>>>>>>> the inner set of the same pointers.  If we try to go multiple levels
>>>>>>> deep we start losing data.
>>>>>>>
>>>>>> Huh? GUE/FOU has been running perfectly well with two levels of
>>>>>> encapsulation for over a year now. We never had to add anything to
>>>>>> skbuff to make that work. If "losing data" is a problem please provide
>>>>>> the *reproducible* test case for that and we'll debug that.
>>>>>
>>>>> I'm guessing most of your examples involve either a remote checksum
>>>>> being enabled or using NICs that don't support any tunnel offloads?
>>>>> Hardware needs to be able to identify where headers are in order to
>>>>> perform most of their offloads for TSO.  We either have to parse to
>>>>> find them or we are provided with them by the stack.  GSO can work
>>>>> around it as long as we don't stack checksum based offload with
>>>>> non-checksum of the same type.
>>>>>
>>>>> mostIf for example you were to try and send a frame that had either an
>>>>> inner or outer GRE tunnel in addition to a UDP tunnel most NICs would
>>>>> probably screw it up.
>>>>
>>>> Please be more precise. Obviously we're only talking about the few
>>>> NICs that even support UDP tunnel offload so it's not most NICs. Also,
>>>> there is a big difference between "probably" and "definitely"; no one
>>>> has provided a single data point that that there is even an issue. For
>>>> instance, looking a i40e I suspect this will work with GRE/UDP since
>>>> the driver already deals with offsets and shouldn't care about
>>>> intermediate levels of encapsulation.
>>>
>>> I'm sorry I cannot be super precise as I hadn't looked that closely at
>>> the FOU or GUE code before.  Honestly I suspect most people probably
>>> haven't.
>>>
>> Sorry, but one simple test would have identified this patch was a
>> regression. I don't mind that bugs are introduced with new patches,
>> but it is frustrating when testing of the patches is obviously
>> inadequate and then we get the "it's your stuff that's broken" knee
>> jerk reaction when a patch causes a regression for someone else.
>>
>>> So from what I can tell FOU and GUE isn't really even necessarily
>>> doing stacked tunnels.  It looks like you support IPIP, SIT, or GRE.
>>> So in the case of IPIP and SIT for instance the only real difference
>>> between VXLAN and those tunnels with fou is that you don't have the
>>> VXLAN or inner Ethernet headers.  So really you still only have two
>>> levels of headers.  Even in the case of GRE you have that set after
>>> the outer UDP header so in that case GRE ends up being treated as a
>>> tunnel header since the outer transport offset was overwritten.  If we
>>> had hardware that supported both UDP and GRE outer checksums it would
>>> cause a mess as the hardware would place the GRE checksum in the wrong
>>> spot.
>>>
>>> So if anything all we probably would need to do is treat the FOU or
>>> GUE stuff as a special case.  Basically if we end up having to do a
>>> GRO over a FOU or GUE instance maybe we need to knock the encap_mark
>>> back to 0 of it is at 1 and the next level is IPIP, SIT, or GRE
>>> because really it can just be treated as a UDP tunnel.  Jesse's code
>>> is still needed to catch the case where someone is trying to do
>>> something like IPIP over VXLAN or whatever but it does seem like there
>>> should be some wiggle room for FOU or GUE.
>>>
>> Nothing is needed other than to revert this patch. There is no problem
>> with GRO. You nor Jesse have not identified any tangible problem. If a
>> driver really does had an issue with doing GRE/UDP with GSO then it
>> can filter that in check_features (this is like 2 lines of code). But
>> that has not been proven to be a problem, and I would expect that
>> anyone who wants to fix that better run tests showing there is a
>> problem.
>
> Let me try to give a very clear and specific example. Note that this
> is pure software and does not involve any hardware offloading.
>
> * A packet is received that is encapsulated with two layers of GRE. It
> looks like this: Eth|IP|GRE|IP|GRE|IP|TCP
> * The packet is processed through GRO successfully. skb->encapsulation
> bit is set and skb_shinfo(skb)->gso_type is set to SKB_GSO_GRE |
> SKB_GSO_TCPV4.
> * The packet is bridged to an output device and is prepared for
> transmission. skb_gso_segment() is called to segment the packet.
> * As we descent down the GSO code, we get to gre_gso_segment() for the
> first GRE header. skb->encapsulation is cleared and we keep going to
> the next header.
> * We return to gre_gso_segment() again for the second GRE header.
> There is a check for skb->encapsulation being set but it is now clear.
> GSO processing is aborted.
> * The packet is dropped.

If multiple level of GRE GSO is the problem then you are welcome to
fix it after FOU is fixed and when net-next opens (GSO partial should
fix this this anyway). But this is not at all the same problem as
saying all multiple levels of encapsulation are invalid so we need to
disallow that in GRO for everyone regardless of whether the packet is
is being forwarded or some driver can't understand a certain valid
combination.

Testing GUE is really not hard. There is no reason why GUE, Geneve,
and VXLAN should not be tested each time a change is made to any of
the common UDP tunneling code.

Configuring ipip-GUE can be done by:

./ip fou add port 6080 gue
./ip link add name tun1 type ipip remote 10.1.1.2 local 10.1.1.1 ttl
225 encap gue encap-sport auto encap-dport 6080 encap-csum
encap-remcsum
ifconfig tun1 192.168.1.1
ip route add 192.168.1.0/24 dev tun1

Configuring gre-GUE is just s/ipip/gre/ of above.

./netperf -H 192.168.1.2 -t TCP_STREAM -l 100

Is good for showing showing regression in a single flow. You should
see GSO/GRO being effective on both sides and perf should show only a
minute amount of time in csum_partial assuming that your device has
checksum offload for outer UDP (which should be about all).

./super_netperf 200 -H 192.168.1.2 -j -l 1 -t TCP_RR -- -r 1,1 -o
TRANSACTION_RATE,P50_LATENCY,P90_LATENCY,P99_LATENCY

Is run to test pps. We're looking for no regression in tput, latency,
or CPU utilization.

Next time you make changes to anything that affects common paths in
tunnels please run these tests and report the results in the commit
log so we can avoid regressions like this. You should also be running
an equivalent battery of VXLAN tests. The configuration I use is:

./ip link add vxlan0 type vxlan id 10 group 224.10.10.10 ttl 10 dev
eth0  udpcsum remcsumtx remcsumrx
ifconfig vxlan0 192.168.111.1
ip route add 192.168.111.0/24 dev vxlan0

Again we expect the same sort of results, GRO/GSO should be effective,
csum_partial should not be getting significant tine, etc...

Thanks,
Tom
