From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 02:45:38 +0100
Message-ID: <20050125014538.GB31837@postel.suug.ch>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124121610.GP23931@postel.suug.ch> <41F50B6C.6010107@davidcoulson.net> <20050124151510.GV23931@postel.suug.ch> <20050124225423.GA15405@gondor.apana.org.au> <20050124234515.GA31837@postel.suug.ch> <20050125000759.GA15883@gondor.apana.org.au> <20050124164049.3b939791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, david@davidcoulson.net,
        kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050124164049.3b939791.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050124164049.3b939791.davem@davemloft.net> 2005-01-24 16:40
> On Tue, 25 Jan 2005 11:07:59 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > On Tue, Jan 25, 2005 at 12:45:15AM +0100, Thomas Graf wrote:
> > > 
> > > I don't quite understand how this solves the problem. How could
> > > ip_summed be non zero after ip_forward? The earliest possible call
> > > to ip_fragment is in postrouting. Please correct me if I'm wrong.
> > 
> > ip_forward only sets ip_summed for the packet at the head.  It does
> > not clear ip_summed for the fragments themselves.

You are indeed right, I actually thought it would be like this first but
tricked myself into not believeing in this anymore because it would have
meant that every fragmented sequence could crash a kernel with one of
the drivers setting ip_summed to HW and the card not being able to do
the checksummin itself, so I thought I'd have missed some magic.

As it seems, it is really the case, a first peeks shows that the
following drivers set ip_summed to HW under some circumstances:
 acenic, he, hamachi, starfire, sungem, happy meal

> However, if we forward this thing, only the head SKB in the
> fraglist has it's skb->ip_summed value reset.  Then ip_output()
> sees that the head skb has a length greater than the dst_pmtu()
> and we get to ip_fragment() which is where Herbert's fix is
> located.

> We want to preserve local IP protocol input usage of CHECKSUM_HW
> information on such frag list SKBs, so the location to fix this
> is in fact ip_fragment() and not any of the code in ip_fragment.c

Agreed.

I've been talking to David on IRC and we have been able to reproduce the
bug by sending a sequence of fragmented ip packets to a host behind
the router. The only objection I had with this patch was, that I found
it too unlikely that his box wouldn't receive fragmented packets more
often, but as it seems it is really is this simple.

Still, one problem remains, even if ip_summed was incorrect,
skb_checksum_help should never be called in dev_queue_xmit for the
acenic driver since it sets NETIF_F_IP_CSUM. For some reason, features
is set to 0 while checking for it.
