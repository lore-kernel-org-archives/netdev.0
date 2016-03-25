From: Ben Greear <greearb@candelatech.com>
Subject: =?UTF-8?Q?Re:_veth_regression_with_=22don=e2=80=99t_modify_ip=5fsum?=
 =?UTF-8?Q?med;_doing_so_treats_packets_with_bad_checksums_as_good.=22?=
Date: Fri, 25 Mar 2016 16:46:44 -0700
Message-ID: <56F5CDE4.7010306@candelatech.com>
References: <56F463D6.7080406@candelatech.com>
 <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
 <56F4810A.9060904@candelatech.com> <56F49036.8050902@candelatech.com>
 <56F490B2.3090603@candelatech.com>
 <CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
 <56F4BFF1.8010806@candelatech.com>
 <CAM_iQpUaBD-HmHVAcEBCRw38PbecjYk2to+DO9TNkLY93u2_NA@mail.gmail.com>
 <56F4C8FD.7030907@candelatech.com>
 <CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
 <56F5A618.9070206@candelatech.com>
 <CAKUBDd844=BTpK2B2izzRGqwKQV5RtsFAO9nFQ5CJqDENLFW5A@mail.gmail.com>
 <56F5BA45.2030706@candelatech.com>
 <CAKUBDd8FGh3mhDmoyH70WvNGyofPVbjdROPKzenm+6DLfALyqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:44568 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbcCYXqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 19:46:45 -0400
In-Reply-To: <CAKUBDd8FGh3mhDmoyH70WvNGyofPVbjdROPKzenm+6DLfALyqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/2016 04:03 PM, Vijay Pandurangan wrote:
> On Fri, Mar 25, 2016 at 6:23 PM, Ben Greear <greearb@candelatech.com> wrote:
>> On 03/25/2016 02:59 PM, Vijay Pandurangan wrote:
>>>
>>> consider two scenarios, where process a sends raw ethernet frames
>>> containing UDP packets to b
>>>
>>> I) process a --> veth --> process b
>>>
>>> II) process a -> eth -> wire -> eth -> process b
>>>
>>> I believe (I) is the simplest setup we can create that will replicate this
>>> bug.
>>>
>>> If process a sends frames that contain UDP packets to process b, what
>>> is the behaviour we want if the UDP packet *has an incorrect
>>> checksum*?
>>>
>>> It seems to me that I and II should have identical behaviour, and I
>>> would think that (II) would not deliver the packets to the
>>> application.
>>>
>>> In (I) with Cong's patch would we be delivering corrupt UDP packets to
>>> process b despite an incorrect checksum in (I)?
>>>
>>> If so, I would argue that this patch isn't right.
>>
>>
>> Checksums are normally used to deal with flaky transport mechanisms,
>> and once a machine receives the frame, we do not keep re-calculating
>> checksums
>> as we move it through various drivers and subsystems.
>>
>> In particular, checksums are NOT a security mechanism and can be easily
>> faked.
>>
>> Since packets sent on one veth never actually hit any unreliable transport
>> before they are received on the peer veth, then there should be no need to
>> checksum packets whose origin is known to be on the local machine.
>
> That's a good argument.  I'm trying to figure out how to reconcile
> your thoughts with the argument that virtual ethernet devices are an
> abstraction that should behave identically to perfectly-functional
> physical ethernet devices when connected with a wire.
>
> In my view, the invariant must be identical functionality, and if I
> were writing a regression test for this system, that's what I would
> test. I think optimizations for eliding checksums should be
> implemented only if they don't alter this functionality.
>
> There must be a way to structure / write this code so that we can
> optimize veths without causing different behaviour ...

A real NIC can either do hardware checksums, or it cannot.  If it
cannot, then the host must do it on the CPU for both transmit and
receive.

Veth is not a real NIC, and it cannot do hardware checksum offloading.

So, we either lie and pretend it does, or we eat massive amounts
of CPU usage to calculate and check checksums when sending across
a veth pair.

>> Any frame sent from a socket can be considered to be a local packet in my
>> opinion.
>
> I'm not sure that's totally right. Your bridge is adding a delay to
> your packets; it could just as easily be simulating corruption by
> corrupting 5% of packets going through it. If this change allows
> corrupt packets to be delivered to an application when they could not
> be delivered if the packets were routed via physical eths, I think
> that is a bug.

I actually do support corrupting the frame, but what I normally do is corrupt the contents
of the packet, and then recalculate the IP checksum (and TCP if it applies)
and send it on its way.  The receiving NIC and stack will pass the frame up to
the application since the checksums match, and it would be up the application
to deal with it.  So, I can easily cause an application to receive corrupted
frames over physical eths.

I can also corrupt without updating the checksums in case you want to
test another systems NIC and/or stack.

But, if I am purposely corrupting a frame destined for veth, then the only reason
I would want the stack to check the checksums is if I were testing my own
stack's checksum logic, and that seems to be a pretty limited use.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
