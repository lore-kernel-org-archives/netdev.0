From: Anton <Anton.Uzunov@dsto.defence.gov.au>
Subject: sending IPv6 packets via kern_sendmsg
Date: Wed, 06 Jun 2007 13:53:55 +0930
Message-ID: <466636DB.8060107@dsto.defence.gov.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from digger1.defence.gov.au ([203.5.217.4]:35871 "EHLO
	digger1.defence.gov.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbXFFEYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 00:24:04 -0400
Received: from ednmsw510.dsto.defence.gov.au (ednmsw510.dsto.defence.gov.au [131.185.68.11])
	by digger1.defence.gov.au (8.13.8/8.13.8) with ESMTP id l564E95m008066
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 13:44:09 +0930 (CST)
Received: from ednex510.dsto.defence.gov.au (ednex510.dsto.defence.gov.au) by
    ednmsw510.dsto.defence.gov.au (Clearswift SMTPRS 5.2.9) with ESMTP id
    <T800db8e95683b9440bb8c@ednmsw510.dsto.defence.gov.au> for
    <netdev@vger.kernel.org>; Wed, 6 Jun 2007 13:53:56 +0930
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Following on from a previous (now lost :-)) posting, I have been trying 
to send out IPv6 packets from a kernel module using the kern_sendmsg() 
function. Since in theory I need this function to be started in 
interrupt context (actually, softirq context), but since this is 
impossible because kern_sendmsg() needs to sleep, I have created a work 
queue which calls the kern_sendmsg() function separately. The work queue 
is scheduled from the softirq context (actually, at the moment this 
happens from a Netfilter hook). The work queue function creates a msghdr 
structure, fills in a sin6_addr structure, calls sock_create_kern() and 
then uses this socket to send an IPv6 packet, which consists of a header 
(struct ipv6hdr *iphdr) and some data following on from this. The above 
packet is placed in the msghdr structure by setting (after the 
appropriate initializations):
msg.msg_iov->iov_base = (char *) ip6hdr;
msg.msg_iov->iov_len = sizeof( struct ipv6hdr + ntohs( 
ip6hdr->payload_len ) );
msg.msg_iovlen = 1;
msg.msg_name = &sin6addr;
msg.msg_namelen = sizeof( struct sin6_addr );
However, when trying to send this using kern_sendmsg() (or even 
sock_sendmsg()) to perform the send operation, I get an error  (-22 - 
EINVAL), which, according to the user-space sendmsg(), corresponds to:
"The sum of the iov_len values overflows an ssize_t. "
Certainly this is not the case, since the packet in question is an 
ICMPv6 ping packet whose header size and data would rarely exceed 100 
bytes.
The test is being run on kernel 2.6.18.
 From what I have read on the internet, in books and in a previous 
suggestion from the netdev mailing-list, the use of kern_sendmsg() seems 
to be the appropriate way of sending packets from a kernel module. Am I 
doing something incorrectly above, or should I be using some other 
function instead of kern_sendmsg() (or sock_sendmsg())?

I would appreciate any ideas.

Regards,
Anton


IMPORTANT: This email remains the property of the Australian Defence Organisation and is subject to the jurisdiction of section 70 of the CRIMES ACT 1914.  If you have received this email in error, you are requested to contact the sender and delete the email.


