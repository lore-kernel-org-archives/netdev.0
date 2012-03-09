From: Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk>
Subject: regarding trill implementation
Date: Fri, 9 Mar 2012 23:13:42 +0500
Message-ID: <CAAZheXnWv-td=YmTftijmJ079mP_Cc4UDHPg9YNCMHQ3h4QsPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:62717 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568Ab2CISNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 13:13:43 -0500
Received: by vcqp1 with SMTP id p1so1595325vcq.19
        for <netdev@vger.kernel.org>; Fri, 09 Mar 2012 10:13:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
    I have got the point where packet data is truncated. The function
nf_bridge_maybe_copy_header( ) in  br_dev_queue_push_xmit( ) actually
truncates it.
Can you please tell me the purpose of nf_bridge_maybe_copy_headers( ).

 As far as i have understood, it is used for vlan or pppoe header
encapsulation. I don't understand the purpose of netfilters as vlan
and pppoe data is copied from skb->nf_bridge->data to skb->data but do
so in case of when netfilters are configured.

Should i put my encapsulation headers also in skb->nf_bridge->data?
And modify the function nf_bridge_encap_header_len(const struct
sk_buff *skb) by adding a "case" for trill header. So that header will
be put in skb->data in  function   skb_copy_to_linear_data_offset(skb,
-header_size, skb->nf_bridge->data, header_size);

Temporarily, i have called a function create_trill_header( ) in
br_dev_queue_push_xmit( ).

Actual is:

  int br_dev_queue_push_xmit(struct sk_buff *skb)
  {
          /* ip_fragment doesn't copy the MAC header */
          if (nf_bridge_maybe_copy_header(skb) ||
              (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
                  kfree_skb(skb);
          } else {
                  skb_push(skb, ETH_HLEN);
                  dev_queue_xmit(skb);
          }

          return 0;
  }


Now after addition of trill hooks:

int br_dev_queue_push_xmit(struct sk_buff *skb)
{
	/* ip_fragment doesn't copy the MAC header */
	if (nf_bridge_maybe_copy_header(skb) ||
	    (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
		kfree_skb(skb);
	} else {
	    printk ("Outside 1");	
			if(eth_hdr(skb)->h_proto == htons(0x0800) && skb->protocol != htons(0x22f3))
			{
				printk("Entery 1");
		
    				printk("Entery 2");
     				skb = create_trill_header(skb,false,0);
					
			}

		skb_push(skb, ETH_HLEN);
		trill_testing(skb);
		dev_queue_xmit(skb);
	}

	return 0;
}

It is working somehow fine. But i have got the problem with checks
before calling encapsulating function as shown above. I don't get upon
things i have to put in checks as given above.

Any idea and help......

How do i distinguish between packets which come from other bridges and
from it own connected hosts?

Should i extend the data structure of bridge "net_bridge_fdb_entry" by
adding trill fields as in solaris trill for generating trill data
base?
