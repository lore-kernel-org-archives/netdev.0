From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 02/10] udp: Expand UDP tunnel common APIs
Date: Wed, 23 Jul 2014 23:24:40 -0400
Message-ID: <CAEP_g=_whjHzVrR+EuCQsYC1owwRk==RnOUYuetHXB9s22RHQQ@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
 <1406024393-6778-3-git-send-email-azhou@nicira.com> <CA+mtBx9M_BpjT-_Egng+jFxmqJzdC2Npg0ufE2ZSAb9Lhw8hxg@mail.gmail.com>
 <CACzMAJ+uW0rYQxxmi4GouGF64bbr0VDCsdrBymypWLxCaHQSrA@mail.gmail.com>
 <CA+mtBx9RUe7a2hYsRjHbS3E+TzGOQ4Q8wLZp+-TDHQkV+L5c1Q@mail.gmail.com>
 <CAEP_g=8oQ_Yn1ZDNjoFKgwRaGvpyW+s9RfOd1utEMsNWmJmX-Q@mail.gmail.com>
 <CA+mtBx830L17hr_eaRKHcA9MaE9Xs7W3pC+sYh7a=E=CVmM3QQ@mail.gmail.com>
 <53CEEBFD.9020402@intel.com> <CA+mtBx-q0PV4U_jGt-N+v5Ax_uoxYeQjrvHCqmAvU_VEQtFZNg@mail.gmail.com>
 <53CF1B16.1000009@gmail.com> <CA+mtBx8oUfWNRchbvsmV4UevZro6dZucjRH+RYxmmTtoMmhzmA@mail.gmail.com>
 <CAEP_g=_Kqh8So6v4JFuJqfLwEUWo=Re-_Ak2btEzsdH=bfM8-A@mail.gmail.com> <CA+mtBx8iiZp7hG9uckUPkpxT1t7fNDgzZWOf0TywG42DYS+PCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Andy Zhou <azhou@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:37792 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758463AbaGXDZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 23:25:02 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so2574134qgd.13
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 20:25:01 -0700 (PDT)
In-Reply-To: <CA+mtBx8iiZp7hG9uckUPkpxT1t7fNDgzZWOf0TywG42DYS+PCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 11:45 AM, Tom Herbert <therbert@google.com> wrote:
> On Tue, Jul 22, 2014 at 9:35 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Tue, Jul 22, 2014 at 11:53 PM, Tom Herbert <therbert@google.com> wrote:
>>>>> Which feature flags control the receive side parsing in the device?
>>>>
>>>> The only real features that need the port info are Rx hash and Rx
>>>> checksum.  If those are disabled then there shouldn't be any need for
>>>> the port numbers.  I don't recall if you can disable them separately
>>>> from the non-tunnel case though.  I believe they are linked to the
>>>> standard offloads.
>>>>
>>> Rx hash is unnecessary consideration because we can derive that from
>>> UDP header. The fact that we can deduce a reasonable hash is a major
>>> rationale of UDP encapsulation. We will need drivers to start
>>> enabling/supporting UDP RSS and providing RX hash to realize full
>>> benefits of this.
>>
>> That's true for basic hashing but for more sophisticated things like
>> flow steering or sending OAM packets to control queues the hardware
>> still needs to be able to look into the header.
>>
> Flow steering (aRFS, FlowDirector, ECMP in network) will work just
> fine based on UDP header-- again this is a fundamental property in UDP
> encapsulation. If you need to implement mechanisms that require
> parsing of the encapsulated headers, then it's better to make this
> part of RX filtering.

Sure, it can operate on the UDP hash but I would argue that it works
better if you actually look into the packet. Using the hash is either
going to just randomly spread traffic or require you to track hashes
and direct them to particular places for established connections.
However, depending on the situation this may not really be optimal
compared to, say, steering based on inner MAC address.

But in reality, whether it is for steering or filtering these
operations are pretty similar to me, just different goals.

> btw, Geneve draft allows for non-zero UDP checksums to be ignored like
> in VXLAN-- this is a violation of UDP standard :-(. We will not do
> this in the stack, but it opens the possibility that HW may tell us
> checksum is okay when it actually isn't. Accepting
> CHECKSUM_UNNECESSARY from all these devices is quite the leap of faith
> we're taking!

This is actually not the intention but I see that the wording of the
draft is poor. I'll see if I can improve it to avoid this situation.

>> Some of these are obviously future looking but I think that means that
>> even if you got your desired changes, the use of the UDP port on
>> receive would only shift, not go away.
>
> I think your hitting the major point that we have to be future
> looking. When hardware hardwire specific protocols instead of using
> generic mechanisms, we become pigeonholed-- this is *not* future
> looking and in the long run it's a disservice to customers if we
> advocate this in the stack. Consider that geneve is likely superior to
> VXLAN because it is extensible, but that VXLAN may still win since it
> is already "supported" in so much HW.

I understand your goal but I'm not really sure what solution you are
proposing. There are obviously ways that the stack can be made more
generic from where it is today but I think we agree that at least some
things will require protocol knowledge.

Geneve (and GUE) are trying to solve this by having a protocol that is
generic - hardware will still need to have support for a specific
protocol but at least that can support many uses. However, this
doesn't seem to be what you are getting at since it's not true of
VXLAN, particularly if you are concerned with deployed hardware.
