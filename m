From: jamal <hadi@cyberus.ca>
Subject: Re: tun device - bug or feature? WAS(Re: IMQ / new Dummy device
	post.
Date: 08 May 2004 07:55:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1084017322.1041.30.camel@jzny.localdomain>
References: <wazza.87ad18jbdl.fsf@message.id>
	 <1082427350.1034.70.camel@jzny.localdomain>
	 <wazza.87fzayw1fy.fsf@message.id> <wazza.87fzaxmr6x.fsf@message.id>
	 <wazza.87hdvddqxq.fsf@message.id>
	 <1082639764.1059.81.camel@jzny.localdomain>
	 <87oepjx65r.87n053x65r@87llknx65r.message.id>
	 <1082719745.1057.27.camel@jzny.localdomain>
	 <1082816083.1054.32.camel@jzny.localdomain>
	 <1083007898.7788.276.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, syrius.ml@no-log.org, Jeff Garzik <jgarzik@pobox.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Max Krasnyansky <maxk@qualcomm.com>
In-Reply-To: <1083007898.7788.276.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Max, Dave, Jeff,

I get what was bothering me now - it took me a while to formulate it:

TUN_TUN_DEV dev->type is ARPHRD_PPP
dev->type is really related to link layer header, perhaps at the low
level if neighbor discovery works well then we have a link-headerless
packet which gets manipulated with the correct header by some generic
code. The combination of dev->type and dev->hard_header_len works
together to achieve this.
In the case of TUN_TUN_DEV, the header_len is 0 ;->
To be of type ARPHRD_PPP, tun needs to have a header_len which is the
size of the l2 ppp header.
As an example, TUN_TAP_DEV is fine as type ARPHRD_ETHER and header_len
of ETH_HLEN.

A lot of devices are abusing this system, tun is not the only one.

My suggestion is to change dev->type to ARPHRD_VOID for TUN_TUN_DEV or
we introduce something like ARPHDR_NONE for devices with link layer
headers of size 0.

thoughts?

cheers,
jamal

On Mon, 2004-04-26 at 15:31, Max Krasnyansky wrote:
> On Sat, 2004-04-24 at 07:14, jamal wrote:
> > Maxim,
> > 
> > When TUN_TUN_DEV is used, before the packet is injected into
> > the netif_rx() only skb->mac.raw = skb->data is set; the other headers
> > are not adjusted. Typically netdevs would do a
> > skb_pull(skb,dev->hard_header_len) to make the adjustment.
> > I have a feeling this is design intent thats why i didnt send you a
> > patch. 
> Well TUN does not have any hw headers so there is nothing to pull :).
> Basically it does what ever PPP driver does. Which is
> 
> 	skb_pull(skb, 2);       /* chop off protocol */
>         skb->dev = ppp->dev;
>         skb->protocol = htons(npindex_to_ethertype[npi]);
>         skb->mac.raw = skb->data;
>         netif_rx(skb);
> 
> Max
> 
> 
> 
