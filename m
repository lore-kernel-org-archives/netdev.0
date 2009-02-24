From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/06: xt_recent: fix proc-file addition/removal of IPv4 addresses
Date: Tue, 24 Feb 2009 15:52:51 +0100 (MET)
Message-ID: <20090224145251.9789.74927.sendpatchset@x2.localnet>
References: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 325fb5b4d26038cba665dd0d8ee09555321061f0
Author: Josef Drexler <joe-lk@ttdpatch.net>
Date:   Tue Feb 24 14:53:12 2009 +0100

    netfilter: xt_recent: fix proc-file addition/removal of IPv4 addresses
    
    Fix regression introduded by commit 079aa88 (netfilter: xt_recent: IPv6 support):
    
    From http://bugzilla.kernel.org/show_bug.cgi?id=12753:
    
    Problem Description:
    An uninitialized buffer causes IPv4 addresses added manually (via the +IP
    command to the proc interface) to never match any packets. Similarly, the -IP
    command fails to remove IPv4 addresses.
    
    Details:
    In the function recent_entry_lookup, the xt_recent module does comparisons of
    the entire nf_inet_addr union value, both for IPv4 and IPv6 addresses. For
    addresses initialized from actual packets the remaining 12 bytes not occupied
    by the IPv4 are zeroed so this works correctly. However when setting the
    nf_inet_addr addr variable in the recent_mt_proc_write function, only the IPv4
    bytes are initialized and the remaining 12 bytes contain garbage.
    
    Hence addresses added in this way never match any packets, unless these
    uninitialized 12 bytes happened to be zero by coincidence. Similarly, addresses
    cannot consistently be removed using the proc interface due to mismatch of the
    garbage bytes (although it will sometimes work to remove an address that was
    added manually).
    
    Reading the /proc/net/xt_recent/ entries hides this problem because this only
    uses the first 4 bytes when displaying IPv4 addresses.
    
    Steps to reproduce:
    $ iptables -I INPUT -m recent --rcheck -j LOG
    $ echo +169.254.156.239 > /proc/net/xt_recent/DEFAULT
    $ cat /proc/net/xt_recent/DEFAULT
    src=169.254.156.239 ttl: 0 last_seen: 119910 oldest_pkt: 1 119910
    
    [At this point no packets from 169.254.156.239 are being logged.]
    
    $ iptables -I INPUT -s 169.254.156.239 -m recent --set
    $ cat /proc/net/xt_recent/DEFAULT
    src=169.254.156.239 ttl: 0 last_seen: 119910 oldest_pkt: 1 119910
    src=169.254.156.239 ttl: 255 last_seen: 126184 oldest_pkt: 4 125434, 125684, 125934, 126184
    
    [At this point, adding the address via an iptables rule, packets are being
    logged correctly.]
    
    $ echo -169.254.156.239 > /proc/net/xt_recent/DEFAULT
    $ cat /proc/net/xt_recent/DEFAULT
    src=169.254.156.239 ttl: 0 last_seen: 119910 oldest_pkt: 1 119910
    src=169.254.156.239 ttl: 255 last_seen: 126992 oldest_pkt: 10 125434, 125684, 125934, 126184, 126434, 126684, 126934, 126991, 126991, 126992
    $ echo -169.254.156.239 > /proc/net/xt_recent/DEFAULT
    $ cat /proc/net/xt_recent/DEFAULT
    src=169.254.156.239 ttl: 0 last_seen: 119910 oldest_pkt: 1 119910
    src=169.254.156.239 ttl: 255 last_seen: 126992 oldest_pkt: 10 125434, 125684, 125934, 126184, 126434, 126684, 126934, 126991, 126991, 126992
    
    [Removing the address via /proc interface failed evidently.]
    
    Possible solutions:
    - initialize the addr variable in recent_mt_proc_write
    - compare only 4 bytes for IPv4 addresses in recent_entry_lookup
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index fe80b61..791e030 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -542,7 +542,7 @@ recent_mt_proc_write(struct file *file, const char __user *input,
 	struct recent_entry *e;
 	char buf[sizeof("+b335:1d35:1e55:dead:c0de:1715:5afe:c0de")];
 	const char *c = buf;
-	union nf_inet_addr addr;
+	union nf_inet_addr addr = {};
 	u_int16_t family;
 	bool add, succ;
 
