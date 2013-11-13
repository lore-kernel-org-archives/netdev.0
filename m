From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Handle new frag_list of frags GRO packets
Date: Tue, 12 Nov 2013 18:45:04 -0800
Message-ID: <1384310704.28458.79.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107004339.GA28156@gondor.apana.org.au>
	 <20131107062234.GA31156@gondor.apana.org.au>
	 <20131107070335.GA31638@gondor.apana.org.au>
	 <20131107070647.GB31638@gondor.apana.org.au>
	 <20131111185207.GA12277@gondor.apana.org.au>
	 <1384305223.28458.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113012920.GA27897@gondor.apana.org.au>
	 <1384309034.28458.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113022243.GA28204@gondor.apana.org.au>
	 <20131113022525.GA28236@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:56674 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492Ab3KMCpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 21:45:08 -0500
Received: by mail-pa0-f52.google.com with SMTP id kl14so1935984pab.39
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 18:45:08 -0800 (PST)
In-Reply-To: <20131113022525.GA28236@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 10:25 +0800, Herbert Xu wrote:

> So a better test for the time being would be to test with TSO
> disabled in both cases.
> 

GRO on, TSO off, little difference between two cases :

(Note some small things run in background, so these numbers are not
ultra precise)

1) Full size GRO packets (frag_list enabled)

lpaa6:~# mpstat -P 3 1 10
06:39:32 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle    intr/s
06:39:33 PM    3    3.23    0.00   43.55    0.00   12.90    0.00    0.00    0.00   40.32 123209.68
06:39:34 PM    3    3.39    0.00   28.81    0.00   16.95    0.00    0.00    0.00   50.85  84559.32
06:39:35 PM    3    1.79    0.00    3.57    0.00   10.71    0.00    0.00    0.00   83.93 108898.21
06:39:36 PM    3    3.39    0.00   30.51    0.00   16.95    0.00    0.00    0.00   49.15  84661.02
06:39:37 PM    3    0.00    0.00    7.46    0.00   10.45    0.00    0.00    0.00   82.09  72135.82
06:39:38 PM    3    1.56    0.00   26.56    0.00    9.38    0.00    0.00    0.00   62.50  73562.50
06:39:39 PM    3    0.00    0.00    8.47    0.00   15.25    0.00    0.00    0.00   76.27  75715.25
06:39:40 PM    3    8.33    0.00    8.33    0.00    2.08    0.00    0.00    0.00   81.25 129195.83
06:39:41 PM    3    1.56    0.00   23.44    0.00   23.44    0.00    0.00    0.00   51.56  73389.06
06:39:42 PM    3    0.00    0.00    1.96    0.00   17.65    0.00    0.00    0.00   80.39 102474.51
Average:       3    2.21    0.00   18.85    0.00   13.75    0.00    0.00    0.00   65.20  91433.11

2) No frag_list skbs

lpaa6:~# mpstat -P 3 1 10
06:39:56 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle    intr/s
06:39:57 PM    3    0.00    0.00    2.63    0.00   26.32    0.00    0.00    0.00   71.05 173105.26
06:39:58 PM    3    3.85    0.00   13.46    0.00   15.38    0.00    0.00    0.00   67.31 121346.15
06:39:59 PM    3    9.09    0.00   18.18    0.00   14.55    0.00    0.00    0.00   58.18  84216.36
06:40:00 PM    3    0.00    0.00   10.53    0.00   10.53    2.63    0.00    0.00   76.32 170863.16
06:40:01 PM    3    3.45    0.00   20.69    0.00   18.97    0.00    0.00    0.00   56.90  83941.38
06:40:02 PM    3    0.00    0.00    5.88    0.00   19.61    0.00    0.00    0.00   74.51 125625.49
06:40:03 PM    3    1.85    0.00   24.07    0.00   16.67    0.00    0.00    0.00   57.41  88242.59
06:40:04 PM    3    3.33    0.00   13.33    0.00   13.33    0.00    0.00    0.00   70.00  74181.67
06:40:05 PM    3    0.00    0.00   10.00    0.00   16.00    2.00    0.00    0.00   72.00 150906.00
06:40:06 PM    3    3.28    0.00   44.26    0.00   14.75    0.00    0.00    0.00   37.70  79821.31
Average:       3    2.71    0.00   17.41    0.00   16.44    0.39    0.00    0.00   63.06 110094.00


> In the mean time I'm cooking up a patch to generate TSO packets.

That would be very nice !

Thanks
