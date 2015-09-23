From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Wed, 23 Sep 2015 22:54:55 +0200
Message-ID: <20150923225456.74c5cd1d@griffin>
References: <cover.1442936392.git.jbenc@redhat.com>
	<87zj0d92ba.fsf@x220.int.ebiederm.org>
	<20150923080957.GB29680@pox.localdomain>
	<87lhbx72j2.fsf@x220.int.ebiederm.org>
	<20150923162927.6d437a1f@griffin>
	<8761313ud5.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39892 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753905AbbIWUzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 16:55:00 -0400
In-Reply-To: <8761313ud5.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2015 12:42:30 -0500, Eric W. Biederman wrote:
> Without your ARP changes in this patchset I don't understand what the
> purpose of metadata dsts are, so I am probably still missing something
> important.
> 
> If ARP and ndisc are the only uses of metadata dsts, allocating a
> metadata dst for every packet seems undesirable.

They're not. Metadata dsts carry information about the original
encapsulation. This is used to match flows on the original
encapsulation data. The current users are openvswitch, eBPF, in the
future also tc. Could be used also by e.g. nftables in the future.

In the other direction, it can be used to specify egress encapsulation
data. Alternatively, lwtstate pointer in dst_entry can be used for
egress.

> In which case I suspect what is desriable is a ndo operation that
> looks at the packet and computes the dst.
> 
> So perhaps instead of:
> +	if (arp->ar_op == htons(ARPOP_REQUEST) && skb_metadata_dst(skb))
> +		reply_dst = (struct dst_entry *)
> +			    iptunnel_metadata_reply(skb_metadata_dst(skb),
> +						    GFP_ATOMIC);
> +
> The code would be:
> 	if (arp->ar_op == htons(AROP_REQUEST) && dev->ndo_reply_dst)
> 		reply_dst = dev->ndo_reply_dst(skb, GFP_ATOMIC);

This is something I intended to do originally. I also considered adding
the callback into metadata_dst itself. However, it doesn't make much
sense for the time being. The only thing that's using metadata_dst
currently is IP based lwtunnels. Look at the struct metadata_dst
definition:

struct metadata_dst {
        struct dst_entry                dst;
        union { 
                struct ip_tunnel_info   tun_info; 
        } u;            
};                      

Although there's an union, there's nothing that says what kind of data
the metadata_dst carries. Adding new field to the union would also
require adding a new type field. Otherwise you risk misinterpretation
of the data, as all current places just blindly reach into tun_info if
metadata dst is present, regardless of where the skb came from.

If there's another user of metadata_dst in the future, this needs to be
changed anyway. We can add such ndo callback (or some other kind of
callback) then, if it turns out to be needed. For now, we don't need it
and the changes to make metadata_dst usable for other things than IP
tunnels are not suitable for net.git.

> For any network that does interesting things with network level
> identifiers below IP this seems like a general problem.  Further it
> seems more desirable to only perform an allocation when necessary,
> rather than for every packet, and two for the packets that actually
> need replies.

The metadata_dst are only allocated when requested. Look at e.g.
vxlan_collect_metadata function. If they're requested, it means they are
needed. And they certainly need to be allocated for ARP replies to such
packets. I don't see what could be further optimized here. Seems to me
that you assume that the sole purpose of why metadata_dst exist is ARP
which is not the case.

 Jiri

-- 
Jiri Benc
