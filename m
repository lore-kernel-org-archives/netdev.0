From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: 2.6.25: Weird IPv4 stack behaviour, IPv6 is fine
Date: Mon, 28 Apr 2008 11:18:35 +0100
Message-ID: <20080428101835.GA13522@flint.arm.linux.org.uk>
References: <20080427231411.GA5261@flint.arm.linux.org.uk> <48157685.1040709@openvz.org> <20080428093130.GA1011@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:37774 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbYD1KSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 06:18:45 -0400
Content-Disposition: inline
In-Reply-To: <20080428093130.GA1011@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2008 at 10:31:30AM +0100, Russell King wrote:
> int ip_local_deliver(struct sk_buff *skb)
> {
> ...
> if (ip_hdr(skb)->saddr == htonl(0xc0a80043) &&
>     ip_hdr(skb)->protocol == IPPROTO_ICMP) printk("ping 2\n");
>         return NF_HOOK(PF_INET, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
>                        ip_local_deliver_finish);
> }
> 
> static int ip_local_deliver_finish(struct sk_buff *skb)
> {
>         __skb_pull(skb, ip_hdrlen(skb));
> 
>         /* Point into the IP datagram, just past the header. */
>         skb_reset_transport_header(skb);
> 
> if (ip_hdr(skb)->saddr == htonl(0xc0a80043) &&
>     ip_hdr(skb)->protocol == IPPROTO_ICMP) printk("ping 3\n");
> 
> When the machine stops responding to pings, I see in the kernel message
> log 'ping 2' but no 'ping 3' (whereas I get both when it does respond.)
> 
> I don't have the iptables binary installed, so there aren't any rules.
> (Also, the iptables_filter module isn't loaded.)

(Adding netfilter mailing list.  See http://marc.info/?t=120933809600001&r=1&w=2
for the initial problem description.)

Further to this, it's looking like there's a nf_conntrack issue.  Having
placed similar printks in the netfilter code, I see the ipv4_confirm()
hook normally returning 1 (NF_ACCEPT), but then decides to return 0
(NF_DROP) and no ping replies.

-bash-3.1# cat /proc/net/stat/ip_conntrack
entries  searched found new invalid ignore delete delete_list insert insert_failed drop early_drop icmp_error  expect_new expect_create expect_delete
00000110  000000e2 000001c6 000003bb 00000140 00000000 000002ab 0000023a 0000034a 0000005f 00000000 00000000 0000000f  00000000 00000000 00000000

insert_failed increments when there aren't any ping replies.

The other interesting thing (though I'm not sure if it's really
related or helps) is:

-bash-3.1# grep 'ipv4.*icmp.*192.168.0.67' /proc/net/nf_conntrack
ipv4     2 icmp     1 29 src=192.168.0.67 dst=78.32.30.220 type=8 code=0 id=53823 packets=19 bytes=156180 [UNREPLIED] src=78.32.30.220 dst=192.168.0.67 type=0 code=0 id=53823 packets=0 bytes=0 mark=0 use=1
-bash-3.1# grep 'ipv4.*icmp.*192.168.0.67' /proc/net/nf_conntrack
ipv4     2 icmp     1 29 src=192.168.0.67 dst=78.32.30.220 type=8 code=0 id=53823 packets=21 bytes=172620 [UNREPLIED] src=78.32.30.220 dst=192.168.0.67 type=0 code=0 id=53823 packets=0 bytes=0 mark=0 use=1
-bash-3.1# grep 'ipv4.*icmp.*192.168.0.67' /proc/net/nf_conntrack
ipv4     2 icmp     1 29 src=192.168.0.67 dst=78.32.30.220 type=8 code=0 id=53823 packets=22 bytes=180840 [UNREPLIED] src=78.32.30.220 dst=192.168.0.67 type=0 code=0 id=53823 packets=0 bytes=0 mark=0 use=1
-bash-3.1# grep 'ipv4.*icmp.*192.168.0.67' /proc/net/nf_conntrack
ipv4     2 icmp     1 29 src=192.168.0.67 dst=78.32.30.220 type=8 code=0 id=53823 packets=23 bytes=189060 [UNREPLIED] src=78.32.30.220 dst=192.168.0.67 type=0 code=0 id=53823 packets=0 bytes=0 mark=0 use=1
-bash-3.1# grep 'ipv4.*icmp.*192.168.0.67' /proc/net/nf_conntrack
ipv4     2 icmp     1 29 src=192.168.0.67 dst=78.32.30.220 type=8 code=0 id=53823 packets=24 bytes=197280 [UNREPLIED] src=78.32.30.220 dst=192.168.0.67 type=0 code=0 id=53823 packets=0 bytes=0 mark=0 use=1
-bash-3.1# grep 'ipv4.*icmp.*192.168.0.67' /proc/net/nf_conntrack
ipv4     2 icmp     1 28 src=192.168.0.67 dst=78.32.30.220 type=8 code=0 id=53823 packets=26 bytes=213720 [UNREPLIED] src=78.32.30.220 dst=192.168.0.67 type=0 code=0 id=53823 packets=0 bytes=0 mark=0 use=1
-bash-3.1# grep 'ipv4.*icmp.*192.168.0.67' /proc/net/nf_conntrack
ipv4     2 icmp     1 25 src=192.168.0.67 dst=78.32.30.220 type=8 code=0 id=53823 packets=26 bytes=213720 [UNREPLIED] src=78.32.30.220 dst=192.168.0.67 type=0 code=0 id=53823 packets=0 bytes=0 mark=0 use=1
-bash-3.1# grep 'ipv4.*icmp.*192.168.0.67' /proc/net/nf_conntrack
ipv4     2 icmp     1 24 src=192.168.0.67 dst=78.32.30.220 type=8 code=0 id=53823 packets=26 bytes=213720 [UNREPLIED] src=78.32.30.220 dst=192.168.0.67 type=0 code=0 id=53823 packets=0 bytes=0 mark=0 use=1
-bash-3.1# grep 'ipv4.*icmp.*192.168.0.67' /proc/net/nf_conntrack
ipv4     2 icmp     1 23 src=192.168.0.67 dst=78.32.30.220 type=8 code=0 id=53823 packets=26 bytes=213720 [UNREPLIED] src=78.32.30.220 dst=192.168.0.67 type=0 code=0 id=53823 packets=0 bytes=0 mark=0 use=1

Note how the conntrack entry stays as "unreplied" and the packet and
byte counters stop incrementing with each ping packet sent.  Maybe
something's missing from the local IP output path to confirm the
entry?

-- 
Russell King
