From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Sat, 05 Nov 2005 10:19:51 +0100
Message-ID: <436C7937.9070901@trash.net>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<20051027121545.GA5530@gondor.apana.org.au>
	<20051027.235732.01166239.yoshfuji@linux-ipv6.org>
	<20051105063030.GA32385@gondor.apana.org.au>
	<436C6580.6030007@trash.net>
	<20051105083955.GA30293@gondor.apana.org.au>
	<436C7430.5030707@trash.net>
	<20051105090904.GA30733@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051105090904.GA30733@gondor.apana.org.au>
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
> On Sat, Nov 05, 2005 at 09:58:24AM +0100, Patrick McHardy wrote:
> 
>>IMO the view for netfilter should be as if we called netif_rx,
>>so on the input path decapsulated packets from the innermost
>>transport mode SA should go through PRE_ROUTING->LOCAL_IN
>>or possibly FORWARD in case of NAT.
> 
> You mean we simply skip the pre-decapsulation LOCAL_IN step
> and the post-encapsulation LOCAL_OUT step? That sounds great
> to me.

No, that won't be possible if we have more than one SA and
would also make DNAT in LOCAL_OUT on the encapsulated packet
impossible.

What I propose is to keep tunnel mode handling as it is, so
for each tunnel mode SA we hit PRE_ROUTING and LOCAL_IN in
the normal packet path. If the final SA is a transport mode
SA, we don't call netif_rx as in my first patchset, but pass
the packet through a new PRE_ROUTING hook in xfrm{4,6}_input
and LOCAL_IN afterwards. The packet won't be processed a second
time by the stack, just the netfilter hooks will be called.
NAT be will be handled manually for IPv4 by doing a new route
lookup and calling dst_input if NAT took place.
