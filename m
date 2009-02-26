From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel module
Date: Thu, 26 Feb 2009 10:14:33 -0800
Message-ID: <22876.1235672073@death.nxdomain.ibm.com>
References: <49A5ADB3.2010709@hp.com> <28797.1235599858@death.nxdomain.ibm.com> <20090225.141430.166906161.davem@davemloft.net> <49A6C6ED.3070801@hp.com>
Cc: David Miller <davem@davemloft.net>, arvidjaar@mail.ru,
	vladislav.yasevich@hp.com, chuck.lever@oracle.com, tytso@mit.edu,
	Valdis.Kletnieks@vt.edu, rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:43559 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751241AbZBZSOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 13:14:37 -0500
In-reply-to: <49A6C6ED.3070801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote:

>David Miller wrote:
>> From: Jay Vosburgh <fubar@us.ibm.com>
>> Date: Wed, 25 Feb 2009 14:10:58 -0800
>>
>>> 	I've been fooling with the disable_ipv6 sysctl, and one issue is
>>> that, at least on the distro I'm testing on (SLES), it's not picked up
>>> from /etc/sysctl.conf at boot time (presumably because ipv6 isn't loaded
>>> yet, although I haven't really checked).
>>
>> Correct, that's the problem.
>>
>> We could create a blocker bitmap.  Two sysctls, "block_af" and
>> "unblock_af".  You write the AF_foo value for the protocol there and
>> it sets or clears the assosciated bit in the internal blocker bitmap.
>>
>> Things like sys_socket() et al. key off of this.
>
>I'm open to suggestions at this point in time, I just don't see how this
>will solve the bonding problem since it still wouldn't load, right?

	It would permit users to load ipv6 (thus allowing bonding to
load), but prevent ipv6 from actually doing anything.  (because
sys_socket, e.g., won't open an ipv6 socket if block_af includes ipv6).

	Actually, __sock_create might be the better place to put the
hook for "create a socket"; there would probably need to be a check
within the protocol code as well, so that, e.g., ipv6 addrconf won't run
if AF_INET6 is disabled.

>Dave - do you feel I need to fix this regression?  If not I can try to
>work on this AF blocker thing.  My only other thought if we want to fix
>this is to have the IPv6 module register these five functions into an ops
>structure that bonding can call.  It doesn't fix SCTP, qeth, etc, but it
>gets these "blacklist ipv6" configs working again, and gets me out of the
>crosshairs :)

	I think the problem (customers want to disable ipv6 and use
bonding, sctp, qeth, whatever) needs to be fixed.  If it's not, I'm sure
I'll be getting lots of cards and letters from customers.

	I don't think the solution needs to preserve the current
solution (preventing the ipv6 module from loading).  Ipv6 being unusable
should be sufficient.  Except perhaps in an embedded environment, but
they're probably in a position to compile their kernel without ipv6.

	Another possible resolution is to modify the initscripts in the
distros to perform sysctl -p (read sysctls from /etc/sysctl.conf) after
ipv6 is loaded, so that the disable_ipv6 sysctl can be set.  That seems
like more work, and is limited to ipv6, so I don't see it as being
better than a "kernel shut off AF_xxx" type of solution.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
