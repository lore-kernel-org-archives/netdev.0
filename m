From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: regarding trill implementation
Date: Sat, 10 Mar 2012 09:27:03 -0800
Message-ID: <20120310092703.16059851@nehalam.linuxnetplumber.net>
References: <CAAZheXnWv-td=YmTftijmJ079mP_Cc4UDHPg9YNCMHQ3h4QsPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51315 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752008Ab2CJUG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 15:06:57 -0500
In-Reply-To: <CAAZheXnWv-td=YmTftijmJ079mP_Cc4UDHPg9YNCMHQ3h4QsPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Mar 2012 23:13:42 +0500
Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk> wrote:

> Hi,
>     I have got the point where packet data is truncated. The function
> nf_bridge_maybe_copy_header( ) in  br_dev_queue_push_xmit( ) actually
> truncates it.
> Can you please tell me the purpose of nf_bridge_maybe_copy_headers( ).

Packets that go through a transparent bridge need to have special processing.
The original header is copied to an area above the header, so that netfilter
rules see the original header, not the header of destination.

    

               +----------+
               | Original |
               | Ethernet |
               | Header   |
               +----------+<-------+ skb->data
               | Bridged  |
               | Ethernet |
               | Header   |
               +----------+
               | IP and   |
               | rest     |
               |          |
               |          |
               |          |
               |          |
               |          |
               |          |
               |          |
               |          |
               |          |
               |          |
               |          |
               +----------+


When allocating skb's, dev_alloc_skb and other routines setup the
required padding.

>  As far as i have understood, it is used for vlan or pppoe header
> encapsulation. I don't understand the purpose of netfilters as vlan
> and pppoe data is copied from skb->nf_bridge->data to skb->data but do
> so in case of when netfilters are configured.
> 
> Should i put my encapsulation headers also in skb->nf_bridge->data?
> And modify the function nf_bridge_encap_header_len(const struct
> sk_buff *skb) by adding a "case" for trill header. So that header will
> be put in skb->data in  function   skb_copy_to_linear_data_offset(skb,
> -header_size, skb->nf_bridge->data, header_size);
> 
> Temporarily, i have called a function create_trill_header( ) in
> br_dev_queue_push_xmit( ).
> 
> Actual is:
> 
>   int br_dev_queue_push_xmit(struct sk_buff *skb)
>   {
>           /* ip_fragment doesn't copy the MAC header */
>           if (nf_bridge_maybe_copy_header(skb) ||
>               (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
>                   kfree_skb(skb);
>           } else {
>                   skb_push(skb, ETH_HLEN);
>                   dev_queue_xmit(skb);
>           }
> 
>           return 0;
>   }
> 
> 
> Now after addition of trill hooks:

Trill should be a tunnel (look at gretap) that can be added to bridge
transparently.
