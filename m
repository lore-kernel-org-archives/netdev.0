From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel module
Date: Thu, 26 Feb 2009 11:49:05 -0800
Message-ID: <31896.1235677745@death.nxdomain.ibm.com>
References: <49A5ADB3.2010709@hp.com> <28797.1235599858@death.nxdomain.ibm.com> <20090225.141430.166906161.davem@davemloft.net> <49A6C6ED.3070801@hp.com> <22876.1235672073@death.nxdomain.ibm.com> <49A6E1BC.4020209@hp.com>
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, arvidjaar@mail.ru,
	chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:45958 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647AbZBZTtD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 14:49:03 -0500
In-reply-to: <49A6E1BC.4020209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich@hp.com> wrote:

>Jay Vosburgh wrote:
>> Brian Haley <brian.haley@hp.com> wrote:
>> 
>>> David Miller wrote:
>>>> From: Jay Vosburgh <fubar@us.ibm.com>
>>>> Date: Wed, 25 Feb 2009 14:10:58 -0800
>>>>
>>>>> 	I've been fooling with the disable_ipv6 sysctl, and one issue is
>>>>> that, at least on the distro I'm testing on (SLES), it's not picked up
>>>>> from /etc/sysctl.conf at boot time (presumably because ipv6 isn't loaded
>>>>> yet, although I haven't really checked).
>>>> Correct, that's the problem.
>>>>
>>>> We could create a blocker bitmap.  Two sysctls, "block_af" and
>>>> "unblock_af".  You write the AF_foo value for the protocol there and
>>>> it sets or clears the assosciated bit in the internal blocker bitmap.
>>>>
>>>> Things like sys_socket() et al. key off of this.
>>> I'm open to suggestions at this point in time, I just don't see how this
>>> will solve the bonding problem since it still wouldn't load, right?
>> 
>> 	It would permit users to load ipv6 (thus allowing bonding to
>> load), but prevent ipv6 from actually doing anything.  (because
>> sys_socket, e.g., won't open an ipv6 socket if block_af includes ipv6).
>> 
>> 	Actually, __sock_create might be the better place to put the
>> hook for "create a socket"; there would probably need to be a check
>> within the protocol code as well, so that, e.g., ipv6 addrconf won't run
>> if AF_INET6 is disabled.
>
>But addrconf_init doesn't care about AF_INET6 sockets...
>
>Additionally, why is it absolutely necessary to block AF_INET6 sockets.
>I never understood that requirement?

	I don't know that it is, but it's the current behavior if ipv6
is prevented from loading.

>I can see people blocking IPv6 from loading because the module automatically
>configures IPv6 addresses and thus opens another communication channel that
>may not be monitored/controlled.  AF_INET6 sockets, on the other hand, are
>simply relegated to IPv4 protocol, when there are no IPv6 addresses.

	I believe that's only true if the ipv6 module is loaded.  If
ipv6 is not loaded, then socket(AF_INET6, ...)  returns failure with
EAFNOSUPPORT.  If ipv6 is loaded, socket(AF_INET6, ...) succeeds
(apparently no matter if there are ipv6 addresses configured or not).

>>> Dave - do you feel I need to fix this regression?  If not I can try to
>>> work on this AF blocker thing.  My only other thought if we want to fix
>>> this is to have the IPv6 module register these five functions into an ops
>>> structure that bonding can call.  It doesn't fix SCTP, qeth, etc, but it
>>> gets these "blacklist ipv6" configs working again, and gets me out of the
>>> crosshairs :)
>> 
>> 	I think the problem (customers want to disable ipv6 and use
>> bonding, sctp, qeth, whatever) needs to be fixed.  If it's not, I'm sure
>> I'll be getting lots of cards and letters from customers.
>> 
>> 	I don't think the solution needs to preserve the current
>> solution (preventing the ipv6 module from loading).  Ipv6 being unusable
>> should be sufficient.  Except perhaps in an embedded environment, but
>> they're probably in a position to compile their kernel without ipv6.
>
>Yes.  The system must not be reachable using IPv6.
>
>> 
>> 	Another possible resolution is to modify the initscripts in the
>> distros to perform sysctl -p (read sysctls from /etc/sysctl.conf) after
>> ipv6 is loaded, so that the disable_ipv6 sysctl can be set.  That seems
>> like more work, and is limited to ipv6, so I don't see it as being
>> better than a "kernel shut off AF_xxx" type of solution.
>
>This not enough.  You need to disable parts of IPv6 at module initiation
>time and the only way to do that is with a parameter.  Otherwise, you will
>have a small window of time when the system has ipv6 configured and is potentially
>vulnerable.
>
>We can have our own sysfs parameter calls that can turn the functionality
>back on to get back to a fully functional ipv6 implementation.
>
>-vlad

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
