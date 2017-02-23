From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next v4 4/7] gtp: consolidate gtp socket rx path
Date: Thu, 23 Feb 2017 17:46:57 +0100
Message-ID: <20170223164657.tmj7djdpgcdlm2ri@nataraja>
References: <20170221101855.23940-1-aschultz@tpip.net>
 <20170221101855.23940-5-aschultz@tpip.net>
 <CALx6S34-H9rzbJjJRGkRqswnOFK7pKg0gMU+JkgK=Nh77dWoiQ@mail.gmail.com>
 <754038178.195270.1487841591136.JavaMail.zimbra@tpip.net>
 <CALx6S34mFZh31Yorq7WMabTO9SPyxOn5=1iSEQV41HguYJ1bDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Schultz <aschultz@tpip.net>, pablo <pablo@netfilter.org>,
        netdev <netdev@vger.kernel.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        timo lindhorst <timo.lindhorst@travelping.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:54210 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbdBWQwH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 11:52:07 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S34mFZh31Yorq7WMabTO9SPyxOn5=1iSEQV41HguYJ1bDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Thu, Feb 23, 2017 at 08:28:47AM -0800, Tom Herbert wrote:

> If there is a way for us to test this without setting up a full mobile
> network please provide details on how to do that in the commit log.

There are different ways how to do this.  With the existing in-kernel
code (that lacks the "SGSN role" patch which would be for testing only),
you can e.g. use two relatively small C-language programs from the
openggnsn package [http://git.osmocom.org/openggsn/]:

* OpenGGSN with support for libgtpnl and the kernel GTP-U module
* sgsnemu (included in openggsn source tree) which implements a minimal
  SGSN-side of the tunnel.  It will
  * perform the GTP-C signaling required with OpenGGSN (which in turn
    will then instruct the kernel to open a  tunnel via the netlink
    interface).
  * start a tun/tap device for the "mobile station end" of the tunnel
    perform en/decapsulation of data between that tun/tap device and GTP
    in userspace

The wiki at https://osmocom.org/projects/openggsn/wiki/OpenGGSN contains
step-by-step instructions how to build and configure OpenGGSN with
support for kernel GTP-U. It's nothing more than autotools based
compile+install of libgtpnl followed by "./configure --enable-gtp-linux"
and "make" for OpenGGSN 

What is not described on the above page is how to use sgsnemu to
simulate the SGSN side, as within Osmocom we typically run the open
source OsmoSGSN (a more "real" SGSN).

So using two small binaries that can be compiled without much external
dependencies (and very few lines of configuration), it is possible to do
some functional testing of the kernel GTP module.  For performance
testing this of course won't work, as sgsnemu is running entirely in
userspace.

For performance testing, you would need a SGSN-side implementation of
GTP-U that performs equally well or better than the GGSN-side
implementation in the kernel.  One option is the patch that has recently
been submitted to netdev and which is under discussion.  However, then
you simply test one implementation against itself, which provides no
interoperability guarantees with other implementations, and thus also
limited in different regards.

> > Adding static tunnel support into the kernel module in any form
> > makes IMHO no sense. GTP as defined by 3GPP always need a control
> > instance and there are much better options for static tunnel
> > encapsulations.
> >
> That misses the point. From the kernel point of view GTP is just
> another encapsulation protocol and we now have a lot of experience
> with those. The problem is when you post patches to improve it or fix
> issues, if there is no practical way to perform independent  analysis
> or investigation. This makes GTP no different than a proprietary
> protocol to us and that severely limits the value of trying to work
> with the community.

I wholeheartedly agree.  That's one of the reasons why I recently posted
a RFC about what to do for (regression and other) testing of the kernel
GTP-U module.

I'll try to cook up some instructions extending
https://osmocom.org/projects/openggsn/wiki/OpenGGSN to cover also
sgsnemu for a basic use case of establishing one single tunnel.  That's
of course like a manual "HOWTO" and not yet anything that can be tested
automatically.

Regards,
	Harald

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
