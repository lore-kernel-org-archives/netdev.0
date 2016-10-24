From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 2/2] firewire: net: set initial MTU = 1500
 unconditionally, fix IPv6 on some CardBus cards
Date: Sun, 23 Oct 2016 21:50:13 -0400
Message-ID: <20161024015013.GB42084@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
 <20161020175524.6184-8-jarod@redhat.com>
 <20161022211606.3b5d137d@kant>
 <20161022212759.228c7642@kant>
 <20161023011824.GE32569@redhat.com>
 <20161023162903.4166a35d@kant>
 <20161023163056.6bc38610@kant>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux1394-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161023163056.6bc38610@kant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 23, 2016 at 04:30:56PM +0200, Stefan Richter wrote:
> firewire-net, like the older eth1394 driver, reduced the initial MTU to
> less than 1500 octets if the local link layer controller's asynchronous
> packet reception limit was lower.
> 
> This is bogus, since this reception limit does not have anything to do
> with the transmission limit.  Neither did this reduction affect the TX
> path positively, nor could it prevent link fragmentation at the RX path.
> 
> Many FireWire CardBus cards have a max_rec of 9, causing an initial MTU
> of 1024 - 16 = 1008.  RFC 2734 and RFC 3146 allow a minimum max_rec = 8,
> which would result in an initial MTU of 512 - 16 = 496.  On such cards,
> IPv6 could only be employed if the MTU was manually increased to 1280 or
> more, i.e. IPv6 would not work without intervention from userland.
> 
> We now always initialize the MTU to 1500, which is the default according
> to RFC 2734 and RFC 3146.
> 
> On a VIA VT6316 based CardBus card which was affected by this, changing
> the MTU from 1008 to 1500 also increases TX bandwidth by 6 %.
> RX remains unaffected.
> 
> CC: netdev@vger.kernel.org
> CC: linux1394-devel@lists.sourceforge.net
> CC: Jarod Wilson <jarod@redhat.com>
> Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
> ---
>  drivers/firewire/net.c | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
> index 99379542b263..03715e7d9d92 100644
> --- a/drivers/firewire/net.c
> +++ b/drivers/firewire/net.c
> @@ -1463,13 +1463,7 @@ static int fwnet_probe(struct fw_unit *unit,
>  		goto out;
>  	dev->local_fifo = dev->handler.offset;
>  
> -	/*
> -	 * Use the RFC 2734 default 1500 octets or the maximum payload
> -	 * as initial MTU
> -	 */
> -	net->mtu = min(1500U,
> -		       (1U << (card->max_receive + 1))
> -		       - RFC2374_FRAG_HDR_SIZE - IEEE1394_GASP_HDR_SIZE);
> +	net->mtu = 1500U;

Should be able to do just net->mtu = ETH_DATA_LEN;

-- 
Jarod Wilson
jarod@redhat.com
