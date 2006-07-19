From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL (RTAB
 BUG)
Date: Wed, 19 Jul 2006 22:26:40 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0607192114240.9570@tyr.diku.dk>
References: <1150278004.26181.35.camel@localhost.localdomain>
 <1150286766.5233.15.camel@jzny2>  <1150287983.3246.27.camel@ras.pc.brisbane.lube>
  <1150292693.5197.1.camel@jzny2>  <1150843471.17455.2.camel@ras.pc.brisbane.lube>
  <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>
 <1151000966.5392.34.camel@jzny2>  <1151066247.4217.254.camel@ras.pc.brisbane.lube>
  <1151158431.6716.95.camel@jzny2>  <1153188409.13145.5.camel@ras.pc.brisbane.lube>
  <44BD56A4.9090002@andyfurniss.entadsl.com> <1153270932.4242.60.camel@ras.pc.brisbane.lube>
 <44BE44E3.9080100@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Russell Stuart <russell-tcatm@stuart.id.au>, hadi@cyberus.ca,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:10629 "EHLO mgw1.diku.dk")
	by vger.kernel.org with ESMTP id S1030273AbWGSU0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 16:26:45 -0400
To: Andy Furniss <lists@andyfurniss.entadsl.com>
In-Reply-To: <44BE44E3.9080100@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Russell Stuart wrote:
> 
> - As it stands, it doesn't help the qdiscs that use 
> RTAB.  So unless he proposes to remove RTAB entirely the ATM patch as 
> it will still have to go in.

Here is a very important point here:

  The RTAB (rate-table) in the kernel is NOT aligned, this is the ONLY
  reason why we need to patch the kernel.

This why the kernel RTAB patch is still needed even with Patrick's 
excelent STAB patch.  (Maybe the RTAB system should be removed entirely?)

I have discussed this RTAB issue with Patrick (off list) and he denoted 
this RTAB issue as a regular BUG.


This is the problem with the RTAB:
----------------------------------
The "hash" function for packet size lookups is a simple binary shift
operation.

  rtab[pkt_len>>cell_log] = pkt_xmit_time;

With a cell_log of 3 (the default), this implies that:
     pkt_len  0 to  7 goes into entry 0,
and pkt_len  8 to 15 goes into entry 1,
and pkt_len 16 to 23 goes into entry 2,
and pkt_len 24 to 31 goes into entry 3,
and so on...

Current mapping:
entry[0](maps: 0- 7)=xmit_size:0
entry[1](maps: 8-15)=xmit_size:8
entry[2](maps:16-23)=xmit_size:16
entry[3](maps:24-31)=xmit_size:24
entry[4](maps:32-39)=xmit_size:32
entry[5](maps:40-47)=xmit_size:40
entry[6](maps:48-55)=xmit_size:48

When the table is constructed (in tc_core.c) the pkt_xmit_time is 
calculated from the lower boundary.  Meaning that transmitting a 7 byte 
packet "costs" 0 bytes to transmit.  The zero transmit cost is properly 
not a real-world problem as the IP header bounds the minimum packet size.

for (i=0; i<256; i++) {
   unsigned sz = (i<<cell_log);
   rtab[i] = tc_core_usec2tick(1000000*((double)sz/bps));
}

Basically transmitting a packet size and accounting for a smaller
packet size in the QoS system pose a problem.  We can loose queue
control by transmitting faster than the QoS was configured for.
(maybe a (DoS/queue) attack to loose QoS control with small special
sized packets?)


One possible FIX to the RTAB "BUG":
-----------------------------------
One solution would be to change the table to:
  entry[0](maps:0-7)=xmit_size:7
  entry[1](maps:8-15)=xmit_size:15
  entry[2](maps:16-23)=xmit_size:23
  entry[3](maps:24-31)=xmit_size:31
  entry[4](maps:32-39)=xmit_size:39
  entry[5](maps:40-47)=xmit_size:47
  entry[6](maps:48-55)=xmit_size:55

But most packets align to a even boundary, thus in the general case we
would over estimate. Instead it would be preferable to change the
table (mapping) to:

  rtab[(pkt_len-1)>>cell_log]

and adjusting the xmit_size accordingly.
Giving the table:

  entry[0](maps:1-8)=xmit_size:8
  entry[1](maps:9-16)=xmit_size:16
  entry[2](maps:15-24)=xmit_size:24
  entry[3](maps:24-32)=xmit_size:32
  entry[4](maps:33-40)=xmit_size:40
  entry[5](maps:41-48)=xmit_size:48
  entry[6](maps:47-56)=xmit_size:56

The xmit_size is done like this:

for (i=0; i<256; i++) {
   unsigned sz = ((i+1)<<cell_log);
   rtab[i] = tc_core_usec2tick(1000000*((double)sz/bps));
}

All table lookups should be changed to:
    rtab[(pkt_len-1)>>cell_log]


Another fix for the RTAB:
-------------------------
Remove the RTAB array lookups and calculate the pkt_xmit_time instead.

Guess that Alexey wrote these RTAB lookup in a time where array lookups 
was faster... now we have that memory lookups are the bottleneck.

What about removing the RTAB system entirely?


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
