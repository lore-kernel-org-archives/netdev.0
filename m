From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Fri, 4 Feb 2005 21:38:13 -0800
Message-ID: <20050204213813.4bd642ad.davem@davemloft.net>
References: <20050131162201.GA1000@stilzchen.informatik.tu-chemnitz.de>
	<20050205052407.GA17266@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mirko.parthey@informatik.tu-chemnitz.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, shemminger@osdl.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050205052407.GA17266@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Feb 2005 16:24:07 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This is the key to the problem.
 ...
> All of these bugs stem from the idev reference held in rtable/rt6_info.
 ...
> Anyway, this particular problem is due to IPv6 adding local addresses
> with split devices.  That is, routes to local addresses are added with
> rt6i_dev set to &loopback_dev and rt6i_idev set to the idev of the
> device where the address is added.
 ...
> It also goes against the Linux philosophy where the addresses are owned
> by the host, not the interface.
> 
> Therefore I propose the simple solution of not doing the split device
> accounting in rt6_info.

I agree with your analysis, however... this change is not sufficient.
You have to then walk over all the uses of rt6i_dev and sanitize the
cases that still expect the split semantics.  For example, things like
this piece of coe in rt6_device_match():

			if (dev->flags & IFF_LOOPBACK) {
				if (sprt->rt6i_idev == NULL ||
				    sprt->rt6i_idev->dev->ifindex != oif) {
					if (strict && oif)
						continue;
					if (local && (!oif || 
						      local->rt6i_idev->dev->ifindex == oif))
						continue;
				}
				local = sprt;
			}

It is just the first such thing I found, scanning rt6i_idev uses
will easily find several others.
