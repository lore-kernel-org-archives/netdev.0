From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: netlink: 12 bytes leftover after parsing attributes - triggered by
 iproute2 libnetlink's rtnl_dump_request()
Date: Tue, 20 Mar 2012 13:41:07 +0100
Message-ID: <20120320134107.6acea83c@pluto.restena.lu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Greg Rose <gregory.v.rose@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Starting with 3.3 when using collectd's netlink plugin to monitor
interface stattistics I'm seeing 3 lines of complaint in kernel log per
monitoring loop (10s interval)

  [64951.027953] netlink: 12 bytes leftover after parsing attributes.

It seems link the message is generated for each network interface on the
system.

The same userspace code running on 3.2 does not produce the lines in
kernel log.



Basic source code to reproduce (netlink subset of collectd's netlink plugin):
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <linux/netlink.h>
#include <linux/rtnetlink.h>
#include <libnetlink.h>

int link_filter (const struct sockaddr_nl *sa, struct nlmsghdr *nmh, void *args) {
	return 0;
}

int main(int argc, char **argv) {
	struct rtnl_handle rth;
	struct ifinfomsg im;
	struct tcmsg tm;

	memset(&rth, 0, sizeof(rth));
	rtnl_open(&rth, 0);
	memset(&im, 0, sizeof(im));
	im.ifi_type = AF_UNSPEC;

	rtnl_dump_request(&rth, RTM_GETLINK, &im, sizeof(im));
	rtnl_dump_filter(&rth, link_filter, NULL, NULL, NULL);
	rtnl_close(&rth);
	return 0;
}



Compile with
  $CC -o test test.c -lnetlink
  (here using libnetlink.a from iproute2-2.6.38)



Strace of test code shows the following:
sendmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(2)=[{" \0\0\0\22\0\1\3\272[hO\0\0\0\0", 16}, {"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16}], msg_controllen=0, msg_flags=0}, 0) = 32
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 2980
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 20

Note: when omitting the rtnl_dump_filter() call only two lines appear
in kernel log.

Comparing to iproute2 call (ip -s link list) which does not trigger the same
message in kernel log I have:
send(3, "\24\0\0\0\22\0\1\3\225]hO\0\0\0\0\21\0\0\0", 20, 0) = 20
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 2980
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 20





Looking at kernel history related to net/netlink I've seen the following
commit which introduced the warning (or rather started using kernel's
nla_parse() function in this path - and that function complains):


commit 115c9b81928360d769a76c632bae62d15206a94a
Author: Greg Rose <gregory.v.rose@intel.com>
Date:   Tue Feb 21 16:54:48 2012 -0500

    rtnetlink: Fix problem with buffer allocation
    
    Implement a new netlink attribute type IFLA_EXT_MASK.  The mask
    is a 32 bit value that can be used to indicate to the kernel that
    certain extended ifinfo values are requested by the user application.
    At this time the only mask value defined is RTEXT_FILTER_VF to
    indicate that the user wants the ifinfo dump to send information
    about the VFs belonging to the interface.
    
    This patch fixes a bug in which certain applications do not have
    large enough buffers to accommodate the extra information returned
    by the kernel with large numbers of SR-IOV virtual functions.
    Those applications will not send the new netlink attribute with
    the interface info dump request netlink messages so they will
    not get unexpectedly large request buffers returned by the kernel.
    
    Modifies the rtnl_calcit function to traverse the list of net
    devices and compute the minimum buffer size that can hold the
    info dumps of all matching devices based upon the filter passed
    in via the new netlink attribute filter mask.  If no filter
    mask is sent then the buffer allocation defaults to NLMSG_GOODSIZE.
    
    With this change it is possible to add yet to be defined netlink
    attributes to the dump request which should make it fairly extensible
    in the future.


A kernel at preceding commit 84338a6c9dbb6ff3de4749864020f8f25d86fc81 (neighbour:
Fixed race condition at tbl->nht) does not show the log message,
starting with that commit the message appears.


Should this get fixed at kernel level, iproute2 libnetlink level or
at end-user level (e.g. collectd)?
Three lines every 10 seconds is a damn lot!

Thanks,
Bruno
