From: James Morris <jmorris@redhat.com>
Subject: Re: pskb change in dst->output
Date: Wed, 7 Jul 2004 23:34:59 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407072327390.29365-100000@thoron.boston.redhat.com>
References: <20040708011100.GA31600@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040708011100.GA31600@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Jul 2004, Herbert Xu wrote:

> I'm just a bit unsure whether the pskb change is needed in dst_output().

Ok, dst_output() iterates over the skb->dst stack:

	for (;;) {
                err = skb->dst->output(&skb);

                if (likely(err == 0))
                        return err;
                if (unlikely(err != NET_XMIT_BYPASS))
                        return err;
        }

We need to pass a pointer to skb to skb->dst->output() because the skb can
be changed by skb_checksum_help() in one of these output paths.  Further
iteration would otherwise pass an incorrect (freed) skb.

The change to dst->output() which implements a double skb pointer is then
propagated throughout the code, e.g.  ah_output() has to change because it
becomes an output function via xfrm->type->output().


- James
-- 
James Morris
<jmorris@redhat.com>
