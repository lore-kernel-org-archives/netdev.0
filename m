From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] r8169: Reduce looping in the interrupt handler.
Date: Wed, 26 Aug 2009 14:40:57 -0700
Message-ID: <m1hbvu45jq.fsf@fess.ebiederm.org>
References: <m1r5v0ogvw.fsf@fess.ebiederm.org>
	<1251169150.4023.11.camel@obelisk.thedillows.org>
	<m1prajabk8.fsf@fess.ebiederm.org>
	<1251232848.9607.15.camel@lap75545.ornl.gov>
	<m1k50r8u4p.fsf@fess.ebiederm.org>
	<20090825221903.GA13630@electric-eye.fr.zoreil.com>
	<m1iqgbknun.fsf_-_@fess.ebiederm.org>
	<1251294974.14241.9.camel@obelisk.thedillows.org>
	<1251295175.14241.11.camel@obelisk.thedillows.org>
	<m11vmy737x.fsf@fess.ebiederm.org>
	<20090826213024.GA20428@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dillow <dave@thedillows.org>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Rui Santos <rsantos@grupopie.com>,
	Michael B??ker <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57291 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478AbZHZVlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 17:41:04 -0400
In-Reply-To: <20090826213024.GA20428@electric-eye.fr.zoreil.com> (Francois Romieu's message of "Wed\, 26 Aug 2009 23\:30\:24 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> writes:

> Eric W. Biederman <ebiederm@xmission.com> :
> [...]
>> It is a bit weird but it also means we aren't playing silly games
>> with status inside the loop.  So if we go through the loop we ack
>> everything in status.
>
> I fear we have some longstanding problem anyway :
>
> 1. quiescent state
> 2. packets are received
> 3. rtl8169_interrupt schedules napi, clears IntrStatus and exits
> 4. packets are received and some non-napi event happens
> 5. rtl8169_interrupt wakes up, reads IntrStatus and goes on...
> 6. rtl8169_poll wakes up, processes Rx and Tx napi events and goes on...
> 7. tp->intr_mask still equals ~tp->napi_event : rtl8169_interrupt
>    handler does not even try to schedule napi.
> 8. more packets are received
> 9. rtl8169_interrupt clears IntrStatus
> a. rtl8169_poll reenables napi scheduling, updates IntrMask and exits
> b. rtl8169_interrupt reads a perfectly clean IntrStatus and exits

That would not surprise me.

Right now I really don't have much more test bandwidth.  So I tried
for something simple that would address my problem without
fundamentally changing the already tested logic.  I am not seeing any
of the weird corner cases where we get confused.  The changes to fix
that problem is totally killing my ability to use the NIC, because it
loops way to much.

Perhaps we should unconditionally ack everything after changing the 
interrupt mask?  If that would prevent races it sounds like a simple fix.

Eric
