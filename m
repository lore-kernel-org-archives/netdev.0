From: John Haxby <john.haxby@oracle.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 13:37:17 +0100
Message-ID: <4E01E1FD.8010802@oracle.com>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com> <4E0115B3.2030802@redhat.com> <20110621225645.GD16021@Chamillionaire.breakpoint.cc> <20110621.155816.1840729860084652508.davem@davemloft.net> <4E01C34F.6050009@redhat.com> <20110622105434.GE16021@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Prarit Bhargava <prarit@redhat.com>,
	David Miller <davem@davemloft.net>, fbl@redhat.com,
	netdev@vger.kernel.org, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:49907 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757815Ab1FVMhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 08:37:50 -0400
In-Reply-To: <20110622105434.GE16021@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/06/11 11:54, Florian Westphal wrote:
> Prarit Bhargava <prarit@redhat.com> wrote:
>
> [ cc'd John Haxby, who worked on xt_SYSREQ ]
>
>> On 06/21/2011 06:58 PM, David Miller wrote:
>>> From: Florian Westphal <fw@strlen.de>
>>> Date: Wed, 22 Jun 2011 00:56:45 +0200
>>>> This is one of the reasons why I still think that
>>>> xt_SYSREQ would be the better solution, you get all
>>>> kinds of filtering features for free.
>>>>
>>>> You could even use crazy things like '-m time' to restrict
>>>> sysreq availability to working hours and whatnot.
>>>>
>>> Agreed.
>> Using the netfilter xt-SYSRQ code seems to store the entered code and
>> execute it later after the system has returned to a normal state....
>> which is much too late to be useful.
> The target handler of the kernel part invokes handle_sysrq(),
> I don't see any delaying/queueing?
>
> FWIW, the old discussion is in the archives:
> search for subject "nf-next: sysrq and condition 20100421" from Jan
> Engelhardt, or try
> http://thread.gmane.org/gmane.comp.security.firewalls.netfilter.devel/33615/focus=34808
>
> As far as i understand the use case described by John Haxby matches yours.
>
> Patrick McHardy suggested an alternative standalone method involving
> encapsulation sockets; perhaps the reasons why this path was not chosen
> have changed.
>
> I think that a standalone module (i.e. not requiring netfilter) that
> runs the sysreq handling after all netfilter hooks would be optimal,
> but I don't see a simple method to implement that.

The xt_SYSRQ calls handle_sysrq() in BH context, much the same context
as ping is handled in.  (Actually, it's likely xt_SYSRQ will work even
if ping doesn't since nothing has to come back.)

It's possible for xt_SYSRQ to fail.   My usual case for failure was
simply not enabling it :-)  However, as you typically have to fight your
way through iptables to get to xt_SYSRQ then you can get into trouble
that way.

Although I wasn't sure that it could happen, it's also possible that the
cryptographic functions can get in your way.  xt_SYSRQ does its best to
avoid problems by pre-allocating everything it can so there is as little
as possible to do when it is needed, but it is possible for it to fail.

The module that Patrick McHardy suggested works up to a point:
handle_sysrq() can still be called in BH context but unfortunately I
couldn't get it working for IPv6: the necessary hook isn't implemented
for IPv6 (or rather, it wasn't, I don't know if something has changed
since then).

jch
