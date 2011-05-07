From: Alex Bligh <alex@alex.org.uk>
Subject: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 12:08:01 +0100
Message-ID: <891B02256A0667292521A4BF@Ximines.local>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Bligh <alex@alex.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:49041 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754845Ab1EGLIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 07:08:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am trying to track down why interface creation slows down badly with
large numbers of interfaces (~1,000 interfaces) and why deletion is so
slow. Use case: restarting routers needs to be fast; some failover methods
require interface up/down; some routers need lots of interfaces.

I have written a small shell script to create and delete a number of
interfaces supplied on the command line (script appended below). It
is important to run this with udev, udev-bridge etc. disabled. In
my environment
(Ubuntu 2.6.32-28-generic, Lucid). I did this by
 * service upstart-udev-bridge stop
 * service udev stop
 * unshare -n bash
If you don't do this, you are simply timing your distro's interface
scripts.

Note the "-n" parameter creates the supplied number of veth pair
interfaces. As these are pairs, there are twice as many interfaces actually
created.

So, the results which are pretty repeatable are as follows:

                            100 pairs      500 pairs
Interface creation               14ms          110ms
Interface deletion              160ms          148ms

Now I don't think interface deletion has in fact got faster: simply
the overhead of loading the script is spread over more processes.
But there are two obvious conclusions:

1. Interface creation slows down hugely with more interfaces
2. Interface deletion is normally much slower than interface creation

strace -T -ttt on the "ip" command used to do this does not show the delay
where I thought it would be - cataloguing the existing interfaces. Instead,
it's the final send() to the netlink socket which does the relevant action
which appears to be slow, for both addition and detion. Adding the last
interface takes 200ms in that syscall, the first is quick (symptomatic of a
slowdown); for deletion the last send syscall is quick.

Poking about in net/core/dev.c, I see that interface names are hashed using
a hash with a maximum of 256 entries. However, these seem to be hash
buckets supporting multiple entries so I can't imagine a chain of 4 entries
is problematic.

I am having difficulty seeing what might be the issue in interface
creation. Any ideas?

In interface deletion, my attention is drawn to netdev_wait_allrefs,
which does this:
        refcnt = netdev_refcnt_read(dev);

        while (refcnt != 0) {
                ...
                msleep(250);

                refcnt = netdev_refcnt_read(dev);
		....
        }

I am guessing that this is going to do the msleep 50% of the time,
explaining 125ms of the observed time. How would people react to
exponential backoff instead (untested):

	int backoff = 10;
        refcnt = netdev_refcnt_read(dev);

        while (refcnt != 0) {
                ...
                msleep(backoff);
                if ((backoff *= 2) > 250)
                  backoff = 250;
		
                refcnt = netdev_refcnt_read(dev);
		....
        }


-- 
Alex Bligh



#!/bin/bash

# Usage:
#   ifaceseq [options]
#
# Options:
#   -n NUM : use NUM interfaces
#   -t TYPE : use TYPE of interfaces (supported: veth, vlan)

numifs=10
itype=veth

while getopts n:t: flag; do
    case ${flag} in
	n) numifs=${OPTARG} ;;
	t) itype=${OPTARG} ;;
    esac
done

shift $((OPTIND-1))

createifs ()
{
    echo `date` creating $numifs interfaces
    case ${itype} in
	vlan)
	    for i in `seq 1 $numifs` ; do
		ip link add link eth0 name vlan${i} type vlan id ${i}
	    done
	    ;;
	*)
	    for i in `seq 1 $numifs` ; do
		ip link add testa${i} type veth peer name testb${i}
	    done
    esac
    echo `date` done
}

deleteifs ()
{
    echo `date` deleting $numifs interfaces
    case ${itype} in
	vlan)
	    for i in `seq 1 $numifs` ; do
		ip link delete dev vlan${i}
	    done
	    ;;
	*)
	    for i in `seq 1 $numifs` ; do
		ip link delete testa${i}
	    done
    esac
    echo `date` done
}

time createifs;
time deleteifs;



