From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/2] qdisc_restart - couple of optimizations.
Date: Wed, 13 Jun 2007 10:51:00 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290306A777@orsmsx414.amr.corp.intel.com>
References: <1181724049.10679.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <kumarkr@linux.vnet.ibm.com>, <davem@davemloft.net>,
	<jamal@cyberus.ca>, <herbert@gondor.apana.org.au>, <tgraf@suug.ch>,
	<kaber@trash.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:61941 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758529AbXFMRvV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 13:51:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1181724049.10679.31.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> - netif_queue_stopped need not be called inside qdisc_restart as
>   it has been called already in qdisc_run() before the first skb
>   is sent, and in __qdisc_run() after each intermediate skb is
>   sent (note : we are the only sender, so the queue cannot get
>   stopped while the tx lock was got in the ~LLTX case).

I somewhat disagree here.  The underlying driver can conceivably stop
the device queue even if the stack holds the queue lock during an
interrupt to clean Tx descriptors, and it finds it's out of them or
needs to grab the device for whatever reason.  Granted this is a corner
case, and the net effect would be a simple requeue of the skb, but
checking the status of the queue at the last possible moment before
entering the driver could alleviate the requeue in the time between
->dequeue() from the qdisc, and hard_start_xmit() if an event like I
mentioned happened.

I'm ok with it either way, especially since this is a corner case.  But
it does need to be considered that it can happen.

Cheers,

-PJ Waskiewicz
