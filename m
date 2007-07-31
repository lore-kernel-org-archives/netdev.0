From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [Bugme-new] [Bug 8754] New: Kernel addrconf modifies MTU of non-kernel
 routes
Date: Tue, 31 Jul 2007 21:32:35 +0100
Message-ID: <46AF9C63.5090303@simon.arlott.org.uk>
References: <bug-8754-10286@http.bugzilla.kernel.org/> <20070714150908.093eefdb.akpm@linux-foundation.org> <4699E915.5040904@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:35882 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932501AbXGaUcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 16:32:39 -0400
In-Reply-To: <4699E915.5040904@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/07/07 10:29, Simon Arlott wrote:
> On 14/07/07 23:09, Andrew Morton wrote:
>> On Sat, 14 Jul 2007 14:54:32 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
>>> http://bugzilla.kernel.org/show_bug.cgi?id=8754
>>> 
>>> I have an MTU of 16110 set on eth0 on a network where the MTU is 1500 as set by
>>> RAs. One of the other hosts on the network has an MRU/MTU of 7200 so I have a
>>> specific route to it with this MTU.
>>> 
>>> If I add the route early (i.e. on startup) before address autoconfiguration
>>> takes place, when the first RA is received the kernel changes the MTU on my
>>> route - this should not happen.
> 
> This also happens whenever I change the MTU on eth0 - it will alter the
> MTU on routes *I* have added too. While this is valid behaviour for a
> new MTU that is too low for the route it is not for an MTU above the route.
> 
> Changing the MTU also allows the "next RA with MTU set changes
> non-kernel routes too" problem to occur again.

The problem seems to be that because the IPv6 code maintains its own MTU for 
each interface, which is set from RAs (router advertisements) and when the 
interface MTU is set (it's also improperly modifiable via sysctl when it 
shouldn't be, but that's another bug), it uses that to limit the MTU of every 
route.


I propose that it should use the real interface MTU as the limit for non-kernel 
routes and the RA MTU for kernel routes.


Since IPv6 routes (appear to) always have an MTU (IPv4 routes don't and hence 
inherit from the interface) this would have the side effect that a user-added 
route's automatically set MTU would not be lowered by the RA MTU.

New user IPv6 routes without an explicit MTU should not have one set and use 
the RA MTU automatically.


Is this ok? I'll send a patch to do this some time this week when I get around 
to it.

-- 
Simon Arlott
