From: Patrick McHardy <kaber@trash.net>
Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
Date: Wed, 27 Apr 2005 02:56:48 +0200
Message-ID: <426EE350.1070902@trash.net>
References: <E1DQ1Ct-00055s-00@gondolin.me.apana.org.au>
	<426D0CB9.4060500@trash.net>
	<20050425213400.GB29288@gondor.apana.org.au>
	<426D8672.1030001@trash.net>
	<20050426003925.GA13650@gondor.apana.org.au>
	<426E3F67.8090006@trash.net>
	<20050426232857.GA18358@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org, Yair@arx.com,
	linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050426232857.GA18358@gondor.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Let's look at the bigger picture.  There are three users of
> ip_route_me_harder: nat, mangle and queue.  They're all done
> in LOCAL_OUT.
> 
> For nat/mangle, the source address cannot change so it's
> guaranteed to be a local IP address.  On the face of it,
> queue could be changing the source address.  However, the
> more I think about it the more I reckon that it should
> be disallowed.

The ipt_REJECT target can send TCP RSTs with foreign source which
go through LOCAL_OUT. Restricting it to this case and adding proper
checks to ipt_REJECT would relieve us of having to handle the last
case you pointed out (foreign saddr, broadcast/multicast daddr), but
it shouldn't be hard to also handle this case.

> If the user is changing the source address in LOCAL_OUT/queue
> then he's doing SNAT in LOCAL_OUT.  This violates some fundamental
> assumptions in netfilter.  The user also isn't going to have
> an easy time setting up the reverse DNAT since the corresponding
> location on the reverse side does not have a ip_route_me_harder
> call.

These assumptions are only for stateful NAT, the mangle table seems
to try to deal with stateless NAT by rerouting in LOCAL_OUT when
saddr/daddr changed. But it could also just be some left-over
cut-n-pasted from ip_nat_standalone.c, I don't think anyone is doing
stateless NAT with netfilter.

Regards
Patrick
