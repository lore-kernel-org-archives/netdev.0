From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Thu, 02 Oct 2014 04:45:27 -0700
Message-ID: <1412250327.16704.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
		 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
		 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
		 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>
		 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>
		 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>
		 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
		 <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412224524.16704.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <542D06C1.6090802@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <or.gerlitz@gmail.com>, amira@mellanox.com,
	idos@mellanox.com, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	eyalpe@mellanox.com
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:47394 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbaJBLpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 07:45:39 -0400
Received: by mail-ig0-f174.google.com with SMTP id l13so1870397iga.1
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 04:45:38 -0700 (PDT)
In-Reply-To: <542D06C1.6090802@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-02 at 11:03 +0300, Amir Vadai wrote:

> Hi,
> 
> Will take it into the split patchset - we just hit this bug when tried
> to run benchmarks with blueflame disabled (easy to test by using ethtool
> priv flag blueflame).

Hmm, I do not know this ethtool command, please share ;)

> 
> I'm still working on it, but I can't reproduce the numbers that you
> show. On my development machine, I get ~5.5Mpps with burst=8 and ~2Mpps
> with burst=1.

You have to be careful with the 'clone X' : If you choose a too big
value, TX completion competes with the sender thread.

> 
> In addition, I see no improvements when adding the optimization to the
> xmit path.
> I use the net-next kernel + pktgen burst support patch, with and without
> this xmit path optimization patch.
> 
> Do you use other patches not upstream in your environment?

Nope, this is with David net-next tree.

> Can you share the .config/pktgen configuration?

Sure.

> 
> One other note: we're checking now that blueflame could be used with
> xmit_more. It might result with packets reordering/drops. Still under
> investigation.

I noticed no reorders. I tweaked the stack to force a gso segmentation
(in software) instead of using NIC TSO for small packets (2 or 3 MSS)

200 concurrent netperf -t TCP_RR -- -r 2000,2000    performance was
increased by ~100%.


#!/bin/bash
#
# on the destination, drop packets with
#   iptables -A PREROUTING -t raw -p udp --dport 9 -j DROP
#   Or run a recent enough kernel with global ICMP rate limiting to 1000 packets/sec
#   ( http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=4cdf507d54525842dfd9f6313fdafba039084046 )
#
#### Configure

# Yeah, if you use PKTSIZE <= 104, performance is lower because of inline (copy whole frame content into tx desc)
PKTSIZE=105

echo "pktrate: $PKTRATE"

COUNT=20000000000
RUN_SECS=60
SRC_DEV=eth0
SRC_IP_MIN=7.0.0.1
SRC_IP_MAX=7.255.255.255
SRC_MAC=00:1a:11:c3:0d:7f 
DST_IP=10.246.7.152 
DST_MAC=00:1a:11:c3:0d:45 
DST_UDP=9

## END OF CONFIGURATION OPTIONS

#### Helper

## Configuration procfs inodes

DEV_INODE=/proc/net/pktgen/$SRC_DEV
MAIN_INODE=/proc/net/pktgen/pgctrl
THREAD_INODE=/proc/net/pktgen/kpktgend_2

# write to a procfs file
function pgset_ex()
{
  local result

	echo $2
  echo $2 > $1

  result=`cat $1 | fgrep "Result: OK:"`
  if [ "$result" = "" ]; then
       cat $1 | fgrep Result:
  fi
}


#### Pre: configure

# attach device exclusively
pgset_ex $THREAD_INODE "rem_device_all"
pgset_ex $THREAD_INODE "add_device $SRC_DEV"

# configure basics
pgset_ex $DEV_INODE "clone_skb 8"
pgset_ex $DEV_INODE "src_min $SRC_IP_MIN"
pgset_ex $DEV_INODE "src_max $SRC_IP_MAX"
pgset_ex $DEV_INODE "dst $DST_IP"
pgset_ex $DEV_INODE "dst_mac $DST_MAC"
pgset_ex $DEV_INODE "udp_dst_min $DST_UDP"
pgset_ex $DEV_INODE "udp_dst_max $DST_UDP"
pgset_ex $DEV_INODE "queue_map_min 0"
pgset_ex $DEV_INODE "queue_map_max 0"
pgset_ex $DEV_INODE "burst 8"

pgset_ex $DEV_INODE "pkt_size $PKTSIZE"

 pgset_ex $DEV_INODE "delay 0"

# reset to continuous transmission
pgset_ex $DEV_INODE "count $COUNT"


#### Run: transmit

echo -e "UDP packet generator (based on linux pktgen)\n"
echo -e "  src:  mac=$SRC_MAC ip=$SRC_IP dev=$SRC_DEV"
echo -e "  dest: mac=$DST_MAC ip=$DST_IP port=$DST_UDP\n"

modprobe pktgen

#ethtool -C eth0 tx-usecs 16 tx-frames 16
#ethtool -C eth1 tx-usecs 16 tx-frames 16

# start thread(s)
# the write will block until Ctrl^C is pressed or a timeout kills the write
echo "Running for $RUN_SECS seconds"
#pgset_ex $MAIN_INODE "start"
echo "start" > $MAIN_INODE 2>/dev/null &


  sleep $RUN_SECS
 echo $DEV_INODE 
 cat $DEV_INODE

# stop
kill $!
pgset_ex $MAIN_INODE "stop"

echo "OK. All done"
