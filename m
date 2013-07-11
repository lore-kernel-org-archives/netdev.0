From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] gso: Update tunnel segmentation to support Tx
 checksum offload
Date: Wed, 10 Jul 2013 18:43:57 -0700
Message-ID: <1373507037.4600.34.camel@edumazet-glaptop>
References: <20130711000015.13134.17801.stgit@ahduyck-hc1.jf.intel.com>
	 <1373503334.4600.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	pshelar@nicira.com, joseph.gasparakis@intel.com, jesse@nicira.com,
	Eilon Greenstein <eilong@broadcom.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>,
	Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:45263 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135Ab3GKBoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 21:44:04 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so6983739pde.9
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 18:44:03 -0700 (PDT)
In-Reply-To: <1373503334.4600.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-10 at 17:42 -0700, Eric Dumazet wrote:
> On Wed, 2013-07-10 at 17:05 -0700, Alexander Duyck wrote:
> > This change makes it so that the GRE and VXLAN tunnels can make use of Tx
> > checksum offload support provided by some drivers via the hw_enc_features.
> > Without this fix enabling GSO means sacrificing Tx checksum offload and
> > this actually leads to a performance regression as shown below:
> > 
> >             Utilization
> >             Send
> > Throughput  local         GSO
> > 10^6bits/s  % S           state
> >   6276.51   8.39          enabled
> >   7123.52   8.42          disabled
> 
> While testing your patch, I discovered TSO support is completely broken
> on GRE, using bnx2x testbed.
> 
> Oh well.
> 
> It seems Nicira guys do not test a lot their patches.
> 

Receiver receives corrupted frames : IpExtInCsumErrors is increasing

The outer checksum is not correct.

Maybe Dmitry has an idea of what is going on ?

18:36:06.085164 IP (tos 0x0, ttl  64, id 48051, offset 0, flags [DF],
proto: GRE (47), length: 1500, bad cksum 3fad (->40ad)!) 10.246.17.83 >
10.246.17.84: GREv0, Flags [none], length 1480
	IP (tos 0x0, ttl  64, id 48051, offset 0, flags [DF], proto: TCP (6),
length: 1476) 7.7.8.83.52523 > 7.7.8.84.48165: ., cksum 0x88b9
(correct), 1:1425(1424) ack 1 win 449 <nop,nop,timestamp 1901210
83620016>

18:36:06.085165 IP (tos 0x0, ttl  64, id 48051, offset 0, flags [DF],
proto: GRE (47), length: 1500, bad cksum 3fad (->40ad)!) 10.246.17.83 >
10.246.17.84: GREv0, Flags [none], length 1480
	IP (tos 0x0, ttl  64, id 48052, offset 0, flags [DF], proto: TCP (6),
length: 1476) 7.7.8.83.52523 > 7.7.8.84.48165: ., cksum 0x8329
(correct), 1425:2849(1424) ack 1 win 449 <nop,nop,timestamp 1901210
83620016>

18:36:06.085166 IP (tos 0x0, ttl  64, id 48051, offset 0, flags [DF],
proto: GRE (47), length: 1500, bad cksum 3fad (->40ad)!) 10.246.17.83 >
10.246.17.84: GREv0, Flags [none], length 1480
	IP (tos 0x0, ttl  64, id 48053, offset 0, flags [DF], proto: TCP (6),
length: 1476) 7.7.8.83.52523 > 7.7.8.84.48165: ., cksum 0x7d99
(correct), 2849:4273(1424) ack 1 win 449 <nop,nop,timestamp 1901210
83620016>
