From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: ipsec impact on performance
Date: Tue, 1 Dec 2015 12:59:53 -0500
Message-ID: <20151201175953.GC21252@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40547 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbbLAR75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 12:59:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I instrumented iperf with and without ipsec, just using esp-null, 
and 1 thread, to keep things simple. I'm seeing some pretty dismal 
performance numbers with ipsec, and trying to think of ways to
improve this. Here are my findings, please share feedback.

I suspect that a big part of the problem is the implicit loss of GSO,
and this is made worse by some inefficiencies in the xfrm code:
for single stream iperf (to avoid effects of rx-hash), I see the
following on a 10G p2p ethernet link.
     8.5-9.5 Gbps clear traffic, TSO disabled, so GSO, GRO is in effect
     3-4 Gbps clear traffic, with both TSO/GSO disabled
     1.8-2 Gbps for esp-null.
So the above numbers suggest that losing TSO/GSO results in one
big drop in performance, and then there's another cliff for the 
clear -> esp-null transition. And those cliffs apply even if you are
merely doing TCP-MD5 or AO for basic protection of the TCP connection.

I tried moving things about a bit to defer the ipsec after GSO - I'll 
share my experimental patch as an RFC in a separate thread. (Disclaimer:
the patch is just an experiment at this point).

In that patch, I'm only focussing on esp-null and transp-mode ipsec
for now, just to get some basic performance numbers to see if this is 
at all interesting.  Essentially my hack mainly involves the following

- don't disable TSO in sk_setup_caps() if a dst->header_len is found
- in xfrm4_output, if GSO is applicable, bail out without esp header 
  addition - that will get done after skb_segment()
- at the end of tcp_gso_segment() (when tcp segment is available),
  set things up for xfrm_output_one and trigger the esp_output..
  I have to be very careful about setting up skb pointers here, since
  it looks like esp_output overloads the mac_header pointer e.g., for
  setting up the ip protocol field 

If I do all these things, the ipsec+iperf improves slightly- for
esp-null, I move from approx 1.8 Gbps  to about 3 Gbps, but clearly,
this is still quite far from the 8 - 9 Gbps that I can get with just
GSO+GRO for non-ipsec traffic.

There are some inefficiencies that I can see in the xfrm code,
that I am inheriting in my patch, e.g.,:
  memory management in the xfrm code has room for improvement. Every
  pass through xfrm_transport_output ends up doing a (avoidable?) memmove,
  and each pass through esp_output ends up doing a kmalloc/free of the
  "tmp" buffer. 
But these are all still relatively small things - tweaking them 
doesnt get me significantly past the 3 Gbps limit. Any suggestions
on how to make this budge (or design criticism of the patch) would
be welcome.

--Sowmini
