From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Wed, 21 Apr 2010 14:45:31 +0300
Message-ID: <20100421114531.GA31746@redhat.com>
References: <20100413145944.GA7716@redhat.com> <20100421113557.GA31606@redhat.com> <4BCEE599.1020501@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "stable@kernel.org" <stable@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qemu-devel <qemu-devel@nongnu.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753663Ab0DULu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 07:50:58 -0400
Content-Disposition: inline
In-Reply-To: <4BCEE599.1020501@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 01:46:33PM +0200, Jan Kiszka wrote:
> Michael S. Tsirkin wrote:
> > On Tue, Apr 13, 2010 at 05:59:44PM +0300, Michael S. Tsirkin wrote:
> >> The following situation was observed in the field:
> >> tap1 sends packets, tap2 does not consume them, as a result
> >> tap1 can not be closed. This happens because
> >> tun/tap devices can hang on to skbs undefinitely.
> >>
> >> As noted by Herbert, possible solutions include a timeout followed by a
> >> copy/change of ownership of the skb, or always copying/changing
> >> ownership if we're going into a hostile device.
> >>
> >> This patch implements the second approach.
> >>
> >> Note: one issue still remaining is that since skbs
> >> keep reference to tun socket and tun socket has a
> >> reference to tun device, we won't flush backlog,
> >> instead simply waiting for all skbs to get transmitted.
> >> At least this is not user-triggerable, and
> >> this was not reported in practice, my assumption is
> >> other devices besides tap complete an skb
> >> within finite time after it has been queued.
> >>
> >> A possible solution for the second issue
> >> would not to have socket reference the device,
> >> instead, implement dev->destructor for tun, and
> >> wait for all skbs to complete there, but this
> >> needs some thought, probably too risky for 2.6.34.
> >>
> >> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >> Tested-by: Yan Vugenfirer <yvugenfi@redhat.com>
> >>
> >> ---
> >>
> >> Please review the below, and consider for 2.6.34,
> >> and stable trees.
> >>
> >>  drivers/net/tun.c |    4 ++++
> >>  1 files changed, 4 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> >> index 96c39bd..4326520 100644
> >> --- a/drivers/net/tun.c
> >> +++ b/drivers/net/tun.c
> >> @@ -387,6 +387,10 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
> >>  		}
> >>  	}
> >>  
> >> +	/* Orphan the skb - required as we might hang on to it
> >> +	 * for indefinite time. */
> >> +	skb_orphan(skb);
> >> +
> >>  	/* Enqueue packet */
> >>  	skb_queue_tail(&tun->socket.sk->sk_receive_queue, skb);
> >>  	dev->trans_start = jiffies;
> >> -- 
> >> 1.7.0.2.280.gc6f05
> > 
> > This is commit 0110d6f22f392f976e84ab49da1b42f85b64a3c5 in net-2.6
> > Please cherry-pick this fix in stable kernels (2.6.32 and 2.6.33).
> > 
> > Thanks!
> > 
> 
> Before I forget again:
> 
> Tested-by: Jan Kiszka <jan.kiszka@siemens.com>
> (namely the field test of our customer)
> 
> Jan

Cool, thanks!

> -- 
> Siemens AG, Corporate Technology, CT T DE IT 1
> Corporate Competence Center Embedded Linux
