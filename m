From: jamal <hadi@cyberus.ca>
Subject: [WIP][PATCHES] Network xmit batching
Date: Wed, 06 Jun 2007 09:49:21 -0400
Message-ID: <1181137761.4068.22.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-93e17dzQQlum17bnp9gL"
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Gagan Arneja <gaagaan@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Rick Jones <rick.jones2@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:41129 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934599AbXFFNtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 09:49:24 -0400
Received: by wx-out-0506.google.com with SMTP id t15so129976wxc
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2007 06:49:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-93e17dzQQlum17bnp9gL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Folks,

While Krishna and I have been attempting this on the side, progress has
been rather slow - so this is to solicit for more participation so we
can get this over with faster. Success (myself being conservative when
it comes to performance) requires testing on a wide variety of hardware.

The results look promising - certainly from a pktgen perspective where
performance has been known in some cases to go up over 50%.
Tests by Sridhar on a low number of TCP flows also indicate improved
performance as well as lowered CPU use.
 
I have setup the current state of my patches against Linus tree at:
git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git

This is also clean against 2.6.22-rc4. So if you want just a diff that
will work against 2.6.22-rc4 - i can send it to you.
I also have a tree against Daves net-2.6 at 
git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-net26.git
but iam abandoning that effort until we get this stable due to the
occasional bug that cropped up(like e1000).

I am attaching a pktgen script. There is one experimental parameter
called "batch_low" - for starters just leave it at 0 in order to reduce
experimental variance. If you have solid results you can muck around
with it.
KK has a netperf script he has been using - if you know netperf your
help will really be appreciated in testing it on your hardware.
KK, can you please post your script?
Testing with forwarding and bridging will also be appreaciated.
Above that, suggestions to changes as long as they are based on
verifiable results or glaringly obvious changes are welcome. My
preference at the moment is to flesh out the patch as is and then
improve on it later if it shows it has some value on a wide variety of
apps. As the subject is indicating this is a WIP and as all eulas
suggest "subject to change without notice". 
If you help out, when you post your results, can you please say what
hardware and setup was?

The only real driver that has been changed is e1000 for now. KK is
working on something infiniband related and i plan (if noone beats me)
to get tg3 working. It would be nice if someone converted some 10G
ethernet driver.

cheers,
jamal

--=-93e17dzQQlum17bnp9gL
Content-Disposition: attachment; filename=pktgen.batch-1-1
Content-Type: application/x-shellscript; name=pktgen.batch-1-1
Content-Transfer-Encoding: 7bit

#! /bin/sh

function pgset() {
    local result

    echo $1 > $PGDEV

    result=`cat $PGDEV | fgrep "Result: OK:"`
    if [ "$result" = "" ]; then
         cat $PGDEV | fgrep Result:
    fi
}

function pg() {
    echo inject > $PGDEV
    cat $PGDEV
}

# Config Start Here -----------------------------------------------------------


# thread config
# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.

PGDEV=/proc/net/pktgen/kpktgend_0
  echo "Removing all devices"
 pgset "rem_device_all" 
  echo "Adding eth1"
 pgset "add_device eth1" 
  echo "Setting max_before_softirq 10000"
 pgset "max_before_softirq 10000"


# device config
# delay 0 means maximum speed.

CLONE_SKB="clone_skb 1000000"
CLONE_SKB="clone_skb 1"
# NIC adds 4 bytes CRC
PKT_SIZE="pkt_size 60"

# COUNT 0 means forever
#COUNT="count 0"
COUNT="count 10000000"
COUNT="count 1000"
COUNT="count 10000000"
BATCH="batch_low 400"
BATCH="batch_low 0"
DELAY="delay 200"
DELAY="delay 0"

PGDEV=/proc/net/pktgen/eth1
  echo "Configuring $PGDEV"
 pgset "$COUNT"
 pgset "$CLONE_SKB"
 pgset "$PKT_SIZE"
 pgset "$DELAY"
 pgset "$BATCH"
 pgset "dst 192.168.100.2" 
 pgset "dst_mac  00:C0:95:E6:2D:67"


# Time to run
PGDEV=/proc/net/pktgen/pgctrl

 echo "Running... ctrl^C to stop"
 pgset "start" 
 echo "Done"
 echo 
 echo 
 echo 

# Result can be vieved in /proc/net/pktgen/eth1
cat /proc/net/pktgen/eth1


--=-93e17dzQQlum17bnp9gL--

