From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 21 Apr 2011 11:25:49 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E4999A4A@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	<1302253651.4409.2.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	<1302267400.4409.22.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
	<1302275223.4409.36.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>
	<1302330998.2656.113.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>
	<4DA3151B.4030507@intel.com>
	<D12839161ADD3A4B8DA63D1A134D084026E4909714@ESGSCCMS0001.eapac.ericsson.se>
	<1302536577.4605.1.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E49535F2@ESGSCCMS0001.eapac.ericsson.se>
	<1302761251.3549.198.camel@edumazet-laptop>
	<1302762810.3549.233.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E49536AF@ESGSCCMS0001.eapac.ericsson.se>
	<4DA723F1.7000901@intel.com>	<1302800202.2035.32.camel@laptop>
	<1302800221.3248.39.camel@edumazet-laptop>	<1302857857.2388.158.camel@twins>
	<D12839161ADD3A4B8DA63D1A134D084026E4953D6E@ESGSCCMS0001.eapac.ericsson.se>
 <BANLkTin_OgBo3N8qi5cF5rOd__pRKifwsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Mike Galbraith <efault@gmx.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:62390 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab1DUD0i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 23:26:38 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Okay, I see the magic in the code:
static inline void skb_record_rx_queue(struct sk_buff *skb, u16 rx_queue)
{
        skb->queue_mapping = rx_queue + 1;
}

static inline u16 skb_get_rx_queue(const struct sk_buff *skb)
{
        return skb->queue_mapping - 1;
}

static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
{
        return (skb->queue_mapping != 0);
}

Anyway it seems strange that we have different meaning of skb->queue_mapping for Tx and Rx. Is it better to using higher 4 bit Or even FFFF to indicate rx_queue not recorded?

-----Original Message-----
From: Wei Gu
Sent: Thursday, April 21, 2011 10:57 AM
To: 'netdev'
Cc: 'Peter Zijlstra'; 'Eric Dumazet'; 'Alexander Duyck'; 'Kirsher, Jeffrey T'; 'Mike Galbraith'; 'Thomas Gleixner'; 'Jesse Brandeburg'
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel


A quick question, regarding the skb->queue_mapping?
Do you know who will put the queue number for the received skb on the receving path? Cause I found it has a value in the recevied skb, but it seems over the range of rx/tx queues. Like if only have 8 rx and 8 tx queues on this netdev, then I can see the queue_mapping in the receving skb will be in [1-8], which I expect is [0-7].

Thanks
WeiGu
-----Original Message-----
From: Wei Gu
Sent: Tuesday, April 19, 2011 12:09 PM
To: 'Jesse Brandeburg'
Cc: Peter Zijlstra; Eric Dumazet; Alexander Duyck; netdev; Kirsher, Jeffrey T; Mike Galbraith; Thomas Gleixner
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

Hi,
This is the result that I running the turbostat via 2.6.35.3 and perform the same load test on eth10 (8 tx/rx queue binding to core 24-31) according you instruction.
I was add the processor.max_cstate=1 in the boot params, and also disabled the cstate in the BIOS. But looks like the kernel does take them.

Thanks
WeiGu

-----Original Message-----
From: Jesse Brandeburg [mailto:jesse.brandeburg@gmail.com]
Sent: Tuesday, April 19, 2011 5:12 AM
To: Wei Gu
Cc: Peter Zijlstra; Eric Dumazet; Alexander Duyck; netdev; Kirsher, Jeffrey T; Mike Galbraith; Thomas Gleixner
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

On Fri, Apr 15, 2011 at 2:14 AM, Wei Gu <wei.gu@ericsson.com> wrote:
> Is there something that I can provide in order to identify the problem?

for power state concerns you may want to try running turbostat (available in recent kernels, runs also on older kernels) during the workload in question.  Capture the results via something like:
cd /home/jbrandeb/linux-2.6.38.2/tools/power/x86/turbostat
make
for i in `seq 1 10` ; do ./turbostat -v sleep 5 >> turbostat.txt 2>&1 ; done

Jesse
