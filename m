From: Andrew Dickinson <andrew@whydna.net>
Subject: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Wed, 29 Apr 2009 16:00:58 -0700
Message-ID: <606676310904291600u40e44187g4cfc104007b24fce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:59163 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbZD2XA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 19:00:59 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1138026rvb.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 16:00:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy list,

Background...
I'm trying to evaluate a new system for routing performance for some
custom packet modification that we do.  To start, I'm trying to get a
high-water mark of routing performance without our custom cruft in the
middle.  The hardware setup is a dual-package Nehalem box (X5550,
Hyper-Threading disabled) with a dual 10G intel card (pci-id:
8086:10fb).  Because this NIC is freakishly new, I'm running the
latest torvalds kernel in order to get the ixgbe driver to identify it
(<sigh>).  With HT off, I've got 8 cores in the system.  For the sake
of reducing the number of variables that I'm dealing with, I'm only
using one of the NICs to start with and simply routing packets back
out the single 10G NIC.

Interrupts...
I've disabled irqbalance and I'm explicitly pinning interrupts, one
per core, as follows:

-bash-3.2# for x in 57 65; do for i in `seq 0 7`; do echo $i | awk
'{printf("%X", (2^$1));}' > /proc/irq/$(($i + $x))/smp_affinity; done;
done

-bash-3.2# for i in `seq 57 72`; do cat /proc/irq/$i/smp_affinity; done
0001
0002
0004
0008
0010
0020
0040
0080
0001
0002
0004
0008
0010
0020
0040
0080

-bash-3.2# cat /proc/interrupts  | grep eth2
  57:      77941          0          0          0          0
0          0          0   PCI-MSI-edge      eth2-rx-0
  58:         92      59682          0          0          0
0          0          0   PCI-MSI-edge      eth2-rx-1
  59:         92          0      21716          0          0
0          0          0   PCI-MSI-edge      eth2-rx-2
  60:         92          0          0      14356          0
0          0          0   PCI-MSI-edge      eth2-rx-3
  61:         92          0          0          0      91483
0          0          0   PCI-MSI-edge      eth2-rx-4
  62:         92          0          0          0          0
19495          0          0   PCI-MSI-edge      eth2-rx-5
  63:         92          0          0          0          0
0         24          0   PCI-MSI-edge      eth2-rx-6
  64:         92          0          0          0          0
0          0      19605   PCI-MSI-edge      eth2-rx-7
  65:      94709          0          0          0          0
0          0          0   PCI-MSI-edge      eth2-tx-0
  66:         92         24          0          0          0
0          0          0   PCI-MSI-edge      eth2-tx-1
  67:         98          0         24          0          0
0          0          0   PCI-MSI-edge      eth2-tx-2
  68:         92          0          0     100208          0
0          0          0   PCI-MSI-edge      eth2-tx-3
  69:         92          0          0          0         24
0          0          0   PCI-MSI-edge      eth2-tx-4
  70:         92          0          0          0          0
24          0          0   PCI-MSI-edge      eth2-tx-5
  71:         92          0          0          0          0
0     144566          0   PCI-MSI-edge      eth2-tx-6
  72:         92          0          0          0          0
0          0         24   PCI-MSI-edge      eth2-tx-7
  73:          2          0          0          0          0
0          0          0   PCI-MSI-edge      eth2:lsc

The output of /proc/interrupts is hinting at the problem that I'm
having...  The TX queues which are being chosen are only 0, 3, and 6.
The flow of traffic that I'm generating is random source/dest pairs,
each within a /24, so I don't think that I'm sending data that should
be breaking the skb_tx_hash() routine.

Further, when I run top, I see that almost all of the interrupt
processing is happening on a single cpu.
Cpu0  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu1  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu2  :  0.0%us,  0.0%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.3%si,  0.0%st
Cpu3  :  0.0%us,  0.0%sy,  0.0%ni, 99.0%id,  0.0%wa,  0.3%hi,  0.7%si,  0.0%st
Cpu4  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu5  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,  0.0%id,  0.0%wa, 19.3%hi, 80.7%si,  0.0%st
Cpu7  :  0.0%us,  0.0%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.3%si,  0.0%st

This appears to be due to 'tx'-based activity... if I change my route
table to blackhole the traffic, the CPUs are nearly idle.

My next thought was to try multiqueue...
-bash-3.2# ./tc/tc qdisc add dev eth2 root handle 1: multiq
-bash-3.2# ./tc/tc qdisc show dev eth2
qdisc multiq 1: root refcnt 128 bands 8/128

With multiq scheduling, the CPU load evens out a bunch, but I still
have a soft-interrupt hot-spot (see CPU3 here.  Also note that only
CPU's 0, 3, and 6 are handling hardware interrupts.):
Cpu0  :  0.0%us,  0.0%sy,  0.0%ni, 69.9%id,  0.0%wa,  0.3%hi, 29.8%si,  0.0%st
Cpu1  :  0.0%us,  0.0%sy,  0.0%ni, 64.8%id,  0.0%wa,  0.0%hi, 35.2%si,  0.0%st
Cpu2  :  0.0%us,  0.0%sy,  0.0%ni, 76.5%id,  0.0%wa,  0.0%hi, 23.5%si,  0.0%st
Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,  4.8%id,  0.0%wa,  2.6%hi, 92.6%si,  0.0%st
Cpu4  :  0.3%us,  0.3%sy,  0.0%ni, 76.2%id,  0.3%wa,  0.0%hi, 22.8%si,  0.0%st
Cpu5  :  0.0%us,  0.0%sy,  0.0%ni, 49.4%id,  0.0%wa,  0.0%hi, 50.6%si,  0.0%st
Cpu6  :  0.0%us,  0.0%sy,  0.0%ni, 56.8%id,  0.0%wa,  1.0%hi, 42.3%si,  0.0%st
Cpu7  :  0.0%us,  0.0%sy,  0.0%ni, 51.6%id,  0.0%wa,  0.0%hi, 48.4%si,  0.0%st

However, what I see with multiqueue enabled is that I'm dropping 80%
of my traffic (which appears to be due to a large number of
'rx_missed_errors').

Any thoughts on what I'm doing wrong or where I should continue to look?

-Andrew
