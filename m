From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the gfs2 tree with the net tree
Date: Mon, 27 Mar 2017 10:56:40 +1100
Message-ID: <20170327105640.699082ee@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Florian Westphal <fw@strlen.de>,
        Alexey Kodanev <alexey.kodanev@oracle.com>
To: Steven Whitehouse <swhiteho@redhat.com>,
        Bob Peterson <rpeterso@redhat.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the gfs2 tree got a conflict in:

  net/core/secure_seq.c

between commit:

  28ee1b746f49 ("secure_seq: downgrade to per-host timestamp offsets")

from the net tree and commit:

  a30aad50c26c ("tcp: rename *_sequence_number() to *_seq_and_tsoff()")

from the gfs2 and net-next trees.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/core/secure_seq.c
index d28da7d363f1,fb87e78a2cc7..000000000000
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@@ -47,25 -45,8 +47,25 @@@ static u32 seq_scale(u32 seq
  #endif
  
  #if IS_ENABLED(CONFIG_IPV6)
 +static u32 secure_tcpv6_ts_off(const __be32 *saddr, const __be32 *daddr)
 +{
 +	const struct {
 +		struct in6_addr saddr;
 +		struct in6_addr daddr;
 +	} __aligned(SIPHASH_ALIGNMENT) combined = {
 +		.saddr = *(struct in6_addr *)saddr,
 +		.daddr = *(struct in6_addr *)daddr,
 +	};
 +
 +	if (sysctl_tcp_timestamps != 1)
 +		return 0;
 +
 +	return siphash(&combined, offsetofend(typeof(combined), daddr),
 +		       &ts_secret);
 +}
 +
- u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
- 				 __be16 sport, __be16 dport, u32 *tsoff)
+ u32 secure_tcpv6_seq_and_tsoff(const __be32 *saddr, const __be32 *daddr,
+ 			       __be16 sport, __be16 dport, u32 *tsoff)
  {
  	const struct {
  		struct in6_addr saddr;
@@@ -82,10 -63,10 +82,10 @@@
  	net_secret_init();
  	hash = siphash(&combined, offsetofend(typeof(combined), dport),
  		       &net_secret);
 -	*tsoff = sysctl_tcp_timestamps == 1 ? (hash >> 32) : 0;
 +	*tsoff = secure_tcpv6_ts_off(saddr, daddr);
  	return seq_scale(hash);
  }
- EXPORT_SYMBOL(secure_tcpv6_sequence_number);
+ EXPORT_SYMBOL(secure_tcpv6_seq_and_tsoff);
  
  u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
  			       __be16 dport)
@@@ -107,16 -88,8 +107,16 @@@ EXPORT_SYMBOL(secure_ipv6_port_ephemera
  #endif
  
  #ifdef CONFIG_INET
 +static u32 secure_tcp_ts_off(__be32 saddr, __be32 daddr)
 +{
 +	if (sysctl_tcp_timestamps != 1)
 +		return 0;
 +
 +	return siphash_2u32((__force u32)saddr, (__force u32)daddr,
 +			    &ts_secret);
 +}
  
- /* secure_tcp_sequence_number(a, b, 0, d) == secure_ipv4_port_ephemeral(a, b, d),
+ /* secure_tcp_seq_and_tsoff(a, b, 0, d) == secure_ipv4_port_ephemeral(a, b, d),
   * but fortunately, `sport' cannot be 0 in any circumstances. If this changes,
   * it would be easy enough to have the former function use siphash_4u32, passing
   * the arguments as separate u32.
