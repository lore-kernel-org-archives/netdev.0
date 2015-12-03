From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Thu, 3 Dec 2015 15:32:24 -0500
Message-ID: <20151203203224.GA25340@oracle.com>
References: <20151201175953.GC21252@oracle.com>
 <20151203.143328.1246663523839158336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151203.143328.1246663523839158336.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/03/15 14:33), David Miller wrote:
> 
> Doesn't skb_cow_data() contribute significantly to the ESP base cost,
> especially for TCP packets?

Indeed. For esp-null, it's about half of the total time spent
in esp_output (for one run that I just instrumented with perf 
tracepoints 2.5 ms compared to 5.8 ms)

It never goes into the slow path of skb_cow_data (the path
with comment about mincer fragments) because whether or not you
do this after GSO, TCP makes sure to fit within the MSS, so (unless you
have Jumbo enabled?) you'd send it something that does not have
a fraglist.

Was the cow_data call just intended to handle the fraglist case? 
Or is there something else more generic going on here (it's hard
to tell because esp_output doesnt have too many comments to explain
what it thinks its doing, as it juggles different len fields around)

> I mean, we're copying every TCP data frame.
> 
> If this is the case, even with GSO/whatever offloads, I expect that
> performance will be roughly halfed.

The other obvious "low-hanging fruit" is to address the TODO in the
comment above esp_alloc_tmp.

--Sowmini
