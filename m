From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Wed, 14 Feb 2007 13:27:29 -0800
Message-ID: <20070214132729.479793ac@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46718 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932627AbXBNV22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Feb 2007 16:28:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben found this but the problem seems pretty widespread.

The following places are subject to deadlock between flush_scheduled_work
and the RTNL mutex. What can happen is that a work queue routine (like
bridge port_carrier_check) is waiting forever for RTNL, and the driver
routine has called flush_scheduled_work with RTNL held and is waiting
for the work queue to clear.

Several other places have comments like: "can't call flush_scheduled_work
here or it will deadlock". Most of the problem places are in device close
routine. My recommendation would be to add a check for device netif_running in
what ever work routine is used, and move the flush_scheduled_work to the
remove routine.

8139too.c: rtl8139_close --> rtl8139_stop_thread
r8169.c:   rtl8169_down
cassini.c: cas_change_mtu
iseries_veth.c: veth_stop_connection
s2io.c: s2io_close
sis190.c: sis190_down


