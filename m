From: David Miller <davem@davemloft.net>
Subject: Re: [ PATCH 2.6.17-rc6 1/1] udp.c: counting InDatagrams which are
 never delivered
Date: Sun, 11 Jun 2006 23:13:00 -0700 (PDT)
Message-ID: <20060611.231300.95505265.davem@davemloft.net>
References: <200606061925.40327@this-message-has-been-logged>
	<20060611.212913.70218067.davem@davemloft.net>
	<200606120702.46014@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@coreworks.de, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21954
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750929AbWFLGMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 02:12:52 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200606120702.46014@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 12 Jun 2006 07:02:45 +0100

> This is clearly preferable - would it look like this:
> 
> csum_copy_err:
>      UDP_INC_STATS_BH(UDP_MIB_INERRORS);
>      UDP_DEC_STATS_BH(UDP_MIB_INDATAGRAMS); /* requires new macro */
> 
>      skb_kill_datagram(sk, skb, flags);
>      /* ... */
> 
> in udp_recvmsg? Here I must pass - there is no xxx_DEC_BH macro in 
> include/net/snmp.h and I don't know whether the following guess is correct:
> 
> #define SNMP_DEC_STATS_BH(mib, field) 	\
> 	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field]--)
> 
> If this is correct, then it seems done; one could use this macro or add
> a corresponding UDP_DEC_STATS_BH to include/net/udp.h .

The index of mib[] in those macros is always "!in_softirq()", the
*_BH() variants use zero for the index because they are called in
contexts where we know that "!in_sortirq()" evaluates to false.

So your SNMP_DEC_STATS_BH() macro is correct.

Can you cook up the patch, which adds your SNMP_DEC_STATS_BH() macro,
the UDP_DEC_STATS_BH counterpart, and the change that uses it in
net/ipv4/udp.c?

I'd appreciate this, thanks a lot.
