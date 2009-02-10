From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] iptables: lock free counters (v0.6)
Date: Tue, 10 Feb 2009 14:20:30 -0800
Message-ID: <4991FDAE.9060006@hp.com>
References: <20090204001202.724266235@vyatta.com>	<20090204001755.808036408@vyatta.com>	<4989071E.5000803@cosmosbay.com> <4990515B.3070409@trash.net>	<20090209091437.5d5cbf48@extreme> <20090210095220.3e1350a1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:13933 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017AbZBJWUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 17:20:35 -0500
In-Reply-To: <20090210095220.3e1350a1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> The reader/writer lock in ip_tables is acquired in the critical path of
> processing packets and is one of the reasons just loading iptables can cause
> a 20% performance loss. The rwlock serves two functions:
> 
> 1) it prevents changes to table state (xt_replace) while table is in use.
>    This is now handled by doing rcu on the xt_table. When table is
>    replaced, the new table(s) are put in and the old one table(s) are freed
>    after RCU period.
> 
> 2) it provides synchronization when accesing the counter values.
>    This is now handled by swapping in new table_info entries for each cpu
>    then summing the old values, and putting the result back onto one
>    cpu.  On a busy system it may cause sampling to occur at different
>    times on each cpu, but no packet/byte counts are lost in the process.

I've taken this round for a spin on the 32-core setup.  I'd not previously 
applied Patrick's patches to remove the initialization, so my kludges to compile 
may have altered things, but assuming it was OK (convert the inits to 
__MUTEX_INITIALIZER to make the compiler happy) it appears that this change does 
very good things indeed for the "empty" case.  Where the 
2.6.29-rc2/unpatchednet-next showed a 50% drop (handwaving math) in the "empty" 
case compared to the "none" case (aka none is no iptables modules loaded, empty 
being what one gets after iptables --list) this patch shows what appears to be a 
much much smaller drop of less than 6%.

The original data can be seen at:

ftp://ftp.netperf.org/iptable_scaling/  in no_iptables and empty_iptables

and the data after this patch can be seen at:

ftp://ftp.netperf.org/hemminger/hemminger6/  in none and empty

while I have none of Eric's patches in this tree, just for grins I went ahead and 
ran "full" as well.

happy benchmarking,

rick jones
