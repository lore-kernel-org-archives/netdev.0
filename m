From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Fri, 16 Feb 2007 08:29:28 +0100
Message-ID: <20070216072928.GA1599@ff.dom.local>
References: <20070214132729.479793ac@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:53134 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932989AbXBPH0O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 02:26:14 -0500
Content-Disposition: inline
In-Reply-To: <20070214132729.479793ac@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14-02-2007 22:27, Stephen Hemminger wrote:
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
> 
> 8139too.c: rtl8139_close --> rtl8139_stop_thread
> r8169.c:   rtl8169_down
> cassini.c: cas_change_mtu
> iseries_veth.c: veth_stop_connection
> s2io.c: s2io_close
> sis190.c: sis190_down
> 

There is probably more than this...

I think the same problem is with
cancel_rearming_delayed_work. Plus indirect calling
these functions: eg. by ieee8021softmac_stop.

I found these dangerous places (probably not all):

cxgb3/cxgb3_main.c (cxgb_close -> cxgb_down),

macb.c (macb_close),

skge.c (skge_down),

wireless/bcm43xx/bcm43xx_main.c (bcm_net_stop both
	ieee80211...  and flush_...),
wireless/zd1211rw/zd_mac.c (zd_mac_stop ->
	housekeeping_disable),

chelsio/my3126.c (t1_interrupts_disable ->
	my3126_interrupt_disable), /* not sure */

drivers/usb/net/kaweth.c (kaweth_close ->
	kaweth_kill_urbs)

Regards,
Jarek P.
