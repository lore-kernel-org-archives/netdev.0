From: Joe Perches <realty@perches.com>
Subject: Convert net_msg_warn, NETDEBUG, & LIMIT_NETDEBUG?
Date: Tue, 04 Nov 2014 12:46:40 -0800
Message-ID: <1415134000.23168.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0246.hostedemail.com ([216.40.44.246]:39753 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751732AbaKDUxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 15:53:17 -0500
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by smtpgrave01.hostedemail.com (Postfix) with ESMTP id 5BA0F5DFF6
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 20:46:45 +0000 (UTC)
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay07.hostedemail.com (Postfix) with ESMTP id 657FDC2129
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 20:46:44 +0000 (UTC)
Received: from joe-X200MA.home (pool-71-103-235-196.lsanca.fios.verizon.net [71.103.235.196])
	(Authenticated sender: joe@perches.com)
	by omf12.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 20:46:41 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_msg_warn is a sysctl used to control the printk
of a bundle of mostly ipv4/ipv6 logging messages.

Does anyone use it?

NETDEBUG is used 4 times, 2 of which seem senseless
as they are allocation failures messages after an
alloc_skb.  These already get stack dumps.

The other NETDEBUG uses are ESP crypto descriptions.

LIMIT_NETDEBUG is used a lot more.

include/net/sock.h:#define LIMIT_NETDEBUG(fmt, args...) \
include/net/sock.h-     do { if (net_msg_warn && net_ratelimit()) printk(fmt,##args); } while(0)

Most of the LIMIT_NETDEBUG uses are emitted at KERN_DEBUG.

Here is the count of each type of use:
     31 KERN_DEBUG
      2 KERN_ERR
      3 KERN_INFO
     11 KERN_WARNING

Should those KERN_DEBUG uses be converted to
net_dbg_ratelimited so that these uses could be
controlled via dynamic_debug instead of the
net_msg_warn sysctl?

net/dccp/ uses LIMIT_NETDEBUG via DCCP_WARN to
control another 38 KERN_WARNING messages.

The others LIMIT_NETDEBUG uses could be converted
to net_<level>_ratelimited if appropriate.
