From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 15/25] netfilter: nf_nat: support IPv6 in SIP NAT helper
Date: Tue, 04 Sep 2012 16:14:43 -0700
Message-ID: <87pq61qt24.fsf@xmission.com>
References: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
	<1346716452-3080-16-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1346716452-3080-16-git-send-email-pablo@netfilter.org>
	(pablo@netfilter.org's message of "Tue, 4 Sep 2012 01:54:02 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pablo@netfilter.org writes:

> From: Patrick McHardy <kaber@trash.net>
>
> Add IPv6 support to the SIP NAT helper. There are no functional differences
> to IPv4 NAT, just different formats for addresses.

Am I missing something here?  It looks like you are implementing port
translation for ipv6.

Simple address translation I can understand.  Especially when it
conforms to RFC6296 and doesn't need to look beyond the addresses and
doesn't even need to recompute checksums.

I can understand having a policy that explicitly manglees various
aspects of a packet as it comes through.  Sometimes people have weird
local policies and need to do weird and peculiar things.

I can understand connection tracking, and have no problems with
connection tracking as it does not get in the way of protocol evolution.

However this looks like full automatic address and port translation like
we have with ipv4.


I can't understand implementiong port translation for ipv6.  We don't
have a shortage of addresses, so there is no need to share addresses.


There has been a lot of work done with with protocol design and figuring
out how to work through NAT boxes.  One of the most complete
descriptions is in RFC5245 ICE.

Frequently protocol designers suggest that ALGs like this not be used
because they get in the way of protocol enhancements like ICE that
provide more general ways to work through the challenges.

RFC5245 can handle any kind of common NAT except both sides doing prefix
translation.  As long as one side can predict the port on the other side
of the NAT device ICE can successfully establish a connection.

Please tell me I am missing something and you are not generalizing code
that breaks protocols without any known work around?

Given that RFC5245 is strongly suggested if not required for ipv6 sip
support I really fail to see why generalizing the sip nat code from ipv4
to ipv6 makes a bit of sense.

RFC6314 "NAT Traversal Practices for Client-Server SIP" may be
interesting for more background on what people are implementing.

As a statement of how protocol designers feel about ALGs section
18.6 of RFC5245 is interesting:

   ICE works best through ALGs when the signaling is run over TLS.  This
   prevents the ALG from manipulating the SDP messages and interfering
   with ICE operation.  Implementations that are expected to be deployed
   behind ALGs SHOULD provide for TLS transport of the SDP.


So I am trying to understand how IPv6 ALGs make sense in general, as
IPv6 prefix translation is checksum neutral so they are in general
unneeded.  And how IPv6 ALGs for sip make sense as the protocol
maintainers report that best results are had without ALGs.
My own experiments confirm that ALGs are not needed for SIP if
you have ICE implementations on both sides.

What am I missing?

Eric


> Signed-off-by: Patrick McHardy <kaber@trash.net>
> ---
>  include/linux/netfilter/nf_conntrack_sip.h |    9 +-
>  net/ipv4/netfilter/Kconfig                 |    5 -
>  net/ipv4/netfilter/Makefile                |    1 -
>  net/ipv4/netfilter/nf_nat_sip.c            |  580 --------------------------
>  net/netfilter/Kconfig                      |    5 +
>  net/netfilter/Makefile                     |    1 +
>  net/netfilter/nf_conntrack_sip.c           |   68 ++--
>  net/netfilter/nf_nat_sip.c                 |  609 ++++++++++++++++++++++++++++
>  8 files changed, 653 insertions(+), 625 deletions(-)
>  delete mode 100644 net/ipv4/netfilter/nf_nat_sip.c
>  create mode 100644 net/netfilter/nf_nat_sip.c
>
> diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
> index 1afc669..387bdd0 100644
> --- a/include/linux/netfilter/nf_conntrack_sip.h
> +++ b/include/linux/netfilter/nf_conntrack_sip.h
> @@ -99,10 +99,8 @@ enum sip_header_types {
>  enum sdp_header_types {
>  	SDP_HDR_UNSPEC,
>  	SDP_HDR_VERSION,
> -	SDP_HDR_OWNER_IP4,
> -	SDP_HDR_CONNECTION_IP4,
> -	SDP_HDR_OWNER_IP6,
> -	SDP_HDR_CONNECTION_IP6,
> +	SDP_HDR_OWNER,
> +	SDP_HDR_CONNECTION,
>  	SDP_HDR_MEDIA,
>  };
>  
> @@ -111,7 +109,8 @@ extern unsigned int (*nf_nat_sip_hook)(struct sk_buff *skb,
>  				       unsigned int dataoff,
>  				       const char **dptr,
>  				       unsigned int *datalen);
> -extern void (*nf_nat_sip_seq_adjust_hook)(struct sk_buff *skb, s16 off);
> +extern void (*nf_nat_sip_seq_adjust_hook)(struct sk_buff *skb,
> +					  unsigned int protoff, s16 off);
>  extern unsigned int (*nf_nat_sip_expect_hook)(struct sk_buff *skb,
>  					      unsigned int protoff,
>  					      unsigned int dataoff,
> diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
> index 52c4a87..30197f8 100644
> --- a/net/ipv4/netfilter/Kconfig
> +++ b/net/ipv4/netfilter/Kconfig
> @@ -242,11 +242,6 @@ config NF_NAT_H323
>  	depends on NF_CONNTRACK && NF_NAT_IPV4
>  	default NF_NAT_IPV4 && NF_CONNTRACK_H323
>  
> -config NF_NAT_SIP
> -	tristate
> -	depends on NF_CONNTRACK && NF_NAT_IPV4
> -	default NF_NAT_IPV4 && NF_CONNTRACK_SIP
> -
>  # mangle + specific targets
>  config IP_NF_MANGLE
>  	tristate "Packet mangling"
> diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
> index 8baa496..8914abf 100644
> --- a/net/ipv4/netfilter/Makefile
> +++ b/net/ipv4/netfilter/Makefile
> @@ -23,7 +23,6 @@ obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
>  obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
>  obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
>  obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
> -obj-$(CONFIG_NF_NAT_SIP) += nf_nat_sip.o
>  obj-$(CONFIG_NF_NAT_SNMP_BASIC) += nf_nat_snmp_basic.o
>  obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
>  
> diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
> deleted file mode 100644
> index 47a4718..0000000
> --- a/net/ipv4/netfilter/nf_nat_sip.c
> +++ /dev/null
> @@ -1,580 +0,0 @@
> -/* SIP extension for NAT alteration.
> - *
> - * (C) 2005 by Christian Hentschel <chentschel@arnet.com.ar>
> - * based on RR's ip_nat_ftp.c and other modules.
> - * (C) 2007 United Security Providers
> - * (C) 2007, 2008 Patrick McHardy <kaber@trash.net>
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 as
> - * published by the Free Software Foundation.
> - */
> -
> -#include <linux/module.h>
> -#include <linux/skbuff.h>
> -#include <linux/ip.h>
> -#include <net/ip.h>
> -#include <linux/udp.h>
> -#include <linux/tcp.h>
> -
> -#include <net/netfilter/nf_nat.h>
> -#include <net/netfilter/nf_nat_helper.h>
> -#include <net/netfilter/nf_conntrack_helper.h>
> -#include <net/netfilter/nf_conntrack_expect.h>
> -#include <linux/netfilter/nf_conntrack_sip.h>
> -
> -MODULE_LICENSE("GPL");
> -MODULE_AUTHOR("Christian Hentschel <chentschel@arnet.com.ar>");
> -MODULE_DESCRIPTION("SIP NAT helper");
> -MODULE_ALIAS("ip_nat_sip");
> -
> -
> -static unsigned int mangle_packet(struct sk_buff *skb, unsigned int protoff,
> -				  unsigned int dataoff,
> -				  const char **dptr, unsigned int *datalen,
> -				  unsigned int matchoff, unsigned int matchlen,
> -				  const char *buffer, unsigned int buflen)
> -{
> -	enum ip_conntrack_info ctinfo;
> -	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> -	struct tcphdr *th;
> -	unsigned int baseoff;
> -
> -	if (nf_ct_protonum(ct) == IPPROTO_TCP) {
> -		th = (struct tcphdr *)(skb->data + ip_hdrlen(skb));
> -		baseoff = ip_hdrlen(skb) + th->doff * 4;
> -		matchoff += dataoff - baseoff;
> -
> -		if (!__nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
> -						protoff, matchoff, matchlen,
> -						buffer, buflen, false))
> -			return 0;
> -	} else {
> -		baseoff = ip_hdrlen(skb) + sizeof(struct udphdr);
> -		matchoff += dataoff - baseoff;
> -
> -		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo,
> -					      protoff, matchoff, matchlen,
> -					      buffer, buflen))
> -			return 0;
> -	}
> -
> -	/* Reload data pointer and adjust datalen value */
> -	*dptr = skb->data + dataoff;
> -	*datalen += buflen - matchlen;
> -	return 1;
> -}
> -
> -static int map_addr(struct sk_buff *skb, unsigned int protoff,
> -		    unsigned int dataoff,
> -		    const char **dptr, unsigned int *datalen,
> -		    unsigned int matchoff, unsigned int matchlen,
> -		    union nf_inet_addr *addr, __be16 port)
> -{
> -	enum ip_conntrack_info ctinfo;
> -	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> -	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
> -	char buffer[sizeof("nnn.nnn.nnn.nnn:nnnnn")];
> -	unsigned int buflen;
> -	__be32 newaddr;
> -	__be16 newport;
> -
> -	if (ct->tuplehash[dir].tuple.src.u3.ip == addr->ip &&
> -	    ct->tuplehash[dir].tuple.src.u.udp.port == port) {
> -		newaddr = ct->tuplehash[!dir].tuple.dst.u3.ip;
> -		newport = ct->tuplehash[!dir].tuple.dst.u.udp.port;
> -	} else if (ct->tuplehash[dir].tuple.dst.u3.ip == addr->ip &&
> -		   ct->tuplehash[dir].tuple.dst.u.udp.port == port) {
> -		newaddr = ct->tuplehash[!dir].tuple.src.u3.ip;
> -		newport = ct->tuplehash[!dir].tuple.src.u.udp.port;
> -	} else
> -		return 1;
> -
> -	if (newaddr == addr->ip && newport == port)
> -		return 1;
> -
> -	buflen = sprintf(buffer, "%pI4:%u", &newaddr, ntohs(newport));
> -
> -	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
> -			     matchoff, matchlen, buffer, buflen);
> -}
> -
> -static int map_sip_addr(struct sk_buff *skb, unsigned int protoff,
> -			unsigned int dataoff,
> -			const char **dptr, unsigned int *datalen,
> -			enum sip_header_types type)
> -{
> -	enum ip_conntrack_info ctinfo;
> -	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> -	unsigned int matchlen, matchoff;
> -	union nf_inet_addr addr;
> -	__be16 port;
> -
> -	if (ct_sip_parse_header_uri(ct, *dptr, NULL, *datalen, type, NULL,
> -				    &matchoff, &matchlen, &addr, &port) <= 0)
> -		return 1;
> -	return map_addr(skb, protoff, dataoff, dptr, datalen,
> -			matchoff, matchlen, &addr, port);
> -}
> -
> -static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int protoff,
> -			       unsigned int dataoff,
> -			       const char **dptr, unsigned int *datalen)
> -{
> -	enum ip_conntrack_info ctinfo;
> -	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> -	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
> -	unsigned int coff, matchoff, matchlen;
> -	enum sip_header_types hdr;
> -	union nf_inet_addr addr;
> -	__be16 port;
> -	int request, in_header;
> -
> -	/* Basic rules: requests and responses. */
> -	if (strnicmp(*dptr, "SIP/2.0", strlen("SIP/2.0")) != 0) {
> -		if (ct_sip_parse_request(ct, *dptr, *datalen,
> -					 &matchoff, &matchlen,
> -					 &addr, &port) > 0 &&
> -		    !map_addr(skb, protoff, dataoff, dptr, datalen,
> -			      matchoff, matchlen, &addr, port))
> -			return NF_DROP;
> -		request = 1;
> -	} else
> -		request = 0;
> -
> -	if (nf_ct_protonum(ct) == IPPROTO_TCP)
> -		hdr = SIP_HDR_VIA_TCP;
> -	else
> -		hdr = SIP_HDR_VIA_UDP;
> -
> -	/* Translate topmost Via header and parameters */
> -	if (ct_sip_parse_header_uri(ct, *dptr, NULL, *datalen,
> -				    hdr, NULL, &matchoff, &matchlen,
> -				    &addr, &port) > 0) {
> -		unsigned int olen, matchend, poff, plen, buflen, n;
> -		char buffer[sizeof("nnn.nnn.nnn.nnn:nnnnn")];
> -
> -		/* We're only interested in headers related to this
> -		 * connection */
> -		if (request) {
> -			if (addr.ip != ct->tuplehash[dir].tuple.src.u3.ip ||
> -			    port != ct->tuplehash[dir].tuple.src.u.udp.port)
> -				goto next;
> -		} else {
> -			if (addr.ip != ct->tuplehash[dir].tuple.dst.u3.ip ||
> -			    port != ct->tuplehash[dir].tuple.dst.u.udp.port)
> -				goto next;
> -		}
> -
> -		olen = *datalen;
> -		if (!map_addr(skb, protoff, dataoff, dptr, datalen,
> -			      matchoff, matchlen, &addr, port))
> -			return NF_DROP;
> -
> -		matchend = matchoff + matchlen + *datalen - olen;
> -
> -		/* The maddr= parameter (RFC 2361) specifies where to send
> -		 * the reply. */
> -		if (ct_sip_parse_address_param(ct, *dptr, matchend, *datalen,
> -					       "maddr=", &poff, &plen,
> -					       &addr, true) > 0 &&
> -		    addr.ip == ct->tuplehash[dir].tuple.src.u3.ip &&
> -		    addr.ip != ct->tuplehash[!dir].tuple.dst.u3.ip) {
> -			buflen = sprintf(buffer, "%pI4",
> -					&ct->tuplehash[!dir].tuple.dst.u3.ip);
> -			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
> -					   poff, plen, buffer, buflen))
> -				return NF_DROP;
> -		}
> -
> -		/* The received= parameter (RFC 2361) contains the address
> -		 * from which the server received the request. */
> -		if (ct_sip_parse_address_param(ct, *dptr, matchend, *datalen,
> -					       "received=", &poff, &plen,
> -					       &addr, false) > 0 &&
> -		    addr.ip == ct->tuplehash[dir].tuple.dst.u3.ip &&
> -		    addr.ip != ct->tuplehash[!dir].tuple.src.u3.ip) {
> -			buflen = sprintf(buffer, "%pI4",
> -					&ct->tuplehash[!dir].tuple.src.u3.ip);
> -			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
> -					   poff, plen, buffer, buflen))
> -				return NF_DROP;
> -		}
> -
> -		/* The rport= parameter (RFC 3581) contains the port number
> -		 * from which the server received the request. */
> -		if (ct_sip_parse_numerical_param(ct, *dptr, matchend, *datalen,
> -						 "rport=", &poff, &plen,
> -						 &n) > 0 &&
> -		    htons(n) == ct->tuplehash[dir].tuple.dst.u.udp.port &&
> -		    htons(n) != ct->tuplehash[!dir].tuple.src.u.udp.port) {
> -			__be16 p = ct->tuplehash[!dir].tuple.src.u.udp.port;
> -			buflen = sprintf(buffer, "%u", ntohs(p));
> -			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
> -					   poff, plen, buffer, buflen))
> -				return NF_DROP;
> -		}
> -	}
> -
> -next:
> -	/* Translate Contact headers */
> -	coff = 0;
> -	in_header = 0;
> -	while (ct_sip_parse_header_uri(ct, *dptr, &coff, *datalen,
> -				       SIP_HDR_CONTACT, &in_header,
> -				       &matchoff, &matchlen,
> -				       &addr, &port) > 0) {
> -		if (!map_addr(skb, protoff, dataoff, dptr, datalen,
> -			      matchoff, matchlen,
> -			      &addr, port))
> -			return NF_DROP;
> -	}
> -
> -	if (!map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_FROM) ||
> -	    !map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_TO))
> -		return NF_DROP;
> -
> -	return NF_ACCEPT;
> -}
> -
> -static void ip_nat_sip_seq_adjust(struct sk_buff *skb, s16 off)
> -{
> -	enum ip_conntrack_info ctinfo;
> -	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> -	const struct tcphdr *th;
> -
> -	if (nf_ct_protonum(ct) != IPPROTO_TCP || off == 0)
> -		return;
> -
> -	th = (struct tcphdr *)(skb->data + ip_hdrlen(skb));
> -	nf_nat_set_seq_adjust(ct, ctinfo, th->seq, off);
> -}
> -
> -/* Handles expected signalling connections and media streams */
> -static void ip_nat_sip_expected(struct nf_conn *ct,
> -				struct nf_conntrack_expect *exp)
> -{
> -	struct nf_nat_range range;
> -
> -	/* This must be a fresh one. */
> -	BUG_ON(ct->status & IPS_NAT_DONE_MASK);
> -
> -	/* For DST manip, map port here to where it's expected. */
> -	range.flags = (NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED);
> -	range.min_proto = range.max_proto = exp->saved_proto;
> -	range.min_addr = range.max_addr = exp->saved_addr;
> -	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_DST);
> -
> -	/* Change src to where master sends to, but only if the connection
> -	 * actually came from the same source. */
> -	if (ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip ==
> -	    ct->master->tuplehash[exp->dir].tuple.src.u3.ip) {
> -		range.flags = NF_NAT_RANGE_MAP_IPS;
> -		range.min_addr = range.max_addr
> -			= ct->master->tuplehash[!exp->dir].tuple.dst.u3;
> -		nf_nat_setup_info(ct, &range, NF_NAT_MANIP_SRC);
> -	}
> -}
> -
> -static unsigned int ip_nat_sip_expect(struct sk_buff *skb, unsigned int protoff,
> -				      unsigned int dataoff,
> -				      const char **dptr, unsigned int *datalen,
> -				      struct nf_conntrack_expect *exp,
> -				      unsigned int matchoff,
> -				      unsigned int matchlen)
> -{
> -	enum ip_conntrack_info ctinfo;
> -	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> -	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
> -	__be32 newip;
> -	u_int16_t port;
> -	char buffer[sizeof("nnn.nnn.nnn.nnn:nnnnn")];
> -	unsigned int buflen;
> -
> -	/* Connection will come from reply */
> -	if (ct->tuplehash[dir].tuple.src.u3.ip == ct->tuplehash[!dir].tuple.dst.u3.ip)
> -		newip = exp->tuple.dst.u3.ip;
> -	else
> -		newip = ct->tuplehash[!dir].tuple.dst.u3.ip;
> -
> -	/* If the signalling port matches the connection's source port in the
> -	 * original direction, try to use the destination port in the opposite
> -	 * direction. */
> -	if (exp->tuple.dst.u.udp.port ==
> -	    ct->tuplehash[dir].tuple.src.u.udp.port)
> -		port = ntohs(ct->tuplehash[!dir].tuple.dst.u.udp.port);
> -	else
> -		port = ntohs(exp->tuple.dst.u.udp.port);
> -
> -	exp->saved_addr = exp->tuple.dst.u3;
> -	exp->tuple.dst.u3.ip = newip;
> -	exp->saved_proto.udp.port = exp->tuple.dst.u.udp.port;
> -	exp->dir = !dir;
> -	exp->expectfn = ip_nat_sip_expected;
> -
> -	for (; port != 0; port++) {
> -		int ret;
> -
> -		exp->tuple.dst.u.udp.port = htons(port);
> -		ret = nf_ct_expect_related(exp);
> -		if (ret == 0)
> -			break;
> -		else if (ret != -EBUSY) {
> -			port = 0;
> -			break;
> -		}
> -	}
> -
> -	if (port == 0)
> -		return NF_DROP;
> -
> -	if (exp->tuple.dst.u3.ip != exp->saved_addr.ip ||
> -	    exp->tuple.dst.u.udp.port != exp->saved_proto.udp.port) {
> -		buflen = sprintf(buffer, "%pI4:%u", &newip, port);
> -		if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
> -				   matchoff, matchlen, buffer, buflen))
> -			goto err;
> -	}
> -	return NF_ACCEPT;
> -
> -err:
> -	nf_ct_unexpect_related(exp);
> -	return NF_DROP;
> -}
> -
> -static int mangle_content_len(struct sk_buff *skb, unsigned int protoff,
> -			      unsigned int dataoff,
> -			      const char **dptr, unsigned int *datalen)
> -{
> -	enum ip_conntrack_info ctinfo;
> -	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> -	unsigned int matchoff, matchlen;
> -	char buffer[sizeof("65536")];
> -	int buflen, c_len;
> -
> -	/* Get actual SDP length */
> -	if (ct_sip_get_sdp_header(ct, *dptr, 0, *datalen,
> -				  SDP_HDR_VERSION, SDP_HDR_UNSPEC,
> -				  &matchoff, &matchlen) <= 0)
> -		return 0;
> -	c_len = *datalen - matchoff + strlen("v=");
> -
> -	/* Now, update SDP length */
> -	if (ct_sip_get_header(ct, *dptr, 0, *datalen, SIP_HDR_CONTENT_LENGTH,
> -			      &matchoff, &matchlen) <= 0)
> -		return 0;
> -
> -	buflen = sprintf(buffer, "%u", c_len);
> -	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
> -			     matchoff, matchlen, buffer, buflen);
> -}
> -
> -static int mangle_sdp_packet(struct sk_buff *skb, unsigned int protoff,
> -			     unsigned int dataoff,
> -			     const char **dptr, unsigned int *datalen,
> -			     unsigned int sdpoff,
> -			     enum sdp_header_types type,
> -			     enum sdp_header_types term,
> -			     char *buffer, int buflen)
> -{
> -	enum ip_conntrack_info ctinfo;
> -	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> -	unsigned int matchlen, matchoff;
> -
> -	if (ct_sip_get_sdp_header(ct, *dptr, sdpoff, *datalen, type, term,
> -				  &matchoff, &matchlen) <= 0)
> -		return -ENOENT;
> -	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
> -			     matchoff, matchlen, buffer, buflen) ? 0 : -EINVAL;
> -}
> -
> -static unsigned int ip_nat_sdp_addr(struct sk_buff *skb, unsigned int protoff,
> -				    unsigned int dataoff,
> -				    const char **dptr, unsigned int *datalen,
> -				    unsigned int sdpoff,
> -				    enum sdp_header_types type,
> -				    enum sdp_header_types term,
> -				    const union nf_inet_addr *addr)
> -{
> -	char buffer[sizeof("nnn.nnn.nnn.nnn")];
> -	unsigned int buflen;
> -
> -	buflen = sprintf(buffer, "%pI4", &addr->ip);
> -	if (mangle_sdp_packet(skb, protoff, dataoff, dptr, datalen,
> -			      sdpoff, type, term, buffer, buflen))
> -		return 0;
> -
> -	return mangle_content_len(skb, protoff, dataoff, dptr, datalen);
> -}
> -
> -static unsigned int ip_nat_sdp_port(struct sk_buff *skb, unsigned int protoff,
> -				    unsigned int dataoff,
> -				    const char **dptr, unsigned int *datalen,
> -				    unsigned int matchoff,
> -				    unsigned int matchlen,
> -				    u_int16_t port)
> -{
> -	char buffer[sizeof("nnnnn")];
> -	unsigned int buflen;
> -
> -	buflen = sprintf(buffer, "%u", port);
> -	if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
> -			   matchoff, matchlen, buffer, buflen))
> -		return 0;
> -
> -	return mangle_content_len(skb, protoff, dataoff, dptr, datalen);
> -}
> -
> -static unsigned int ip_nat_sdp_session(struct sk_buff *skb, unsigned int protoff,
> -				       unsigned int dataoff,
> -				       const char **dptr, unsigned int *datalen,
> -				       unsigned int sdpoff,
> -				       const union nf_inet_addr *addr)
> -{
> -	char buffer[sizeof("nnn.nnn.nnn.nnn")];
> -	unsigned int buflen;
> -
> -	/* Mangle session description owner and contact addresses */
> -	buflen = sprintf(buffer, "%pI4", &addr->ip);
> -	if (mangle_sdp_packet(skb, protoff, dataoff, dptr, datalen, sdpoff,
> -			       SDP_HDR_OWNER_IP4, SDP_HDR_MEDIA,
> -			       buffer, buflen))
> -		return 0;
> -
> -	switch (mangle_sdp_packet(skb, protoff, dataoff, dptr, datalen, sdpoff,
> -				  SDP_HDR_CONNECTION_IP4, SDP_HDR_MEDIA,
> -				  buffer, buflen)) {
> -	case 0:
> -	/*
> -	 * RFC 2327:
> -	 *
> -	 * Session description
> -	 *
> -	 * c=* (connection information - not required if included in all media)
> -	 */
> -	case -ENOENT:
> -		break;
> -	default:
> -		return 0;
> -	}
> -
> -	return mangle_content_len(skb, protoff, dataoff, dptr, datalen);
> -}
> -
> -/* So, this packet has hit the connection tracking matching code.
> -   Mangle it, and change the expectation to match the new version. */
> -static unsigned int ip_nat_sdp_media(struct sk_buff *skb, unsigned int protoff,
> -				     unsigned int dataoff,
> -				     const char **dptr, unsigned int *datalen,
> -				     struct nf_conntrack_expect *rtp_exp,
> -				     struct nf_conntrack_expect *rtcp_exp,
> -				     unsigned int mediaoff,
> -				     unsigned int medialen,
> -				     union nf_inet_addr *rtp_addr)
> -{
> -	enum ip_conntrack_info ctinfo;
> -	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> -	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
> -	u_int16_t port;
> -
> -	/* Connection will come from reply */
> -	if (ct->tuplehash[dir].tuple.src.u3.ip ==
> -	    ct->tuplehash[!dir].tuple.dst.u3.ip)
> -		rtp_addr->ip = rtp_exp->tuple.dst.u3.ip;
> -	else
> -		rtp_addr->ip = ct->tuplehash[!dir].tuple.dst.u3.ip;
> -
> -	rtp_exp->saved_addr = rtp_exp->tuple.dst.u3;
> -	rtp_exp->tuple.dst.u3.ip = rtp_addr->ip;
> -	rtp_exp->saved_proto.udp.port = rtp_exp->tuple.dst.u.udp.port;
> -	rtp_exp->dir = !dir;
> -	rtp_exp->expectfn = ip_nat_sip_expected;
> -
> -	rtcp_exp->saved_addr = rtcp_exp->tuple.dst.u3;
> -	rtcp_exp->tuple.dst.u3.ip = rtp_addr->ip;
> -	rtcp_exp->saved_proto.udp.port = rtcp_exp->tuple.dst.u.udp.port;
> -	rtcp_exp->dir = !dir;
> -	rtcp_exp->expectfn = ip_nat_sip_expected;
> -
> -	/* Try to get same pair of ports: if not, try to change them. */
> -	for (port = ntohs(rtp_exp->tuple.dst.u.udp.port);
> -	     port != 0; port += 2) {
> -		int ret;
> -
> -		rtp_exp->tuple.dst.u.udp.port = htons(port);
> -		ret = nf_ct_expect_related(rtp_exp);
> -		if (ret == -EBUSY)
> -			continue;
> -		else if (ret < 0) {
> -			port = 0;
> -			break;
> -		}
> -		rtcp_exp->tuple.dst.u.udp.port = htons(port + 1);
> -		ret = nf_ct_expect_related(rtcp_exp);
> -		if (ret == 0)
> -			break;
> -		else if (ret != -EBUSY) {
> -			nf_ct_unexpect_related(rtp_exp);
> -			port = 0;
> -			break;
> -		}
> -	}
> -
> -	if (port == 0)
> -		goto err1;
> -
> -	/* Update media port. */
> -	if (rtp_exp->tuple.dst.u.udp.port != rtp_exp->saved_proto.udp.port &&
> -	    !ip_nat_sdp_port(skb, protoff, dataoff, dptr, datalen,
> -			     mediaoff, medialen, port))
> -		goto err2;
> -
> -	return NF_ACCEPT;
> -
> -err2:
> -	nf_ct_unexpect_related(rtp_exp);
> -	nf_ct_unexpect_related(rtcp_exp);
> -err1:
> -	return NF_DROP;
> -}
> -
> -static struct nf_ct_helper_expectfn sip_nat = {
> -        .name           = "sip",
> -        .expectfn       = ip_nat_sip_expected,
> -};
> -
> -static void __exit nf_nat_sip_fini(void)
> -{
> -	RCU_INIT_POINTER(nf_nat_sip_hook, NULL);
> -	RCU_INIT_POINTER(nf_nat_sip_seq_adjust_hook, NULL);
> -	RCU_INIT_POINTER(nf_nat_sip_expect_hook, NULL);
> -	RCU_INIT_POINTER(nf_nat_sdp_addr_hook, NULL);
> -	RCU_INIT_POINTER(nf_nat_sdp_port_hook, NULL);
> -	RCU_INIT_POINTER(nf_nat_sdp_session_hook, NULL);
> -	RCU_INIT_POINTER(nf_nat_sdp_media_hook, NULL);
> -	nf_ct_helper_expectfn_unregister(&sip_nat);
> -	synchronize_rcu();
> -}
> -
> -static int __init nf_nat_sip_init(void)
> -{
> -	BUG_ON(nf_nat_sip_hook != NULL);
> -	BUG_ON(nf_nat_sip_seq_adjust_hook != NULL);
> -	BUG_ON(nf_nat_sip_expect_hook != NULL);
> -	BUG_ON(nf_nat_sdp_addr_hook != NULL);
> -	BUG_ON(nf_nat_sdp_port_hook != NULL);
> -	BUG_ON(nf_nat_sdp_session_hook != NULL);
> -	BUG_ON(nf_nat_sdp_media_hook != NULL);
> -	RCU_INIT_POINTER(nf_nat_sip_hook, ip_nat_sip);
> -	RCU_INIT_POINTER(nf_nat_sip_seq_adjust_hook, ip_nat_sip_seq_adjust);
> -	RCU_INIT_POINTER(nf_nat_sip_expect_hook, ip_nat_sip_expect);
> -	RCU_INIT_POINTER(nf_nat_sdp_addr_hook, ip_nat_sdp_addr);
> -	RCU_INIT_POINTER(nf_nat_sdp_port_hook, ip_nat_sdp_port);
> -	RCU_INIT_POINTER(nf_nat_sdp_session_hook, ip_nat_sdp_session);
> -	RCU_INIT_POINTER(nf_nat_sdp_media_hook, ip_nat_sdp_media);
> -	nf_ct_helper_expectfn_register(&sip_nat);
> -	return 0;
> -}
> -
> -module_init(nf_nat_sip_init);
> -module_exit(nf_nat_sip_fini);
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index 2eee9f1..bf3e464 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -390,6 +390,11 @@ config NF_NAT_FTP
>  	depends on NF_CONNTRACK && NF_NAT
>  	default NF_NAT && NF_CONNTRACK_FTP
>  
> +config NF_NAT_SIP
> +	tristate
> +	depends on NF_CONNTRACK && NF_NAT
> +	default NF_NAT && NF_CONNTRACK_SIP
> +
>  endif # NF_CONNTRACK
>  
>  # transparent proxy support
> diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> index 7d6e1ea..7d6d1a0 100644
> --- a/net/netfilter/Makefile
> +++ b/net/netfilter/Makefile
> @@ -57,6 +57,7 @@ obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
>  # NAT helpers
>  obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
>  obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
> +obj-$(CONFIG_NF_NAT_SIP) += nf_nat_sip.o
>  
>  # transparent proxy support
>  obj-$(CONFIG_NETFILTER_TPROXY) += nf_tproxy_core.o
> diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
> index d517490..df8f4f2 100644
> --- a/net/netfilter/nf_conntrack_sip.c
> +++ b/net/netfilter/nf_conntrack_sip.c
> @@ -57,7 +57,8 @@ unsigned int (*nf_nat_sip_hook)(struct sk_buff *skb, unsigned int protoff,
>  				unsigned int *datalen) __read_mostly;
>  EXPORT_SYMBOL_GPL(nf_nat_sip_hook);
>  
> -void (*nf_nat_sip_seq_adjust_hook)(struct sk_buff *skb, s16 off) __read_mostly;
> +void (*nf_nat_sip_seq_adjust_hook)(struct sk_buff *skb, unsigned int protoff,
> +				   s16 off) __read_mostly;
>  EXPORT_SYMBOL_GPL(nf_nat_sip_seq_adjust_hook);
>  
>  unsigned int (*nf_nat_sip_expect_hook)(struct sk_buff *skb,
> @@ -742,13 +743,18 @@ static int sdp_addr_len(const struct nf_conn *ct, const char *dptr,
>   * be tolerant and also accept records terminated with a single newline
>   * character". We handle both cases.
>   */
> -static const struct sip_header ct_sdp_hdrs[] = {
> -	[SDP_HDR_VERSION]		= SDP_HDR("v=", NULL, digits_len),
> -	[SDP_HDR_OWNER_IP4]		= SDP_HDR("o=", "IN IP4 ", sdp_addr_len),
> -	[SDP_HDR_CONNECTION_IP4]	= SDP_HDR("c=", "IN IP4 ", sdp_addr_len),
> -	[SDP_HDR_OWNER_IP6]		= SDP_HDR("o=", "IN IP6 ", sdp_addr_len),
> -	[SDP_HDR_CONNECTION_IP6]	= SDP_HDR("c=", "IN IP6 ", sdp_addr_len),
> -	[SDP_HDR_MEDIA]			= SDP_HDR("m=", NULL, media_len),
> +static const struct sip_header ct_sdp_hdrs_v4[] = {
> +	[SDP_HDR_VERSION]	= SDP_HDR("v=", NULL, digits_len),
> +	[SDP_HDR_OWNER]		= SDP_HDR("o=", "IN IP4 ", sdp_addr_len),
> +	[SDP_HDR_CONNECTION]	= SDP_HDR("c=", "IN IP4 ", sdp_addr_len),
> +	[SDP_HDR_MEDIA]		= SDP_HDR("m=", NULL, media_len),
> +};
> +
> +static const struct sip_header ct_sdp_hdrs_v6[] = {
> +	[SDP_HDR_VERSION]	= SDP_HDR("v=", NULL, digits_len),
> +	[SDP_HDR_OWNER]		= SDP_HDR("o=", "IN IP6 ", sdp_addr_len),
> +	[SDP_HDR_CONNECTION]	= SDP_HDR("c=", "IN IP6 ", sdp_addr_len),
> +	[SDP_HDR_MEDIA]		= SDP_HDR("m=", NULL, media_len),
>  };
>  
>  /* Linear string search within SDP header values */
> @@ -774,11 +780,14 @@ int ct_sip_get_sdp_header(const struct nf_conn *ct, const char *dptr,
>  			  enum sdp_header_types term,
>  			  unsigned int *matchoff, unsigned int *matchlen)
>  {
> -	const struct sip_header *hdr = &ct_sdp_hdrs[type];
> -	const struct sip_header *thdr = &ct_sdp_hdrs[term];
> +	const struct sip_header *hdrs, *hdr, *thdr;
>  	const char *start = dptr, *limit = dptr + datalen;
>  	int shift = 0;
>  
> +	hdrs = nf_ct_l3num(ct) == NFPROTO_IPV4 ? ct_sdp_hdrs_v4 : ct_sdp_hdrs_v6;
> +	hdr = &hdrs[type];
> +	thdr = &hdrs[term];
> +
>  	for (dptr += dataoff; dptr < limit; dptr++) {
>  		/* Find beginning of line */
>  		if (*dptr != '\r' && *dptr != '\n')
> @@ -945,12 +954,12 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
>  		    exp->class != class)
>  			break;
>  #ifdef CONFIG_NF_NAT_NEEDED
> -		if (exp->tuple.src.l3num == AF_INET && !direct_rtp &&
> -		    (exp->saved_addr.ip != exp->tuple.dst.u3.ip ||
> +		if (!direct_rtp &&
> +		    (!nf_inet_addr_cmp(&exp->saved_addr, &exp->tuple.dst.u3) ||
>  		     exp->saved_proto.udp.port != exp->tuple.dst.u.udp.port) &&
>  		    ct->status & IPS_NAT_MASK) {
> -			daddr->ip		= exp->saved_addr.ip;
> -			tuple.dst.u3.ip		= exp->saved_addr.ip;
> +			*daddr			= exp->saved_addr;
> +			tuple.dst.u3		= exp->saved_addr;
>  			tuple.dst.u.udp.port	= exp->saved_proto.udp.port;
>  			direct_rtp = 1;
>  		} else
> @@ -987,8 +996,7 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
>  			  IPPROTO_UDP, NULL, &rtcp_port);
>  
>  	nf_nat_sdp_media = rcu_dereference(nf_nat_sdp_media_hook);
> -	if (nf_nat_sdp_media && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
> -	    ct->status & IPS_NAT_MASK && !direct_rtp)
> +	if (nf_nat_sdp_media && ct->status & IPS_NAT_MASK && !direct_rtp)
>  		ret = nf_nat_sdp_media(skb, protoff, dataoff, dptr, datalen,
>  				       rtp_exp, rtcp_exp,
>  				       mediaoff, medialen, daddr);
> @@ -1044,15 +1052,12 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
>  	unsigned int i;
>  	union nf_inet_addr caddr, maddr, rtp_addr;
>  	unsigned int port;
> -	enum sdp_header_types c_hdr;
>  	const struct sdp_media_type *t;
>  	int ret = NF_ACCEPT;
>  	typeof(nf_nat_sdp_addr_hook) nf_nat_sdp_addr;
>  	typeof(nf_nat_sdp_session_hook) nf_nat_sdp_session;
>  
>  	nf_nat_sdp_addr = rcu_dereference(nf_nat_sdp_addr_hook);
> -	c_hdr = nf_ct_l3num(ct) == AF_INET ? SDP_HDR_CONNECTION_IP4 :
> -					     SDP_HDR_CONNECTION_IP6;
>  
>  	/* Find beginning of session description */
>  	if (ct_sip_get_sdp_header(ct, *dptr, 0, *datalen,
> @@ -1066,7 +1071,7 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
>  	 * the end of the session description. */
>  	caddr_len = 0;
>  	if (ct_sip_parse_sdp_addr(ct, *dptr, sdpoff, *datalen,
> -				  c_hdr, SDP_HDR_MEDIA,
> +				  SDP_HDR_CONNECTION, SDP_HDR_MEDIA,
>  				  &matchoff, &matchlen, &caddr) > 0)
>  		caddr_len = matchlen;
>  
> @@ -1096,7 +1101,7 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
>  		/* The media description overrides the session description. */
>  		maddr_len = 0;
>  		if (ct_sip_parse_sdp_addr(ct, *dptr, mediaoff, *datalen,
> -					  c_hdr, SDP_HDR_MEDIA,
> +					  SDP_HDR_CONNECTION, SDP_HDR_MEDIA,
>  					  &matchoff, &matchlen, &maddr) > 0) {
>  			maddr_len = matchlen;
>  			memcpy(&rtp_addr, &maddr, sizeof(rtp_addr));
> @@ -1113,11 +1118,10 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
>  			return ret;
>  
>  		/* Update media connection address if present */
> -		if (maddr_len && nf_nat_sdp_addr &&
> -		    nf_ct_l3num(ct) == NFPROTO_IPV4 && ct->status & IPS_NAT_MASK) {
> +		if (maddr_len && nf_nat_sdp_addr && ct->status & IPS_NAT_MASK) {
>  			ret = nf_nat_sdp_addr(skb, protoff, dataoff,
> -					      dptr, datalen,
> -					      mediaoff, c_hdr, SDP_HDR_MEDIA,
> +					      dptr, datalen, mediaoff,
> +					      SDP_HDR_CONNECTION, SDP_HDR_MEDIA,
>  					      &rtp_addr);
>  			if (ret != NF_ACCEPT)
>  				return ret;
> @@ -1127,8 +1131,7 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
>  
>  	/* Update session connection and owner addresses */
>  	nf_nat_sdp_session = rcu_dereference(nf_nat_sdp_session_hook);
> -	if (nf_nat_sdp_session && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
> -	    ct->status & IPS_NAT_MASK)
> +	if (nf_nat_sdp_session && ct->status & IPS_NAT_MASK)
>  		ret = nf_nat_sdp_session(skb, protoff, dataoff,
>  					 dptr, datalen, sdpoff, &rtp_addr);
>  
> @@ -1293,8 +1296,7 @@ static int process_register_request(struct sk_buff *skb, unsigned int protoff,
>  	exp->flags = NF_CT_EXPECT_PERMANENT | NF_CT_EXPECT_INACTIVE;
>  
>  	nf_nat_sip_expect = rcu_dereference(nf_nat_sip_expect_hook);
> -	if (nf_nat_sip_expect && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
> -	    ct->status & IPS_NAT_MASK)
> +	if (nf_nat_sip_expect && ct->status & IPS_NAT_MASK)
>  		ret = nf_nat_sip_expect(skb, protoff, dataoff, dptr, datalen,
>  					exp, matchoff, matchlen);
>  	else {
> @@ -1476,8 +1478,7 @@ static int process_sip_msg(struct sk_buff *skb, struct nf_conn *ct,
>  	else
>  		ret = process_sip_response(skb, protoff, dataoff, dptr, datalen);
>  
> -	if (ret == NF_ACCEPT && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
> -	    ct->status & IPS_NAT_MASK) {
> +	if (ret == NF_ACCEPT && ct->status & IPS_NAT_MASK) {
>  		nf_nat_sip = rcu_dereference(nf_nat_sip_hook);
>  		if (nf_nat_sip && !nf_nat_sip(skb, protoff, dataoff,
>  					      dptr, datalen))
> @@ -1560,11 +1561,10 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
>  		datalen  = datalen + diff - msglen;
>  	}
>  
> -	if (ret == NF_ACCEPT && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
> -	    ct->status & IPS_NAT_MASK) {
> +	if (ret == NF_ACCEPT && ct->status & IPS_NAT_MASK) {
>  		nf_nat_sip_seq_adjust = rcu_dereference(nf_nat_sip_seq_adjust_hook);
>  		if (nf_nat_sip_seq_adjust)
> -			nf_nat_sip_seq_adjust(skb, tdiff);
> +			nf_nat_sip_seq_adjust(skb, protoff, tdiff);
>  	}
>  
>  	return ret;
> diff --git a/net/netfilter/nf_nat_sip.c b/net/netfilter/nf_nat_sip.c
> new file mode 100644
> index 0000000..f4db3a7
> --- /dev/null
> +++ b/net/netfilter/nf_nat_sip.c
> @@ -0,0 +1,609 @@
> +/* SIP extension for NAT alteration.
> + *
> + * (C) 2005 by Christian Hentschel <chentschel@arnet.com.ar>
> + * based on RR's ip_nat_ftp.c and other modules.
> + * (C) 2007 United Security Providers
> + * (C) 2007, 2008, 2011, 2012 Patrick McHardy <kaber@trash.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/skbuff.h>
> +#include <linux/inet.h>
> +#include <linux/udp.h>
> +#include <linux/tcp.h>
> +
> +#include <net/netfilter/nf_nat.h>
> +#include <net/netfilter/nf_nat_helper.h>
> +#include <net/netfilter/nf_conntrack_helper.h>
> +#include <net/netfilter/nf_conntrack_expect.h>
> +#include <linux/netfilter/nf_conntrack_sip.h>
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Christian Hentschel <chentschel@arnet.com.ar>");
> +MODULE_DESCRIPTION("SIP NAT helper");
> +MODULE_ALIAS("ip_nat_sip");
> +
> +
> +static unsigned int mangle_packet(struct sk_buff *skb, unsigned int protoff,
> +				  unsigned int dataoff,
> +				  const char **dptr, unsigned int *datalen,
> +				  unsigned int matchoff, unsigned int matchlen,
> +				  const char *buffer, unsigned int buflen)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	struct tcphdr *th;
> +	unsigned int baseoff;
> +
> +	if (nf_ct_protonum(ct) == IPPROTO_TCP) {
> +		th = (struct tcphdr *)(skb->data + protoff);
> +		baseoff = protoff + th->doff * 4;
> +		matchoff += dataoff - baseoff;
> +
> +		if (!__nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
> +						protoff, matchoff, matchlen,
> +						buffer, buflen, false))
> +			return 0;
> +	} else {
> +		baseoff = protoff + sizeof(struct udphdr);
> +		matchoff += dataoff - baseoff;
> +
> +		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo,
> +					      protoff, matchoff, matchlen,
> +					      buffer, buflen))
> +			return 0;
> +	}
> +
> +	/* Reload data pointer and adjust datalen value */
> +	*dptr = skb->data + dataoff;
> +	*datalen += buflen - matchlen;
> +	return 1;
> +}
> +
> +static int sip_sprintf_addr(const struct nf_conn *ct, char *buffer,
> +			    const union nf_inet_addr *addr, bool delim)
> +{
> +	if (nf_ct_l3num(ct) == NFPROTO_IPV4)
> +		return sprintf(buffer, "%pI4", &addr->ip);
> +	else {
> +		if (delim)
> +			return sprintf(buffer, "[%pI6c]", &addr->ip6);
> +		else
> +			return sprintf(buffer, "%pI6c", &addr->ip6);
> +	}
> +}
> +
> +static int sip_sprintf_addr_port(const struct nf_conn *ct, char *buffer,
> +				 const union nf_inet_addr *addr, u16 port)
> +{
> +	if (nf_ct_l3num(ct) == NFPROTO_IPV4)
> +		return sprintf(buffer, "%pI4:%u", &addr->ip, port);
> +	else
> +		return sprintf(buffer, "[%pI6c]:%u", &addr->ip6, port);
> +}
> +
> +static int map_addr(struct sk_buff *skb, unsigned int protoff,
> +		    unsigned int dataoff,
> +		    const char **dptr, unsigned int *datalen,
> +		    unsigned int matchoff, unsigned int matchlen,
> +		    union nf_inet_addr *addr, __be16 port)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
> +	char buffer[INET6_ADDRSTRLEN + sizeof("[]:nnnnn")];
> +	unsigned int buflen;
> +	union nf_inet_addr newaddr;
> +	__be16 newport;
> +
> +	if (nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.src.u3, addr) &&
> +	    ct->tuplehash[dir].tuple.src.u.udp.port == port) {
> +		newaddr = ct->tuplehash[!dir].tuple.dst.u3;
> +		newport = ct->tuplehash[!dir].tuple.dst.u.udp.port;
> +	} else if (nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.dst.u3, addr) &&
> +		   ct->tuplehash[dir].tuple.dst.u.udp.port == port) {
> +		newaddr = ct->tuplehash[!dir].tuple.src.u3;
> +		newport = ct->tuplehash[!dir].tuple.src.u.udp.port;
> +	} else
> +		return 1;
> +
> +	if (nf_inet_addr_cmp(&newaddr, addr) && newport == port)
> +		return 1;
> +
> +	buflen = sip_sprintf_addr_port(ct, buffer, &newaddr, ntohs(newport));
> +	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
> +			     matchoff, matchlen, buffer, buflen);
> +}
> +
> +static int map_sip_addr(struct sk_buff *skb, unsigned int protoff,
> +			unsigned int dataoff,
> +			const char **dptr, unsigned int *datalen,
> +			enum sip_header_types type)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	unsigned int matchlen, matchoff;
> +	union nf_inet_addr addr;
> +	__be16 port;
> +
> +	if (ct_sip_parse_header_uri(ct, *dptr, NULL, *datalen, type, NULL,
> +				    &matchoff, &matchlen, &addr, &port) <= 0)
> +		return 1;
> +	return map_addr(skb, protoff, dataoff, dptr, datalen,
> +			matchoff, matchlen, &addr, port);
> +}
> +
> +static unsigned int nf_nat_sip(struct sk_buff *skb, unsigned int protoff,
> +			       unsigned int dataoff,
> +			       const char **dptr, unsigned int *datalen)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
> +	unsigned int coff, matchoff, matchlen;
> +	enum sip_header_types hdr;
> +	union nf_inet_addr addr;
> +	__be16 port;
> +	int request, in_header;
> +
> +	/* Basic rules: requests and responses. */
> +	if (strnicmp(*dptr, "SIP/2.0", strlen("SIP/2.0")) != 0) {
> +		if (ct_sip_parse_request(ct, *dptr, *datalen,
> +					 &matchoff, &matchlen,
> +					 &addr, &port) > 0 &&
> +		    !map_addr(skb, protoff, dataoff, dptr, datalen,
> +			      matchoff, matchlen, &addr, port))
> +			return NF_DROP;
> +		request = 1;
> +	} else
> +		request = 0;
> +
> +	if (nf_ct_protonum(ct) == IPPROTO_TCP)
> +		hdr = SIP_HDR_VIA_TCP;
> +	else
> +		hdr = SIP_HDR_VIA_UDP;
> +
> +	/* Translate topmost Via header and parameters */
> +	if (ct_sip_parse_header_uri(ct, *dptr, NULL, *datalen,
> +				    hdr, NULL, &matchoff, &matchlen,
> +				    &addr, &port) > 0) {
> +		unsigned int olen, matchend, poff, plen, buflen, n;
> +		char buffer[INET6_ADDRSTRLEN + sizeof("[]:nnnnn")];
> +
> +		/* We're only interested in headers related to this
> +		 * connection */
> +		if (request) {
> +			if (!nf_inet_addr_cmp(&addr,
> +					&ct->tuplehash[dir].tuple.src.u3) ||
> +			    port != ct->tuplehash[dir].tuple.src.u.udp.port)
> +				goto next;
> +		} else {
> +			if (!nf_inet_addr_cmp(&addr,
> +					&ct->tuplehash[dir].tuple.dst.u3) ||
> +			    port != ct->tuplehash[dir].tuple.dst.u.udp.port)
> +				goto next;
> +		}
> +
> +		olen = *datalen;
> +		if (!map_addr(skb, protoff, dataoff, dptr, datalen,
> +			      matchoff, matchlen, &addr, port))
> +			return NF_DROP;
> +
> +		matchend = matchoff + matchlen + *datalen - olen;
> +
> +		/* The maddr= parameter (RFC 2361) specifies where to send
> +		 * the reply. */
> +		if (ct_sip_parse_address_param(ct, *dptr, matchend, *datalen,
> +					       "maddr=", &poff, &plen,
> +					       &addr, true) > 0 &&
> +		    nf_inet_addr_cmp(&addr, &ct->tuplehash[dir].tuple.src.u3) &&
> +		    !nf_inet_addr_cmp(&addr, &ct->tuplehash[!dir].tuple.dst.u3)) {
> +			buflen = sip_sprintf_addr(ct, buffer,
> +					&ct->tuplehash[!dir].tuple.dst.u3,
> +					true);
> +			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
> +					   poff, plen, buffer, buflen))
> +				return NF_DROP;
> +		}
> +
> +		/* The received= parameter (RFC 2361) contains the address
> +		 * from which the server received the request. */
> +		if (ct_sip_parse_address_param(ct, *dptr, matchend, *datalen,
> +					       "received=", &poff, &plen,
> +					       &addr, false) > 0 &&
> +		    nf_inet_addr_cmp(&addr, &ct->tuplehash[dir].tuple.dst.u3) &&
> +		    !nf_inet_addr_cmp(&addr, &ct->tuplehash[!dir].tuple.src.u3)) {
> +			buflen = sip_sprintf_addr(ct, buffer,
> +					&ct->tuplehash[!dir].tuple.src.u3,
> +					false);
> +			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
> +					   poff, plen, buffer, buflen))
> +				return NF_DROP;
> +		}
> +
> +		/* The rport= parameter (RFC 3581) contains the port number
> +		 * from which the server received the request. */
> +		if (ct_sip_parse_numerical_param(ct, *dptr, matchend, *datalen,
> +						 "rport=", &poff, &plen,
> +						 &n) > 0 &&
> +		    htons(n) == ct->tuplehash[dir].tuple.dst.u.udp.port &&
> +		    htons(n) != ct->tuplehash[!dir].tuple.src.u.udp.port) {
> +			__be16 p = ct->tuplehash[!dir].tuple.src.u.udp.port;
> +			buflen = sprintf(buffer, "%u", ntohs(p));
> +			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
> +					   poff, plen, buffer, buflen))
> +				return NF_DROP;
> +		}
> +	}
> +
> +next:
> +	/* Translate Contact headers */
> +	coff = 0;
> +	in_header = 0;
> +	while (ct_sip_parse_header_uri(ct, *dptr, &coff, *datalen,
> +				       SIP_HDR_CONTACT, &in_header,
> +				       &matchoff, &matchlen,
> +				       &addr, &port) > 0) {
> +		if (!map_addr(skb, protoff, dataoff, dptr, datalen,
> +			      matchoff, matchlen,
> +			      &addr, port))
> +			return NF_DROP;
> +	}
> +
> +	if (!map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_FROM) ||
> +	    !map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_TO))
> +		return NF_DROP;
> +
> +	return NF_ACCEPT;
> +}
> +
> +static void nf_nat_sip_seq_adjust(struct sk_buff *skb, unsigned int protoff,
> +				  s16 off)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	const struct tcphdr *th;
> +
> +	if (nf_ct_protonum(ct) != IPPROTO_TCP || off == 0)
> +		return;
> +
> +	th = (struct tcphdr *)(skb->data + protoff);
> +	nf_nat_set_seq_adjust(ct, ctinfo, th->seq, off);
> +}
> +
> +/* Handles expected signalling connections and media streams */
> +static void nf_nat_sip_expected(struct nf_conn *ct,
> +				struct nf_conntrack_expect *exp)
> +{
> +	struct nf_nat_range range;
> +
> +	/* This must be a fresh one. */
> +	BUG_ON(ct->status & IPS_NAT_DONE_MASK);
> +
> +	/* For DST manip, map port here to where it's expected. */
> +	range.flags = (NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED);
> +	range.min_proto = range.max_proto = exp->saved_proto;
> +	range.min_addr = range.max_addr = exp->saved_addr;
> +	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_DST);
> +
> +	/* Change src to where master sends to, but only if the connection
> +	 * actually came from the same source. */
> +	if (nf_inet_addr_cmp(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3,
> +			     &ct->master->tuplehash[exp->dir].tuple.src.u3)) {
> +		range.flags = NF_NAT_RANGE_MAP_IPS;
> +		range.min_addr = range.max_addr
> +			= ct->master->tuplehash[!exp->dir].tuple.dst.u3;
> +		nf_nat_setup_info(ct, &range, NF_NAT_MANIP_SRC);
> +	}
> +}
> +
> +static unsigned int nf_nat_sip_expect(struct sk_buff *skb, unsigned int protoff,
> +				      unsigned int dataoff,
> +				      const char **dptr, unsigned int *datalen,
> +				      struct nf_conntrack_expect *exp,
> +				      unsigned int matchoff,
> +				      unsigned int matchlen)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
> +	union nf_inet_addr newaddr;
> +	u_int16_t port;
> +	char buffer[INET6_ADDRSTRLEN + sizeof("[]:nnnnn")];
> +	unsigned int buflen;
> +
> +	/* Connection will come from reply */
> +	if (nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.src.u3,
> +			     &ct->tuplehash[!dir].tuple.dst.u3))
> +		newaddr = exp->tuple.dst.u3;
> +	else
> +		newaddr = ct->tuplehash[!dir].tuple.dst.u3;
> +
> +	/* If the signalling port matches the connection's source port in the
> +	 * original direction, try to use the destination port in the opposite
> +	 * direction. */
> +	if (exp->tuple.dst.u.udp.port ==
> +	    ct->tuplehash[dir].tuple.src.u.udp.port)
> +		port = ntohs(ct->tuplehash[!dir].tuple.dst.u.udp.port);
> +	else
> +		port = ntohs(exp->tuple.dst.u.udp.port);
> +
> +	exp->saved_addr = exp->tuple.dst.u3;
> +	exp->tuple.dst.u3 = newaddr;
> +	exp->saved_proto.udp.port = exp->tuple.dst.u.udp.port;
> +	exp->dir = !dir;
> +	exp->expectfn = nf_nat_sip_expected;
> +
> +	for (; port != 0; port++) {
> +		int ret;
> +
> +		exp->tuple.dst.u.udp.port = htons(port);
> +		ret = nf_ct_expect_related(exp);
> +		if (ret == 0)
> +			break;
> +		else if (ret != -EBUSY) {
> +			port = 0;
> +			break;
> +		}
> +	}
> +
> +	if (port == 0)
> +		return NF_DROP;
> +
> +	if (!nf_inet_addr_cmp(&exp->tuple.dst.u3, &exp->saved_addr) ||
> +	    exp->tuple.dst.u.udp.port != exp->saved_proto.udp.port) {
> +		buflen = sip_sprintf_addr_port(ct, buffer, &newaddr, port);
> +		if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
> +				   matchoff, matchlen, buffer, buflen))
> +			goto err;
> +	}
> +	return NF_ACCEPT;
> +
> +err:
> +	nf_ct_unexpect_related(exp);
> +	return NF_DROP;
> +}
> +
> +static int mangle_content_len(struct sk_buff *skb, unsigned int protoff,
> +			      unsigned int dataoff,
> +			      const char **dptr, unsigned int *datalen)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	unsigned int matchoff, matchlen;
> +	char buffer[sizeof("65536")];
> +	int buflen, c_len;
> +
> +	/* Get actual SDP length */
> +	if (ct_sip_get_sdp_header(ct, *dptr, 0, *datalen,
> +				  SDP_HDR_VERSION, SDP_HDR_UNSPEC,
> +				  &matchoff, &matchlen) <= 0)
> +		return 0;
> +	c_len = *datalen - matchoff + strlen("v=");
> +
> +	/* Now, update SDP length */
> +	if (ct_sip_get_header(ct, *dptr, 0, *datalen, SIP_HDR_CONTENT_LENGTH,
> +			      &matchoff, &matchlen) <= 0)
> +		return 0;
> +
> +	buflen = sprintf(buffer, "%u", c_len);
> +	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
> +			     matchoff, matchlen, buffer, buflen);
> +}
> +
> +static int mangle_sdp_packet(struct sk_buff *skb, unsigned int protoff,
> +			     unsigned int dataoff,
> +			     const char **dptr, unsigned int *datalen,
> +			     unsigned int sdpoff,
> +			     enum sdp_header_types type,
> +			     enum sdp_header_types term,
> +			     char *buffer, int buflen)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	unsigned int matchlen, matchoff;
> +
> +	if (ct_sip_get_sdp_header(ct, *dptr, sdpoff, *datalen, type, term,
> +				  &matchoff, &matchlen) <= 0)
> +		return -ENOENT;
> +	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
> +			     matchoff, matchlen, buffer, buflen) ? 0 : -EINVAL;
> +}
> +
> +static unsigned int nf_nat_sdp_addr(struct sk_buff *skb, unsigned int protoff,
> +				    unsigned int dataoff,
> +				    const char **dptr, unsigned int *datalen,
> +				    unsigned int sdpoff,
> +				    enum sdp_header_types type,
> +				    enum sdp_header_types term,
> +				    const union nf_inet_addr *addr)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	char buffer[INET6_ADDRSTRLEN];
> +	unsigned int buflen;
> +
> +	buflen = sip_sprintf_addr(ct, buffer, addr, false);
> +	if (mangle_sdp_packet(skb, protoff, dataoff, dptr, datalen,
> +			      sdpoff, type, term, buffer, buflen))
> +		return 0;
> +
> +	return mangle_content_len(skb, protoff, dataoff, dptr, datalen);
> +}
> +
> +static unsigned int nf_nat_sdp_port(struct sk_buff *skb, unsigned int protoff,
> +				    unsigned int dataoff,
> +				    const char **dptr, unsigned int *datalen,
> +				    unsigned int matchoff,
> +				    unsigned int matchlen,
> +				    u_int16_t port)
> +{
> +	char buffer[sizeof("nnnnn")];
> +	unsigned int buflen;
> +
> +	buflen = sprintf(buffer, "%u", port);
> +	if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
> +			   matchoff, matchlen, buffer, buflen))
> +		return 0;
> +
> +	return mangle_content_len(skb, protoff, dataoff, dptr, datalen);
> +}
> +
> +static unsigned int nf_nat_sdp_session(struct sk_buff *skb, unsigned int protoff,
> +				       unsigned int dataoff,
> +				       const char **dptr, unsigned int *datalen,
> +				       unsigned int sdpoff,
> +				       const union nf_inet_addr *addr)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	char buffer[INET6_ADDRSTRLEN];
> +	unsigned int buflen;
> +
> +	/* Mangle session description owner and contact addresses */
> +	buflen = sip_sprintf_addr(ct, buffer, addr, false);
> +	if (mangle_sdp_packet(skb, protoff, dataoff, dptr, datalen, sdpoff,
> +			      SDP_HDR_OWNER, SDP_HDR_MEDIA, buffer, buflen))
> +		return 0;
> +
> +	switch (mangle_sdp_packet(skb, protoff, dataoff, dptr, datalen, sdpoff,
> +				  SDP_HDR_CONNECTION, SDP_HDR_MEDIA,
> +				  buffer, buflen)) {
> +	case 0:
> +	/*
> +	 * RFC 2327:
> +	 *
> +	 * Session description
> +	 *
> +	 * c=* (connection information - not required if included in all media)
> +	 */
> +	case -ENOENT:
> +		break;
> +	default:
> +		return 0;
> +	}
> +
> +	return mangle_content_len(skb, protoff, dataoff, dptr, datalen);
> +}
> +
> +/* So, this packet has hit the connection tracking matching code.
> +   Mangle it, and change the expectation to match the new version. */
> +static unsigned int nf_nat_sdp_media(struct sk_buff *skb, unsigned int protoff,
> +				     unsigned int dataoff,
> +				     const char **dptr, unsigned int *datalen,
> +				     struct nf_conntrack_expect *rtp_exp,
> +				     struct nf_conntrack_expect *rtcp_exp,
> +				     unsigned int mediaoff,
> +				     unsigned int medialen,
> +				     union nf_inet_addr *rtp_addr)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
> +	u_int16_t port;
> +
> +	/* Connection will come from reply */
> +	if (nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.src.u3,
> +			     &ct->tuplehash[!dir].tuple.dst.u3))
> +		*rtp_addr = rtp_exp->tuple.dst.u3;
> +	else
> +		*rtp_addr = ct->tuplehash[!dir].tuple.dst.u3;
> +
> +	rtp_exp->saved_addr = rtp_exp->tuple.dst.u3;
> +	rtp_exp->tuple.dst.u3 = *rtp_addr;
> +	rtp_exp->saved_proto.udp.port = rtp_exp->tuple.dst.u.udp.port;
> +	rtp_exp->dir = !dir;
> +	rtp_exp->expectfn = nf_nat_sip_expected;
> +
> +	rtcp_exp->saved_addr = rtcp_exp->tuple.dst.u3;
> +	rtcp_exp->tuple.dst.u3 = *rtp_addr;
> +	rtcp_exp->saved_proto.udp.port = rtcp_exp->tuple.dst.u.udp.port;
> +	rtcp_exp->dir = !dir;
> +	rtcp_exp->expectfn = nf_nat_sip_expected;
> +
> +	/* Try to get same pair of ports: if not, try to change them. */
> +	for (port = ntohs(rtp_exp->tuple.dst.u.udp.port);
> +	     port != 0; port += 2) {
> +		int ret;
> +
> +		rtp_exp->tuple.dst.u.udp.port = htons(port);
> +		ret = nf_ct_expect_related(rtp_exp);
> +		if (ret == -EBUSY)
> +			continue;
> +		else if (ret < 0) {
> +			port = 0;
> +			break;
> +		}
> +		rtcp_exp->tuple.dst.u.udp.port = htons(port + 1);
> +		ret = nf_ct_expect_related(rtcp_exp);
> +		if (ret == 0)
> +			break;
> +		else if (ret != -EBUSY) {
> +			nf_ct_unexpect_related(rtp_exp);
> +			port = 0;
> +			break;
> +		}
> +	}
> +
> +	if (port == 0)
> +		goto err1;
> +
> +	/* Update media port. */
> +	if (rtp_exp->tuple.dst.u.udp.port != rtp_exp->saved_proto.udp.port &&
> +	    !nf_nat_sdp_port(skb, protoff, dataoff, dptr, datalen,
> +			     mediaoff, medialen, port))
> +		goto err2;
> +
> +	return NF_ACCEPT;
> +
> +err2:
> +	nf_ct_unexpect_related(rtp_exp);
> +	nf_ct_unexpect_related(rtcp_exp);
> +err1:
> +	return NF_DROP;
> +}
> +
> +static struct nf_ct_helper_expectfn sip_nat = {
> +	.name		= "sip",
> +	.expectfn	= nf_nat_sip_expected,
> +};
> +
> +static void __exit nf_nat_sip_fini(void)
> +{
> +	RCU_INIT_POINTER(nf_nat_sip_hook, NULL);
> +	RCU_INIT_POINTER(nf_nat_sip_seq_adjust_hook, NULL);
> +	RCU_INIT_POINTER(nf_nat_sip_expect_hook, NULL);
> +	RCU_INIT_POINTER(nf_nat_sdp_addr_hook, NULL);
> +	RCU_INIT_POINTER(nf_nat_sdp_port_hook, NULL);
> +	RCU_INIT_POINTER(nf_nat_sdp_session_hook, NULL);
> +	RCU_INIT_POINTER(nf_nat_sdp_media_hook, NULL);
> +	nf_ct_helper_expectfn_unregister(&sip_nat);
> +	synchronize_rcu();
> +}
> +
> +static int __init nf_nat_sip_init(void)
> +{
> +	BUG_ON(nf_nat_sip_hook != NULL);
> +	BUG_ON(nf_nat_sip_seq_adjust_hook != NULL);
> +	BUG_ON(nf_nat_sip_expect_hook != NULL);
> +	BUG_ON(nf_nat_sdp_addr_hook != NULL);
> +	BUG_ON(nf_nat_sdp_port_hook != NULL);
> +	BUG_ON(nf_nat_sdp_session_hook != NULL);
> +	BUG_ON(nf_nat_sdp_media_hook != NULL);
> +	RCU_INIT_POINTER(nf_nat_sip_hook, nf_nat_sip);
> +	RCU_INIT_POINTER(nf_nat_sip_seq_adjust_hook, nf_nat_sip_seq_adjust);
> +	RCU_INIT_POINTER(nf_nat_sip_expect_hook, nf_nat_sip_expect);
> +	RCU_INIT_POINTER(nf_nat_sdp_addr_hook, nf_nat_sdp_addr);
> +	RCU_INIT_POINTER(nf_nat_sdp_port_hook, nf_nat_sdp_port);
> +	RCU_INIT_POINTER(nf_nat_sdp_session_hook, nf_nat_sdp_session);
> +	RCU_INIT_POINTER(nf_nat_sdp_media_hook, nf_nat_sdp_media);
> +	nf_ct_helper_expectfn_register(&sip_nat);
> +	return 0;
> +}
> +
> +module_init(nf_nat_sip_init);
> +module_exit(nf_nat_sip_fini);
