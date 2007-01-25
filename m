From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Thu, 25 Jan 2007 12:16:59 -0500
Message-ID: <45B8E60B.7080809@hp.com>
References: <20070119212314.GA10748@hmsreliant.homelinux.net> <20070120.080507.25118874.yoshfuji@linux-ipv6.org> <20070122181528.GD21059@hmsreliant.homelinux.net> <20070123.091820.104515696.yoshfuji@linux-ipv6.org> <20070123205118.GC582@hmsreliant.homelinux.net> <1169690087.23312.7.camel@w-sridhar2.beaverton.ibm.com> <20070125133340.GA8891@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kg?=
	 =?UTF-8?B?LyDlkInol6Toi7HmmI4=?= <yoshfuji@linux-ipv6.org>,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:54516 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030465AbXAYRRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 12:17:09 -0500
In-Reply-To: <20070125133340.GA8891@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman wrote:
> On Wed, Jan 24, 2007 at 05:54:47PM -0800, Sridhar Samudrala wrote:
>> Sec 2.1 of RFC 4429 says
>>
>>    Unless noted otherwise, components of the IPv6 protocol stack should
>>    treat addresses in the Optimistic state equivalently to those in the
>>    Deprecated state, indicating that the address is available for use
>>    but should not be used if another suitable address is available.  For
>>    example, Default Address Selection [RFC3484] uses the address state
>>    to decide which source address to use for an outgoing packet.
>>    Implementations should treat an address in state Optimistic as if it
>>    were in state Deprecated.  If address states are recorded as
>>    individual flags, this can easily be achieved by also setting
>>    'Deprecated' when 'Optimistic' is set.
>>
>> So i think DEPRECATED flag also should be set when we mark an address
>> as OPTIMISTIC so that we don't use it as source address for new 
>> connections if another address is available until DAD is completed.
>>
>> Thanks
>> Sridhar
>>
> 
> Oh, good catch.  Thank you Sri.  However, I'm worried about the next paragraph:
> 
> It is important to note that the address lifetime rules of [RFC2462]
>    still apply, and so an address may be Deprecated as well as
>    Optimistic.  When DAD completes without incident, the address becomes
>    either a Preferred or a Deprecated address, as per RFC 2462
> 
> Given that, it seems to me that addresses which are flagged as Deprecated may
> enter and exit that state independently of the DAD process, which I think gives
> rise to the possibility of a race.  I.e. if an address becomes deprecated right
> before DAD completes, and then addrconf_dad_complete clears the IFA_F_DEPRECATED
> flag, that seems wrong.  Instead I think it would be better if we tested for the
> OPTIMISTIC flag in ipv6_dev_get_saddr in parallel with the DEPRECATED flag.  I
> may be wrong about this, but I'm going to err on the side of safety.  If you can
> ensure that this race is not possible.  Please let me know, and I'll happily
> just set the flag.  I'll repost a new patch soon.

I tend to agree with Neil here.  Marking optimistic addresses as deprecated doesn't
buy as much since the address can transition in and out of deprecated state regardless
of DAD.

However, there is a problem with the current implementation in that OPTIMISTIC address
will never be chosen as source because it's always TENTATIVE and OPTIMISTIC at the
same time.  What needs to happen is for ipv6_dev_get_saddr() to not ignore OPTIMISTIC
addresses and treat them same as DEPRECATED.

-vlad

