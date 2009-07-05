From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Sun, 5 Jul 2009 11:26:58 +0800
Message-ID: <20090705032658.GA7430@gondor.apana.org.au>
References: <20090703075530.GA25190@gondor.apana.org.au>
	<20090703.200254.172991821.davem@davemloft.net>
	<20090704030830.GA32442@gondor.apana.org.au>
	<20090703.201347.146036232.davem@davemloft.net>
	<20090704074245.GA1615@gondor.apana.org.au>
	<20090704090910.GA2185@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patrick.ohly@intel.com, libertas-dev@lists.infradead.org, dcbw@redhat.com,
        netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        rolandd@cisco.com, divy@chelsio.com, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20090704090910.GA2185@gondor.apana.org.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 04, 2009 at 05:09:10PM +0800, Herbert Xu wrote:
>
> One potential problem is if the socket is constantly running
> close to capacity, but that should only happen if the device
> TX queue is also close to capacity which means that the qdisc
> queue should be non-empty.

Here's a another crazy idea:

Let's use dummy TX descriptors to generate an interrupt, either
with or without transmitting an actual packet on the wire depending
on the NIC.

xmit(skb)

	if (TX queue contains no interrupting descriptor &&
	    qdisc is empty)
		mark TX descriptor as interrupting

clean()

	do work
	if (TX queue contains no interrupting descriptor &&
	    TX queue non-empty &&
	    qdisc is empty)
		send dummy TX descriptor

This is based on the assumption that in the time it takes for
the NIC to process one packet and interrupt us, we can generate
more packets.  Obviously if we can't then even if the NIC had
a queue-empty interrupt capability it wouldn't help.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
