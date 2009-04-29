From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 29 Apr 2009 09:42:29 -0400
Message-ID: <49F85945.7030900@myri.com>
References: <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au> <20090428061225.GA1591@gondor.apana.org.au> <49F71A00.5090701@myri.com> <20090428152047.GB7549@gondor.apana.org.au> <49F77134.9030907@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1830 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751341AbZD2NoN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 09:44:13 -0400
In-Reply-To: <49F77134.9030907@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Gallatin wrote:
> For variety, I grabbed a different "slow" receiver.  This is another
> 2 CPU machine, but a dual-socket single-core opteron (Tyan S2895)
> 
> processor       : 0
> vendor_id       : AuthenticAMD
> cpu family      : 15
> model           : 37
> model name      : AMD Opteron(tm) Processor 252
<...>
> The sender was an identical machine running an ancient RHEL4 kernel
> (2.6.9-42.ELsmp) and our downloadable (backported) driver.
> (http://www.myri.com/ftp/pub/Myri10GE/myri10ge-linux.1.4.4.tgz)
> I disabled LRO, on the sender.
> 
> Binding the IRQ to CPU0, and the netserver to CPU1 I see 8.1Gb/s with
> LRO and 8.0Gb/s with GRO.

With the recent patch to fix idle CPU time accounting from LKML applied,
it is again possible to trust netperf's service demand (based on %CPU).
So here is raw netperf output for LRO and GRO, bound as above.

TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
hail1-m.sw.myri.com (10.0.130.167) port 0 AF_INET : cpu bind
Recv   Send    Send                          Utilization       Service 
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local 
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

LRO:
  87380  65536  65536    60.00      8279.36   8.10     77.55    0.160 
1.535
GRO:
  87380  65536  65536    60.00      8053.19   7.86     85.47    0.160 
1.739

The difference is bigger if you disable TCP timestamps (and thus shrink
the packets headers down so they require fewer cachelines):
LRO:
  87380  65536  65536    60.02      7753.55   8.01     74.06    0.169 
1.565
GRO:
  87380  65536  65536    60.02      7535.12   7.27     84.57    0.158 
1.839


As you can see, even though the raw bandwidth is very close, the
service demand makes it clear that GRO is more expensive
than LRO.  I just wish I understood why.

Drew
