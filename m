From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next 02/10] udp: Expand UDP tunnel common APIs
Date: Wed, 23 Jul 2014 08:45:11 -0700
Message-ID: <CA+mtBx8iiZp7hG9uckUPkpxT1t7fNDgzZWOf0TywG42DYS+PCQ@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<1406024393-6778-3-git-send-email-azhou@nicira.com>
	<CA+mtBx9M_BpjT-_Egng+jFxmqJzdC2Npg0ufE2ZSAb9Lhw8hxg@mail.gmail.com>
	<CACzMAJ+uW0rYQxxmi4GouGF64bbr0VDCsdrBymypWLxCaHQSrA@mail.gmail.com>
	<CA+mtBx9RUe7a2hYsRjHbS3E+TzGOQ4Q8wLZp+-TDHQkV+L5c1Q@mail.gmail.com>
	<CAEP_g=8oQ_Yn1ZDNjoFKgwRaGvpyW+s9RfOd1utEMsNWmJmX-Q@mail.gmail.com>
	<CA+mtBx830L17hr_eaRKHcA9MaE9Xs7W3pC+sYh7a=E=CVmM3QQ@mail.gmail.com>
	<53CEEBFD.9020402@intel.com>
	<CA+mtBx-q0PV4U_jGt-N+v5Ax_uoxYeQjrvHCqmAvU_VEQtFZNg@mail.gmail.com>
	<53CF1B16.1000009@gmail.com>
	<CA+mtBx8oUfWNRchbvsmV4UevZro6dZucjRH+RYxmmTtoMmhzmA@mail.gmail.com>
	<CAEP_g=_Kqh8So6v4JFuJqfLwEUWo=Re-_Ak2btEzsdH=bfM8-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Andy Zhou <azhou@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:39367 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932278AbaGWPpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 11:45:12 -0400
Received: by mail-ig0-f177.google.com with SMTP id hn18so1583533igb.10
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 08:45:11 -0700 (PDT)
In-Reply-To: <CAEP_g=_Kqh8So6v4JFuJqfLwEUWo=Re-_Ak2btEzsdH=bfM8-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 9:35 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Tue, Jul 22, 2014 at 11:53 PM, Tom Herbert <therbert@google.com> wrote:
>>>> Which feature flags control the receive side parsing in the device?
>>>
>>> The only real features that need the port info are Rx hash and Rx
>>> checksum.  If those are disabled then there shouldn't be any need for
>>> the port numbers.  I don't recall if you can disable them separately
>>> from the non-tunnel case though.  I believe they are linked to the
>>> standard offloads.
>>>
>> Rx hash is unnecessary consideration because we can derive that from
>> UDP header. The fact that we can deduce a reasonable hash is a major
>> rationale of UDP encapsulation. We will need drivers to start
>> enabling/supporting UDP RSS and providing RX hash to realize full
>> benefits of this.
>
> That's true for basic hashing but for more sophisticated things like
> flow steering or sending OAM packets to control queues the hardware
> still needs to be able to look into the header.
>
Flow steering (aRFS, FlowDirector, ECMP in network) will work just
fine based on UDP header-- again this is a fundamental property in UDP
encapsulation. If you need to implement mechanisms that require
parsing of the encapsulated headers, then it's better to make this
part of RX filtering.

We already have a mess with the all the GSO protocol variants for
different protocols because no one has defined a generic TSO
mechanism, let's avoid repeating that for RX.

>> Rx checksum is also an unnecessary consideration if devices return
>> CHECKSUM_COMPLETE instead of CHECKSUM_UNNECESSARY. Pretty much
>> anything can (and probably will) be encapsulated in UDP (VXLAN, GRE,
>> MPLS, L2TP, IPIP, SIT, etc.), so if your hardware provides
>> CHECKSUM_COMPLETE this immediately gives us easy calculation the
>> embedded checksums no matter how many encapsulation layers there are.
>
> This property only applies to ones-complement checksums though. If I
> recall correctly, I believe you have a desire for something stronger
> :)

True, I desire full line rate encryption of all packets :-). In order
to the do this efficiently and generically we will want to do
something like ESP/UDP to keep the flow hash visible. So this is one
valid case where we'd need to configure the HW with a UDP port if it
is to do decrypt.

btw, Geneve draft allows for non-zero UDP checksums to be ignored like
in VXLAN-- this is a violation of UDP standard :-(. We will not do
this in the stack, but it opens the possibility that HW may tell us
checksum is okay when it actually isn't. Accepting
CHECKSUM_UNNECESSARY from all these devices is quite the leap of faith
we're taking!

>
>> Another need for parsing UDP contents would be for LRO. This would
>> require implementation of each encapsulation format supported. I
>> believe that LRO pretty much deprecated, so maybe this is not an issue
>> either.
>
> I think only the old style of LRO is deprecated. Some drivers provide
> "GRO" where the hardware supplies the original MSS and that works OK.
>
> Some of these are obviously future looking but I think that means that
> even if you got your desired changes, the use of the UDP port on
> receive would only shift, not go away.

I think your hitting the major point that we have to be future
looking. When hardware hardwire specific protocols instead of using
generic mechanisms, we become pigeonholed-- this is *not* future
looking and in the long run it's a disservice to customers if we
advocate this in the stack. Consider that geneve is likely superior to
VXLAN because it is extensible, but that VXLAN may still win since it
is already "supported" in so much HW.
