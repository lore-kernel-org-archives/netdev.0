From: David Ahern <dsa@cumulusnetworks.com>
Subject: increase in time to delete an interface with 4.x kernels
Date: Mon, 27 Jul 2015 10:49:48 -0600
Message-ID: <55B6612C.7050506@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36348 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753614AbbG0Qtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 12:49:50 -0400
Received: by igbij6 with SMTP id ij6so79942659igb.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 09:49:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex:

I believe you did the recent overhaul to the fib implementation. I am 
seeing dramatically higher times to delete an interface with an ipv4 
address in 4.2-rc3. perf-top points to update_suffix:

    PerfTop:   15834 irqs/sec  kernel:97.3%  exact:  0.0% [4000Hz 
cpu-clock],  (all, 4 CPUs)
-------------------------------------------------------------------------------------------

     74.69%  [kernel]       [k] update_suffix
      2.38%  [kernel]       [k] fib_table_flush
      2.20%  [kernel]       [k] fib6_walk_continue
      2.03%  [kernel]       [k] fib6_ifdown
      1.31%  [kernel]       [k] fib6_age


I have a simple script to create and assign an ipv4 address to 10k dummy 
interfaces:

l=0
for (( j = 1; j <= 40; j += 1))
do
	for (( k = 1 ; k <= 250  ; k += 1 ))
	do
		l=$((l + 1))
		ip link add dev dummy${l} type dummy
	  	ip addr add  72.$j.$k.1/24 dev dummy${l}
	  	ifconfig dummy${l} up
	done
done


and a counter script to delete them all:

k=$(ip link show | grep dummy | wc -l)
for (( j = 1; j <= k; j += 1))
do
	ip link del dev dummy${j}
done


Looking at v3.19:

# time ./tadd-dummy.sh

real    3m8.896s
user    0m7.104s
sys     0m22.020s


# time ./tdel-dummy.sh

real    7m18.207s
user    0m3.824s
sys     3m15.672s


And the time to delete 1 interface after all 10k have been created:
# time ip link del dev dummy6666

real    0m0.064s
user    0m0.000s
sys     0m0.020s


Contrast those times with 4.2.0-rc3+ running the exact same scripts

# time ./tadd-dummy.sh

real	2m51.044s
user	0m7.220s
sys	0m29.520s

#  time ip link del dev dummy6666

real	0m0.441s
user	0m0.000s
sys	0m0.416s

so here the time to delete 1 interface has gone up by more than 10x.


# time ./tdel-dummy.sh
^C

real	14m10.000s
user	0m0.528s
sys	13m14.728s

I killed the delete; after 14 minutes only ~2k+ interfaces had been deleted:

# ip link show | grep dummy | wc -l
7822

In 4.2.0-rc3 it seems to take about 60 seconds to delete 150 interfaces 
which is inline with the 1 interface time of 0.4 seconds.

David
