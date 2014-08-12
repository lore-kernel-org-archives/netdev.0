From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: protocol 0000 is buggy, dev nlmon
Date: Tue, 12 Aug 2014 21:05:23 +0200
Message-ID: <53EA6573.4060204@redhat.com>
References: <8CB882A0-240B-4759-A119-8867FCF70957@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36282 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753925AbaHLTFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 15:05:30 -0400
In-Reply-To: <8CB882A0-240B-4759-A119-8867FCF70957@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2014 08:05 PM, Marcel Holtmann wrote:
...
> And on that note, I also found that we can not get the multicast group id from nlmon.
 > This is something we should include to be able to distinguish where netlink messages
 > are send to.

Just to follow-up on this thread first for general discussion [ sorry was/am very busy
recently ]. My suggestion was something like the following pseudocode:

--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -212,10 +212,11 @@ static int __netlink_deliver_tap_skb(struct sk_buff *skb,
[...]
  		nskb->protocol = htons((u16) sk->sk_protocol);
  		nskb->pkt_type = netlink_is_kernel(sk) ?
  				 PACKET_KERNEL : PACKET_USER;
+		nskb->sw_hash = 1;
+		nskb->hash = NETLINK_CB(nskb).dst_group;
[...]

The hash itself should currently be 0 actually as it's unused. The upside for
this approach is that it can be used as is, e.g. in BPF socket filters,
TPACKET_V3 exports it to user space already and we could add it to TPACKET_V2
meta data (as we currently have 4 byte padding left). The downside, it doesn't
fit into struct tpacket_auxdata which is for non-mmap operational mode, however
imho this would be an option to go for.

The other options are (as suggested by you) are a split of the 4 byte into
{tp_mac, tp_net} tuple + status flag, or a split into {tp_vlan_tci, tp_vlan_tpid}
tuple plus status flag since both are also exported via tpacket_auxdata. The
first variant is not possible as at least tp_mac contains the start offset
although tp_net would be unused as it carries the same value as tp_mac; however,
another issue with that could be that applications do not check status flags
before accessing tp_{mac,net}, so I don't really like it. Also it makes it
impossible for usage with BPF filters. The same goes for the tp_vlan_{tci,tpid}
variant, it would not be possible to reliably use it with BPF filters attached
as opposed to the hash version. Next, encoding this over tp_vlan_{tci,tpid} would
require special casing in AF_PACKET since we fetch and fill 'em via vlan_tx_tag_get(skb)
and ntohs(skb->vlan_proto). Yet another option would be to introduce something
like struct tpacket_auxdata2 which carries more meta data with it, but that I'd
really don't like -- AF_PACKET has already too many versions of mmap'ed API
which is horrible. Therefore, I am still in favour of going with skb->hash as
it's the cleanest.
