From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/1] bonding: eliminate RTNL assertion spew
Date: Wed, 15 Aug 2007 12:15:45 -0700
Message-ID: <11975.1187205345@death>
References: <20070109225900.GA11755@gospo.rdu.redhat.com> <20070109150935.6ec3ce69@localhost> <20070110193355.GA13249@gospo.rdu.redhat.com> <170fa0d20708142014l217b8804g66426a84547ba91d@mail.gmail.com> <bdfc5d6e0708142027i669347aasa935bb277b2bbb48@mail.gmail.com> <170fa0d20708151136q1535672dvbc90271afe80ec6f@mail.gmail.com>
Cc: "Andy Gospodarek" <andy@greyhouse.net>,
	"Stephen Hemminger" <shemminger@osdl.org>,
	"Jeff Garzik" <jeff@garzik.org>, netdev@vger.kernel.org
To: "Mike Snitzer" <snitzer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:35724 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219AbXHOTPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 15:15:48 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7FJFl7x010604
	for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 15:15:47 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7FJFl0J426132
	for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 15:15:47 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7FJFlJ3022733
	for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 15:15:47 -0400
In-reply-to: <170fa0d20708151136q1535672dvbc90271afe80ec6f@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mike Snitzer <snitzer@gmail.com> wrote:

>I'd very much like to help out.  The "rtnl assertion spew" isn't
>instilling confidence in customers I've been working with.  If you'd
>like to send me patches in private I'd help test them ASAP.

	I'll send you some stuff off-list in a bit.

>Could you elaborate on the associated risk of _not_ fixing these
>issues?  balance-alb _seems_ to be working even though these traces
>occur on initialization.  But these rtnl traces are clearly more
>generic than balance-alb.

	There are really a couple of things going on.

	One danger is that some network device drivers may sleep in
certain critical sections (set MAC address, for example) while bonding
holds some lock.  Most drivers don't have potential sleeps here, but a
few do.  The most notable as I recall are a subset of the tg3 devices,

	The other danger is that some callback in the notifier call when
the MAC address changes may sleep.

	These are both separate from the RTNL warnings, which are a
notification that the interface is being messed with, but RTNL isn't
held.  The danger here is that a concurrent, independent, operation
could acquire RTNL and simultaneously fiddle with the interface.

	The ultimate problem with fixing it is that the locking in
bonding was implemented before these locking constraints existed, and
untangling the locking to conform to the new rules is fairly invovled.
Andy and I have been through several iterations of a "final" patch, and
we keep finding regressions.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
