From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 0/6] NET_SCHED: Rate table fixes
Date: Wed, 12 Sep 2007 12:13:40 +0200
Message-ID: <1189592020.26927.20.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:39707 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933056AbXILKOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:14:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This set of patches, aim at fixing an issue with the rate table used
by the rate based schedulers.

Currently we use the lower-boundry value, which result in
under-estimating the actual bandwidth usage.  The patches will change
this to use the upper-boundry L2T (length to time) value.

The patches include both changes to the kernel and iproute2 userspace
utility. The kernel changes, only adds flexibility to allow userspace
to do the rate table alignment. The patches has been splitup in
cleanup and actual functional change patches.

The patches also moves the overhead calculation (currently only used
by HTB) into the kernel, which makes it more precise (as it won't miss-align
the contents of the rate table).

This should raise some questions,
 1. How does the current/old rate table mapping look like.
 2. How does new aligned rate table mapping look like.
 3. What happens when only the TC util is changed and used on a old kernel.

Lets look at how the layout of the rate tables looks like:

Illustrating the rate table array:
  Legend description
    rtab[x]   : Array index x of rtab[x]
    xmit_sz   : Transmit size contained in rtab[x] (normally transmit time)
    maps[a-b] : Packet sizes from a to b, will map into rtab[x]

(1) Current/old rate table mapping (cell_log:3):
  rtab[0]:=xmit_sz:0  maps[0-7]
  rtab[1]:=xmit_sz:8  maps[8-15]
  rtab[2]:=xmit_sz:16 maps[16-23]
  rtab[3]:=xmit_sz:24 maps[24-31]
  rtab[4]:=xmit_sz:32 maps[32-39]
  rtab[5]:=xmit_sz:40 maps[40-47]
  rtab[6]:=xmit_sz:48 maps[48-55]

The above illustrates that we are using the lower-boundry transmit
size (xmit_sz).

(2) New iproute rate table mapping, with kernel cell_align support.
  rtab[0]:=xmit_sz:8  maps[0-8]
  rtab[1]:=xmit_sz:16 maps[9-16]
  rtab[2]:=xmit_sz:24 maps[17-24]
  rtab[3]:=xmit_sz:32 maps[25-32]
  rtab[4]:=xmit_sz:40 maps[33-40]
  rtab[5]:=xmit_sz:48 maps[41-48]
  rtab[6]:=xmit_sz:56 maps[49-56]

The above illustrates that we are using the upper-boundry transmit
size (xmit_sz), when mapping packets sizes.

The interesting question is what about compatibility.  If a old
iproute utility is used on a new kernel, we simply get the old rate
table (lower-bound) alignment. The interesting case is what happens
with a new iproute util on a old kernel. The table below, shows that
what happens is that we use the upper-bound+1byte.  I believe that
this is a good and acceptable solution.

(3) New TC util on a kernel WITHOUT support for cell_align
  rtab[0]:=xmit_sz:8 maps[0-7]
  rtab[1]:=xmit_sz:16 maps[8-15]
  rtab[2]:=xmit_sz:24 maps[16-23]
  rtab[3]:=xmit_sz:32 maps[24-31]
  rtab[4]:=xmit_sz:40 maps[32-39]
  rtab[5]:=xmit_sz:48 maps[40-47]
  rtab[6]:=xmit_sz:56 maps[48-55]

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
