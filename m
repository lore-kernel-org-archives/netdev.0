From: Patrick McHardy <kaber@trash.net>
Subject: Re: [22/*] [NETFILTER] Use correct IPsec MTU in TCPMSS
Date: Sun, 20 Mar 2005 16:46:34 +0100
Message-ID: <423D9ADA.6050407@trash.net>
References: <20050214221607.GC18465@gondor.apana.org.au>	<20050306213214.7d8a143d.davem@davemloft.net>	<20050307103536.GB7137@gondor.apana.org.au>	<20050308102741.GA23468@gondor.apana.org.au>	<20050314102614.GA9610@gondor.apana.org.au>	<20050314105313.GA21001@gondor.apana.org.au>	<20050314111002.GA29156@gondor.apana.org.au>	<20050315091904.GA6256@gondor.apana.org.au>	<20050315095837.GA7130@gondor.apana.org.au>	<20050318090310.GA28443@gondor.apana.org.au>	<20050318091129.GA28658@gondor.apana.org.au> <20050318104013.57d65e99.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050318104013.57d65e99.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 18 Mar 2005 20:11:29 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>>BTW Patrick, how is the IPsec netfilter stuff going?
> 
> That boy is seriously backlogged, so I'm not sure how much time
> he's gotten to work on that yet.

Indeed, but in case of the netfilter patches that's not the problem.
They are basically working fine, but I have doubts about submitting
them. First, and most importantly, the input patch is incredible ugly.
To recap, we want to pass the encapsulated packets to the netfilter
hooks, then again the decapsulated packets after all decapsulation has
been done. The current input patch makes packets that have been
handled by IPsec skip the netfilter hooks until we know no further
IPsec processing will be done (route is non-local or protocol handler
is not marked as xfrm_prot). The packet is then marked as completely
decapsulated and passed through the stack again and the plain packets
go through netfilter again. There are a couple of problems with this
approach:

- decapsulated tunnel-mode packets go through the stack twice
- netfilter only sees them once, everything else multiple times
   (statistics, packet sockets, ...)
- racy, xfrm protocol could be registered after we determined
   decapsulation is done.
- inefficient

The second reason is that I'm not sure at all wether this is the way
to go. With KLIPS-like IPsec-devices you can sniff the plain packets
before they are handled by IPsec and you can perform traffic shaping
on them. These two points are completely unhandled, and people seem
to want them.

So what's holding back these patches is getting some consensus on what
exactly we want to do and finding a better method for determining when
decapsulation is done. One possibility would be stealing packets
in xfrm_policy_check(), but I haven't thought much about this yet.

Regards
Patrick
