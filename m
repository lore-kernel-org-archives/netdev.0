From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 07:53:05 +0100
Message-ID: <20151202065305.GB14008@secunet.com>
References: <20151201175953.GC21252@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-crypto@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46221 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbbLBHck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 02:32:40 -0500
Content-Disposition: inline
In-Reply-To: <20151201175953.GC21252@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2015 at 12:59:53PM -0500, Sowmini Varadhan wrote:
> 
> I instrumented iperf with and without ipsec, just using esp-null, 
> and 1 thread, to keep things simple. I'm seeing some pretty dismal 
> performance numbers with ipsec, and trying to think of ways to
> improve this. Here are my findings, please share feedback.
> 
> I suspect that a big part of the problem is the implicit loss of GSO,
> and this is made worse by some inefficiencies in the xfrm code:
> for single stream iperf (to avoid effects of rx-hash), I see the
> following on a 10G p2p ethernet link.
>      8.5-9.5 Gbps clear traffic, TSO disabled, so GSO, GRO is in effect
>      3-4 Gbps clear traffic, with both TSO/GSO disabled
>      1.8-2 Gbps for esp-null.
> So the above numbers suggest that losing TSO/GSO results in one
> big drop in performance, and then there's another cliff for the 
> clear -> esp-null transition. And those cliffs apply even if you are
> merely doing TCP-MD5 or AO for basic protection of the TCP connection.
> 
> I tried moving things about a bit to defer the ipsec after GSO - I'll 
> share my experimental patch as an RFC in a separate thread. (Disclaimer:
> the patch is just an experiment at this point).
> 
> In that patch, I'm only focussing on esp-null and transp-mode ipsec
> for now, just to get some basic performance numbers to see if this is 
> at all interesting.  Essentially my hack mainly involves the following
> 
> - don't disable TSO in sk_setup_caps() if a dst->header_len is found
> - in xfrm4_output, if GSO is applicable, bail out without esp header 
>   addition - that will get done after skb_segment()
> - at the end of tcp_gso_segment() (when tcp segment is available),
>   set things up for xfrm_output_one and trigger the esp_output..
>   I have to be very careful about setting up skb pointers here, since
>   it looks like esp_output overloads the mac_header pointer e.g., for
>   setting up the ip protocol field 

I'm currently working on a GRO/GSO codepath for IPsec too. The GRO part
works already. I decapsulate/decrypt the packets on layer2 with a esp GRO
callback function and reinject them into napi_gro_receive(). So in case
the decapsulated packet is TCP, GRO can aggregate big packets.

My approach to GSO is a bit different to yours. I focused on tunnel mode,
but transport mode should work too. I encapsulate the big GSO packets
but don't do the encryption. Then I've added a esp_gso_segment() function,
so the (still not encrypted ESP packets) get segmented with GSO. Finally I
do encryption for all segments. This works well as long as I do sync crypto.
The hard part is when crypto returns async. This is what I'm working on now.
I hope to get this ready during the next weeks that I can post a RFC version
and some numbers.

Also I tried to consider the IPsec GRO/GSO codepath as a software fallback.
So I added hooks for the encapsulation, encryption etc. If a NIC can do
IPsec, it can use this hooks to prepare the packets the way it needs it.
There are NICs that can do IPsec, it's just that our stack does not support
it.

Another thing, I thought about setting up an IPsec BoF/workshop at
netdev1.1. My main topic is GRO/GSO for IPsec. I'll send out a mail
to the list later this week to see if there is enough interest and
maybe some additional topics.
