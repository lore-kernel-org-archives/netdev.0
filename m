From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Checksumming bug in bridge multicast snooping for IPv6?
Date: Sun, 27 Mar 2011 05:44:04 +0200
Message-ID: <20110327034404.GC31916@Sellars>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:52145 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645Ab1C0DoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 23:44:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hi everyone,

Somehow I'm having trouble with the IPv6 bridge snooping again:
MLDv2 Reports are dropped by the multicast snooping feature, looks
like it has something to do with checksums. Wireshark does not
display any weirdness, it at least reports the MLD reports
checksum as correct.


The setup is the following: The VM is running a current Linux
version of torvalds branch with no other additions then the
printk-debug patch attached (2.6.38+ #4 SMP PREEMPT Sat Mar 26
22:59:11 GMT 2011 i686 GNU/Linux):
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=tree;h=16c29dafcc86024048f1dbb8349d31cb22c7c55a;hb=16c29dafcc86024048f1dbb8349d31cb22c7c55a
The host machine which is joining a multicast group is doing an
explicit join on the KVM instances provided tap interface:
IPv6: vlc -vvv "udp://@[ff12::124%vmtap1]"
(IPv4: vlc -vvv "udp://@224.0.1.123")
The host machine is running a kernel from Debian unstable:
2.6.37-2-amd64 #1 SMP Sun Feb 27 12:32:01 UTC 2011 x86_64
GNU/Linux

See the attached debug patch and the according output for some
more details where it fails (the bridge is basically ignoring the
MLDv2 report due to the goto in this line:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=net/bridge/br_multicast.c;h=f61eb2eff3fdd387b83d9fab642bb610dde1ad69;hb=HEAD#l1530)

I'm also attaching both a wireshark capture of the ignored IPv6
MLDv2 report and the working IGMPv3 report, which correspond
directly to the attached printk debug output.


I'm a little bit startled because I definitely had that part
working a couple of weeks ago and I'm still trying to figure out
what I might have changed in the setup. I definitely have updated
the VMs kernel, but the same issue is present for the 2.6.38 and
also 2.6.37 release versions with my fixes backported 
(the latter one was the one I had been using back then).
I probably have updated the multicast listener host's kernel, too,
I might have been running 2.6.32 or something more earlier... I've
also tried having the listener host in another VM with the same
2.6.38+ kernel as the bridge-snooping host, but also that did not
make a difference.


Anyways, skb_checksum_complete() is calculating the checksum from
skb's data to tail pointer, right?
RFC3810 for MLDv2, section 5.1.2 says:
"The standard ICMPv6 checksum; it covers the entire MLDv2 message,
plus a "pseudo-header" of IPv6 header fields [RFC2463]."
Could it be that this "pseudo-header" is not included in the
checksumming? Is there a function in the kernel which could
already provide that?
I guess that could also explain why it's working fine for IPv4,
there it's just the IGMP message being checksummed according to
RFC 3376, section 4.1.2.


Cheers, Linus


PS: There also seems to be another offset bug in the same
function, see comment in debug patch file, though seemingly
unrelated to the issue described above. Correcting that
len-variable does to help for the above issue. 

--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="br-mcast-snoop-printk-debug.log"

IPv6:
[ 2460.557303] +++ br_multicast_ipv6_rcv()
[ 2460.558114] +++ br_multicast_ipv6_rcv() here 0.5
[ 2460.558114] +++ br_multicast_ipv6_rcv() len: 36, offset: 48, skb_network_offset(skb2): 0
[ 2460.558114] +++ br_multicast_ipv6_rcv() new len: -12
[ 2460.558114] +++ br_multicast_ipv6_rcv() skb2->len: 28 len: -12 skb->len: 76
[ 2460.558114] +++ br_multicast_ipv6_rcv() here 1.5
[ 2460.558114] +++ br_multicast_ipv6_rcv() here 1.7, skb2->csum is 0
[ 2460.558114] +++ br_multicast_ipv6_rcv() here 1.8, skb_checksum_complete(skb2): 81e9 (skb): 2e60
[ 2464.981808] +++ br_multicast_ipv6_rcv()
[ 2464.982388] +++ br_multicast_ipv6_rcv() here 0.5
[ 2465.062634] +++ br_multicast_ipv6_rcv() len: 36, offset: 48, skb_network_offset(skb2): 0
[ 2465.066698] +++ br_multicast_ipv6_rcv() new len: -12
[ 2465.069183] +++ br_multicast_ipv6_rcv() skb2->len: 28 len: -12 skb->len: 76
[ 2465.072013] +++ br_multicast_ipv6_rcv() here 1.5
[ 2465.074217] +++ br_multicast_ipv6_rcv() here 1.7, skb2->csum is 0
[ 2465.076785] +++ br_multicast_ipv6_rcv() here 1.8, skb_checksum_complete(skb2): 81e9 (skb): 2e60

IPv4:
[ 2325.265830] +++ br_multicast_ipv4_rcv() skb2->len: 40 len: 40 skb->len: 40
[ 2325.266567] +++ br_multicast_ipv4_rcv() 2) skb2->len: 16 len: 16 skb->len: 16
[ 2325.266567] +++ br_multicast_ipv4_rcv() here 1.7, skb2->csum is 0
[ 2325.266567] +++ br_multicast_ipv4_rcv() here 1.8, skb_checksum_complete: 0
[ 2325.266567] +++ br_ip4_multicast_add_group() eth1 224.0.1.123
[ 2327.326179] +++ br_multicast_ipv4_rcv() skb2->len: 40 len: 40 skb->len: 40
[ 2327.326674] +++ br_multicast_ipv4_rcv() 2) skb2->len: 16 len: 16 skb->len: 16
[ 2327.326674] +++ br_multicast_ipv4_rcv() here 1.7, skb2->csum is 0
[ 2327.326674] +++ br_multicast_ipv4_rcv() here 1.8, skb_checksum_complete: 0
[ 2327.326674] +++ br_ip4_multicast_add_group() eth1 224.0.1.123

--IS0zKkzwUGydFO0o
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename="bridge-snoop-debug.patch"

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index f61eb2e..3d4c5d2 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -764,8 +764,11 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 {
 	struct br_ip br_group;
 
-	if (ipv4_is_local_multicast(group))
+printk("+++ br_ip4_multicast_add_group() %s %pI4\n", port->dev->name, &group);
+	if (ipv4_is_local_multicast(group)) {
+printk("+++ br_ip4_multicast_add_group() %s %pI4, is link local\n", port->dev->name, &group);
 		return 0;
+	}
 
 	br_group.u.ip4 = group;
 	br_group.proto = htons(ETH_P_IP);
@@ -780,8 +783,11 @@ static int br_ip6_multicast_add_group(struct net_bridge *br,
 {
 	struct br_ip br_group;
 
-	if (!ipv6_is_transient_multicast(group))
+printk("+++ br_ip6_multicast_add_group() %s %pI6\n", port->dev->name, group);
+	if (!ipv6_is_transient_multicast(group)) {
+printk("+++ br_ip6_multicast_add_group() %s %pI6, is not transient\n", port->dev->name, group);
 		return 0;
+	}
 
 	ipv6_addr_copy(&br_group.u.ip6, group);
 	br_group.proto = htons(ETH_P_IPV6);
@@ -1001,6 +1007,7 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 	int num;
 	int err = 0;
 
+printk("+++ br_ip6_multicast_mld2_report()\n");
 	if (!pskb_may_pull(skb, sizeof(*icmp6h)))
 		return -EINVAL;
 
@@ -1386,11 +1393,14 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	if (skb->len < len || len < ip_hdrlen(skb))
 		return -EINVAL;
 
+printk("+++ br_multicast_ipv4_rcv() skb2->len: %i len: %i skb->len: %i\n", skb2->len, len, skb->len);
 	if (skb->len > len) {
+printk("+++ br_multicast_ipv4_rcv() doing clone\n");
 		skb2 = skb_clone(skb, GFP_ATOMIC);
 		if (!skb2)
 			return -ENOMEM;
 
+printk("+++ br_multicast_ipv4_rcv() and pskb_trim_rcsum\n");
 		err = pskb_trim_rcsum(skb2, len);
 		if (err)
 			goto err_out;
@@ -1405,14 +1415,20 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	if (!pskb_may_pull(skb2, sizeof(*ih)))
 		goto out;
 
+printk("+++ br_multicast_ipv4_rcv() 2) skb2->len: %i len: %i skb->len: %i\n", skb2->len, len, skb->len);
 	switch (skb2->ip_summed) {
 	case CHECKSUM_COMPLETE:
+printk("+++ br_multicast_ipv4_rcv() here 1.6\n");
 		if (!csum_fold(skb2->csum))
 			break;
 		/* fall through */
 	case CHECKSUM_NONE:
+printk("+++ br_multicast_ipv4_rcv() here 1.7, skb2->csum is %x\n", skb2->csum);
+		__sum16 foobar;
 		skb2->csum = 0;
-		if (skb_checksum_complete(skb2))
+		foobar = skb_checksum_complete(skb2);
+printk("+++ br_multicast_ipv4_rcv() here 1.8, skb_checksum_complete: %x\n", foobar);
+		if (foobar)
 			goto out;
 	}
 
@@ -1459,6 +1475,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	int offset;
 	int err;
 
+printk("+++ br_multicast_ipv6_rcv()\n");
 	if (!pskb_may_pull(skb, sizeof(*ip6h)))
 		return -EINVAL;
 
@@ -1476,6 +1493,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 		return 0;
 
 	len = ntohs(ip6h->payload_len);
+//	len = ntohs(ip6h->payload_len) + sizeof(*ip6h); <- should probably be this?
 	if (skb->len < len)
 		return -EINVAL;
 
@@ -1485,6 +1503,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	if (offset < 0 || nexthdr != IPPROTO_ICMPV6)
 		return 0;
 
+printk("+++ br_multicast_ipv6_rcv() here 0.5\n");
 	/* Okay, we found ICMPv6 header */
 	skb2 = skb_clone(skb, GFP_ATOMIC);
 	if (!skb2)
@@ -1494,7 +1513,9 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	if (!pskb_may_pull(skb2, offset + sizeof(struct icmp6hdr)))
 		goto out;
 
+printk("+++ br_multicast_ipv6_rcv() len: %i, offset: %i, skb_network_offset(skb2): %i\n", len, offset, skb_network_offset(skb2));
 	len -= offset - skb_network_offset(skb2);
+printk("+++ br_multicast_ipv6_rcv() new len: %i\n", len);
 
 	__skb_pull(skb2, offset);
 	skb_reset_transport_header(skb2);
@@ -1513,27 +1534,37 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	}
 
 	/* Okay, we found MLD message. Check further. */
+printk("+++ br_multicast_ipv6_rcv() skb2->len: %i len: %i skb->len: %i\n", skb2->len, len, skb->len);
 	if (skb2->len > len) {
+printk("+++ br_multicast_ipv6_rcv() doing pskb_trim_rcsum\n");
 		err = pskb_trim_rcsum(skb2, len);
 		if (err)
 			goto out;
 	}
 
+printk("+++ br_multicast_ipv6_rcv() here 1.5\n");
 	switch (skb2->ip_summed) {
 	case CHECKSUM_COMPLETE:
+printk("+++ br_multicast_ipv6_rcv() here 1.6\n");
 		if (!csum_fold(skb2->csum))
 			break;
 		/*FALLTHROUGH*/
 	case CHECKSUM_NONE:
+printk("+++ br_multicast_ipv6_rcv() here 1.7, skb2->csum is %x\n", skb2->csum);
+		__sum16 foobar;
 		skb2->csum = 0;
-		if (skb_checksum_complete(skb2))
+		foobar = skb_checksum_complete(skb2);
+		if (foobar) {
+printk("+++ br_multicast_ipv6_rcv() here 1.8, skb_checksum_complete(skb2): %x (skb): %x\n", foobar, skb_checksum_complete(skb));
 			goto out;
+		}
 	}
 
 	err = 0;
 
 	BR_INPUT_SKB_CB(skb)->igmp = 1;
 
+printk("+++ br_multicast_ipv6_rcv() here 2\n");
 	switch (icmp6h->icmp6_type) {
 	case ICMPV6_MGM_REPORT:
 	    {

--IS0zKkzwUGydFO0o
Content-Type: application/cap
Content-Disposition: attachment; filename="ipv4-group-join.cap"
Content-Transfer-Encoding: base64

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAmaOOTYU/BgA2AAAANgAAAAEAXgAAFtZzBU0S0QgA
RsAAKAAAQAABAkHFwKgBjOAAABaUBAAAIgD4ggAAAAEEAAAA4AABe5ujjk0uKgcANgAAADYA
AAABAF4AABbWcwVNEtEIAEbAACgAAEAAAQJBxcCoAYzgAAAWlAQAACIA+IIAAAABBAAAAOAA
AXs=

--IS0zKkzwUGydFO0o
Content-Type: application/cap
Content-Disposition: attachment; filename="ipv6-group-join.cap"
Content-Transfer-Encoding: base64

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAIKSOTSm0CgBaAAAAWgAAADMzAAAAFtZzBU0S0Ybd
YAAAAAAkAAH+gAAAAAAAANRzBf/+TRLR/wIAAAAAAAAAAAAAAAAAFjoABQIAAAEAjwCDRQAA
AAEEAAAA/xIAAAAAAAAAAAAAAAABJCWkjk1R6gEAWgAAAFoAAAAzMwAAABbWcwVNEtGG3WAA
AAAAJAAB/oAAAAAAAADUcwX//k0S0f8CAAAAAAAAAAAAAAAAABY6AAUCAAABAI8Ag0UAAAAB
BAAAAP8SAAAAAAAAAAAAAAAAASQ=

--IS0zKkzwUGydFO0o--
