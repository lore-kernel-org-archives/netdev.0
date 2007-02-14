From: Ben Greear <greearb@candelatech.com>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Wed, 14 Feb 2007 13:44:23 -0800
Message-ID: <45D382B7.9020901@candelatech.com>
References: <20070214132729.479793ac@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:53200 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964779AbXBNVpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Feb 2007 16:45:06 -0500
In-Reply-To: <20070214132729.479793ac@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Ben found this but the problem seems pretty widespread.
> 
> The following places are subject to deadlock between flush_scheduled_work
> and the RTNL mutex. What can happen is that a work queue routine (like
> bridge port_carrier_check) is waiting forever for RTNL, and the driver
> routine has called flush_scheduled_work with RTNL held and is waiting
> for the work queue to clear.
> 
> Several other places have comments like: "can't call flush_scheduled_work
> here or it will deadlock". Most of the problem places are in device close
> routine. My recommendation would be to add a check for device netif_running in
> what ever work routine is used, and move the flush_scheduled_work to the
> remove routine.

I seem to be able to trigger this within about 1 minute on a
particular 2.6.18.2 system with some 8139too devices, so if someone
has a patch that could be tested, I'll gladly test it.  For
whatever reason, I haven't hit this problem on 2.6.20 yet, but
that could easily be dumb luck, and I haven't been running .20
very much.

To add to the list below, tg3 has this problem as well, as far as I
can tell by looking at the code.

Thanks,
Ben

> 
> 8139too.c: rtl8139_close --> rtl8139_stop_thread
> r8169.c:   rtl8169_down
> cassini.c: cas_change_mtu
> iseries_veth.c: veth_stop_connection
> s2io.c: s2io_close
> sis190.c: sis190_down
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

