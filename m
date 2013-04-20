From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bonding: change xmit hash functions to use
 skb_flow_dissect
Date: Sat, 20 Apr 2013 08:52:00 -0700
Message-ID: <1366473120.16391.82.camel@edumazet-glaptop>
References: <1366412545-10829-1-git-send-email-nikolay@redhat.com>
	 <1366419435.16391.70.camel@edumazet-glaptop> <517231CE.5030809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:61717 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932191Ab3DTPwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 11:52:04 -0400
Received: by mail-pb0-f50.google.com with SMTP id um15so106433pbc.37
        for <netdev@vger.kernel.org>; Sat, 20 Apr 2013 08:52:03 -0700 (PDT)
In-Reply-To: <517231CE.5030809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-04-20 at 08:12 +0200, Nikolay Aleksandrov wrote:
> On 20/04/13 02:57, Eric Dumazet wrote:
> > On Sat, 2013-04-20 at 01:02 +0200, Nikolay Aleksandrov wrote:
> >> As Eric suggested earlier, bonding hash functions can make good use of
> >> skb_flow_dissect. The old use cases should have the same results, but
> >> there should be good improvement for tunnel users mostly over IPv4.
> >> I've kept the IPv6 address hashing algorithm and thus if a tunnel is
> >> used over IPv6 then the addresses will be the same but there still can be
> >> improvement because the ports from skb_flow_dissect will be mixed in.
> >> This also fixes a problem with protocol == ETH_P_8021Q load balancing.
> > 
> > Are you sure ? we don't look at skb->vlan_tci
> We don't need to look at vlan_tci, the problem was that when we had a
> packet with skb->protocol == htons(ETH_P_8021Q) before we wouldn't use
> the network headers inside and always fall back to L2 hash which in most
> cases is weaker.
> When using skb_flow_dissect we avoid that because of the header extraction

What I meant to say is : Most devices used in a bonding setup use
hardware assist vlan tagging, so I doubt it was a real concern.

The real gain is tunneling decapsulation for free.

> > Not sure its worth doing this test, as IPv6 addresses are mixed already.
> > 
> > So just
> > 
> > hash = (__force u32)flow.ports ^
> >        (__force u32)keys.dst ^
> >        (__force u32)keys.src;
> > 
> > hash ^= (hash >> 16);
> > hash ^= (hash >> 8);
> > 
> > return hash % count;
> > 
> Hm, I actually wanted to keep the old hash because it mixes
> different parts of the address so to produce the same results as the
> original version.
> I think that ipv6_addr_hash mixes the whole IPv6 address, as the old
> bond version mixes only bits 32-128.
> I'd be happy to update it to this version if the bonding maintainers
> agree to it, then we'll be able to remove some ugliness :-)
> 

My original idea was to re-use skb_flow_dissect() to keep a more simple
bonding hash implementation, yet using all bits.

The only difference between l23 and l34 is that l23 wont use flow.ports,
but the hash will be the same :

hash = (__force u32)keys.dst ^ (__force u32)keys.src;
hash ^= (hash >> 16);
hash ^= (hash >> 8);
return hash % count;
 

using ntohl() is really not needed here, just xor32 all the different
parts (or xor64 as in the IPv6 hash function), then the final xor16/xor8
has the property that hash % count is well spread.

Sure, the hash is not the original one, but its not in a RFC, is it ?

Also keep in mind to change documentation.

BTW, I was waiting this patch was first pulled on net-next to do this
myself.
 
commit 4394542ca4ec9f28c3c8405063d200b1e7c347d7
bonding: fix l23 and l34 load balancing in forwarding path

Your patch based on current net-next makes things more complex for
David. I do not feel this is urgent stuff, is it ?
