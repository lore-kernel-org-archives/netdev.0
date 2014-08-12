From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: protocol 0000 is buggy, dev nlmon
Date: Tue, 12 Aug 2014 16:03:31 -0700
Message-ID: <375D1F05-1562-4481-8745-4C7BD9B4978F@holtmann.org>
References: <8CB882A0-240B-4759-A119-8867FCF70957@holtmann.org> <53EA6573.4060204@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:56135 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbaHLXC7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 19:02:59 -0400
In-Reply-To: <53EA6573.4060204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

>> And on that note, I also found that we can not get the multicast group id from nlmon.
> > This is something we should include to be able to distinguish where netlink messages
> > are send to.
> 
> Just to follow-up on this thread first for general discussion [ sorry was/am very busy
> recently ]. My suggestion was something like the following pseudocode:
> 
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -212,10 +212,11 @@ static int __netlink_deliver_tap_skb(struct sk_buff *skb,
> [...]
> 		nskb->protocol = htons((u16) sk->sk_protocol);
> 		nskb->pkt_type = netlink_is_kernel(sk) ?
> 				 PACKET_KERNEL : PACKET_USER;
> +		nskb->sw_hash = 1;
> +		nskb->hash = NETLINK_CB(nskb).dst_group;
> [...]
> 
> The hash itself should currently be 0 actually as it's unused. The upside for
> this approach is that it can be used as is, e.g. in BPF socket filters,
> TPACKET_V3 exports it to user space already and we could add it to TPACKET_V2
> meta data (as we currently have 4 byte padding left). The downside, it doesn't
> fit into struct tpacket_auxdata which is for non-mmap operational mode, however
> imho this would be an option to go for.
> 
> The other options are (as suggested by you) are a split of the 4 byte into
> {tp_mac, tp_net} tuple + status flag, or a split into {tp_vlan_tci, tp_vlan_tpid}
> tuple plus status flag since both are also exported via tpacket_auxdata. The
> first variant is not possible as at least tp_mac contains the start offset
> although tp_net would be unused as it carries the same value as tp_mac; however,
> another issue with that could be that applications do not check status flags
> before accessing tp_{mac,net}, so I don't really like it. Also it makes it
> impossible for usage with BPF filters. The same goes for the tp_vlan_{tci,tpid}
> variant, it would not be possible to reliably use it with BPF filters attached
> as opposed to the hash version. Next, encoding this over tp_vlan_{tci,tpid} would
> require special casing in AF_PACKET since we fetch and fill 'em via vlan_tx_tag_get(skb)
> and ntohs(skb->vlan_proto). Yet another option would be to introduce something
> like struct tpacket_auxdata2 which carries more meta data with it, but that I'd
> really don't like -- AF_PACKET has already too many versions of mmap'ed API
> which is horrible. Therefore, I am still in favour of going with skb->hash as
> it's the cleanest.

I want to be able to also store this in PCAP files with the Cooked Linux header. This makes it really useful to combine Ethernet traffic with Netlink traffic into a single PCAP file. So we have a little bit of limitation here now. This is how SLL header is defined:

struct sll_header {                                                              
        u_int16_t sll_pkttype;          /* packet type */                        
        u_int16_t sll_hatype;           /* link-layer address type */            
        u_int16_t sll_halen;            /* link-layer address length */          
        u_int8_t sll_addr[SLL_ADDRLEN]; /* link-layer address */                 
        u_int16_t sll_protocol;         /* protocol */                           
};

So what we have at the moment is that sll_pktype is defining the direction bit (at least for Ethernet traffic), sll_hatype gives you the ARPHRD_ so can distinguish between Ethernet and Netlink. And then sll_protocol allows you to differentiate either between the Ethernet protocol or the Netlink protocol.

Which fundamentally means that only the sll_addr is left. I mean should we use a sll_halen of 4 bytes and put the multicast group just in there?

Of course what comes out of the kernel does not have to be delivered as the address, that is something that could defined at the PCAP level.

Personally I think the mmaped version of AF_PACKET and the simple CMSG based retrieving of aux data should be feature comparable. Having one being capable of something that the other isn't sounds a bit weird to me.

If we change something we might also consider attaching some of the process information to it. It would be useful to know if messages are from the same process or not. The nlmsg_pid is not reliable to do any mapping. And even in conjunction with nlmsg_seq it can result in false positives. This is especially interesting when you want to make the response to the request. So somehow we need to be able to distinguish nlmsg_seq=x with nlmsg_pid=y from a different client using the exact same values for x and y. And I have seen clients using nlmsg_pid=0 as well.

Regards

Marcel
