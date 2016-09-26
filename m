From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [ovs-dev] [PATCH net-next v11 5/6] openvswitch: add layer 3
 flow/port support
Date: Mon, 26 Sep 2016 18:53:06 +0200
Message-ID: <20160926185306.164bc044@griffin>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com>
        <1467827996-32547-6-git-send-email-simon.horman@netronome.com>
        <CAOrHB_BYD40ZkWbU0dvhPOCcaCVgooksOUkejxyFoagyoiBTNw@mail.gmail.com>
        <20160713073152.GC29661@penelope.isobedori.kobe.vergenet.net>
        <CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33888 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1161424AbcIZQxK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 12:53:10 -0400
In-Reply-To: <CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reviving a very old thread, sorry. Simon handed this over to me, I'm
preparing v12.

On Fri, 15 Jul 2016 14:07:37 -0700, pravin shelar wrote:
> I am not sure if you can use only mac_len to detect L3 packet. This
> does not work with MPLS packets, mac_len is used to account MPLS
> headers pushed on skb. Therefore in case of a MPLS header on L3
> packet, mac_len would be non zero and we have to look at either
> mac_header or some other metadata like is_layer3 flag from key to
> check for L3 packet.

I went through the relevant code paths and I don't see any problem in
using mac_len for that. MPLS GSO seems to work correctly. The kernel
MPLS code expects mac_len to be just the L2 header len, excluding MPLS.
The same is the case for openvswitch (you're not correct that "mac_len
is used to account MPLS headers pushed on skb", at least not with the
current code). In no place I see any problem with mac_len being 0, the
calculations just nicely work.

What was your concern with that, Pravin?

In another mail in this thread you mentioned skb_mpls_header. That one
works correctly with mac_len == 0 if mac_header points to the beginning
of the packet.

You also wrote:

> I was thinking in overall networking stack rather than just ovs
> datapath. I think we should have consistent method of detecting L3
> packet. As commented in previous mail it could be achieved using
> skb-protocol and device type.

Again, mac_len == 0 works correctly and consistently, provided that
both mac_header and network_header point to the same place. In case of
a MPLS packet it would be the beginning of MPLS headers.

> > --- a/include/net/mpls.h
> > +++ b/include/net/mpls.h
> > @@ -34,6 +34,8 @@ static inline bool eth_p_mpls(__be16 eth_type)
> >   */
> >  static inline unsigned char *skb_mpls_header(struct sk_buff *skb)
> >  {
> > -       return skb_mac_header(skb) + skb->mac_len;
> > +       return skb_mac_header_was_set(skb) ?
> > +               skb_mac_header(skb) + skb->mac_len :
> > +               skb->data;
> >  }
> 
> This function is also called from GSO layer.

I don't see it used anywhere outside of openvswitch. Not even when
grepping git history. I may be missing something, though.

> issue is in GSO layer, it
> does reset mac header and mac length and then calls mpls-gso-handler.
> So all subsequent check for L3 packet fails.
> So far we have explored three different ways to detect L3 packet but
> each has its own issue.
> 1. skb mac header : GSO can reset mac header.
> 2. skb mac length : MPLS uses mac_len to account for MPLS header
> length along with L2 header

It does not appear to be the case. Or at least not anymore.

> 3. skb protocol: ETH_P_TEB is not set for all L2 frames, networking
> stack is not ready to handle this type for given skb.
> 
> So none of them works consistently. I think the only option to detect
> L3 packet reliably (and without adding field to skb) is to use
> skb-protocol along with ARPHRD_NONE device type. If ARPHRD_NONE type
> device generates L2 packet it needs to set protocol to ETH_P_TEB. Some
> networking stack function also needs to be fixed to handle this
> protocol type, e.g. vlan_get_protocol(), br_dev_queue_push_xmit(),
> etc.

All of this said, I'm not opposed to using the skb_eth_header_present
helper and checking the device type, it works. I just want to understand
whether I missed some problem with mac_len. Seems to make some things
simpler if we could use mac_len.

Thanks,

 Jiri
