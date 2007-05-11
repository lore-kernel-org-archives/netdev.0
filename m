From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Accessing certain web sites broken from 2.6.19+
Date: Fri, 11 May 2007 08:47:05 -0700
Message-ID: <20070511084705.1fa0db14@freepuppy>
References: <4643efc2.7cb1b0b0.2a08.4658@mx.google.com>
	<7e63f56c0705102138q5a623fadm520473df49e49963@mail.gmail.com>
	<4643fc1e.095ef753.14ef.ffffb9a8@mx.google.com>
	<29891.simon.1178882860@5ec7c279.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Andrew Hall" <andrew.a.hall@gmail.com>,
	"'Robert Iakobashvili'" <coroberti@gmail.com>,
	netdev@vger.kernel.org
To: "Simon Arlott" <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52000 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757409AbXEKPrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 11:47:24 -0400
In-Reply-To: <29891.simon.1178882860@5ec7c279.invalid>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 May 2007 12:27:40 +0100
"Simon Arlott" <simon@fire.lp0.eu> wrote:

> 
> On Fri, May 11, 2007 06:16, Andrew Hall wrote:
> >> -----Original Message-----
> >> From: Robert Iakobashvili [mailto:coroberti@gmail.com]
> >> Sent: Friday, 11 May 2007 2:38 PM
> >> To: Andrew Hall
> >> Cc: netdev@vger.kernel.org
> >> Subject: Re: Accessing certain web sites broken from 2.6.19+
> >>
> >> On 5/11/07, Andrew Hall <andrew.a.hall@gmail.com> wrote:
> >> > When accessing certain web sites when using any kernel above 2.6.19,
> >> TCP
> >> > seems to break. Connection to the site is established but never
> >> completes.
> >> > One particular site is www.dcita.gov.au. Is there a known issue
> >> pertaining
> >> > to this? Using any kernel below 2.6.19 (for example: 2.6.12 or
> >> 2.6.15) works
> >> > fine.
> >>
> >> Including 2.6.21?
> >>
> >> Which browser/s have you tried?
> >>
> >> --
> >> Sincerely,
> >> Robert Iakobashvili,
> >> coroberti %x40 gmail %x2e com
> >> ...........................................................
> >> http://curl-loader.sourceforge.net
> >> A web testing and traffic generation tool.
> >
> > I have not yet tried 2.6.21.. only tried to 2.6.20.9. The issue isn't
> > browser dependent ,as a wget directly from the OS will also fail during the
> > connection. Interestingly requests made from hosts behind the 2.6.20 gateway
> > that make the same request work fine, it seems it's only requests made from
> > the localhost itself.
> >
> 
> Use tcptraceroute with and without -E to check this isn't a problem with ECN.
> 
> 

The problem is TCP window scaling, see:
	http://lwn.net/Articles/92727/

The problem is some sites have firewalls that don't follow the TCP standards.
There is no way to automatically detect these.

Linux has supported TCP window scaling for a long time, but only recently
has the default memory sizing been adjusted to use larger buffers by default.
If the buffer size is >64K then window scaling will be used. If scaling is
greater than 2 (ie >128k) then it is possible to have the problem.

The firewall is doing bad job of passing SYN packets and strips off the
options. This leaves the receiver is doing window scaling, but the sender
is not. The receiver says it has a window of say 1K bytes (with scale of 7)
but sender thinks that is only 8 bytes so goes into silly window syndrome (SWS)
avoidance and doesn't send.

The kernel developers made a conscious decision not to restrict Linux usage
of window scaling, even though it might cause problems with broken networks.
You can avoid the problem by restricting buffering by setting tcp_mem lower,
turning off window scaling with sysctl, or by setting a cwnd limit on
a per route basis.





-- 
Stephen Hemminger <shemminger@linux-foundation.org>
