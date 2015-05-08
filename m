From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v5 2/2] pktgen: introduce xmit_mode
 '<start_xmit|netif_receive>'
Date: Fri, 8 May 2015 17:39:00 +0200
Message-ID: <20150508173900.3fcf78de@redhat.com>
References: <20150507143329.8534.49710.stgit@ivy>
	<20150507143500.8534.4435.stgit@ivy>
	<554B9293.2070702@plumgrid.com>
	<554B9CDE.1050703@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117AbbEHPjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2015 11:39:25 -0400
In-Reply-To: <554B9CDE.1050703@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 May 2015 19:11:58 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 05/07/2015 06:28 PM, Alexei Starovoitov wrote:  
> > On 5/7/15 7:35 AM, Jesper Dangaard Brouer wrote:  
> >> From: Alexei Starovoitov <ast@plumgrid.com>
> >>  
[...snip...]

> > btw, I've started to work on a patch on top of this one that allows
> > multiple pktgen threads to submit into the same netdev.
> > I've used it to stress test removal of spin_lock in ingress qdisc.
> > The idea is to add another 'name' parameter to command:
> > 'add_device name dev'
> > 'name' will be used to identify this pktgen thread in /proc
> > and 'dev' used as target net_device.
> > I think it will be useful for start_xmit testing as well.
> > I wonder why it wasn't done earlier? The queue configuration is
> > already supported.  
> 
> You mean other than below commit (iow independant of queue mapping)?
> 
> commit e6fce5b916cd7f7f79b2b3e53ba74bbfc1d7cf8b
> Author: Robert Olsson <robert.olsson@its.uu.se>
> Date:   Thu Aug 7 02:23:01 2008 -0700
> 
>      pktgen: multiqueue etc.  

For completeness and others reading this threads...

Pktgen multiqueue is already supported via mentioned commit, which adds
the device naming scheme: "add_device dev@number"

And yes, the documentation does not seem to mention this.  I've been
using it for years now... My scripts[1] take param "-t" for "threads".

I've added a more plain version of a script, based on yours, below my
signature.

The funny thing now is that scaling does not "happen" as we stall on:
   atomic_long_inc(&skb->dev->rx_dropped);

[1] https://github.com/netoptimizer/network-testing/tree/master/pktgen
- - 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

multiqueue pktgen script:


#!/bin/bash
function pgset() {
    local result

    echo $1 > $PGDEV

    result=`cat $PGDEV | fgrep "Result: OK:"`
    if [ "$result" = "" ]; then
        cat $PGDEV | fgrep Result:
    fi
}

[ -z "$2" ] && echo "Usage: $0 DEV num_threads" && exit 1
ETH=$1
NUM_THREADS=$2
let "NUM_THREADS -= 1"
echo "Number of threads to start: $2 (0 to $NUM_THREADS)"

# General cleanup everything since last run
PGDEV=/proc/net/pktgen/pgctrl
pgset "reset"

# Add devices to threads
#  Notice the naming scheme ETH@NUM
for NUM in `seq 0 $NUM_THREADS`; do
    PGDEV=/proc/net/pktgen/kpktgend_${NUM}
    pgset "rem_device_all"
    pgset "add_device ${ETH}@${NUM}"
done

# Config each device
for NUM in `seq 0 $NUM_THREADS`; do
    PGDEV=/proc/net/pktgen/${ETH}@${NUM}
    pgset "flag QUEUE_MAP_CPU"
    pgset "xmit_mode netif_receive"
    pgset "pkt_size 60"
    pgset "dst 198.18.0.42"
    pgset "dst_mac 90:e2:ba:ff:ff:ff"
    pgset "count 10000000"
    pgset "burst 32"
done

PGDEV=/proc/net/pktgen/pgctrl
echo "Running... ctrl^C to stop"
pgset "start"
echo "Done"

for NUM in `seq 0 $NUM_THREADS`; do
    echo "Device: ${ETH}@${NUM}"
    cat /proc/net/pktgen/${ETH}@${NUM} | grep -A2 "Result:"
done
