From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: netlink: 12 bytes leftover after parsing attributes - triggered
 by iproute2 libnetlink's rtnl_dump_request()
Date: Tue, 3 Apr 2012 12:17:54 +0200
Message-ID: <20120403121754.56e7727b@pluto.restena.lu>
References: <20120320134107.6acea83c@pluto.restena.lu>
	<20120320074140.39a1b3f0@nehalam.linuxnetplumber.net>
	<1332255630.8043.11.camel@deadeye>
	<20120320170229.49de95f5@nehalam.linuxnetplumber.net>
	<20120403100157.GA8611@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/U2MDWg/DJkvThnzavTu6pY9"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	Greg Rose <gregory.v.rose@intel.com>
To: Thomas Graf <tgraf@infradead.org>, libnl@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.restena.lu ([158.64.1.62]:44033 "EHLO
	smtprelay.restena.lu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab2DCKR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 06:17:56 -0400
In-Reply-To: <20120403100157.GA8611@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/U2MDWg/DJkvThnzavTu6pY9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Thomas,

On Tue, 3 Apr 2012 06:01:57 Thomas Graf <tgraf@infradead.org> wrote:
> Can you send a full bug report to libnl@lists.infradead.org and I'll make sure
> this gets addressed in libnl.

Here it comes (mostly initial mail with some adjustments):


Starting with linux-3.3 when using collectd's netlink plugin to monitor
interface statistics I'm seeing 3 lines of complaint in kernel log per
monitoring loop (10s interval)

  [64951.027953] netlink: 12 bytes leftover after parsing attributes.

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
	return 0; /* would present the data */
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


A working adjustment to collectd (or above test code) is to call
rtnl_wilddump_request() instead of rtnl_dump_request() in order to
get the information.
rtnl_wilddump_request() is also the function used internally by iproute2's
ip command to fetch the data.



Bruno
--MP_/U2MDWg/DJkvThnzavTu6pY9
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=collectd-netlink-kernwarn-fix.patch

Starting with linux-3.3-rc5 kernel at each interval netlink plugin triggers
three lines of kernel log:
  netlink: 12 bytes leftover after parsing attributes.

Change the libnetlink function used to query link statistics to match
iproute2's behavior and thus not trip on the kernel's new parsing of
optional attributes for RTM_GETLINK.

While at it, also fix libnetlink's complaint to stderr:
  !!!Deficit 16, rta_len=996
caused by incorrect calculation of msg_len.

Signed-off-by: Bruno Prémont <bonbons@linux-vserver.org>
---

This should get applied to 5.0 and 4.10 series!

The two hunks may get applied separately.

--- collectd-a/src/netlink.c	2012-03-21 19:20:15.304227640 +0100
+++ collectd-b/src/netlink.c	2012-03-21 19:21:20.454323202 +0100
@@ -223,7 +223,7 @@ static int link_filter (const struct soc
 
   msg = NLMSG_DATA (nmh);
 
-  msg_len = nmh->nlmsg_len - sizeof (struct ifinfomsg);
+  msg_len = nmh->nlmsg_len - NLMSG_LENGTH(sizeof (struct ifinfomsg));
   if (msg_len < 0)
   {
     ERROR ("netlink plugin: link_filter: msg_len = %i < 0;", msg_len);
@@ -554,17 +554,13 @@ static int ir_init (void)
 
 static int ir_read (void)
 {
-  struct ifinfomsg im;
   struct tcmsg tm;
   int ifindex;
 
   static const int type_id[] = { RTM_GETQDISC, RTM_GETTCLASS, RTM_GETTFILTER };
   static const char *type_name[] = { "qdisc", "class", "filter" };
 
-  memset (&im, '\0', sizeof (im));
-  im.ifi_type = AF_UNSPEC;
-
-  if (rtnl_dump_request (&rth, RTM_GETLINK, &im, sizeof (im)) < 0)
+  if (rtnl_wilddump_request (&rth, AF_UNSPEC, RTM_GETLINK) < 0)
   {
     ERROR ("netlink plugin: ir_read: rtnl_dump_request failed.");
     return (-1);

--MP_/U2MDWg/DJkvThnzavTu6pY9--
