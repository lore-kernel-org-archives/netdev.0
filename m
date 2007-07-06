From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
	to -mm tree
Date: Fri, 06 Jul 2007 16:59:04 +0300
Message-ID: <1183730344.6389.11.camel@ranko-fc2.spidernet.net>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org>
	 <1183642800.3789.11.camel@ranko-fc2.spidernet.net>
	 <20070705142135.GG4759@ff.dom.local>
	 <1183646029.4069.11.camel@ranko-fc2.spidernet.net>
	 <1183651165.4069.26.camel@ranko-fc2.spidernet.net>
	 <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local>
	 <20070706064523.GA2144@ff.dom.local>
	 <1183727654.6389.3.camel@ranko-fc2.spidernet.net>
	 <468E434A.9060303@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-jZt4A9kHcBO4CynroXm6"
Cc: Jarek Poplawski <jarkao2@o2.pl>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:20622 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbXGFN7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 09:59:20 -0400
In-Reply-To: <468E434A.9060303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jZt4A9kHcBO4CynroXm6
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2007-07-06 at 15:27 +0200, Patrick McHardy wrote:
> Ranko Zivojnovic wrote:
> > Managed to get stuck on a normal machine as well (2.6.22-rc6-mm1 +
> > sch_htb patch) ... here's the log:
> > 
> 
> Can you post the script you're using to reproduce this please?

Attached.

R.

--=-jZt4A9kHcBO4CynroXm6
Content-Disposition: attachment; filename=tc-crash.sh
Content-Type: application/x-shellscript; name=tc-crash.sh
Content-Transfer-Encoding: 7bit

#!/bin/bash
#
# This script does nothing useful other than attempt
# to hammer the kernel with additions and removals of
# qdisc and classes hoping to crash the kernel
#

def_c=10
a_max=100
b_max=10
dev="lo"
targ_ip="127.0.0.1"

# Flood target
ping -fq $targ_ip &

sleep 1

for ((i=0;i<1000000;i++))
do 
	ms=$((1000 + i)); 
	printf "%i - sleep %ims" $i $ms; 

	tc qdisc del dev $dev root

	(
	echo qdisc add dev $dev root handle 1: htb default $def_c
	
	for ((a=1; a<=a_max; a++))
	do
		echo class add dev $dev parent 1: classid 1:$a htb rate 100kbit ceil 100kbit
		aq=$((a+1))
		echo qdisc add dev $dev parent 1:$a handle $aq: htb default $def_c
		
		for ((b=1; b<=b_max; b++))
		do
			echo class add dev $dev parent $aq: classid $aq:$b htb rate 100kbit ceil 100kbit
			echo qdisc add dev $dev parent $aq:$b sfq perturb 10
		done
	done

	echo filter add dev $dev parent 1:0 prio 5 protocol ip u32
	echo filter add dev $dev parent 1:0 prio 5 handle 1: protocol ip u32 divisor 256
	
	# Just some filters to itterate through before hitting the target ip
	echo filter add dev $dev protocol ip parent 1:0 prio 5 u32 ht 800:: match ip src 1.1.1.1 at 12 flowid $def_c
	echo filter add dev $dev protocol ip parent 1:0 prio 5 u32 ht 800:: match ip dst 2.2.2.2 at 16 flowid $def_c
	echo filter add dev $dev protocol ip parent 1:0 prio 5 u32 ht 800:: match ip dst 10.0.0.0/8 hashkey mask 0x0000ff00 at 16 link 1:
	echo filter add dev $dev protocol ip parent 1:0 prio 5 u32 ht 800:: match ip src $targ_ip at 12 flowid $def_c
	
	) | tc -batch -

	# Skew execution
	usleep $((ms*1000)); 
	echo " - done."
done

--=-jZt4A9kHcBO4CynroXm6--

