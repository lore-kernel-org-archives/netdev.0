From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAPI rescheduling and the delay caused by it
Date: Wed, 04 Dec 2013 15:32:11 -0800
Message-ID: <1386199931.30495.139.camel@edumazet-glaptop2.roam.corp.google.com>
References: <529F7A87.5080303@citrix.com>
	 <1386189718.30495.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <529F9D4B.1020208@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:65381 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280Ab3LDXcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 18:32:14 -0500
Received: by mail-yh0-f46.google.com with SMTP id l109so12072382yhq.33
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 15:32:14 -0800 (PST)
In-Reply-To: <529F9D4B.1020208@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-04 at 21:23 +0000, Zoltan Kiss wrote:

> I see netif_rx_ni makes sure the softirq is executed, but I'm not sure I 
> get how is it related to wake_queue. Can you explain a bit more?
> 

Calling netif_wake_queue() from process context makes no guarantee the
TX softirq is processed in the following cycles.

This interface is meant to be used from softirq context.


Try to enclose it in :

void xenvif_notify_tx_completion(struct xenvif *vif)
{
	if (netif_queue_stopped(vif->dev) && xenvif_rx_schedulable(vif)) {
		local_bh_disable();
		netif_wake_queue(vif->dev);
		local_bh_enable();
	}
}
