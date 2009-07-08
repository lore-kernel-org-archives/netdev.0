From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Tue, 07 Jul 2009 21:23:25 -0400
Message-ID: <4A53F50D.30001@hp.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com> <1246994776-1882-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:40477 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952AbZGHBXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 21:23:30 -0400
In-Reply-To: <1246994776-1882-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Smith wrote:
> This patch adds AF_INET c/r support based on the framework established in
> my AF_UNIX patch.  I've tested it by checkpointing a single app with a
> pair of sockets connected over loopback.
 
> +struct ckpt_hdr_socket_inet {
> +	struct ckpt_hdr h;
> +
> +	__u32 daddr;
> +	__u32 rcv_saddr;
> +	__u32 saddr;
> +	__u16 dport;
> +	__u16 num;
> +	__u16 sport;
> +	__s16 uc_ttl;
> +	__u16 cmsg_flags;
> +	__u16 __pad;
> +
> +	struct {
> +		__u64 timeout;
> +		__u32 ato;
> +		__u32 lrcvtime;
> +		__u16 last_seg_size;
> +		__u16 rcv_mss;
> +		__u8 pending;
> +		__u8 quick;
> +		__u8 pingpong;
> +		__u8 blocked;
> +	} icsk_ack __attribute__ ((aligned(8)));
> +
> +	/* FIXME: Skipped opt, tos, multicast, cork settings */
> +
<snip>
> +
> +	struct {
> +		char saddr[16];
> +		char rcv_saddr[16];
> +		char daddr[16];
> +	} inet6 __attribute__ ((aligned(8)));

These should be 'struct in6_addr'.

And just like in your IPv4 section you need a FIXME here for the things
you skipped :)

> +static int sock_inet_cptrst(struct ckpt_ctx *ctx,
> +			    struct sock *sock,
> +			    struct ckpt_hdr_socket_inet *hh,
> +			  int op)
> +{
<snip>
> +
> +	if (sock->sk_family == AF_INET6) {
> +		struct ipv6_pinfo *inet6 = inet6_sk(sock);
> +		unsigned alen = sizeof(struct in6_addr);
> +		if (op == CKPT_CPT) {
> +			memcpy(hh->inet6.saddr, &inet6->saddr, alen);
> +			memcpy(hh->inet6.rcv_saddr, &inet6->rcv_saddr, alen);
> +			memcpy(hh->inet6.daddr, &inet6->daddr, alen);
> +		} else {
> +			memcpy(&inet6->saddr, hh->inet6.saddr, alen);
> +			memcpy(&inet6->rcv_saddr, hh->inet6.rcv_saddr, alen);
> +			memcpy(&inet6->daddr, hh->inet6.daddr, alen);
> +		}
> +	}

There's an inline called ipv6_addr_copy() that will do the same thing,
then you could drop the alen argument.

-Brian
