From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 16:40:49 -0800
Message-ID: <20050124164049.3b939791.davem@davemloft.net>
References: <20050124005348.GL23931@postel.suug.ch>
	<E1Cst4o-0007bD-00@gondolin.me.apana.org.au>
	<20050123202715.281ac87c.davem@davemloft.net>
	<20050124121610.GP23931@postel.suug.ch>
	<41F50B6C.6010107@davidcoulson.net>
	<20050124151510.GV23931@postel.suug.ch>
	<20050124225423.GA15405@gondor.apana.org.au>
	<20050124234515.GA31837@postel.suug.ch>
	<20050125000759.GA15883@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, david@davidcoulson.net, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050125000759.GA15883@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005 11:07:59 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Jan 25, 2005 at 12:45:15AM +0100, Thomas Graf wrote:
> > 
> > I don't quite understand how this solves the problem. How could
> > ip_summed be non zero after ip_forward? The earliest possible call
> > to ip_fragment is in postrouting. Please correct me if I'm wrong.
> 
> ip_forward only sets ip_summed for the packet at the head.  It does
> not clear ip_summed for the fragments themselves.

Yes, there exists all of this weird logic in ip_fragment.c trying
to preserve the checksumming done on RX by the hardware.

When we reassemble an ipv4 set of frags, we do this in ip_frag_reasm()

	for (fp=head->next; fp; fp = fp->next) {
		head->data_len += fp->len;
		head->len += fp->len;
		if (head->ip_summed != fp->ip_summed)
			head->ip_summed = CHECKSUM_NONE;
		else if (head->ip_summed == CHECKSUM_HW)
			head->csum = csum_add(head->csum, fp->csum);
		head->truesize += fp->truesize;
		atomic_sub(fp->truesize, &ip_frag_mem);
	}

Acenic uses the CHECKSUM_HW case, where the chip does a pretty much
straight 16-bit two's complement checksum over the whole data area.

Thus the head SKB csum field plus it's CHECKSUM_HW setting means
that UDP et al. receive checksumming offloading works for this
fraglist as it gets processed by IPv4 input protocol paths.

However, if we forward this thing, only the head SKB in the
fraglist has it's skb->ip_summed value reset.  Then ip_output()
sees that the head skb has a length greater than the dst_pmtu()
and we get to ip_fragment() which is where Herbert's fix is
located.

Remember that skb->len is the sum of the lengths of all the SKBs
on the fraglist.  So it will likely exceed the PMTU of the outgoing
route.

ip_fragment() notices that we have a frag list, all the geometry
and ownership tests pass, and we simply reuse the fraglist SKBs
to produce the output fragments.  And as Herbert discovered, we need
to reset the frag->ip_summed values before we push the IP header onto
such frags.

We want to preserve local IP protocol input usage of CHECKSUM_HW
information on such frag list SKBs, so the location to fix this
is in fact ip_fragment() and not any of the code in ip_fragment.c

Good catch Herbert, I'll integrate this fix.  2.4.x needs it too
I'm pretty sure.
