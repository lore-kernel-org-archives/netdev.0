From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] ehea: Optional TX/RX path optimized for SMP
Date: Fri, 23 Feb 2007 08:49:59 -0800
Message-ID: <adairdses3s.fsf@cisco.com>
References: <200702231730.58579.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:19239 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1160993AbXBWQuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 11:50:01 -0500
In-Reply-To: <200702231730.58579.ossthema@de.ibm.com> (Jan-Bernd Themann's message of "Fri, 23 Feb 2007 17:30:58 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > This patch introduces an optional alternative receive processing
 > functionality (enabled via module load parameter). The ehea adapter
 > can sort TCP traffic to multiple receive queues to be processed by
 > the driver in parallel on multiple CPUs. The hardware always puts
 > packets for an individual tcp stream on the same queue. As the
 > current NAPI interface does not allow to handle parallel receive
 > threads for a single adapter (processing on multiple CPUs in parallel)
 > this patch uses tasklets with a simple fairness algorithm instead. 
 > On the send side we also take advantage of ehea's multiple send queue
 > capabilites. A simple hash function in combination with the LL_TX
 > attribute allows to process tx-packets on multiple CPUs on different
 > queues. The hash function is needed to guarantee proper TCP packet
 > ordering. This alternative packet processing functionality leads to 
 > significant performance improvements with ehea. 

Why make this a module option that the user has to set?  Are there any
circumstances when someone wouldn't want "significant performance
improvements?"  If this approach is just better, then it should just
replace the old code.

Also, as far as the approach of using tasklets, I think it would be
better to use the "fake netdev" approach to continue to use NAPI.
Basically you create a pseudo-netdev for each receive queue and have
NAPI handle the polling for you -- you could look for
drivers/net/cxgb3 for an example of this.

 - R.
