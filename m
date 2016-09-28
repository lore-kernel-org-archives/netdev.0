From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Wed, 28 Sep 2016 13:03:46 -0400
Message-ID: <20160928170346.GA9263@oracle.com>
References: <20160920190929.57ddaeb0@griffin>
 <20160922.015242.735026657310158125.davem@davemloft.net>
 <20160922213010.GA32052@oracle.com>
 <20160923.080618.678103827885223586.davem@davemloft.net>
 <CAKgT0UcoDb5T9xwfAq83cNwU=XAKZxf0TmPiJZQyHFPr82zggg@mail.gmail.com>
 <20160923172059.GB2484@oracle.com>
 <CAKgT0UeB5n3g4f1v_2nenjcayAi=eOPFSC7132ihXTZOztHRkw@mail.gmail.com>
 <20160923234134.GA6397@oracle.com>
 <CAKgT0Uenb+D44D4g2SieNDf3+P_wnv2WYSBZ+NU_87e011PRjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, sowmini.varadhan@oracle.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33729 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933039AbcI1RDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 13:03:54 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0Uenb+D44D4g2SieNDf3+P_wnv2WYSBZ+NU_87e011PRjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/23/16 17:43), Alexander Duyck wrote:
> > On (09/23/16 10:38), Alexander Duyck wrote:
          ;
> >> almost think of it as us doing something like the inverse of
> >> pskb_pull_tail.  The general idea here is we want to actually leave
> >> the data in skb->data, but just reference it from frag[0] so that we
> >> don't accidentally pull in the 2 byte padding for alignment when
> >> transmitting the frame.

Some additional findings..

Just to recap how we got here: for the Rx path, the inner packet has
been set up as an ethernet frame with the IP header at an aligned address
when it hits vxlan_build_skb.  But that means the (inner) mac address
was offset by NET_IP_ALIGN so vxlan_build_skb needs to pad the data
by NET_IP_ALIGN to make the vxh outer ip header align. 

Then we'd need to do something like the suggestion above (keep some
pointers in frag[0]?  do the reverse of a pskb_expand_head to push out
the inner ip header to the skb_frag_t?), to have the driver skip over the
pad.. 

I tried the following for a hack, and it takes care of the tx side
unaligned access, though, clearly, the memmove needs to be avoided

@@ -1750,10 +1825,38 @@ static int vxlan_build_skb(struct sk_buff *skb, struct d
        if (err)
                goto out_free;
 
+
+#if (NET_IP_ALIGN != 0) 
+       {
+               unsigned char *data;
+
+               /* inner packet is an ethernet frame that was set up
+                * so that the IP header is aligned. But that means the
+                * mac address was offset by NET_IP_ALIGN, so we need
+                * to move things up so that the vxh and outer ip header
+                * are now aligned
+                * XXX The Alexander Duyck idea was to only do the
+                * extra __skb_push() for NET_IP_ALIGN, and avoid the
+                * extram memmove and ->inner* adjustments. Plus keep
+                * additional pointers in frag[0] and have the driver pick
+                * up pointers from frag[0] .. need to investigate
+                * that suggestion further.
+                */
+               data = skb->data;
+               skb->data -= NET_IP_ALIGN;
+               memmove(skb->data, data, skb_headlen(skb));
+               skb->inner_network_header -= NET_IP_ALIGN;
+               skb->inner_mac_header -= NET_IP_ALIGN;
+               skb->inner_transport_header -= NET_IP_ALIGN;
+       }
+#endif
        vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
        vxh->vx_flags = VXLAN_HF_VNI;
        vxh->vx_vni = vxlan_vni_field(vni);

In the general case (when the skb passed to vxlan_build_skb is already
non-linear), wouldn't we end up having to shift all the frags by 1 and/or
do some type of memory copy of the inner packet? However, I think
there are some clever things we can do in general, to avoid the memmove..

I also looked at the Rx path. Here the suggestion was:
"we should only pull the outer headers from the page frag, and then
 when the time is right we drop the outer headers and pull the inner
 headers from the page frag.  That way we can keep all the headers
 aligned."
I hacked up ixgbe_add_rx_frag to always only create nonlinear skb's, 
i.e., always avoid the
   memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
and then I end up with 
- ixgbe_clean_rx_irq copies outer header ether/ip/udp headers
  into linear part as needed, 
- then udp_gro_receive -> vxlan_gro_receive pulls up vxlan header
  into linear part, and then..
- eth_gro_receive pulls up another 34 bytes for the eth + ip header.
  This last pull ends up being unaligned. 
I dont know if we can safely drop the outer ip headers at this point
(have not tried this yet, and I'm not sure we can do this in all udp
encaps cases..)

one other possibility is to set up the inner frame as part of the 
->frag_list (note, this is *not* skb_frag_t). I suspect that is going
to cause other inefficiencies.

but, as tom has been saying all along, a big part of this problem is that
we are tripping up on the ethernet header in the middle of an
IP packet. Unfortunately I dont think the ietf is going to agree
to never ever do that, so I'm not sure we can win that architectural battle.
 
