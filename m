From: Zhenwei Pi <p_ace@126.com>
Subject: patch for udp_sendmsg
Date: Sun, 19 Jul 2015 22:38:54 +0800
Message-ID: <55ABB67E.8040100@126.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030904000408010905020400"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-112.126.com ([123.125.50.112]:50550 "EHLO m50-112.126.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753047AbbGSOi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2015 10:38:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030904000408010905020400
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Dear Sirs,

Commit : the max length of udp msg is (0xFFFF - sizeof(struct udphdr) - 
sizeof(struct iphdr). return -EMSGSIZE in udp_sendmsg.
Patch : as the attached file

____________________________________________________________
| IP header |  UDP header | udp data ........                             |
|___________|______________|_________________________________|
|--> Total Length : 
0xffff                                                       <--|


If length of "data" is between (0xFFFF - sizeof(struct udphdr) - 
sizeof(struct iphdr) and 0xFFFF, sendto will fail because of ip_make_skb.
Should kernel return -EMSGSIZE as soon as possible ?


-- 
Zhenwei Pi
Rather than love ,than money ,than faith,than fame,than fairness,give me truth.


--------------030904000408010905020400
Content-Type: text/plain; charset=UTF-8;
 name="diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="diff"

LS0tIHVkcC5jLm9yaWcJMjAxNS0wNy0xOSAwOToyODoxNi43MzI0NzcyNDUgKzA4MDAKKysr
IHVkcC5jCTIwMTUtMDctMTkgMDk6Mjk6NDYuOTUyNDQxOTU3ICswODAwCkBAIC04OTQsNyAr
ODk0LDcgQEAKIAlzdHJ1Y3Qgc2tfYnVmZiAqc2tiOwogCXN0cnVjdCBpcF9vcHRpb25zX2Rh
dGEgb3B0X2NvcHk7CiAKLQlpZiAobGVuID4gMHhGRkZGKQorCWlmIChsZW4gPiAoMHhGRkZG
IC0gc2l6ZW9mKHN0cnVjdCB1ZHBoZHIpIC0gc2l6ZW9mKHN0cnVjdCBpcGhkcikpKQogCQly
ZXR1cm4gLUVNU0dTSVpFOwogCiAJLyoK
--------------030904000408010905020400
Content-Type: text/x-csrc;
 name="udp.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="udp.c"

/*
 * INET		An implementation of the TCP/IP protocol suite for the LINUX
 *		operating system.  INET is implemented using the  BSD Socket
 *		interface as the means of communication with the user level.
 *
 *		The User Datagram Protocol (UDP).
 *
 * Authors:	Ross Biro
 *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
 *		Arnt Gulbrandsen, <agulbra@nvg.unit.no>
 *		Alan Cox, <alan@lxorguk.ukuu.org.uk>
 *		Hirokazu Takahashi, <taka@valinux.co.jp>
 *
 * Fixes:
 *		Alan Cox	:	verify_area() calls
 *		Alan Cox	: 	stopped close while in use off icmp
 *					messages. Not a fix but a botch that
 *					for udp at least is 'valid'.
 *		Alan Cox	:	Fixed icmp handling properly
 *		Alan Cox	: 	Correct error for oversized datagrams
 *		Alan Cox	:	Tidied select() semantics.
 *		Alan Cox	:	udp_err() fixed properly, also now
 *					select and read wake correctly on errors
 *		Alan Cox	:	udp_send verify_area moved to avoid mem leak
 *		Alan Cox	:	UDP can count its memory
 *		Alan Cox	:	send to an unknown connection causes
 *					an ECONNREFUSED off the icmp, but
 *					does NOT close.
 *		Alan Cox	:	Switched to new sk_buff handlers. No more backlog!
 *		Alan Cox	:	Using generic datagram code. Even smaller and the PEEK
 *					bug no longer crashes it.
 *		Fred Van Kempen	: 	Net2e support for sk->broadcast.
 *		Alan Cox	:	Uses skb_free_datagram
 *		Alan Cox	:	Added get/set sockopt support.
 *		Alan Cox	:	Broadcasting without option set returns EACCES.
 *		Alan Cox	:	No wakeup calls. Instead we now use the callbacks.
 *		Alan Cox	:	Use ip_tos and ip_ttl
 *		Alan Cox	:	SNMP Mibs
 *		Alan Cox	:	MSG_DONTROUTE, and 0.0.0.0 support.
 *		Matt Dillon	:	UDP length checks.
 *		Alan Cox	:	Smarter af_inet used properly.
 *		Alan Cox	:	Use new kernel side addressing.
 *		Alan Cox	:	Incorrect return on truncated datagram receive.
 *	Arnt Gulbrandsen 	:	New udp_send and stuff
 *		Alan Cox	:	Cache last socket
 *		Alan Cox	:	Route cache
 *		Jon Peatfield	:	Minor efficiency fix to sendto().
 *		Mike Shaver	:	RFC1122 checks.
 *		Alan Cox	:	Nonblocking error fix.
 *	Willy Konynenberg	:	Transparent proxying support.
 *		Mike McLagan	:	Routing by source
 *		David S. Miller	:	New socket lookup architecture.
 *					Last socket cache retained as it
 *					does have a high hit rate.
 *		Olaf Kirch	:	Don't linearise iovec on sendmsg.
 *		Andi Kleen	:	Some cleanups, cache destination entry
 *					for connect.
 *	Vitaly E. Lavrov	:	Transparent proxy revived after year coma.
 *		Melvin Smith	:	Check msg_name not msg_namelen in sendto(),
 *					return ENOTCONN for unconnected sockets (POSIX)
 *		Janos Farkas	:	don't deliver multi/broadcasts to a different
 *					bound-to-device socket
 *	Hirokazu Takahashi	:	HW checksumming for outgoing UDP
 *					datagrams.
 *	Hirokazu Takahashi	:	sendfile() on UDP works now.
 *		Arnaldo C. Melo :	convert /proc/net/udp to seq_file
 *	YOSHIFUJI Hideaki @USAGI and:	Support IPV6_V6ONLY socket option, which
 *	Alexey Kuznetsov:		allow both IPv4 and IPv6 sockets to bind
 *					a single port at the same time.
 *	Derek Atkins <derek@ihtfp.com>: Add Encapulation Support
 *	James Chapman		:	Add L2TP encapsulation type.
 *
 *
 *		This program is free software; you can redistribute it and/or
 *		modify it under the terms of the GNU General Public License
 *		as published by the Free Software Foundation; either version
 *		2 of the License, or (at your option) any later version.
 */

#define pr_fmt(fmt) "UDP: " fmt

#include <asm/uaccess.h>
#include <asm/ioctls.h>
#include <linux/bootmem.h>
#include <linux/highmem.h>
#include <linux/swap.h>
#include <linux/types.h>
#include <linux/fcntl.h>
#include <linux/module.h>
#include <linux/socket.h>
#include <linux/sockios.h>
#include <linux/igmp.h>
#include <linux/in.h>
#include <linux/errno.h>
#include <linux/timer.h>
#include <linux/mm.h>
#include <linux/inet.h>
#include <linux/netdevice.h>
#include <linux/slab.h>
#include <net/tcp_states.h>
#include <linux/skbuff.h>
#include <linux/netdevice.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <net/net_namespace.h>
#include <net/icmp.h>
#include <net/inet_hashtables.h>
#include <net/route.h>
#include <net/checksum.h>
#include <net/xfrm.h>
#include <trace/events/udp.h>
#include <linux/static_key.h>
#include <trace/events/skb.h>
#include <net/busy_poll.h>
#include "udp_impl.h"

struct udp_table udp_table __read_mostly;
EXPORT_SYMBOL(udp_table);

long sysctl_udp_mem[3] __read_mostly;
EXPORT_SYMBOL(sysctl_udp_mem);

int sysctl_udp_rmem_min __read_mostly;
EXPORT_SYMBOL(sysctl_udp_rmem_min);

int sysctl_udp_wmem_min __read_mostly;
EXPORT_SYMBOL(sysctl_udp_wmem_min);

atomic_long_t udp_memory_allocated;
EXPORT_SYMBOL(udp_memory_allocated);

#define MAX_UDP_PORTS 65536
#define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)

static int udp_lib_lport_inuse(struct net *net, __u16 num,
			       const struct udp_hslot *hslot,
			       unsigned long *bitmap,
			       struct sock *sk,
			       int (*saddr_comp)(const struct sock *sk1,
						 const struct sock *sk2),
			       unsigned int log)
{
	struct sock *sk2;
	struct hlist_nulls_node *node;
	kuid_t uid = sock_i_uid(sk);

	sk_nulls_for_each(sk2, node, &hslot->head) {
		if (net_eq(sock_net(sk2), net) &&
		    sk2 != sk &&
		    (bitmap || udp_sk(sk2)->udp_port_hash == num) &&
		    (!sk2->sk_reuse || !sk->sk_reuse) &&
		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
		     !uid_eq(uid, sock_i_uid(sk2))) &&
		    saddr_comp(sk, sk2)) {
			if (!bitmap)
				return 1;
			__set_bit(udp_sk(sk2)->udp_port_hash >> log, bitmap);
		}
	}
	return 0;
}

/*
 * Note: we still hold spinlock of primary hash chain, so no other writer
 * can insert/delete a socket with local_port == num
 */
static int udp_lib_lport_inuse2(struct net *net, __u16 num,
				struct udp_hslot *hslot2,
				struct sock *sk,
				int (*saddr_comp)(const struct sock *sk1,
						  const struct sock *sk2))
{
	struct sock *sk2;
	struct hlist_nulls_node *node;
	kuid_t uid = sock_i_uid(sk);
	int res = 0;

	spin_lock(&hslot2->lock);
	udp_portaddr_for_each_entry(sk2, node, &hslot2->head) {
		if (net_eq(sock_net(sk2), net) &&
		    sk2 != sk &&
		    (udp_sk(sk2)->udp_port_hash == num) &&
		    (!sk2->sk_reuse || !sk->sk_reuse) &&
		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
		     !uid_eq(uid, sock_i_uid(sk2))) &&
		    saddr_comp(sk, sk2)) {
			res = 1;
			break;
		}
	}
	spin_unlock(&hslot2->lock);
	return res;
}

/**
 *  udp_lib_get_port  -  UDP/-Lite port lookup for IPv4 and IPv6
 *
 *  @sk:          socket struct in question
 *  @snum:        port number to look up
 *  @saddr_comp:  AF-dependent comparison of bound local IP addresses
 *  @hash2_nulladdr: AF-dependent hash value in secondary hash chains,
 *                   with NULL address
 */
int udp_lib_get_port(struct sock *sk, unsigned short snum,
		     int (*saddr_comp)(const struct sock *sk1,
				       const struct sock *sk2),
		     unsigned int hash2_nulladdr)
{
	struct udp_hslot *hslot, *hslot2;
	struct udp_table *udptable = sk->sk_prot->h.udp_table;
	int    error = 1;
	struct net *net = sock_net(sk);

	if (!snum) {
		int low, high, remaining;
		unsigned int rand;
		unsigned short first, last;
		DECLARE_BITMAP(bitmap, PORTS_PER_CHAIN);

		inet_get_local_port_range(net, &low, &high);
		remaining = (high - low) + 1;

		rand = prandom_u32();
		first = reciprocal_scale(rand, remaining) + low;
		/*
		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
		 */
		rand = (rand | 1) * (udptable->mask + 1);
		last = first + udptable->mask + 1;
		do {
			hslot = udp_hashslot(udptable, net, first);
			bitmap_zero(bitmap, PORTS_PER_CHAIN);
			spin_lock_bh(&hslot->lock);
			udp_lib_lport_inuse(net, snum, hslot, bitmap, sk,
					    saddr_comp, udptable->log);

			snum = first;
			/*
			 * Iterate on all possible values of snum for this hash.
			 * Using steps of an odd multiple of UDP_HTABLE_SIZE
			 * give us randomization and full range coverage.
			 */
			do {
				if (low <= snum && snum <= high &&
				    !test_bit(snum >> udptable->log, bitmap) &&
				    !inet_is_local_reserved_port(net, snum))
					goto found;
				snum += rand;
			} while (snum != first);
			spin_unlock_bh(&hslot->lock);
		} while (++first != last);
		goto fail;
	} else {
		hslot = udp_hashslot(udptable, net, snum);
		spin_lock_bh(&hslot->lock);
		if (hslot->count > 10) {
			int exist;
			unsigned int slot2 = udp_sk(sk)->udp_portaddr_hash ^ snum;

			slot2          &= udptable->mask;
			hash2_nulladdr &= udptable->mask;

			hslot2 = udp_hashslot2(udptable, slot2);
			if (hslot->count < hslot2->count)
				goto scan_primary_hash;

			exist = udp_lib_lport_inuse2(net, snum, hslot2,
						     sk, saddr_comp);
			if (!exist && (hash2_nulladdr != slot2)) {
				hslot2 = udp_hashslot2(udptable, hash2_nulladdr);
				exist = udp_lib_lport_inuse2(net, snum, hslot2,
							     sk, saddr_comp);
			}
			if (exist)
				goto fail_unlock;
			else
				goto found;
		}
scan_primary_hash:
		if (udp_lib_lport_inuse(net, snum, hslot, NULL, sk,
					saddr_comp, 0))
			goto fail_unlock;
	}
found:
	inet_sk(sk)->inet_num = snum;
	udp_sk(sk)->udp_port_hash = snum;
	udp_sk(sk)->udp_portaddr_hash ^= snum;
	if (sk_unhashed(sk)) {
		sk_nulls_add_node_rcu(sk, &hslot->head);
		hslot->count++;
		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);

		hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
		spin_lock(&hslot2->lock);
		hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
					 &hslot2->head);
		hslot2->count++;
		spin_unlock(&hslot2->lock);
	}
	error = 0;
fail_unlock:
	spin_unlock_bh(&hslot->lock);
fail:
	return error;
}
EXPORT_SYMBOL(udp_lib_get_port);

static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
{
	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);

	return 	(!ipv6_only_sock(sk2)  &&
		 (!inet1->inet_rcv_saddr || !inet2->inet_rcv_saddr ||
		   inet1->inet_rcv_saddr == inet2->inet_rcv_saddr));
}

static unsigned int udp4_portaddr_hash(struct net *net, __be32 saddr,
				       unsigned int port)
{
	return jhash_1word((__force u32)saddr, net_hash_mix(net)) ^ port;
}

int udp_v4_get_port(struct sock *sk, unsigned short snum)
{
	unsigned int hash2_nulladdr =
		udp4_portaddr_hash(sock_net(sk), htonl(INADDR_ANY), snum);
	unsigned int hash2_partial =
		udp4_portaddr_hash(sock_net(sk), inet_sk(sk)->inet_rcv_saddr, 0);

	/* precompute partial secondary hash */
	udp_sk(sk)->udp_portaddr_hash = hash2_partial;
	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal, hash2_nulladdr);
}

static inline int compute_score(struct sock *sk, struct net *net,
				__be32 saddr, unsigned short hnum, __be16 sport,
				__be32 daddr, __be16 dport, int dif)
{
	int score;
	struct inet_sock *inet;

	if (!net_eq(sock_net(sk), net) ||
	    udp_sk(sk)->udp_port_hash != hnum ||
	    ipv6_only_sock(sk))
		return -1;

	score = (sk->sk_family == PF_INET) ? 2 : 1;
	inet = inet_sk(sk);

	if (inet->inet_rcv_saddr) {
		if (inet->inet_rcv_saddr != daddr)
			return -1;
		score += 4;
	}

	if (inet->inet_daddr) {
		if (inet->inet_daddr != saddr)
			return -1;
		score += 4;
	}

	if (inet->inet_dport) {
		if (inet->inet_dport != sport)
			return -1;
		score += 4;
	}

	if (sk->sk_bound_dev_if) {
		if (sk->sk_bound_dev_if != dif)
			return -1;
		score += 4;
	}

	return score;
}

/*
 * In this second variant, we check (daddr, dport) matches (inet_rcv_sadd, inet_num)
 */
static inline int compute_score2(struct sock *sk, struct net *net,
				 __be32 saddr, __be16 sport,
				 __be32 daddr, unsigned int hnum, int dif)
{
	int score;
	struct inet_sock *inet;

	if (!net_eq(sock_net(sk), net) ||
	    ipv6_only_sock(sk))
		return -1;

	inet = inet_sk(sk);

	if (inet->inet_rcv_saddr != daddr ||
	    inet->inet_num != hnum)
		return -1;

	score = (sk->sk_family == PF_INET) ? 2 : 1;

	if (inet->inet_daddr) {
		if (inet->inet_daddr != saddr)
			return -1;
		score += 4;
	}

	if (inet->inet_dport) {
		if (inet->inet_dport != sport)
			return -1;
		score += 4;
	}

	if (sk->sk_bound_dev_if) {
		if (sk->sk_bound_dev_if != dif)
			return -1;
		score += 4;
	}

	return score;
}

static unsigned int udp_ehashfn(struct net *net, const __be32 laddr,
				 const __u16 lport, const __be32 faddr,
				 const __be16 fport)
{
	static u32 udp_ehash_secret __read_mostly;

	net_get_random_once(&udp_ehash_secret, sizeof(udp_ehash_secret));

	return __inet_ehashfn(laddr, lport, faddr, fport,
			      udp_ehash_secret + net_hash_mix(net));
}


/* called with read_rcu_lock() */
static struct sock *udp4_lib_lookup2(struct net *net,
		__be32 saddr, __be16 sport,
		__be32 daddr, unsigned int hnum, int dif,
		struct udp_hslot *hslot2, unsigned int slot2)
{
	struct sock *sk, *result;
	struct hlist_nulls_node *node;
	int score, badness, matches = 0, reuseport = 0;
	u32 hash = 0;

begin:
	result = NULL;
	badness = 0;
	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
		score = compute_score2(sk, net, saddr, sport,
				      daddr, hnum, dif);
		if (score > badness) {
			result = sk;
			badness = score;
			reuseport = sk->sk_reuseport;
			if (reuseport) {
				hash = udp_ehashfn(net, daddr, hnum,
						   saddr, sport);
				matches = 1;
			}
		} else if (score == badness && reuseport) {
			matches++;
			if (reciprocal_scale(hash, matches) == 0)
				result = sk;
			hash = next_pseudo_random32(hash);
		}
	}
	/*
	 * if the nulls value we got at the end of this lookup is
	 * not the expected one, we must restart lookup.
	 * We probably met an item that was moved to another chain.
	 */
	if (get_nulls_value(node) != slot2)
		goto begin;
	if (result) {
		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
			result = NULL;
		else if (unlikely(compute_score2(result, net, saddr, sport,
				  daddr, hnum, dif) < badness)) {
			sock_put(result);
			goto begin;
		}
	}
	return result;
}

/* UDP is nearly always wildcards out the wazoo, it makes no sense to try
 * harder than this. -DaveM
 */
struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
		__be16 sport, __be32 daddr, __be16 dport,
		int dif, struct udp_table *udptable)
{
	struct sock *sk, *result;
	struct hlist_nulls_node *node;
	unsigned short hnum = ntohs(dport);
	unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
	int score, badness, matches = 0, reuseport = 0;
	u32 hash = 0;

	rcu_read_lock();
	if (hslot->count > 10) {
		hash2 = udp4_portaddr_hash(net, daddr, hnum);
		slot2 = hash2 & udptable->mask;
		hslot2 = &udptable->hash2[slot2];
		if (hslot->count < hslot2->count)
			goto begin;

		result = udp4_lib_lookup2(net, saddr, sport,
					  daddr, hnum, dif,
					  hslot2, slot2);
		if (!result) {
			hash2 = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
			slot2 = hash2 & udptable->mask;
			hslot2 = &udptable->hash2[slot2];
			if (hslot->count < hslot2->count)
				goto begin;

			result = udp4_lib_lookup2(net, saddr, sport,
						  htonl(INADDR_ANY), hnum, dif,
						  hslot2, slot2);
		}
		rcu_read_unlock();
		return result;
	}
begin:
	result = NULL;
	badness = 0;
	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
		score = compute_score(sk, net, saddr, hnum, sport,
				      daddr, dport, dif);
		if (score > badness) {
			result = sk;
			badness = score;
			reuseport = sk->sk_reuseport;
			if (reuseport) {
				hash = udp_ehashfn(net, daddr, hnum,
						   saddr, sport);
				matches = 1;
			}
		} else if (score == badness && reuseport) {
			matches++;
			if (reciprocal_scale(hash, matches) == 0)
				result = sk;
			hash = next_pseudo_random32(hash);
		}
	}
	/*
	 * if the nulls value we got at the end of this lookup is
	 * not the expected one, we must restart lookup.
	 * We probably met an item that was moved to another chain.
	 */
	if (get_nulls_value(node) != slot)
		goto begin;

	if (result) {
		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
			result = NULL;
		else if (unlikely(compute_score(result, net, saddr, hnum, sport,
				  daddr, dport, dif) < badness)) {
			sock_put(result);
			goto begin;
		}
	}
	rcu_read_unlock();
	return result;
}
EXPORT_SYMBOL_GPL(__udp4_lib_lookup);

static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
						 __be16 sport, __be16 dport,
						 struct udp_table *udptable)
{
	const struct iphdr *iph = ip_hdr(skb);

	return __udp4_lib_lookup(dev_net(skb_dst(skb)->dev), iph->saddr, sport,
				 iph->daddr, dport, inet_iif(skb),
				 udptable);
}

struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
			     __be32 daddr, __be16 dport, int dif)
{
	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif, &udp_table);
}
EXPORT_SYMBOL_GPL(udp4_lib_lookup);

static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
				       __be16 loc_port, __be32 loc_addr,
				       __be16 rmt_port, __be32 rmt_addr,
				       int dif, unsigned short hnum)
{
	struct inet_sock *inet = inet_sk(sk);

	if (!net_eq(sock_net(sk), net) ||
	    udp_sk(sk)->udp_port_hash != hnum ||
	    (inet->inet_daddr && inet->inet_daddr != rmt_addr) ||
	    (inet->inet_dport != rmt_port && inet->inet_dport) ||
	    (inet->inet_rcv_saddr && inet->inet_rcv_saddr != loc_addr) ||
	    ipv6_only_sock(sk) ||
	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
		return false;
	if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, dif))
		return false;
	return true;
}

/*
 * This routine is called by the ICMP module when it gets some
 * sort of error condition.  If err < 0 then the socket should
 * be closed and the error returned to the user.  If err > 0
 * it's just the icmp type << 8 | icmp code.
 * Header points to the ip header of the error packet. We move
 * on past this. Then (as it used to claim before adjustment)
 * header points to the first 8 bytes of the udp header.  We need
 * to find the appropriate port.
 */

void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
{
	struct inet_sock *inet;
	const struct iphdr *iph = (const struct iphdr *)skb->data;
	struct udphdr *uh = (struct udphdr *)(skb->data+(iph->ihl<<2));
	const int type = icmp_hdr(skb)->type;
	const int code = icmp_hdr(skb)->code;
	struct sock *sk;
	int harderr;
	int err;
	struct net *net = dev_net(skb->dev);

	sk = __udp4_lib_lookup(net, iph->daddr, uh->dest,
			iph->saddr, uh->source, skb->dev->ifindex, udptable);
	if (sk == NULL) {
		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
		return;	/* No socket for error */
	}

	err = 0;
	harderr = 0;
	inet = inet_sk(sk);

	switch (type) {
	default:
	case ICMP_TIME_EXCEEDED:
		err = EHOSTUNREACH;
		break;
	case ICMP_SOURCE_QUENCH:
		goto out;
	case ICMP_PARAMETERPROB:
		err = EPROTO;
		harderr = 1;
		break;
	case ICMP_DEST_UNREACH:
		if (code == ICMP_FRAG_NEEDED) { /* Path MTU discovery */
			ipv4_sk_update_pmtu(skb, sk, info);
			if (inet->pmtudisc != IP_PMTUDISC_DONT) {
				err = EMSGSIZE;
				harderr = 1;
				break;
			}
			goto out;
		}
		err = EHOSTUNREACH;
		if (code <= NR_ICMP_UNREACH) {
			harderr = icmp_err_convert[code].fatal;
			err = icmp_err_convert[code].errno;
		}
		break;
	case ICMP_REDIRECT:
		ipv4_sk_redirect(skb, sk);
		goto out;
	}

	/*
	 *      RFC1122: OK.  Passes ICMP errors back to application, as per
	 *	4.1.3.3.
	 */
	if (!inet->recverr) {
		if (!harderr || sk->sk_state != TCP_ESTABLISHED)
			goto out;
	} else
		ip_icmp_error(sk, skb, err, uh->dest, info, (u8 *)(uh+1));

	sk->sk_err = err;
	sk->sk_error_report(sk);
out:
	sock_put(sk);
}

void udp_err(struct sk_buff *skb, u32 info)
{
	__udp4_lib_err(skb, info, &udp_table);
}

/*
 * Throw away all pending data and cancel the corking. Socket is locked.
 */
void udp_flush_pending_frames(struct sock *sk)
{
	struct udp_sock *up = udp_sk(sk);

	if (up->pending) {
		up->len = 0;
		up->pending = 0;
		ip_flush_pending_frames(sk);
	}
}
EXPORT_SYMBOL(udp_flush_pending_frames);

/**
 * 	udp4_hwcsum  -  handle outgoing HW checksumming
 * 	@skb: 	sk_buff containing the filled-in UDP header
 * 	        (checksum field must be zeroed out)
 *	@src:	source IP address
 *	@dst:	destination IP address
 */
void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst)
{
	struct udphdr *uh = udp_hdr(skb);
	int offset = skb_transport_offset(skb);
	int len = skb->len - offset;
	int hlen = len;
	__wsum csum = 0;

	if (!skb_has_frag_list(skb)) {
		/*
		 * Only one fragment on the socket.
		 */
		skb->csum_start = skb_transport_header(skb) - skb->head;
		skb->csum_offset = offsetof(struct udphdr, check);
		uh->check = ~csum_tcpudp_magic(src, dst, len,
					       IPPROTO_UDP, 0);
	} else {
		struct sk_buff *frags;

		/*
		 * HW-checksum won't work as there are two or more
		 * fragments on the socket so that all csums of sk_buffs
		 * should be together
		 */
		skb_walk_frags(skb, frags) {
			csum = csum_add(csum, frags->csum);
			hlen -= frags->len;
		}

		csum = skb_checksum(skb, offset, hlen, csum);
		skb->ip_summed = CHECKSUM_NONE;

		uh->check = csum_tcpudp_magic(src, dst, len, IPPROTO_UDP, csum);
		if (uh->check == 0)
			uh->check = CSUM_MANGLED_0;
	}
}
EXPORT_SYMBOL_GPL(udp4_hwcsum);

/* Function to set UDP checksum for an IPv4 UDP packet. This is intended
 * for the simple case like when setting the checksum for a UDP tunnel.
 */
void udp_set_csum(bool nocheck, struct sk_buff *skb,
		  __be32 saddr, __be32 daddr, int len)
{
	struct udphdr *uh = udp_hdr(skb);

	if (nocheck)
		uh->check = 0;
	else if (skb_is_gso(skb))
		uh->check = ~udp_v4_check(len, saddr, daddr, 0);
	else if (skb_dst(skb) && skb_dst(skb)->dev &&
		 (skb_dst(skb)->dev->features & NETIF_F_V4_CSUM)) {

		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);

		skb->ip_summed = CHECKSUM_PARTIAL;
		skb->csum_start = skb_transport_header(skb) - skb->head;
		skb->csum_offset = offsetof(struct udphdr, check);
		uh->check = ~udp_v4_check(len, saddr, daddr, 0);
	} else {
		__wsum csum;

		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);

		uh->check = 0;
		csum = skb_checksum(skb, 0, len, 0);
		uh->check = udp_v4_check(len, saddr, daddr, csum);
		if (uh->check == 0)
			uh->check = CSUM_MANGLED_0;

		skb->ip_summed = CHECKSUM_UNNECESSARY;
	}
}
EXPORT_SYMBOL(udp_set_csum);

static int udp_send_skb(struct sk_buff *skb, struct flowi4 *fl4)
{
	struct sock *sk = skb->sk;
	struct inet_sock *inet = inet_sk(sk);
	struct udphdr *uh;
	int err = 0;
	int is_udplite = IS_UDPLITE(sk);
	int offset = skb_transport_offset(skb);
	int len = skb->len - offset;
	__wsum csum = 0;

	/*
	 * Create a UDP header
	 */
	uh = udp_hdr(skb);
	uh->source = inet->inet_sport;
	uh->dest = fl4->fl4_dport;
	uh->len = htons(len);
	uh->check = 0;

	if (is_udplite)  				 /*     UDP-Lite      */
		csum = udplite_csum(skb);

	else if (sk->sk_no_check_tx) {   /* UDP csum disabled */

		skb->ip_summed = CHECKSUM_NONE;
		goto send;

	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */

		udp4_hwcsum(skb, fl4->saddr, fl4->daddr);
		goto send;

	} else
		csum = udp_csum(skb);

	/* add protocol-dependent pseudo-header */
	uh->check = csum_tcpudp_magic(fl4->saddr, fl4->daddr, len,
				      sk->sk_protocol, csum);
	if (uh->check == 0)
		uh->check = CSUM_MANGLED_0;

send:
	err = ip_send_skb(sock_net(sk), skb);
	if (err) {
		if (err == -ENOBUFS && !inet->recverr) {
			UDP_INC_STATS_USER(sock_net(sk),
					   UDP_MIB_SNDBUFERRORS, is_udplite);
			err = 0;
		}
	} else
		UDP_INC_STATS_USER(sock_net(sk),
				   UDP_MIB_OUTDATAGRAMS, is_udplite);
	return err;
}

/*
 * Push out all pending data as one UDP datagram. Socket is locked.
 */
int udp_push_pending_frames(struct sock *sk)
{
	struct udp_sock  *up = udp_sk(sk);
	struct inet_sock *inet = inet_sk(sk);
	struct flowi4 *fl4 = &inet->cork.fl.u.ip4;
	struct sk_buff *skb;
	int err = 0;

	skb = ip_finish_skb(sk, fl4);
	if (!skb)
		goto out;

	err = udp_send_skb(skb, fl4);

out:
	up->len = 0;
	up->pending = 0;
	return err;
}
EXPORT_SYMBOL(udp_push_pending_frames);

int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
		size_t len)
{
	struct inet_sock *inet = inet_sk(sk);
	struct udp_sock *up = udp_sk(sk);
	struct flowi4 fl4_stack;
	struct flowi4 *fl4;
	int ulen = len;
	struct ipcm_cookie ipc;
	struct rtable *rt = NULL;
	int free = 0;
	int connected = 0;
	__be32 daddr, faddr, saddr;
	__be16 dport;
	u8  tos;
	int err, is_udplite = IS_UDPLITE(sk);
	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
	struct sk_buff *skb;
	struct ip_options_data opt_copy;

	if (len > (0xFFFF - sizeof(struct udphdr) - sizeof(struct iphdr)))
		return -EMSGSIZE;

	/*
	 *	Check the flags.
	 */

	if (msg->msg_flags & MSG_OOB) /* Mirror BSD error message compatibility */
		return -EOPNOTSUPP;

	ipc.opt = NULL;
	ipc.tx_flags = 0;
	ipc.ttl = 0;
	ipc.tos = -1;

	getfrag = is_udplite ? udplite_getfrag : ip_generic_getfrag;

	fl4 = &inet->cork.fl.u.ip4;
	if (up->pending) {
		/*
		 * There are pending frames.
		 * The socket lock must be held while it's corked.
		 */
		lock_sock(sk);
		if (likely(up->pending)) {
			if (unlikely(up->pending != AF_INET)) {
				release_sock(sk);
				return -EINVAL;
			}
			goto do_append_data;
		}
		release_sock(sk);
	}
	ulen += sizeof(struct udphdr);

	/*
	 *	Get and verify the address.
	 */
	if (msg->msg_name) {
		DECLARE_SOCKADDR(struct sockaddr_in *, usin, msg->msg_name);
		if (msg->msg_namelen < sizeof(*usin))
			return -EINVAL;
		if (usin->sin_family != AF_INET) {
			if (usin->sin_family != AF_UNSPEC)
				return -EAFNOSUPPORT;
		}

		daddr = usin->sin_addr.s_addr;
		dport = usin->sin_port;
		if (dport == 0)
			return -EINVAL;
	} else {
		if (sk->sk_state != TCP_ESTABLISHED)
			return -EDESTADDRREQ;
		daddr = inet->inet_daddr;
		dport = inet->inet_dport;
		/* Open fast path for connected socket.
		   Route will not be used, if at least one option is set.
		 */
		connected = 1;
	}
	ipc.addr = inet->inet_saddr;

	ipc.oif = sk->sk_bound_dev_if;

	sock_tx_timestamp(sk, &ipc.tx_flags);

	if (msg->msg_controllen) {
		err = ip_cmsg_send(sock_net(sk), msg, &ipc,
				   sk->sk_family == AF_INET6);
		if (err)
			return err;
		if (ipc.opt)
			free = 1;
		connected = 0;
	}
	if (!ipc.opt) {
		struct ip_options_rcu *inet_opt;

		rcu_read_lock();
		inet_opt = rcu_dereference(inet->inet_opt);
		if (inet_opt) {
			memcpy(&opt_copy, inet_opt,
			       sizeof(*inet_opt) + inet_opt->opt.optlen);
			ipc.opt = &opt_copy.opt;
		}
		rcu_read_unlock();
	}

	saddr = ipc.addr;
	ipc.addr = faddr = daddr;

	if (ipc.opt && ipc.opt->opt.srr) {
		if (!daddr)
			return -EINVAL;
		faddr = ipc.opt->opt.faddr;
		connected = 0;
	}
	tos = get_rttos(&ipc, inet);
	if (sock_flag(sk, SOCK_LOCALROUTE) ||
	    (msg->msg_flags & MSG_DONTROUTE) ||
	    (ipc.opt && ipc.opt->opt.is_strictroute)) {
		tos |= RTO_ONLINK;
		connected = 0;
	}

	if (ipv4_is_multicast(daddr)) {
		if (!ipc.oif)
			ipc.oif = inet->mc_index;
		if (!saddr)
			saddr = inet->mc_addr;
		connected = 0;
	} else if (!ipc.oif)
		ipc.oif = inet->uc_index;

	if (connected)
		rt = (struct rtable *)sk_dst_check(sk, 0);

	if (rt == NULL) {
		struct net *net = sock_net(sk);

		fl4 = &fl4_stack;
		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
				   inet_sk_flowi_flags(sk),
				   faddr, saddr, dport, inet->inet_sport);

		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
		rt = ip_route_output_flow(net, fl4, sk);
		if (IS_ERR(rt)) {
			err = PTR_ERR(rt);
			rt = NULL;
			if (err == -ENETUNREACH)
				IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
			goto out;
		}

		err = -EACCES;
		if ((rt->rt_flags & RTCF_BROADCAST) &&
		    !sock_flag(sk, SOCK_BROADCAST))
			goto out;
		if (connected)
			sk_dst_set(sk, dst_clone(&rt->dst));
	}

	if (msg->msg_flags&MSG_CONFIRM)
		goto do_confirm;
back_from_confirm:

	saddr = fl4->saddr;
	if (!ipc.addr)
		daddr = ipc.addr = fl4->daddr;

	/* Lockless fast path for the non-corking case. */
	if (!corkreq) {
		skb = ip_make_skb(sk, fl4, getfrag, msg, ulen,
				  sizeof(struct udphdr), &ipc, &rt,
				  msg->msg_flags);
		err = PTR_ERR(skb);
		if (!IS_ERR_OR_NULL(skb))
			err = udp_send_skb(skb, fl4);
		goto out;
	}

	lock_sock(sk);
	if (unlikely(up->pending)) {
		/* The socket is already corked while preparing it. */
		/* ... which is an evident application bug. --ANK */
		release_sock(sk);

		net_dbg_ratelimited("cork app bug 2\n");
		err = -EINVAL;
		goto out;
	}
	/*
	 *	Now cork the socket to pend data.
	 */
	fl4 = &inet->cork.fl.u.ip4;
	fl4->daddr = daddr;
	fl4->saddr = saddr;
	fl4->fl4_dport = dport;
	fl4->fl4_sport = inet->inet_sport;
	up->pending = AF_INET;

do_append_data:
	up->len += ulen;
	err = ip_append_data(sk, fl4, getfrag, msg, ulen,
			     sizeof(struct udphdr), &ipc, &rt,
			     corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
	if (err)
		udp_flush_pending_frames(sk);
	else if (!corkreq)
		err = udp_push_pending_frames(sk);
	else if (unlikely(skb_queue_empty(&sk->sk_write_queue)))
		up->pending = 0;
	release_sock(sk);

out:
	ip_rt_put(rt);
	if (free)
		kfree(ipc.opt);
	if (!err)
		return len;
	/*
	 * ENOBUFS = no kernel mem, SOCK_NOSPACE = no sndbuf space.  Reporting
	 * ENOBUFS might not be good (it's not tunable per se), but otherwise
	 * we don't have a good statistic (IpOutDiscards but it can be too many
	 * things).  We could add another new stat but at least for now that
	 * seems like overkill.
	 */
	if (err == -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
		UDP_INC_STATS_USER(sock_net(sk),
				UDP_MIB_SNDBUFERRORS, is_udplite);
	}
	return err;

do_confirm:
	dst_confirm(&rt->dst);
	if (!(msg->msg_flags&MSG_PROBE) || len)
		goto back_from_confirm;
	err = 0;
	goto out;
}
EXPORT_SYMBOL(udp_sendmsg);

int udp_sendpage(struct sock *sk, struct page *page, int offset,
		 size_t size, int flags)
{
	struct inet_sock *inet = inet_sk(sk);
	struct udp_sock *up = udp_sk(sk);
	int ret;

	if (flags & MSG_SENDPAGE_NOTLAST)
		flags |= MSG_MORE;

	if (!up->pending) {
		struct msghdr msg = {	.msg_flags = flags|MSG_MORE };

		/* Call udp_sendmsg to specify destination address which
		 * sendpage interface can't pass.
		 * This will succeed only when the socket is connected.
		 */
		ret = udp_sendmsg(NULL, sk, &msg, 0);
		if (ret < 0)
			return ret;
	}

	lock_sock(sk);

	if (unlikely(!up->pending)) {
		release_sock(sk);

		net_dbg_ratelimited("udp cork app bug 3\n");
		return -EINVAL;
	}

	ret = ip_append_page(sk, &inet->cork.fl.u.ip4,
			     page, offset, size, flags);
	if (ret == -EOPNOTSUPP) {
		release_sock(sk);
		return sock_no_sendpage(sk->sk_socket, page, offset,
					size, flags);
	}
	if (ret < 0) {
		udp_flush_pending_frames(sk);
		goto out;
	}

	up->len += size;
	if (!(up->corkflag || (flags&MSG_MORE)))
		ret = udp_push_pending_frames(sk);
	if (!ret)
		ret = size;
out:
	release_sock(sk);
	return ret;
}


/**
 *	first_packet_length	- return length of first packet in receive queue
 *	@sk: socket
 *
 *	Drops all bad checksum frames, until a valid one is found.
 *	Returns the length of found skb, or 0 if none is found.
 */
static unsigned int first_packet_length(struct sock *sk)
{
	struct sk_buff_head list_kill, *rcvq = &sk->sk_receive_queue;
	struct sk_buff *skb;
	unsigned int res;

	__skb_queue_head_init(&list_kill);

	spin_lock_bh(&rcvq->lock);
	while ((skb = skb_peek(rcvq)) != NULL &&
		udp_lib_checksum_complete(skb)) {
		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS,
				 IS_UDPLITE(sk));
		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
				 IS_UDPLITE(sk));
		atomic_inc(&sk->sk_drops);
		__skb_unlink(skb, rcvq);
		__skb_queue_tail(&list_kill, skb);
	}
	res = skb ? skb->len : 0;
	spin_unlock_bh(&rcvq->lock);

	if (!skb_queue_empty(&list_kill)) {
		bool slow = lock_sock_fast(sk);

		__skb_queue_purge(&list_kill);
		sk_mem_reclaim_partial(sk);
		unlock_sock_fast(sk, slow);
	}
	return res;
}

/*
 *	IOCTL requests applicable to the UDP protocol
 */

int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
{
	switch (cmd) {
	case SIOCOUTQ:
	{
		int amount = sk_wmem_alloc_get(sk);

		return put_user(amount, (int __user *)arg);
	}

	case SIOCINQ:
	{
		unsigned int amount = first_packet_length(sk);

		if (amount)
			/*
			 * We will only return the amount
			 * of this packet since that is all
			 * that will be read.
			 */
			amount -= sizeof(struct udphdr);

		return put_user(amount, (int __user *)arg);
	}

	default:
		return -ENOIOCTLCMD;
	}

	return 0;
}
EXPORT_SYMBOL(udp_ioctl);

/*
 * 	This should be easy, if there is something there we
 * 	return it, otherwise we block.
 */

int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
		size_t len, int noblock, int flags, int *addr_len)
{
	struct inet_sock *inet = inet_sk(sk);
	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
	struct sk_buff *skb;
	unsigned int ulen, copied;
	int peeked, off = 0;
	int err;
	int is_udplite = IS_UDPLITE(sk);
	bool slow;

	if (flags & MSG_ERRQUEUE)
		return ip_recv_error(sk, msg, len, addr_len);

try_again:
	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
				  &peeked, &off, &err);
	if (!skb)
		goto out;

	ulen = skb->len - sizeof(struct udphdr);
	copied = len;
	if (copied > ulen)
		copied = ulen;
	else if (copied < ulen)
		msg->msg_flags |= MSG_TRUNC;

	/*
	 * If checksum is needed at all, try to do it while copying the
	 * data.  If the data is truncated, or if we only want a partial
	 * coverage checksum (UDP-Lite), do it before the copy.
	 */

	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov) {
		if (udp_lib_checksum_complete(skb))
			goto csum_copy_err;
	}

	if (skb_csum_unnecessary(skb))
		err = skb_copy_datagram_msg(skb, sizeof(struct udphdr),
					    msg, copied);
	else {
		err = skb_copy_and_csum_datagram_msg(skb, sizeof(struct udphdr),
						     msg);

		if (err == -EINVAL)
			goto csum_copy_err;
	}

	if (unlikely(err)) {
		trace_kfree_skb(skb, udp_recvmsg);
		if (!peeked) {
			atomic_inc(&sk->sk_drops);
			UDP_INC_STATS_USER(sock_net(sk),
					   UDP_MIB_INERRORS, is_udplite);
		}
		goto out_free;
	}

	if (!peeked)
		UDP_INC_STATS_USER(sock_net(sk),
				UDP_MIB_INDATAGRAMS, is_udplite);

	sock_recv_ts_and_drops(msg, sk, skb);

	/* Copy the address. */
	if (sin) {
		sin->sin_family = AF_INET;
		sin->sin_port = udp_hdr(skb)->source;
		sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
		*addr_len = sizeof(*sin);
	}
	if (inet->cmsg_flags)
		ip_cmsg_recv(msg, skb);

	err = copied;
	if (flags & MSG_TRUNC)
		err = ulen;

out_free:
	skb_free_datagram_locked(sk, skb);
out:
	return err;

csum_copy_err:
	slow = lock_sock_fast(sk);
	if (!skb_kill_datagram(sk, skb, flags)) {
		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
	}
	unlock_sock_fast(sk, slow);

	if (noblock)
		return -EAGAIN;

	/* starting over for a new packet */
	msg->msg_flags &= ~MSG_TRUNC;
	goto try_again;
}


int udp_disconnect(struct sock *sk, int flags)
{
	struct inet_sock *inet = inet_sk(sk);
	/*
	 *	1003.1g - break association.
	 */

	sk->sk_state = TCP_CLOSE;
	inet->inet_daddr = 0;
	inet->inet_dport = 0;
	sock_rps_reset_rxhash(sk);
	sk->sk_bound_dev_if = 0;
	if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
		inet_reset_saddr(sk);

	if (!(sk->sk_userlocks & SOCK_BINDPORT_LOCK)) {
		sk->sk_prot->unhash(sk);
		inet->inet_sport = 0;
	}
	sk_dst_reset(sk);
	return 0;
}
EXPORT_SYMBOL(udp_disconnect);

void udp_lib_unhash(struct sock *sk)
{
	if (sk_hashed(sk)) {
		struct udp_table *udptable = sk->sk_prot->h.udp_table;
		struct udp_hslot *hslot, *hslot2;

		hslot  = udp_hashslot(udptable, sock_net(sk),
				      udp_sk(sk)->udp_port_hash);
		hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);

		spin_lock_bh(&hslot->lock);
		if (sk_nulls_del_node_init_rcu(sk)) {
			hslot->count--;
			inet_sk(sk)->inet_num = 0;
			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);

			spin_lock(&hslot2->lock);
			hlist_nulls_del_init_rcu(&udp_sk(sk)->udp_portaddr_node);
			hslot2->count--;
			spin_unlock(&hslot2->lock);
		}
		spin_unlock_bh(&hslot->lock);
	}
}
EXPORT_SYMBOL(udp_lib_unhash);

/*
 * inet_rcv_saddr was changed, we must rehash secondary hash
 */
void udp_lib_rehash(struct sock *sk, u16 newhash)
{
	if (sk_hashed(sk)) {
		struct udp_table *udptable = sk->sk_prot->h.udp_table;
		struct udp_hslot *hslot, *hslot2, *nhslot2;

		hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
		nhslot2 = udp_hashslot2(udptable, newhash);
		udp_sk(sk)->udp_portaddr_hash = newhash;
		if (hslot2 != nhslot2) {
			hslot = udp_hashslot(udptable, sock_net(sk),
					     udp_sk(sk)->udp_port_hash);
			/* we must lock primary chain too */
			spin_lock_bh(&hslot->lock);

			spin_lock(&hslot2->lock);
			hlist_nulls_del_init_rcu(&udp_sk(sk)->udp_portaddr_node);
			hslot2->count--;
			spin_unlock(&hslot2->lock);

			spin_lock(&nhslot2->lock);
			hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
						 &nhslot2->head);
			nhslot2->count++;
			spin_unlock(&nhslot2->lock);

			spin_unlock_bh(&hslot->lock);
		}
	}
}
EXPORT_SYMBOL(udp_lib_rehash);

static void udp_v4_rehash(struct sock *sk)
{
	u16 new_hash = udp4_portaddr_hash(sock_net(sk),
					  inet_sk(sk)->inet_rcv_saddr,
					  inet_sk(sk)->inet_num);
	udp_lib_rehash(sk, new_hash);
}

static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
{
	int rc;

	if (inet_sk(sk)->inet_daddr) {
		sock_rps_save_rxhash(sk, skb);
		sk_mark_napi_id(sk, skb);
		sk_incoming_cpu_update(sk);
	}

	rc = sock_queue_rcv_skb(sk, skb);
	if (rc < 0) {
		int is_udplite = IS_UDPLITE(sk);

		/* Note that an ENOMEM error is charged twice */
		if (rc == -ENOMEM)
			UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
					 is_udplite);
		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
		kfree_skb(skb);
		trace_udp_fail_queue_rcv_skb(rc, sk);
		return -1;
	}

	return 0;

}

static struct static_key udp_encap_needed __read_mostly;
void udp_encap_enable(void)
{
	if (!static_key_enabled(&udp_encap_needed))
		static_key_slow_inc(&udp_encap_needed);
}
EXPORT_SYMBOL(udp_encap_enable);

/* returns:
 *  -1: error
 *   0: success
 *  >0: "udp encap" protocol resubmission
 *
 * Note that in the success and error cases, the skb is assumed to
 * have either been requeued or freed.
 */
int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
{
	struct udp_sock *up = udp_sk(sk);
	int rc;
	int is_udplite = IS_UDPLITE(sk);

	/*
	 *	Charge it to the socket, dropping if the queue is full.
	 */
	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
		goto drop;
	nf_reset(skb);

	if (static_key_false(&udp_encap_needed) && up->encap_type) {
		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);

		/*
		 * This is an encapsulation socket so pass the skb to
		 * the socket's udp_encap_rcv() hook. Otherwise, just
		 * fall through and pass this up the UDP socket.
		 * up->encap_rcv() returns the following value:
		 * =0 if skb was successfully passed to the encap
		 *    handler or was discarded by it.
		 * >0 if skb should be passed on to UDP.
		 * <0 if skb should be resubmitted as proto -N
		 */

		/* if we're overly short, let UDP handle it */
		encap_rcv = ACCESS_ONCE(up->encap_rcv);
		if (skb->len > sizeof(struct udphdr) && encap_rcv != NULL) {
			int ret;

			/* Verify checksum before giving to encap */
			if (udp_lib_checksum_complete(skb))
				goto csum_error;

			ret = encap_rcv(sk, skb);
			if (ret <= 0) {
				UDP_INC_STATS_BH(sock_net(sk),
						 UDP_MIB_INDATAGRAMS,
						 is_udplite);
				return -ret;
			}
		}

		/* FALLTHROUGH -- it's a UDP Packet */
	}

	/*
	 * 	UDP-Lite specific tests, ignored on UDP sockets
	 */
	if ((is_udplite & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {

		/*
		 * MIB statistics other than incrementing the error count are
		 * disabled for the following two types of errors: these depend
		 * on the application settings, not on the functioning of the
		 * protocol stack as such.
		 *
		 * RFC 3828 here recommends (sec 3.3): "There should also be a
		 * way ... to ... at least let the receiving application block
		 * delivery of packets with coverage values less than a value
		 * provided by the application."
		 */
		if (up->pcrlen == 0) {          /* full coverage was set  */
			net_dbg_ratelimited("UDPLite: partial coverage %d while full coverage %d requested\n",
					    UDP_SKB_CB(skb)->cscov, skb->len);
			goto drop;
		}
		/* The next case involves violating the min. coverage requested
		 * by the receiver. This is subtle: if receiver wants x and x is
		 * greater than the buffersize/MTU then receiver will complain
		 * that it wants x while sender emits packets of smaller size y.
		 * Therefore the above ...()->partial_cov statement is essential.
		 */
		if (UDP_SKB_CB(skb)->cscov  <  up->pcrlen) {
			net_dbg_ratelimited("UDPLite: coverage %d too small, need min %d\n",
					    UDP_SKB_CB(skb)->cscov, up->pcrlen);
			goto drop;
		}
	}

	if (rcu_access_pointer(sk->sk_filter) &&
	    udp_lib_checksum_complete(skb))
		goto csum_error;


	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
				 is_udplite);
		goto drop;
	}

	rc = 0;

	ipv4_pktinfo_prepare(sk, skb);
	bh_lock_sock(sk);
	if (!sock_owned_by_user(sk))
		rc = __udp_queue_rcv_skb(sk, skb);
	else if (sk_add_backlog(sk, skb, sk->sk_rcvbuf)) {
		bh_unlock_sock(sk);
		goto drop;
	}
	bh_unlock_sock(sk);

	return rc;

csum_error:
	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
drop:
	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
	atomic_inc(&sk->sk_drops);
	kfree_skb(skb);
	return -1;
}


static void flush_stack(struct sock **stack, unsigned int count,
			struct sk_buff *skb, unsigned int final)
{
	unsigned int i;
	struct sk_buff *skb1 = NULL;
	struct sock *sk;

	for (i = 0; i < count; i++) {
		sk = stack[i];
		if (likely(skb1 == NULL))
			skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);

		if (!skb1) {
			atomic_inc(&sk->sk_drops);
			UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
					 IS_UDPLITE(sk));
			UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
					 IS_UDPLITE(sk));
		}

		if (skb1 && udp_queue_rcv_skb(sk, skb1) <= 0)
			skb1 = NULL;

		sock_put(sk);
	}
	if (unlikely(skb1))
		kfree_skb(skb1);
}

/* For TCP sockets, sk_rx_dst is protected by socket lock
 * For UDP, we use xchg() to guard against concurrent changes.
 */
static void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
{
	struct dst_entry *old;

	dst_hold(dst);
	old = xchg(&sk->sk_rx_dst, dst);
	dst_release(old);
}

/*
 *	Multicasts and broadcasts go to each listener.
 *
 *	Note: called only from the BH handler context.
 */
static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
				    struct udphdr  *uh,
				    __be32 saddr, __be32 daddr,
				    struct udp_table *udptable,
				    int proto)
{
	struct sock *sk, *stack[256 / sizeof(struct sock *)];
	struct hlist_nulls_node *node;
	unsigned short hnum = ntohs(uh->dest);
	struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
	int dif = skb->dev->ifindex;
	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
	bool inner_flushed = false;

	if (use_hash2) {
		hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
			    udp_table.mask;
		hash2 = udp4_portaddr_hash(net, daddr, hnum) & udp_table.mask;
start_lookup:
		hslot = &udp_table.hash2[hash2];
		offset = offsetof(typeof(*sk), __sk_common.skc_portaddr_node);
	}

	spin_lock(&hslot->lock);
	sk_nulls_for_each_entry_offset(sk, node, &hslot->head, offset) {
		if (__udp_is_mcast_sock(net, sk,
					uh->dest, daddr,
					uh->source, saddr,
					dif, hnum)) {
			if (unlikely(count == ARRAY_SIZE(stack))) {
				flush_stack(stack, count, skb, ~0);
				inner_flushed = true;
				count = 0;
			}
			stack[count++] = sk;
			sock_hold(sk);
		}
	}

	spin_unlock(&hslot->lock);

	/* Also lookup *:port if we are using hash2 and haven't done so yet. */
	if (use_hash2 && hash2 != hash2_any) {
		hash2 = hash2_any;
		goto start_lookup;
	}

	/*
	 * do the slow work with no lock held
	 */
	if (count) {
		flush_stack(stack, count, skb, count - 1);
	} else {
		if (!inner_flushed)
			UDP_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
					 proto == IPPROTO_UDPLITE);
		consume_skb(skb);
	}
	return 0;
}

/* Initialize UDP checksum. If exited with zero value (success),
 * CHECKSUM_UNNECESSARY means, that no more checks are required.
 * Otherwise, csum completion requires chacksumming packet body,
 * including udp header and folding it to skb->csum.
 */
static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
				 int proto)
{
	int err;

	UDP_SKB_CB(skb)->partial_cov = 0;
	UDP_SKB_CB(skb)->cscov = skb->len;

	if (proto == IPPROTO_UDPLITE) {
		err = udplite_checksum_init(skb, uh);
		if (err)
			return err;
	}

	return skb_checksum_init_zero_check(skb, proto, uh->check,
					    inet_compute_pseudo);
}

/*
 *	All we need to do is get the socket, and then do a checksum.
 */

int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
		   int proto)
{
	struct sock *sk;
	struct udphdr *uh;
	unsigned short ulen;
	struct rtable *rt = skb_rtable(skb);
	__be32 saddr, daddr;
	struct net *net = dev_net(skb->dev);

	/*
	 *  Validate the packet.
	 */
	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
		goto drop;		/* No space for header. */

	uh   = udp_hdr(skb);
	ulen = ntohs(uh->len);
	saddr = ip_hdr(skb)->saddr;
	daddr = ip_hdr(skb)->daddr;

	if (ulen > skb->len)
		goto short_packet;

	if (proto == IPPROTO_UDP) {
		/* UDP validates ulen. */
		if (ulen < sizeof(*uh) || pskb_trim_rcsum(skb, ulen))
			goto short_packet;
		uh = udp_hdr(skb);
	}

	if (udp4_csum_init(skb, uh, proto))
		goto csum_error;

	sk = skb_steal_sock(skb);
	if (sk) {
		struct dst_entry *dst = skb_dst(skb);
		int ret;

		if (unlikely(sk->sk_rx_dst != dst))
			udp_sk_rx_dst_set(sk, dst);

		ret = udp_queue_rcv_skb(sk, skb);
		sock_put(sk);
		/* a return value > 0 means to resubmit the input, but
		 * it wants the return to be -protocol, or 0
		 */
		if (ret > 0)
			return -ret;
		return 0;
	}

	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
		return __udp4_lib_mcast_deliver(net, skb, uh,
						saddr, daddr, udptable, proto);

	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
	if (sk != NULL) {
		int ret;

		if (udp_sk(sk)->convert_csum && uh->check && !IS_UDPLITE(sk))
			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
						 inet_compute_pseudo);

		ret = udp_queue_rcv_skb(sk, skb);
		sock_put(sk);

		/* a return value > 0 means to resubmit the input, but
		 * it wants the return to be -protocol, or 0
		 */
		if (ret > 0)
			return -ret;
		return 0;
	}

	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
		goto drop;
	nf_reset(skb);

	/* No socket. Drop packet silently, if checksum is wrong */
	if (udp_lib_checksum_complete(skb))
		goto csum_error;

	UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);

	/*
	 * Hmm.  We got an UDP packet to a port to which we
	 * don't wanna listen.  Ignore it.
	 */
	kfree_skb(skb);
	return 0;

short_packet:
	net_dbg_ratelimited("UDP%s: short packet: From %pI4:%u %d/%d to %pI4:%u\n",
			    proto == IPPROTO_UDPLITE ? "Lite" : "",
			    &saddr, ntohs(uh->source),
			    ulen, skb->len,
			    &daddr, ntohs(uh->dest));
	goto drop;

csum_error:
	/*
	 * RFC1122: OK.  Discards the bad packet silently (as far as
	 * the network is concerned, anyway) as per 4.1.3.4 (MUST).
	 */
	net_dbg_ratelimited("UDP%s: bad checksum. From %pI4:%u to %pI4:%u ulen %d\n",
			    proto == IPPROTO_UDPLITE ? "Lite" : "",
			    &saddr, ntohs(uh->source), &daddr, ntohs(uh->dest),
			    ulen);
	UDP_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
drop:
	UDP_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
	kfree_skb(skb);
	return 0;
}

/* We can only early demux multicast if there is a single matching socket.
 * If more than one socket found returns NULL
 */
static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
						  __be16 loc_port, __be32 loc_addr,
						  __be16 rmt_port, __be32 rmt_addr,
						  int dif)
{
	struct sock *sk, *result;
	struct hlist_nulls_node *node;
	unsigned short hnum = ntohs(loc_port);
	unsigned int count, slot = udp_hashfn(net, hnum, udp_table.mask);
	struct udp_hslot *hslot = &udp_table.hash[slot];

	/* Do not bother scanning a too big list */
	if (hslot->count > 10)
		return NULL;

	rcu_read_lock();
begin:
	count = 0;
	result = NULL;
	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
		if (__udp_is_mcast_sock(net, sk,
					loc_port, loc_addr,
					rmt_port, rmt_addr,
					dif, hnum)) {
			result = sk;
			++count;
		}
	}
	/*
	 * if the nulls value we got at the end of this lookup is
	 * not the expected one, we must restart lookup.
	 * We probably met an item that was moved to another chain.
	 */
	if (get_nulls_value(node) != slot)
		goto begin;

	if (result) {
		if (count != 1 ||
		    unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
			result = NULL;
		else if (unlikely(!__udp_is_mcast_sock(net, result,
						       loc_port, loc_addr,
						       rmt_port, rmt_addr,
						       dif, hnum))) {
			sock_put(result);
			result = NULL;
		}
	}
	rcu_read_unlock();
	return result;
}

/* For unicast we should only early demux connected sockets or we can
 * break forwarding setups.  The chains here can be long so only check
 * if the first socket is an exact match and if not move on.
 */
static struct sock *__udp4_lib_demux_lookup(struct net *net,
					    __be16 loc_port, __be32 loc_addr,
					    __be16 rmt_port, __be32 rmt_addr,
					    int dif)
{
	struct sock *sk, *result;
	struct hlist_nulls_node *node;
	unsigned short hnum = ntohs(loc_port);
	unsigned int hash2 = udp4_portaddr_hash(net, loc_addr, hnum);
	unsigned int slot2 = hash2 & udp_table.mask;
	struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
	INET_ADDR_COOKIE(acookie, rmt_addr, loc_addr);
	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);

	rcu_read_lock();
	result = NULL;
	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
		if (INET_MATCH(sk, net, acookie,
			       rmt_addr, loc_addr, ports, dif))
			result = sk;
		/* Only check first socket in chain */
		break;
	}

	if (result) {
		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
			result = NULL;
		else if (unlikely(!INET_MATCH(sk, net, acookie,
					      rmt_addr, loc_addr,
					      ports, dif))) {
			sock_put(result);
			result = NULL;
		}
	}
	rcu_read_unlock();
	return result;
}

void udp_v4_early_demux(struct sk_buff *skb)
{
	struct net *net = dev_net(skb->dev);
	const struct iphdr *iph;
	const struct udphdr *uh;
	struct sock *sk;
	struct dst_entry *dst;
	int dif = skb->dev->ifindex;

	/* validate the packet */
	if (!pskb_may_pull(skb, skb_transport_offset(skb) + sizeof(struct udphdr)))
		return;

	iph = ip_hdr(skb);
	uh = udp_hdr(skb);

	if (skb->pkt_type == PACKET_BROADCAST ||
	    skb->pkt_type == PACKET_MULTICAST)
		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
						   uh->source, iph->saddr, dif);
	else if (skb->pkt_type == PACKET_HOST)
		sk = __udp4_lib_demux_lookup(net, uh->dest, iph->daddr,
					     uh->source, iph->saddr, dif);
	else
		return;

	if (!sk)
		return;

	skb->sk = sk;
	skb->destructor = sock_efree;
	dst = sk->sk_rx_dst;

	if (dst)
		dst = dst_check(dst, 0);
	if (dst)
		skb_dst_set_noref(skb, dst);
}

int udp_rcv(struct sk_buff *skb)
{
	return __udp4_lib_rcv(skb, &udp_table, IPPROTO_UDP);
}

void udp_destroy_sock(struct sock *sk)
{
	struct udp_sock *up = udp_sk(sk);
	bool slow = lock_sock_fast(sk);
	udp_flush_pending_frames(sk);
	unlock_sock_fast(sk, slow);
	if (static_key_false(&udp_encap_needed) && up->encap_type) {
		void (*encap_destroy)(struct sock *sk);
		encap_destroy = ACCESS_ONCE(up->encap_destroy);
		if (encap_destroy)
			encap_destroy(sk);
	}
}

/*
 *	Socket option code for UDP
 */
int udp_lib_setsockopt(struct sock *sk, int level, int optname,
		       char __user *optval, unsigned int optlen,
		       int (*push_pending_frames)(struct sock *))
{
	struct udp_sock *up = udp_sk(sk);
	int val, valbool;
	int err = 0;
	int is_udplite = IS_UDPLITE(sk);

	if (optlen < sizeof(int))
		return -EINVAL;

	if (get_user(val, (int __user *)optval))
		return -EFAULT;

	valbool = val ? 1 : 0;

	switch (optname) {
	case UDP_CORK:
		if (val != 0) {
			up->corkflag = 1;
		} else {
			up->corkflag = 0;
			lock_sock(sk);
			push_pending_frames(sk);
			release_sock(sk);
		}
		break;

	case UDP_ENCAP:
		switch (val) {
		case 0:
		case UDP_ENCAP_ESPINUDP:
		case UDP_ENCAP_ESPINUDP_NON_IKE:
			up->encap_rcv = xfrm4_udp_encap_rcv;
			/* FALLTHROUGH */
		case UDP_ENCAP_L2TPINUDP:
			up->encap_type = val;
			udp_encap_enable();
			break;
		default:
			err = -ENOPROTOOPT;
			break;
		}
		break;

	case UDP_NO_CHECK6_TX:
		up->no_check6_tx = valbool;
		break;

	case UDP_NO_CHECK6_RX:
		up->no_check6_rx = valbool;
		break;

	/*
	 * 	UDP-Lite's partial checksum coverage (RFC 3828).
	 */
	/* The sender sets actual checksum coverage length via this option.
	 * The case coverage > packet length is handled by send module. */
	case UDPLITE_SEND_CSCOV:
		if (!is_udplite)         /* Disable the option on UDP sockets */
			return -ENOPROTOOPT;
		if (val != 0 && val < 8) /* Illegal coverage: use default (8) */
			val = 8;
		else if (val > USHRT_MAX)
			val = USHRT_MAX;
		up->pcslen = val;
		up->pcflag |= UDPLITE_SEND_CC;
		break;

	/* The receiver specifies a minimum checksum coverage value. To make
	 * sense, this should be set to at least 8 (as done below). If zero is
	 * used, this again means full checksum coverage.                     */
	case UDPLITE_RECV_CSCOV:
		if (!is_udplite)         /* Disable the option on UDP sockets */
			return -ENOPROTOOPT;
		if (val != 0 && val < 8) /* Avoid silly minimal values.       */
			val = 8;
		else if (val > USHRT_MAX)
			val = USHRT_MAX;
		up->pcrlen = val;
		up->pcflag |= UDPLITE_RECV_CC;
		break;

	default:
		err = -ENOPROTOOPT;
		break;
	}

	return err;
}
EXPORT_SYMBOL(udp_lib_setsockopt);

int udp_setsockopt(struct sock *sk, int level, int optname,
		   char __user *optval, unsigned int optlen)
{
	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
					  udp_push_pending_frames);
	return ip_setsockopt(sk, level, optname, optval, optlen);
}

#ifdef CONFIG_COMPAT
int compat_udp_setsockopt(struct sock *sk, int level, int optname,
			  char __user *optval, unsigned int optlen)
{
	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
					  udp_push_pending_frames);
	return compat_ip_setsockopt(sk, level, optname, optval, optlen);
}
#endif

int udp_lib_getsockopt(struct sock *sk, int level, int optname,
		       char __user *optval, int __user *optlen)
{
	struct udp_sock *up = udp_sk(sk);
	int val, len;

	if (get_user(len, optlen))
		return -EFAULT;

	len = min_t(unsigned int, len, sizeof(int));

	if (len < 0)
		return -EINVAL;

	switch (optname) {
	case UDP_CORK:
		val = up->corkflag;
		break;

	case UDP_ENCAP:
		val = up->encap_type;
		break;

	case UDP_NO_CHECK6_TX:
		val = up->no_check6_tx;
		break;

	case UDP_NO_CHECK6_RX:
		val = up->no_check6_rx;
		break;

	/* The following two cannot be changed on UDP sockets, the return is
	 * always 0 (which corresponds to the full checksum coverage of UDP). */
	case UDPLITE_SEND_CSCOV:
		val = up->pcslen;
		break;

	case UDPLITE_RECV_CSCOV:
		val = up->pcrlen;
		break;

	default:
		return -ENOPROTOOPT;
	}

	if (put_user(len, optlen))
		return -EFAULT;
	if (copy_to_user(optval, &val, len))
		return -EFAULT;
	return 0;
}
EXPORT_SYMBOL(udp_lib_getsockopt);

int udp_getsockopt(struct sock *sk, int level, int optname,
		   char __user *optval, int __user *optlen)
{
	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
		return udp_lib_getsockopt(sk, level, optname, optval, optlen);
	return ip_getsockopt(sk, level, optname, optval, optlen);
}

#ifdef CONFIG_COMPAT
int compat_udp_getsockopt(struct sock *sk, int level, int optname,
				 char __user *optval, int __user *optlen)
{
	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
		return udp_lib_getsockopt(sk, level, optname, optval, optlen);
	return compat_ip_getsockopt(sk, level, optname, optval, optlen);
}
#endif
/**
 * 	udp_poll - wait for a UDP event.
 *	@file - file struct
 *	@sock - socket
 *	@wait - poll table
 *
 *	This is same as datagram poll, except for the special case of
 *	blocking sockets. If application is using a blocking fd
 *	and a packet with checksum error is in the queue;
 *	then it could get return from select indicating data available
 *	but then block when reading it. Add special case code
 *	to work around these arguably broken applications.
 */
unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
{
	unsigned int mask = datagram_poll(file, sock, wait);
	struct sock *sk = sock->sk;

	sock_rps_record_flow(sk);

	/* Check for false positives due to checksum errors */
	if ((mask & POLLRDNORM) && !(file->f_flags & O_NONBLOCK) &&
	    !(sk->sk_shutdown & RCV_SHUTDOWN) && !first_packet_length(sk))
		mask &= ~(POLLIN | POLLRDNORM);

	return mask;

}
EXPORT_SYMBOL(udp_poll);

struct proto udp_prot = {
	.name		   = "UDP",
	.owner		   = THIS_MODULE,
	.close		   = udp_lib_close,
	.connect	   = ip4_datagram_connect,
	.disconnect	   = udp_disconnect,
	.ioctl		   = udp_ioctl,
	.destroy	   = udp_destroy_sock,
	.setsockopt	   = udp_setsockopt,
	.getsockopt	   = udp_getsockopt,
	.sendmsg	   = udp_sendmsg,
	.recvmsg	   = udp_recvmsg,
	.sendpage	   = udp_sendpage,
	.backlog_rcv	   = __udp_queue_rcv_skb,
	.release_cb	   = ip4_datagram_release_cb,
	.hash		   = udp_lib_hash,
	.unhash		   = udp_lib_unhash,
	.rehash		   = udp_v4_rehash,
	.get_port	   = udp_v4_get_port,
	.memory_allocated  = &udp_memory_allocated,
	.sysctl_mem	   = sysctl_udp_mem,
	.sysctl_wmem	   = &sysctl_udp_wmem_min,
	.sysctl_rmem	   = &sysctl_udp_rmem_min,
	.obj_size	   = sizeof(struct udp_sock),
	.slab_flags	   = SLAB_DESTROY_BY_RCU,
	.h.udp_table	   = &udp_table,
#ifdef CONFIG_COMPAT
	.compat_setsockopt = compat_udp_setsockopt,
	.compat_getsockopt = compat_udp_getsockopt,
#endif
	.clear_sk	   = sk_prot_clear_portaddr_nulls,
};
EXPORT_SYMBOL(udp_prot);

/* ------------------------------------------------------------------------ */
#ifdef CONFIG_PROC_FS

static struct sock *udp_get_first(struct seq_file *seq, int start)
{
	struct sock *sk;
	struct udp_iter_state *state = seq->private;
	struct net *net = seq_file_net(seq);

	for (state->bucket = start; state->bucket <= state->udp_table->mask;
	     ++state->bucket) {
		struct hlist_nulls_node *node;
		struct udp_hslot *hslot = &state->udp_table->hash[state->bucket];

		if (hlist_nulls_empty(&hslot->head))
			continue;

		spin_lock_bh(&hslot->lock);
		sk_nulls_for_each(sk, node, &hslot->head) {
			if (!net_eq(sock_net(sk), net))
				continue;
			if (sk->sk_family == state->family)
				goto found;
		}
		spin_unlock_bh(&hslot->lock);
	}
	sk = NULL;
found:
	return sk;
}

static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
{
	struct udp_iter_state *state = seq->private;
	struct net *net = seq_file_net(seq);

	do {
		sk = sk_nulls_next(sk);
	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family != state->family));

	if (!sk) {
		if (state->bucket <= state->udp_table->mask)
			spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
		return udp_get_first(seq, state->bucket + 1);
	}
	return sk;
}

static struct sock *udp_get_idx(struct seq_file *seq, loff_t pos)
{
	struct sock *sk = udp_get_first(seq, 0);

	if (sk)
		while (pos && (sk = udp_get_next(seq, sk)) != NULL)
			--pos;
	return pos ? NULL : sk;
}

static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
{
	struct udp_iter_state *state = seq->private;
	state->bucket = MAX_UDP_PORTS;

	return *pos ? udp_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
}

static void *udp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
{
	struct sock *sk;

	if (v == SEQ_START_TOKEN)
		sk = udp_get_idx(seq, 0);
	else
		sk = udp_get_next(seq, v);

	++*pos;
	return sk;
}

static void udp_seq_stop(struct seq_file *seq, void *v)
{
	struct udp_iter_state *state = seq->private;

	if (state->bucket <= state->udp_table->mask)
		spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
}

int udp_seq_open(struct inode *inode, struct file *file)
{
	struct udp_seq_afinfo *afinfo = PDE_DATA(inode);
	struct udp_iter_state *s;
	int err;

	err = seq_open_net(inode, file, &afinfo->seq_ops,
			   sizeof(struct udp_iter_state));
	if (err < 0)
		return err;

	s = ((struct seq_file *)file->private_data)->private;
	s->family		= afinfo->family;
	s->udp_table		= afinfo->udp_table;
	return err;
}
EXPORT_SYMBOL(udp_seq_open);

/* ------------------------------------------------------------------------ */
int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
{
	struct proc_dir_entry *p;
	int rc = 0;

	afinfo->seq_ops.start		= udp_seq_start;
	afinfo->seq_ops.next		= udp_seq_next;
	afinfo->seq_ops.stop		= udp_seq_stop;

	p = proc_create_data(afinfo->name, S_IRUGO, net->proc_net,
			     afinfo->seq_fops, afinfo);
	if (!p)
		rc = -ENOMEM;
	return rc;
}
EXPORT_SYMBOL(udp_proc_register);

void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo)
{
	remove_proc_entry(afinfo->name, net->proc_net);
}
EXPORT_SYMBOL(udp_proc_unregister);

/* ------------------------------------------------------------------------ */
static void udp4_format_sock(struct sock *sp, struct seq_file *f,
		int bucket)
{
	struct inet_sock *inet = inet_sk(sp);
	__be32 dest = inet->inet_daddr;
	__be32 src  = inet->inet_rcv_saddr;
	__u16 destp	  = ntohs(inet->inet_dport);
	__u16 srcp	  = ntohs(inet->inet_sport);

	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d",
		bucket, src, srcp, dest, destp, sp->sk_state,
		sk_wmem_alloc_get(sp),
		sk_rmem_alloc_get(sp),
		0, 0L, 0,
		from_kuid_munged(seq_user_ns(f), sock_i_uid(sp)),
		0, sock_i_ino(sp),
		atomic_read(&sp->sk_refcnt), sp,
		atomic_read(&sp->sk_drops));
}

int udp4_seq_show(struct seq_file *seq, void *v)
{
	seq_setwidth(seq, 127);
	if (v == SEQ_START_TOKEN)
		seq_puts(seq, "  sl  local_address rem_address   st tx_queue "
			   "rx_queue tr tm->when retrnsmt   uid  timeout "
			   "inode ref pointer drops");
	else {
		struct udp_iter_state *state = seq->private;

		udp4_format_sock(v, seq, state->bucket);
	}
	seq_pad(seq, '\n');
	return 0;
}

static const struct file_operations udp_afinfo_seq_fops = {
	.owner    = THIS_MODULE,
	.open     = udp_seq_open,
	.read     = seq_read,
	.llseek   = seq_lseek,
	.release  = seq_release_net
};

/* ------------------------------------------------------------------------ */
static struct udp_seq_afinfo udp4_seq_afinfo = {
	.name		= "udp",
	.family		= AF_INET,
	.udp_table	= &udp_table,
	.seq_fops	= &udp_afinfo_seq_fops,
	.seq_ops	= {
		.show		= udp4_seq_show,
	},
};

static int __net_init udp4_proc_init_net(struct net *net)
{
	return udp_proc_register(net, &udp4_seq_afinfo);
}

static void __net_exit udp4_proc_exit_net(struct net *net)
{
	udp_proc_unregister(net, &udp4_seq_afinfo);
}

static struct pernet_operations udp4_net_ops = {
	.init = udp4_proc_init_net,
	.exit = udp4_proc_exit_net,
};

int __init udp4_proc_init(void)
{
	return register_pernet_subsys(&udp4_net_ops);
}

void udp4_proc_exit(void)
{
	unregister_pernet_subsys(&udp4_net_ops);
}
#endif /* CONFIG_PROC_FS */

static __initdata unsigned long uhash_entries;
static int __init set_uhash_entries(char *str)
{
	ssize_t ret;

	if (!str)
		return 0;

	ret = kstrtoul(str, 0, &uhash_entries);
	if (ret)
		return 0;

	if (uhash_entries && uhash_entries < UDP_HTABLE_SIZE_MIN)
		uhash_entries = UDP_HTABLE_SIZE_MIN;
	return 1;
}
__setup("uhash_entries=", set_uhash_entries);

void __init udp_table_init(struct udp_table *table, const char *name)
{
	unsigned int i;

	table->hash = alloc_large_system_hash(name,
					      2 * sizeof(struct udp_hslot),
					      uhash_entries,
					      21, /* one slot per 2 MB */
					      0,
					      &table->log,
					      &table->mask,
					      UDP_HTABLE_SIZE_MIN,
					      64 * 1024);

	table->hash2 = table->hash + (table->mask + 1);
	for (i = 0; i <= table->mask; i++) {
		INIT_HLIST_NULLS_HEAD(&table->hash[i].head, i);
		table->hash[i].count = 0;
		spin_lock_init(&table->hash[i].lock);
	}
	for (i = 0; i <= table->mask; i++) {
		INIT_HLIST_NULLS_HEAD(&table->hash2[i].head, i);
		table->hash2[i].count = 0;
		spin_lock_init(&table->hash2[i].lock);
	}
}

void __init udp_init(void)
{
	unsigned long limit;

	udp_table_init(&udp_table, "UDP");
	limit = nr_free_buffer_pages() / 8;
	limit = max(limit, 128UL);
	sysctl_udp_mem[0] = limit / 4 * 3;
	sysctl_udp_mem[1] = limit;
	sysctl_udp_mem[2] = sysctl_udp_mem[0] * 2;

	sysctl_udp_rmem_min = SK_MEM_QUANTUM;
	sysctl_udp_wmem_min = SK_MEM_QUANTUM;
}

--------------030904000408010905020400
Content-Type: text/plain; charset=UTF-8;
 name="udp.c.orig"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="udp.c.orig"

LyoKICogSU5FVAkJQW4gaW1wbGVtZW50YXRpb24gb2YgdGhlIFRDUC9JUCBwcm90b2NvbCBz
dWl0ZSBmb3IgdGhlIExJTlVYCiAqCQlvcGVyYXRpbmcgc3lzdGVtLiAgSU5FVCBpcyBpbXBs
ZW1lbnRlZCB1c2luZyB0aGUgIEJTRCBTb2NrZXQKICoJCWludGVyZmFjZSBhcyB0aGUgbWVh
bnMgb2YgY29tbXVuaWNhdGlvbiB3aXRoIHRoZSB1c2VyIGxldmVsLgogKgogKgkJVGhlIFVz
ZXIgRGF0YWdyYW0gUHJvdG9jb2wgKFVEUCkuCiAqCiAqIEF1dGhvcnM6CVJvc3MgQmlybwog
KgkJRnJlZCBOLiB2YW4gS2VtcGVuLCA8d2FsdGplQHVXYWx0Lk5MLk11Z25ldC5PUkc+CiAq
CQlBcm50IEd1bGJyYW5kc2VuLCA8YWd1bGJyYUBudmcudW5pdC5ubz4KICoJCUFsYW4gQ294
LCA8YWxhbkBseG9yZ3VrLnVrdXUub3JnLnVrPgogKgkJSGlyb2thenUgVGFrYWhhc2hpLCA8
dGFrYUB2YWxpbnV4LmNvLmpwPgogKgogKiBGaXhlczoKICoJCUFsYW4gQ294CToJdmVyaWZ5
X2FyZWEoKSBjYWxscwogKgkJQWxhbiBDb3gJOiAJc3RvcHBlZCBjbG9zZSB3aGlsZSBpbiB1
c2Ugb2ZmIGljbXAKICoJCQkJCW1lc3NhZ2VzLiBOb3QgYSBmaXggYnV0IGEgYm90Y2ggdGhh
dAogKgkJCQkJZm9yIHVkcCBhdCBsZWFzdCBpcyAndmFsaWQnLgogKgkJQWxhbiBDb3gJOglG
aXhlZCBpY21wIGhhbmRsaW5nIHByb3Blcmx5CiAqCQlBbGFuIENveAk6IAlDb3JyZWN0IGVy
cm9yIGZvciBvdmVyc2l6ZWQgZGF0YWdyYW1zCiAqCQlBbGFuIENveAk6CVRpZGllZCBzZWxl
Y3QoKSBzZW1hbnRpY3MuCiAqCQlBbGFuIENveAk6CXVkcF9lcnIoKSBmaXhlZCBwcm9wZXJs
eSwgYWxzbyBub3cKICoJCQkJCXNlbGVjdCBhbmQgcmVhZCB3YWtlIGNvcnJlY3RseSBvbiBl
cnJvcnMKICoJCUFsYW4gQ294CToJdWRwX3NlbmQgdmVyaWZ5X2FyZWEgbW92ZWQgdG8gYXZv
aWQgbWVtIGxlYWsKICoJCUFsYW4gQ294CToJVURQIGNhbiBjb3VudCBpdHMgbWVtb3J5CiAq
CQlBbGFuIENveAk6CXNlbmQgdG8gYW4gdW5rbm93biBjb25uZWN0aW9uIGNhdXNlcwogKgkJ
CQkJYW4gRUNPTk5SRUZVU0VEIG9mZiB0aGUgaWNtcCwgYnV0CiAqCQkJCQlkb2VzIE5PVCBj
bG9zZS4KICoJCUFsYW4gQ294CToJU3dpdGNoZWQgdG8gbmV3IHNrX2J1ZmYgaGFuZGxlcnMu
IE5vIG1vcmUgYmFja2xvZyEKICoJCUFsYW4gQ294CToJVXNpbmcgZ2VuZXJpYyBkYXRhZ3Jh
bSBjb2RlLiBFdmVuIHNtYWxsZXIgYW5kIHRoZSBQRUVLCiAqCQkJCQlidWcgbm8gbG9uZ2Vy
IGNyYXNoZXMgaXQuCiAqCQlGcmVkIFZhbiBLZW1wZW4JOiAJTmV0MmUgc3VwcG9ydCBmb3Ig
c2stPmJyb2FkY2FzdC4KICoJCUFsYW4gQ294CToJVXNlcyBza2JfZnJlZV9kYXRhZ3JhbQog
KgkJQWxhbiBDb3gJOglBZGRlZCBnZXQvc2V0IHNvY2tvcHQgc3VwcG9ydC4KICoJCUFsYW4g
Q294CToJQnJvYWRjYXN0aW5nIHdpdGhvdXQgb3B0aW9uIHNldCByZXR1cm5zIEVBQ0NFUy4K
ICoJCUFsYW4gQ294CToJTm8gd2FrZXVwIGNhbGxzLiBJbnN0ZWFkIHdlIG5vdyB1c2UgdGhl
IGNhbGxiYWNrcy4KICoJCUFsYW4gQ294CToJVXNlIGlwX3RvcyBhbmQgaXBfdHRsCiAqCQlB
bGFuIENveAk6CVNOTVAgTWlicwogKgkJQWxhbiBDb3gJOglNU0dfRE9OVFJPVVRFLCBhbmQg
MC4wLjAuMCBzdXBwb3J0LgogKgkJTWF0dCBEaWxsb24JOglVRFAgbGVuZ3RoIGNoZWNrcy4K
ICoJCUFsYW4gQ294CToJU21hcnRlciBhZl9pbmV0IHVzZWQgcHJvcGVybHkuCiAqCQlBbGFu
IENveAk6CVVzZSBuZXcga2VybmVsIHNpZGUgYWRkcmVzc2luZy4KICoJCUFsYW4gQ294CToJ
SW5jb3JyZWN0IHJldHVybiBvbiB0cnVuY2F0ZWQgZGF0YWdyYW0gcmVjZWl2ZS4KICoJQXJu
dCBHdWxicmFuZHNlbiAJOglOZXcgdWRwX3NlbmQgYW5kIHN0dWZmCiAqCQlBbGFuIENveAk6
CUNhY2hlIGxhc3Qgc29ja2V0CiAqCQlBbGFuIENveAk6CVJvdXRlIGNhY2hlCiAqCQlKb24g
UGVhdGZpZWxkCToJTWlub3IgZWZmaWNpZW5jeSBmaXggdG8gc2VuZHRvKCkuCiAqCQlNaWtl
IFNoYXZlcgk6CVJGQzExMjIgY2hlY2tzLgogKgkJQWxhbiBDb3gJOglOb25ibG9ja2luZyBl
cnJvciBmaXguCiAqCVdpbGx5IEtvbnluZW5iZXJnCToJVHJhbnNwYXJlbnQgcHJveHlpbmcg
c3VwcG9ydC4KICoJCU1pa2UgTWNMYWdhbgk6CVJvdXRpbmcgYnkgc291cmNlCiAqCQlEYXZp
ZCBTLiBNaWxsZXIJOglOZXcgc29ja2V0IGxvb2t1cCBhcmNoaXRlY3R1cmUuCiAqCQkJCQlM
YXN0IHNvY2tldCBjYWNoZSByZXRhaW5lZCBhcyBpdAogKgkJCQkJZG9lcyBoYXZlIGEgaGln
aCBoaXQgcmF0ZS4KICoJCU9sYWYgS2lyY2gJOglEb24ndCBsaW5lYXJpc2UgaW92ZWMgb24g
c2VuZG1zZy4KICoJCUFuZGkgS2xlZW4JOglTb21lIGNsZWFudXBzLCBjYWNoZSBkZXN0aW5h
dGlvbiBlbnRyeQogKgkJCQkJZm9yIGNvbm5lY3QuCiAqCVZpdGFseSBFLiBMYXZyb3YJOglU
cmFuc3BhcmVudCBwcm94eSByZXZpdmVkIGFmdGVyIHllYXIgY29tYS4KICoJCU1lbHZpbiBT
bWl0aAk6CUNoZWNrIG1zZ19uYW1lIG5vdCBtc2dfbmFtZWxlbiBpbiBzZW5kdG8oKSwKICoJ
CQkJCXJldHVybiBFTk9UQ09OTiBmb3IgdW5jb25uZWN0ZWQgc29ja2V0cyAoUE9TSVgpCiAq
CQlKYW5vcyBGYXJrYXMJOglkb24ndCBkZWxpdmVyIG11bHRpL2Jyb2FkY2FzdHMgdG8gYSBk
aWZmZXJlbnQKICoJCQkJCWJvdW5kLXRvLWRldmljZSBzb2NrZXQKICoJSGlyb2thenUgVGFr
YWhhc2hpCToJSFcgY2hlY2tzdW1taW5nIGZvciBvdXRnb2luZyBVRFAKICoJCQkJCWRhdGFn
cmFtcy4KICoJSGlyb2thenUgVGFrYWhhc2hpCToJc2VuZGZpbGUoKSBvbiBVRFAgd29ya3Mg
bm93LgogKgkJQXJuYWxkbyBDLiBNZWxvIDoJY29udmVydCAvcHJvYy9uZXQvdWRwIHRvIHNl
cV9maWxlCiAqCVlPU0hJRlVKSSBIaWRlYWtpIEBVU0FHSSBhbmQ6CVN1cHBvcnQgSVBWNl9W
Nk9OTFkgc29ja2V0IG9wdGlvbiwgd2hpY2gKICoJQWxleGV5IEt1em5ldHNvdjoJCWFsbG93
IGJvdGggSVB2NCBhbmQgSVB2NiBzb2NrZXRzIHRvIGJpbmQKICoJCQkJCWEgc2luZ2xlIHBv
cnQgYXQgdGhlIHNhbWUgdGltZS4KICoJRGVyZWsgQXRraW5zIDxkZXJla0BpaHRmcC5jb20+
OiBBZGQgRW5jYXB1bGF0aW9uIFN1cHBvcnQKICoJSmFtZXMgQ2hhcG1hbgkJOglBZGQgTDJU
UCBlbmNhcHN1bGF0aW9uIHR5cGUuCiAqCiAqCiAqCQlUaGlzIHByb2dyYW0gaXMgZnJlZSBz
b2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5kL29yCiAqCQltb2RpZnkgaXQg
dW5kZXIgdGhlIHRlcm1zIG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZQogKgkJ
YXMgcHVibGlzaGVkIGJ5IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb247IGVpdGhlciB2
ZXJzaW9uCiAqCQkyIG9mIHRoZSBMaWNlbnNlLCBvciAoYXQgeW91ciBvcHRpb24pIGFueSBs
YXRlciB2ZXJzaW9uLgogKi8KCiNkZWZpbmUgcHJfZm10KGZtdCkgIlVEUDogIiBmbXQKCiNp
bmNsdWRlIDxhc20vdWFjY2Vzcy5oPgojaW5jbHVkZSA8YXNtL2lvY3Rscy5oPgojaW5jbHVk
ZSA8bGludXgvYm9vdG1lbS5oPgojaW5jbHVkZSA8bGludXgvaGlnaG1lbS5oPgojaW5jbHVk
ZSA8bGludXgvc3dhcC5oPgojaW5jbHVkZSA8bGludXgvdHlwZXMuaD4KI2luY2x1ZGUgPGxp
bnV4L2ZjbnRsLmg+CiNpbmNsdWRlIDxsaW51eC9tb2R1bGUuaD4KI2luY2x1ZGUgPGxpbnV4
L3NvY2tldC5oPgojaW5jbHVkZSA8bGludXgvc29ja2lvcy5oPgojaW5jbHVkZSA8bGludXgv
aWdtcC5oPgojaW5jbHVkZSA8bGludXgvaW4uaD4KI2luY2x1ZGUgPGxpbnV4L2Vycm5vLmg+
CiNpbmNsdWRlIDxsaW51eC90aW1lci5oPgojaW5jbHVkZSA8bGludXgvbW0uaD4KI2luY2x1
ZGUgPGxpbnV4L2luZXQuaD4KI2luY2x1ZGUgPGxpbnV4L25ldGRldmljZS5oPgojaW5jbHVk
ZSA8bGludXgvc2xhYi5oPgojaW5jbHVkZSA8bmV0L3RjcF9zdGF0ZXMuaD4KI2luY2x1ZGUg
PGxpbnV4L3NrYnVmZi5oPgojaW5jbHVkZSA8bGludXgvbmV0ZGV2aWNlLmg+CiNpbmNsdWRl
IDxsaW51eC9wcm9jX2ZzLmg+CiNpbmNsdWRlIDxsaW51eC9zZXFfZmlsZS5oPgojaW5jbHVk
ZSA8bmV0L25ldF9uYW1lc3BhY2UuaD4KI2luY2x1ZGUgPG5ldC9pY21wLmg+CiNpbmNsdWRl
IDxuZXQvaW5ldF9oYXNodGFibGVzLmg+CiNpbmNsdWRlIDxuZXQvcm91dGUuaD4KI2luY2x1
ZGUgPG5ldC9jaGVja3N1bS5oPgojaW5jbHVkZSA8bmV0L3hmcm0uaD4KI2luY2x1ZGUgPHRy
YWNlL2V2ZW50cy91ZHAuaD4KI2luY2x1ZGUgPGxpbnV4L3N0YXRpY19rZXkuaD4KI2luY2x1
ZGUgPHRyYWNlL2V2ZW50cy9za2IuaD4KI2luY2x1ZGUgPG5ldC9idXN5X3BvbGwuaD4KI2lu
Y2x1ZGUgInVkcF9pbXBsLmgiCgpzdHJ1Y3QgdWRwX3RhYmxlIHVkcF90YWJsZSBfX3JlYWRf
bW9zdGx5OwpFWFBPUlRfU1lNQk9MKHVkcF90YWJsZSk7Cgpsb25nIHN5c2N0bF91ZHBfbWVt
WzNdIF9fcmVhZF9tb3N0bHk7CkVYUE9SVF9TWU1CT0woc3lzY3RsX3VkcF9tZW0pOwoKaW50
IHN5c2N0bF91ZHBfcm1lbV9taW4gX19yZWFkX21vc3RseTsKRVhQT1JUX1NZTUJPTChzeXNj
dGxfdWRwX3JtZW1fbWluKTsKCmludCBzeXNjdGxfdWRwX3dtZW1fbWluIF9fcmVhZF9tb3N0
bHk7CkVYUE9SVF9TWU1CT0woc3lzY3RsX3VkcF93bWVtX21pbik7CgphdG9taWNfbG9uZ190
IHVkcF9tZW1vcnlfYWxsb2NhdGVkOwpFWFBPUlRfU1lNQk9MKHVkcF9tZW1vcnlfYWxsb2Nh
dGVkKTsKCiNkZWZpbmUgTUFYX1VEUF9QT1JUUyA2NTUzNgojZGVmaW5lIFBPUlRTX1BFUl9D
SEFJTiAoTUFYX1VEUF9QT1JUUyAvIFVEUF9IVEFCTEVfU0laRV9NSU4pCgpzdGF0aWMgaW50
IHVkcF9saWJfbHBvcnRfaW51c2Uoc3RydWN0IG5ldCAqbmV0LCBfX3UxNiBudW0sCgkJCSAg
ICAgICBjb25zdCBzdHJ1Y3QgdWRwX2hzbG90ICpoc2xvdCwKCQkJICAgICAgIHVuc2lnbmVk
IGxvbmcgKmJpdG1hcCwKCQkJICAgICAgIHN0cnVjdCBzb2NrICpzaywKCQkJICAgICAgIGlu
dCAoKnNhZGRyX2NvbXApKGNvbnN0IHN0cnVjdCBzb2NrICpzazEsCgkJCQkJCSBjb25zdCBz
dHJ1Y3Qgc29jayAqc2syKSwKCQkJICAgICAgIHVuc2lnbmVkIGludCBsb2cpCnsKCXN0cnVj
dCBzb2NrICpzazI7CglzdHJ1Y3QgaGxpc3RfbnVsbHNfbm9kZSAqbm9kZTsKCWt1aWRfdCB1
aWQgPSBzb2NrX2lfdWlkKHNrKTsKCglza19udWxsc19mb3JfZWFjaChzazIsIG5vZGUsICZo
c2xvdC0+aGVhZCkgewoJCWlmIChuZXRfZXEoc29ja19uZXQoc2syKSwgbmV0KSAmJgoJCSAg
ICBzazIgIT0gc2sgJiYKCQkgICAgKGJpdG1hcCB8fCB1ZHBfc2soc2syKS0+dWRwX3BvcnRf
aGFzaCA9PSBudW0pICYmCgkJICAgICghc2syLT5za19yZXVzZSB8fCAhc2stPnNrX3JldXNl
KSAmJgoJCSAgICAoIXNrMi0+c2tfYm91bmRfZGV2X2lmIHx8ICFzay0+c2tfYm91bmRfZGV2
X2lmIHx8CgkJICAgICBzazItPnNrX2JvdW5kX2Rldl9pZiA9PSBzay0+c2tfYm91bmRfZGV2
X2lmKSAmJgoJCSAgICAoIXNrMi0+c2tfcmV1c2Vwb3J0IHx8ICFzay0+c2tfcmV1c2Vwb3J0
IHx8CgkJICAgICAhdWlkX2VxKHVpZCwgc29ja19pX3VpZChzazIpKSkgJiYKCQkgICAgc2Fk
ZHJfY29tcChzaywgc2syKSkgewoJCQlpZiAoIWJpdG1hcCkKCQkJCXJldHVybiAxOwoJCQlf
X3NldF9iaXQodWRwX3NrKHNrMiktPnVkcF9wb3J0X2hhc2ggPj4gbG9nLCBiaXRtYXApOwoJ
CX0KCX0KCXJldHVybiAwOwp9CgovKgogKiBOb3RlOiB3ZSBzdGlsbCBob2xkIHNwaW5sb2Nr
IG9mIHByaW1hcnkgaGFzaCBjaGFpbiwgc28gbm8gb3RoZXIgd3JpdGVyCiAqIGNhbiBpbnNl
cnQvZGVsZXRlIGEgc29ja2V0IHdpdGggbG9jYWxfcG9ydCA9PSBudW0KICovCnN0YXRpYyBp
bnQgdWRwX2xpYl9scG9ydF9pbnVzZTIoc3RydWN0IG5ldCAqbmV0LCBfX3UxNiBudW0sCgkJ
CQlzdHJ1Y3QgdWRwX2hzbG90ICpoc2xvdDIsCgkJCQlzdHJ1Y3Qgc29jayAqc2ssCgkJCQlp
bnQgKCpzYWRkcl9jb21wKShjb25zdCBzdHJ1Y3Qgc29jayAqc2sxLAoJCQkJCQkgIGNvbnN0
IHN0cnVjdCBzb2NrICpzazIpKQp7CglzdHJ1Y3Qgc29jayAqc2syOwoJc3RydWN0IGhsaXN0
X251bGxzX25vZGUgKm5vZGU7CglrdWlkX3QgdWlkID0gc29ja19pX3VpZChzayk7CglpbnQg
cmVzID0gMDsKCglzcGluX2xvY2soJmhzbG90Mi0+bG9jayk7Cgl1ZHBfcG9ydGFkZHJfZm9y
X2VhY2hfZW50cnkoc2syLCBub2RlLCAmaHNsb3QyLT5oZWFkKSB7CgkJaWYgKG5ldF9lcShz
b2NrX25ldChzazIpLCBuZXQpICYmCgkJICAgIHNrMiAhPSBzayAmJgoJCSAgICAodWRwX3Nr
KHNrMiktPnVkcF9wb3J0X2hhc2ggPT0gbnVtKSAmJgoJCSAgICAoIXNrMi0+c2tfcmV1c2Ug
fHwgIXNrLT5za19yZXVzZSkgJiYKCQkgICAgKCFzazItPnNrX2JvdW5kX2Rldl9pZiB8fCAh
c2stPnNrX2JvdW5kX2Rldl9pZiB8fAoJCSAgICAgc2syLT5za19ib3VuZF9kZXZfaWYgPT0g
c2stPnNrX2JvdW5kX2Rldl9pZikgJiYKCQkgICAgKCFzazItPnNrX3JldXNlcG9ydCB8fCAh
c2stPnNrX3JldXNlcG9ydCB8fAoJCSAgICAgIXVpZF9lcSh1aWQsIHNvY2tfaV91aWQoc2sy
KSkpICYmCgkJICAgIHNhZGRyX2NvbXAoc2ssIHNrMikpIHsKCQkJcmVzID0gMTsKCQkJYnJl
YWs7CgkJfQoJfQoJc3Bpbl91bmxvY2soJmhzbG90Mi0+bG9jayk7CglyZXR1cm4gcmVzOwp9
CgovKioKICogIHVkcF9saWJfZ2V0X3BvcnQgIC0gIFVEUC8tTGl0ZSBwb3J0IGxvb2t1cCBm
b3IgSVB2NCBhbmQgSVB2NgogKgogKiAgQHNrOiAgICAgICAgICBzb2NrZXQgc3RydWN0IGlu
IHF1ZXN0aW9uCiAqICBAc251bTogICAgICAgIHBvcnQgbnVtYmVyIHRvIGxvb2sgdXAKICog
IEBzYWRkcl9jb21wOiAgQUYtZGVwZW5kZW50IGNvbXBhcmlzb24gb2YgYm91bmQgbG9jYWwg
SVAgYWRkcmVzc2VzCiAqICBAaGFzaDJfbnVsbGFkZHI6IEFGLWRlcGVuZGVudCBoYXNoIHZh
bHVlIGluIHNlY29uZGFyeSBoYXNoIGNoYWlucywKICogICAgICAgICAgICAgICAgICAgd2l0
aCBOVUxMIGFkZHJlc3MKICovCmludCB1ZHBfbGliX2dldF9wb3J0KHN0cnVjdCBzb2NrICpz
aywgdW5zaWduZWQgc2hvcnQgc251bSwKCQkgICAgIGludCAoKnNhZGRyX2NvbXApKGNvbnN0
IHN0cnVjdCBzb2NrICpzazEsCgkJCQkgICAgICAgY29uc3Qgc3RydWN0IHNvY2sgKnNrMiks
CgkJICAgICB1bnNpZ25lZCBpbnQgaGFzaDJfbnVsbGFkZHIpCnsKCXN0cnVjdCB1ZHBfaHNs
b3QgKmhzbG90LCAqaHNsb3QyOwoJc3RydWN0IHVkcF90YWJsZSAqdWRwdGFibGUgPSBzay0+
c2tfcHJvdC0+aC51ZHBfdGFibGU7CglpbnQgICAgZXJyb3IgPSAxOwoJc3RydWN0IG5ldCAq
bmV0ID0gc29ja19uZXQoc2spOwoKCWlmICghc251bSkgewoJCWludCBsb3csIGhpZ2gsIHJl
bWFpbmluZzsKCQl1bnNpZ25lZCBpbnQgcmFuZDsKCQl1bnNpZ25lZCBzaG9ydCBmaXJzdCwg
bGFzdDsKCQlERUNMQVJFX0JJVE1BUChiaXRtYXAsIFBPUlRTX1BFUl9DSEFJTik7CgoJCWlu
ZXRfZ2V0X2xvY2FsX3BvcnRfcmFuZ2UobmV0LCAmbG93LCAmaGlnaCk7CgkJcmVtYWluaW5n
ID0gKGhpZ2ggLSBsb3cpICsgMTsKCgkJcmFuZCA9IHByYW5kb21fdTMyKCk7CgkJZmlyc3Qg
PSByZWNpcHJvY2FsX3NjYWxlKHJhbmQsIHJlbWFpbmluZykgKyBsb3c7CgkJLyoKCQkgKiBm
b3JjZSByYW5kIHRvIGJlIGFuIG9kZCBtdWx0aXBsZSBvZiBVRFBfSFRBQkxFX1NJWkUKCQkg
Ki8KCQlyYW5kID0gKHJhbmQgfCAxKSAqICh1ZHB0YWJsZS0+bWFzayArIDEpOwoJCWxhc3Qg
PSBmaXJzdCArIHVkcHRhYmxlLT5tYXNrICsgMTsKCQlkbyB7CgkJCWhzbG90ID0gdWRwX2hh
c2hzbG90KHVkcHRhYmxlLCBuZXQsIGZpcnN0KTsKCQkJYml0bWFwX3plcm8oYml0bWFwLCBQ
T1JUU19QRVJfQ0hBSU4pOwoJCQlzcGluX2xvY2tfYmgoJmhzbG90LT5sb2NrKTsKCQkJdWRw
X2xpYl9scG9ydF9pbnVzZShuZXQsIHNudW0sIGhzbG90LCBiaXRtYXAsIHNrLAoJCQkJCSAg
ICBzYWRkcl9jb21wLCB1ZHB0YWJsZS0+bG9nKTsKCgkJCXNudW0gPSBmaXJzdDsKCQkJLyoK
CQkJICogSXRlcmF0ZSBvbiBhbGwgcG9zc2libGUgdmFsdWVzIG9mIHNudW0gZm9yIHRoaXMg
aGFzaC4KCQkJICogVXNpbmcgc3RlcHMgb2YgYW4gb2RkIG11bHRpcGxlIG9mIFVEUF9IVEFC
TEVfU0laRQoJCQkgKiBnaXZlIHVzIHJhbmRvbWl6YXRpb24gYW5kIGZ1bGwgcmFuZ2UgY292
ZXJhZ2UuCgkJCSAqLwoJCQlkbyB7CgkJCQlpZiAobG93IDw9IHNudW0gJiYgc251bSA8PSBo
aWdoICYmCgkJCQkgICAgIXRlc3RfYml0KHNudW0gPj4gdWRwdGFibGUtPmxvZywgYml0bWFw
KSAmJgoJCQkJICAgICFpbmV0X2lzX2xvY2FsX3Jlc2VydmVkX3BvcnQobmV0LCBzbnVtKSkK
CQkJCQlnb3RvIGZvdW5kOwoJCQkJc251bSArPSByYW5kOwoJCQl9IHdoaWxlIChzbnVtICE9
IGZpcnN0KTsKCQkJc3Bpbl91bmxvY2tfYmgoJmhzbG90LT5sb2NrKTsKCQl9IHdoaWxlICgr
K2ZpcnN0ICE9IGxhc3QpOwoJCWdvdG8gZmFpbDsKCX0gZWxzZSB7CgkJaHNsb3QgPSB1ZHBf
aGFzaHNsb3QodWRwdGFibGUsIG5ldCwgc251bSk7CgkJc3Bpbl9sb2NrX2JoKCZoc2xvdC0+
bG9jayk7CgkJaWYgKGhzbG90LT5jb3VudCA+IDEwKSB7CgkJCWludCBleGlzdDsKCQkJdW5z
aWduZWQgaW50IHNsb3QyID0gdWRwX3NrKHNrKS0+dWRwX3BvcnRhZGRyX2hhc2ggXiBzbnVt
OwoKCQkJc2xvdDIgICAgICAgICAgJj0gdWRwdGFibGUtPm1hc2s7CgkJCWhhc2gyX251bGxh
ZGRyICY9IHVkcHRhYmxlLT5tYXNrOwoKCQkJaHNsb3QyID0gdWRwX2hhc2hzbG90Mih1ZHB0
YWJsZSwgc2xvdDIpOwoJCQlpZiAoaHNsb3QtPmNvdW50IDwgaHNsb3QyLT5jb3VudCkKCQkJ
CWdvdG8gc2Nhbl9wcmltYXJ5X2hhc2g7CgoJCQlleGlzdCA9IHVkcF9saWJfbHBvcnRfaW51
c2UyKG5ldCwgc251bSwgaHNsb3QyLAoJCQkJCQkgICAgIHNrLCBzYWRkcl9jb21wKTsKCQkJ
aWYgKCFleGlzdCAmJiAoaGFzaDJfbnVsbGFkZHIgIT0gc2xvdDIpKSB7CgkJCQloc2xvdDIg
PSB1ZHBfaGFzaHNsb3QyKHVkcHRhYmxlLCBoYXNoMl9udWxsYWRkcik7CgkJCQlleGlzdCA9
IHVkcF9saWJfbHBvcnRfaW51c2UyKG5ldCwgc251bSwgaHNsb3QyLAoJCQkJCQkJICAgICBz
aywgc2FkZHJfY29tcCk7CgkJCX0KCQkJaWYgKGV4aXN0KQoJCQkJZ290byBmYWlsX3VubG9j
azsKCQkJZWxzZQoJCQkJZ290byBmb3VuZDsKCQl9CnNjYW5fcHJpbWFyeV9oYXNoOgoJCWlm
ICh1ZHBfbGliX2xwb3J0X2ludXNlKG5ldCwgc251bSwgaHNsb3QsIE5VTEwsIHNrLAoJCQkJ
CXNhZGRyX2NvbXAsIDApKQoJCQlnb3RvIGZhaWxfdW5sb2NrOwoJfQpmb3VuZDoKCWluZXRf
c2soc2spLT5pbmV0X251bSA9IHNudW07Cgl1ZHBfc2soc2spLT51ZHBfcG9ydF9oYXNoID0g
c251bTsKCXVkcF9zayhzayktPnVkcF9wb3J0YWRkcl9oYXNoIF49IHNudW07CglpZiAoc2tf
dW5oYXNoZWQoc2spKSB7CgkJc2tfbnVsbHNfYWRkX25vZGVfcmN1KHNrLCAmaHNsb3QtPmhl
YWQpOwoJCWhzbG90LT5jb3VudCsrOwoJCXNvY2tfcHJvdF9pbnVzZV9hZGQoc29ja19uZXQo
c2spLCBzay0+c2tfcHJvdCwgMSk7CgoJCWhzbG90MiA9IHVkcF9oYXNoc2xvdDIodWRwdGFi
bGUsIHVkcF9zayhzayktPnVkcF9wb3J0YWRkcl9oYXNoKTsKCQlzcGluX2xvY2soJmhzbG90
Mi0+bG9jayk7CgkJaGxpc3RfbnVsbHNfYWRkX2hlYWRfcmN1KCZ1ZHBfc2soc2spLT51ZHBf
cG9ydGFkZHJfbm9kZSwKCQkJCQkgJmhzbG90Mi0+aGVhZCk7CgkJaHNsb3QyLT5jb3VudCsr
OwoJCXNwaW5fdW5sb2NrKCZoc2xvdDItPmxvY2spOwoJfQoJZXJyb3IgPSAwOwpmYWlsX3Vu
bG9jazoKCXNwaW5fdW5sb2NrX2JoKCZoc2xvdC0+bG9jayk7CmZhaWw6CglyZXR1cm4gZXJy
b3I7Cn0KRVhQT1JUX1NZTUJPTCh1ZHBfbGliX2dldF9wb3J0KTsKCnN0YXRpYyBpbnQgaXB2
NF9yY3Zfc2FkZHJfZXF1YWwoY29uc3Qgc3RydWN0IHNvY2sgKnNrMSwgY29uc3Qgc3RydWN0
IHNvY2sgKnNrMikKewoJc3RydWN0IGluZXRfc29jayAqaW5ldDEgPSBpbmV0X3NrKHNrMSks
ICppbmV0MiA9IGluZXRfc2soc2syKTsKCglyZXR1cm4gCSghaXB2Nl9vbmx5X3NvY2soc2sy
KSAgJiYKCQkgKCFpbmV0MS0+aW5ldF9yY3Zfc2FkZHIgfHwgIWluZXQyLT5pbmV0X3Jjdl9z
YWRkciB8fAoJCSAgIGluZXQxLT5pbmV0X3Jjdl9zYWRkciA9PSBpbmV0Mi0+aW5ldF9yY3Zf
c2FkZHIpKTsKfQoKc3RhdGljIHVuc2lnbmVkIGludCB1ZHA0X3BvcnRhZGRyX2hhc2goc3Ry
dWN0IG5ldCAqbmV0LCBfX2JlMzIgc2FkZHIsCgkJCQkgICAgICAgdW5zaWduZWQgaW50IHBv
cnQpCnsKCXJldHVybiBqaGFzaF8xd29yZCgoX19mb3JjZSB1MzIpc2FkZHIsIG5ldF9oYXNo
X21peChuZXQpKSBeIHBvcnQ7Cn0KCmludCB1ZHBfdjRfZ2V0X3BvcnQoc3RydWN0IHNvY2sg
KnNrLCB1bnNpZ25lZCBzaG9ydCBzbnVtKQp7Cgl1bnNpZ25lZCBpbnQgaGFzaDJfbnVsbGFk
ZHIgPQoJCXVkcDRfcG9ydGFkZHJfaGFzaChzb2NrX25ldChzayksIGh0b25sKElOQUREUl9B
TlkpLCBzbnVtKTsKCXVuc2lnbmVkIGludCBoYXNoMl9wYXJ0aWFsID0KCQl1ZHA0X3BvcnRh
ZGRyX2hhc2goc29ja19uZXQoc2spLCBpbmV0X3NrKHNrKS0+aW5ldF9yY3Zfc2FkZHIsIDAp
OwoKCS8qIHByZWNvbXB1dGUgcGFydGlhbCBzZWNvbmRhcnkgaGFzaCAqLwoJdWRwX3NrKHNr
KS0+dWRwX3BvcnRhZGRyX2hhc2ggPSBoYXNoMl9wYXJ0aWFsOwoJcmV0dXJuIHVkcF9saWJf
Z2V0X3BvcnQoc2ssIHNudW0sIGlwdjRfcmN2X3NhZGRyX2VxdWFsLCBoYXNoMl9udWxsYWRk
cik7Cn0KCnN0YXRpYyBpbmxpbmUgaW50IGNvbXB1dGVfc2NvcmUoc3RydWN0IHNvY2sgKnNr
LCBzdHJ1Y3QgbmV0ICpuZXQsCgkJCQlfX2JlMzIgc2FkZHIsIHVuc2lnbmVkIHNob3J0IGhu
dW0sIF9fYmUxNiBzcG9ydCwKCQkJCV9fYmUzMiBkYWRkciwgX19iZTE2IGRwb3J0LCBpbnQg
ZGlmKQp7CglpbnQgc2NvcmU7CglzdHJ1Y3QgaW5ldF9zb2NrICppbmV0OwoKCWlmICghbmV0
X2VxKHNvY2tfbmV0KHNrKSwgbmV0KSB8fAoJICAgIHVkcF9zayhzayktPnVkcF9wb3J0X2hh
c2ggIT0gaG51bSB8fAoJICAgIGlwdjZfb25seV9zb2NrKHNrKSkKCQlyZXR1cm4gLTE7CgoJ
c2NvcmUgPSAoc2stPnNrX2ZhbWlseSA9PSBQRl9JTkVUKSA/IDIgOiAxOwoJaW5ldCA9IGlu
ZXRfc2soc2spOwoKCWlmIChpbmV0LT5pbmV0X3Jjdl9zYWRkcikgewoJCWlmIChpbmV0LT5p
bmV0X3Jjdl9zYWRkciAhPSBkYWRkcikKCQkJcmV0dXJuIC0xOwoJCXNjb3JlICs9IDQ7Cgl9
CgoJaWYgKGluZXQtPmluZXRfZGFkZHIpIHsKCQlpZiAoaW5ldC0+aW5ldF9kYWRkciAhPSBz
YWRkcikKCQkJcmV0dXJuIC0xOwoJCXNjb3JlICs9IDQ7Cgl9CgoJaWYgKGluZXQtPmluZXRf
ZHBvcnQpIHsKCQlpZiAoaW5ldC0+aW5ldF9kcG9ydCAhPSBzcG9ydCkKCQkJcmV0dXJuIC0x
OwoJCXNjb3JlICs9IDQ7Cgl9CgoJaWYgKHNrLT5za19ib3VuZF9kZXZfaWYpIHsKCQlpZiAo
c2stPnNrX2JvdW5kX2Rldl9pZiAhPSBkaWYpCgkJCXJldHVybiAtMTsKCQlzY29yZSArPSA0
OwoJfQoKCXJldHVybiBzY29yZTsKfQoKLyoKICogSW4gdGhpcyBzZWNvbmQgdmFyaWFudCwg
d2UgY2hlY2sgKGRhZGRyLCBkcG9ydCkgbWF0Y2hlcyAoaW5ldF9yY3Zfc2FkZCwgaW5ldF9u
dW0pCiAqLwpzdGF0aWMgaW5saW5lIGludCBjb21wdXRlX3Njb3JlMihzdHJ1Y3Qgc29jayAq
c2ssIHN0cnVjdCBuZXQgKm5ldCwKCQkJCSBfX2JlMzIgc2FkZHIsIF9fYmUxNiBzcG9ydCwK
CQkJCSBfX2JlMzIgZGFkZHIsIHVuc2lnbmVkIGludCBobnVtLCBpbnQgZGlmKQp7CglpbnQg
c2NvcmU7CglzdHJ1Y3QgaW5ldF9zb2NrICppbmV0OwoKCWlmICghbmV0X2VxKHNvY2tfbmV0
KHNrKSwgbmV0KSB8fAoJICAgIGlwdjZfb25seV9zb2NrKHNrKSkKCQlyZXR1cm4gLTE7CgoJ
aW5ldCA9IGluZXRfc2soc2spOwoKCWlmIChpbmV0LT5pbmV0X3Jjdl9zYWRkciAhPSBkYWRk
ciB8fAoJICAgIGluZXQtPmluZXRfbnVtICE9IGhudW0pCgkJcmV0dXJuIC0xOwoKCXNjb3Jl
ID0gKHNrLT5za19mYW1pbHkgPT0gUEZfSU5FVCkgPyAyIDogMTsKCglpZiAoaW5ldC0+aW5l
dF9kYWRkcikgewoJCWlmIChpbmV0LT5pbmV0X2RhZGRyICE9IHNhZGRyKQoJCQlyZXR1cm4g
LTE7CgkJc2NvcmUgKz0gNDsKCX0KCglpZiAoaW5ldC0+aW5ldF9kcG9ydCkgewoJCWlmIChp
bmV0LT5pbmV0X2Rwb3J0ICE9IHNwb3J0KQoJCQlyZXR1cm4gLTE7CgkJc2NvcmUgKz0gNDsK
CX0KCglpZiAoc2stPnNrX2JvdW5kX2Rldl9pZikgewoJCWlmIChzay0+c2tfYm91bmRfZGV2
X2lmICE9IGRpZikKCQkJcmV0dXJuIC0xOwoJCXNjb3JlICs9IDQ7Cgl9CgoJcmV0dXJuIHNj
b3JlOwp9CgpzdGF0aWMgdW5zaWduZWQgaW50IHVkcF9laGFzaGZuKHN0cnVjdCBuZXQgKm5l
dCwgY29uc3QgX19iZTMyIGxhZGRyLAoJCQkJIGNvbnN0IF9fdTE2IGxwb3J0LCBjb25zdCBf
X2JlMzIgZmFkZHIsCgkJCQkgY29uc3QgX19iZTE2IGZwb3J0KQp7CglzdGF0aWMgdTMyIHVk
cF9laGFzaF9zZWNyZXQgX19yZWFkX21vc3RseTsKCgluZXRfZ2V0X3JhbmRvbV9vbmNlKCZ1
ZHBfZWhhc2hfc2VjcmV0LCBzaXplb2YodWRwX2VoYXNoX3NlY3JldCkpOwoKCXJldHVybiBf
X2luZXRfZWhhc2hmbihsYWRkciwgbHBvcnQsIGZhZGRyLCBmcG9ydCwKCQkJICAgICAgdWRw
X2VoYXNoX3NlY3JldCArIG5ldF9oYXNoX21peChuZXQpKTsKfQoKCi8qIGNhbGxlZCB3aXRo
IHJlYWRfcmN1X2xvY2soKSAqLwpzdGF0aWMgc3RydWN0IHNvY2sgKnVkcDRfbGliX2xvb2t1
cDIoc3RydWN0IG5ldCAqbmV0LAoJCV9fYmUzMiBzYWRkciwgX19iZTE2IHNwb3J0LAoJCV9f
YmUzMiBkYWRkciwgdW5zaWduZWQgaW50IGhudW0sIGludCBkaWYsCgkJc3RydWN0IHVkcF9o
c2xvdCAqaHNsb3QyLCB1bnNpZ25lZCBpbnQgc2xvdDIpCnsKCXN0cnVjdCBzb2NrICpzaywg
KnJlc3VsdDsKCXN0cnVjdCBobGlzdF9udWxsc19ub2RlICpub2RlOwoJaW50IHNjb3JlLCBi
YWRuZXNzLCBtYXRjaGVzID0gMCwgcmV1c2Vwb3J0ID0gMDsKCXUzMiBoYXNoID0gMDsKCmJl
Z2luOgoJcmVzdWx0ID0gTlVMTDsKCWJhZG5lc3MgPSAwOwoJdWRwX3BvcnRhZGRyX2Zvcl9l
YWNoX2VudHJ5X3JjdShzaywgbm9kZSwgJmhzbG90Mi0+aGVhZCkgewoJCXNjb3JlID0gY29t
cHV0ZV9zY29yZTIoc2ssIG5ldCwgc2FkZHIsIHNwb3J0LAoJCQkJICAgICAgZGFkZHIsIGhu
dW0sIGRpZik7CgkJaWYgKHNjb3JlID4gYmFkbmVzcykgewoJCQlyZXN1bHQgPSBzazsKCQkJ
YmFkbmVzcyA9IHNjb3JlOwoJCQlyZXVzZXBvcnQgPSBzay0+c2tfcmV1c2Vwb3J0OwoJCQlp
ZiAocmV1c2Vwb3J0KSB7CgkJCQloYXNoID0gdWRwX2VoYXNoZm4obmV0LCBkYWRkciwgaG51
bSwKCQkJCQkJICAgc2FkZHIsIHNwb3J0KTsKCQkJCW1hdGNoZXMgPSAxOwoJCQl9CgkJfSBl
bHNlIGlmIChzY29yZSA9PSBiYWRuZXNzICYmIHJldXNlcG9ydCkgewoJCQltYXRjaGVzKys7
CgkJCWlmIChyZWNpcHJvY2FsX3NjYWxlKGhhc2gsIG1hdGNoZXMpID09IDApCgkJCQlyZXN1
bHQgPSBzazsKCQkJaGFzaCA9IG5leHRfcHNldWRvX3JhbmRvbTMyKGhhc2gpOwoJCX0KCX0K
CS8qCgkgKiBpZiB0aGUgbnVsbHMgdmFsdWUgd2UgZ290IGF0IHRoZSBlbmQgb2YgdGhpcyBs
b29rdXAgaXMKCSAqIG5vdCB0aGUgZXhwZWN0ZWQgb25lLCB3ZSBtdXN0IHJlc3RhcnQgbG9v
a3VwLgoJICogV2UgcHJvYmFibHkgbWV0IGFuIGl0ZW0gdGhhdCB3YXMgbW92ZWQgdG8gYW5v
dGhlciBjaGFpbi4KCSAqLwoJaWYgKGdldF9udWxsc192YWx1ZShub2RlKSAhPSBzbG90MikK
CQlnb3RvIGJlZ2luOwoJaWYgKHJlc3VsdCkgewoJCWlmICh1bmxpa2VseSghYXRvbWljX2lu
Y19ub3RfemVyb19oaW50KCZyZXN1bHQtPnNrX3JlZmNudCwgMikpKQoJCQlyZXN1bHQgPSBO
VUxMOwoJCWVsc2UgaWYgKHVubGlrZWx5KGNvbXB1dGVfc2NvcmUyKHJlc3VsdCwgbmV0LCBz
YWRkciwgc3BvcnQsCgkJCQkgIGRhZGRyLCBobnVtLCBkaWYpIDwgYmFkbmVzcykpIHsKCQkJ
c29ja19wdXQocmVzdWx0KTsKCQkJZ290byBiZWdpbjsKCQl9Cgl9CglyZXR1cm4gcmVzdWx0
Owp9CgovKiBVRFAgaXMgbmVhcmx5IGFsd2F5cyB3aWxkY2FyZHMgb3V0IHRoZSB3YXpvbywg
aXQgbWFrZXMgbm8gc2Vuc2UgdG8gdHJ5CiAqIGhhcmRlciB0aGFuIHRoaXMuIC1EYXZlTQog
Ki8Kc3RydWN0IHNvY2sgKl9fdWRwNF9saWJfbG9va3VwKHN0cnVjdCBuZXQgKm5ldCwgX19i
ZTMyIHNhZGRyLAoJCV9fYmUxNiBzcG9ydCwgX19iZTMyIGRhZGRyLCBfX2JlMTYgZHBvcnQs
CgkJaW50IGRpZiwgc3RydWN0IHVkcF90YWJsZSAqdWRwdGFibGUpCnsKCXN0cnVjdCBzb2Nr
ICpzaywgKnJlc3VsdDsKCXN0cnVjdCBobGlzdF9udWxsc19ub2RlICpub2RlOwoJdW5zaWdu
ZWQgc2hvcnQgaG51bSA9IG50b2hzKGRwb3J0KTsKCXVuc2lnbmVkIGludCBoYXNoMiwgc2xv
dDIsIHNsb3QgPSB1ZHBfaGFzaGZuKG5ldCwgaG51bSwgdWRwdGFibGUtPm1hc2spOwoJc3Ry
dWN0IHVkcF9oc2xvdCAqaHNsb3QyLCAqaHNsb3QgPSAmdWRwdGFibGUtPmhhc2hbc2xvdF07
CglpbnQgc2NvcmUsIGJhZG5lc3MsIG1hdGNoZXMgPSAwLCByZXVzZXBvcnQgPSAwOwoJdTMy
IGhhc2ggPSAwOwoKCXJjdV9yZWFkX2xvY2soKTsKCWlmIChoc2xvdC0+Y291bnQgPiAxMCkg
ewoJCWhhc2gyID0gdWRwNF9wb3J0YWRkcl9oYXNoKG5ldCwgZGFkZHIsIGhudW0pOwoJCXNs
b3QyID0gaGFzaDIgJiB1ZHB0YWJsZS0+bWFzazsKCQloc2xvdDIgPSAmdWRwdGFibGUtPmhh
c2gyW3Nsb3QyXTsKCQlpZiAoaHNsb3QtPmNvdW50IDwgaHNsb3QyLT5jb3VudCkKCQkJZ290
byBiZWdpbjsKCgkJcmVzdWx0ID0gdWRwNF9saWJfbG9va3VwMihuZXQsIHNhZGRyLCBzcG9y
dCwKCQkJCQkgIGRhZGRyLCBobnVtLCBkaWYsCgkJCQkJICBoc2xvdDIsIHNsb3QyKTsKCQlp
ZiAoIXJlc3VsdCkgewoJCQloYXNoMiA9IHVkcDRfcG9ydGFkZHJfaGFzaChuZXQsIGh0b25s
KElOQUREUl9BTlkpLCBobnVtKTsKCQkJc2xvdDIgPSBoYXNoMiAmIHVkcHRhYmxlLT5tYXNr
OwoJCQloc2xvdDIgPSAmdWRwdGFibGUtPmhhc2gyW3Nsb3QyXTsKCQkJaWYgKGhzbG90LT5j
b3VudCA8IGhzbG90Mi0+Y291bnQpCgkJCQlnb3RvIGJlZ2luOwoKCQkJcmVzdWx0ID0gdWRw
NF9saWJfbG9va3VwMihuZXQsIHNhZGRyLCBzcG9ydCwKCQkJCQkJICBodG9ubChJTkFERFJf
QU5ZKSwgaG51bSwgZGlmLAoJCQkJCQkgIGhzbG90Miwgc2xvdDIpOwoJCX0KCQlyY3VfcmVh
ZF91bmxvY2soKTsKCQlyZXR1cm4gcmVzdWx0OwoJfQpiZWdpbjoKCXJlc3VsdCA9IE5VTEw7
CgliYWRuZXNzID0gMDsKCXNrX251bGxzX2Zvcl9lYWNoX3JjdShzaywgbm9kZSwgJmhzbG90
LT5oZWFkKSB7CgkJc2NvcmUgPSBjb21wdXRlX3Njb3JlKHNrLCBuZXQsIHNhZGRyLCBobnVt
LCBzcG9ydCwKCQkJCSAgICAgIGRhZGRyLCBkcG9ydCwgZGlmKTsKCQlpZiAoc2NvcmUgPiBi
YWRuZXNzKSB7CgkJCXJlc3VsdCA9IHNrOwoJCQliYWRuZXNzID0gc2NvcmU7CgkJCXJldXNl
cG9ydCA9IHNrLT5za19yZXVzZXBvcnQ7CgkJCWlmIChyZXVzZXBvcnQpIHsKCQkJCWhhc2gg
PSB1ZHBfZWhhc2hmbihuZXQsIGRhZGRyLCBobnVtLAoJCQkJCQkgICBzYWRkciwgc3BvcnQp
OwoJCQkJbWF0Y2hlcyA9IDE7CgkJCX0KCQl9IGVsc2UgaWYgKHNjb3JlID09IGJhZG5lc3Mg
JiYgcmV1c2Vwb3J0KSB7CgkJCW1hdGNoZXMrKzsKCQkJaWYgKHJlY2lwcm9jYWxfc2NhbGUo
aGFzaCwgbWF0Y2hlcykgPT0gMCkKCQkJCXJlc3VsdCA9IHNrOwoJCQloYXNoID0gbmV4dF9w
c2V1ZG9fcmFuZG9tMzIoaGFzaCk7CgkJfQoJfQoJLyoKCSAqIGlmIHRoZSBudWxscyB2YWx1
ZSB3ZSBnb3QgYXQgdGhlIGVuZCBvZiB0aGlzIGxvb2t1cCBpcwoJICogbm90IHRoZSBleHBl
Y3RlZCBvbmUsIHdlIG11c3QgcmVzdGFydCBsb29rdXAuCgkgKiBXZSBwcm9iYWJseSBtZXQg
YW4gaXRlbSB0aGF0IHdhcyBtb3ZlZCB0byBhbm90aGVyIGNoYWluLgoJICovCglpZiAoZ2V0
X251bGxzX3ZhbHVlKG5vZGUpICE9IHNsb3QpCgkJZ290byBiZWdpbjsKCglpZiAocmVzdWx0
KSB7CgkJaWYgKHVubGlrZWx5KCFhdG9taWNfaW5jX25vdF96ZXJvX2hpbnQoJnJlc3VsdC0+
c2tfcmVmY250LCAyKSkpCgkJCXJlc3VsdCA9IE5VTEw7CgkJZWxzZSBpZiAodW5saWtlbHko
Y29tcHV0ZV9zY29yZShyZXN1bHQsIG5ldCwgc2FkZHIsIGhudW0sIHNwb3J0LAoJCQkJICBk
YWRkciwgZHBvcnQsIGRpZikgPCBiYWRuZXNzKSkgewoJCQlzb2NrX3B1dChyZXN1bHQpOwoJ
CQlnb3RvIGJlZ2luOwoJCX0KCX0KCXJjdV9yZWFkX3VubG9jaygpOwoJcmV0dXJuIHJlc3Vs
dDsKfQpFWFBPUlRfU1lNQk9MX0dQTChfX3VkcDRfbGliX2xvb2t1cCk7CgpzdGF0aWMgaW5s
aW5lIHN0cnVjdCBzb2NrICpfX3VkcDRfbGliX2xvb2t1cF9za2Ioc3RydWN0IHNrX2J1ZmYg
KnNrYiwKCQkJCQkJIF9fYmUxNiBzcG9ydCwgX19iZTE2IGRwb3J0LAoJCQkJCQkgc3RydWN0
IHVkcF90YWJsZSAqdWRwdGFibGUpCnsKCWNvbnN0IHN0cnVjdCBpcGhkciAqaXBoID0gaXBf
aGRyKHNrYik7CgoJcmV0dXJuIF9fdWRwNF9saWJfbG9va3VwKGRldl9uZXQoc2tiX2RzdChz
a2IpLT5kZXYpLCBpcGgtPnNhZGRyLCBzcG9ydCwKCQkJCSBpcGgtPmRhZGRyLCBkcG9ydCwg
aW5ldF9paWYoc2tiKSwKCQkJCSB1ZHB0YWJsZSk7Cn0KCnN0cnVjdCBzb2NrICp1ZHA0X2xp
Yl9sb29rdXAoc3RydWN0IG5ldCAqbmV0LCBfX2JlMzIgc2FkZHIsIF9fYmUxNiBzcG9ydCwK
CQkJICAgICBfX2JlMzIgZGFkZHIsIF9fYmUxNiBkcG9ydCwgaW50IGRpZikKewoJcmV0dXJu
IF9fdWRwNF9saWJfbG9va3VwKG5ldCwgc2FkZHIsIHNwb3J0LCBkYWRkciwgZHBvcnQsIGRp
ZiwgJnVkcF90YWJsZSk7Cn0KRVhQT1JUX1NZTUJPTF9HUEwodWRwNF9saWJfbG9va3VwKTsK
CnN0YXRpYyBpbmxpbmUgYm9vbCBfX3VkcF9pc19tY2FzdF9zb2NrKHN0cnVjdCBuZXQgKm5l
dCwgc3RydWN0IHNvY2sgKnNrLAoJCQkJICAgICAgIF9fYmUxNiBsb2NfcG9ydCwgX19iZTMy
IGxvY19hZGRyLAoJCQkJICAgICAgIF9fYmUxNiBybXRfcG9ydCwgX19iZTMyIHJtdF9hZGRy
LAoJCQkJICAgICAgIGludCBkaWYsIHVuc2lnbmVkIHNob3J0IGhudW0pCnsKCXN0cnVjdCBp
bmV0X3NvY2sgKmluZXQgPSBpbmV0X3NrKHNrKTsKCglpZiAoIW5ldF9lcShzb2NrX25ldChz
ayksIG5ldCkgfHwKCSAgICB1ZHBfc2soc2spLT51ZHBfcG9ydF9oYXNoICE9IGhudW0gfHwK
CSAgICAoaW5ldC0+aW5ldF9kYWRkciAmJiBpbmV0LT5pbmV0X2RhZGRyICE9IHJtdF9hZGRy
KSB8fAoJICAgIChpbmV0LT5pbmV0X2Rwb3J0ICE9IHJtdF9wb3J0ICYmIGluZXQtPmluZXRf
ZHBvcnQpIHx8CgkgICAgKGluZXQtPmluZXRfcmN2X3NhZGRyICYmIGluZXQtPmluZXRfcmN2
X3NhZGRyICE9IGxvY19hZGRyKSB8fAoJICAgIGlwdjZfb25seV9zb2NrKHNrKSB8fAoJICAg
IChzay0+c2tfYm91bmRfZGV2X2lmICYmIHNrLT5za19ib3VuZF9kZXZfaWYgIT0gZGlmKSkK
CQlyZXR1cm4gZmFsc2U7CglpZiAoIWlwX21jX3NmX2FsbG93KHNrLCBsb2NfYWRkciwgcm10
X2FkZHIsIGRpZikpCgkJcmV0dXJuIGZhbHNlOwoJcmV0dXJuIHRydWU7Cn0KCi8qCiAqIFRo
aXMgcm91dGluZSBpcyBjYWxsZWQgYnkgdGhlIElDTVAgbW9kdWxlIHdoZW4gaXQgZ2V0cyBz
b21lCiAqIHNvcnQgb2YgZXJyb3IgY29uZGl0aW9uLiAgSWYgZXJyIDwgMCB0aGVuIHRoZSBz
b2NrZXQgc2hvdWxkCiAqIGJlIGNsb3NlZCBhbmQgdGhlIGVycm9yIHJldHVybmVkIHRvIHRo
ZSB1c2VyLiAgSWYgZXJyID4gMAogKiBpdCdzIGp1c3QgdGhlIGljbXAgdHlwZSA8PCA4IHwg
aWNtcCBjb2RlLgogKiBIZWFkZXIgcG9pbnRzIHRvIHRoZSBpcCBoZWFkZXIgb2YgdGhlIGVy
cm9yIHBhY2tldC4gV2UgbW92ZQogKiBvbiBwYXN0IHRoaXMuIFRoZW4gKGFzIGl0IHVzZWQg
dG8gY2xhaW0gYmVmb3JlIGFkanVzdG1lbnQpCiAqIGhlYWRlciBwb2ludHMgdG8gdGhlIGZp
cnN0IDggYnl0ZXMgb2YgdGhlIHVkcCBoZWFkZXIuICBXZSBuZWVkCiAqIHRvIGZpbmQgdGhl
IGFwcHJvcHJpYXRlIHBvcnQuCiAqLwoKdm9pZCBfX3VkcDRfbGliX2VycihzdHJ1Y3Qgc2tf
YnVmZiAqc2tiLCB1MzIgaW5mbywgc3RydWN0IHVkcF90YWJsZSAqdWRwdGFibGUpCnsKCXN0
cnVjdCBpbmV0X3NvY2sgKmluZXQ7Cgljb25zdCBzdHJ1Y3QgaXBoZHIgKmlwaCA9IChjb25z
dCBzdHJ1Y3QgaXBoZHIgKilza2ItPmRhdGE7CglzdHJ1Y3QgdWRwaGRyICp1aCA9IChzdHJ1
Y3QgdWRwaGRyICopKHNrYi0+ZGF0YSsoaXBoLT5paGw8PDIpKTsKCWNvbnN0IGludCB0eXBl
ID0gaWNtcF9oZHIoc2tiKS0+dHlwZTsKCWNvbnN0IGludCBjb2RlID0gaWNtcF9oZHIoc2ti
KS0+Y29kZTsKCXN0cnVjdCBzb2NrICpzazsKCWludCBoYXJkZXJyOwoJaW50IGVycjsKCXN0
cnVjdCBuZXQgKm5ldCA9IGRldl9uZXQoc2tiLT5kZXYpOwoKCXNrID0gX191ZHA0X2xpYl9s
b29rdXAobmV0LCBpcGgtPmRhZGRyLCB1aC0+ZGVzdCwKCQkJaXBoLT5zYWRkciwgdWgtPnNv
dXJjZSwgc2tiLT5kZXYtPmlmaW5kZXgsIHVkcHRhYmxlKTsKCWlmIChzayA9PSBOVUxMKSB7
CgkJSUNNUF9JTkNfU1RBVFNfQkgobmV0LCBJQ01QX01JQl9JTkVSUk9SUyk7CgkJcmV0dXJu
OwkvKiBObyBzb2NrZXQgZm9yIGVycm9yICovCgl9CgoJZXJyID0gMDsKCWhhcmRlcnIgPSAw
OwoJaW5ldCA9IGluZXRfc2soc2spOwoKCXN3aXRjaCAodHlwZSkgewoJZGVmYXVsdDoKCWNh
c2UgSUNNUF9USU1FX0VYQ0VFREVEOgoJCWVyciA9IEVIT1NUVU5SRUFDSDsKCQlicmVhazsK
CWNhc2UgSUNNUF9TT1VSQ0VfUVVFTkNIOgoJCWdvdG8gb3V0OwoJY2FzZSBJQ01QX1BBUkFN
RVRFUlBST0I6CgkJZXJyID0gRVBST1RPOwoJCWhhcmRlcnIgPSAxOwoJCWJyZWFrOwoJY2Fz
ZSBJQ01QX0RFU1RfVU5SRUFDSDoKCQlpZiAoY29kZSA9PSBJQ01QX0ZSQUdfTkVFREVEKSB7
IC8qIFBhdGggTVRVIGRpc2NvdmVyeSAqLwoJCQlpcHY0X3NrX3VwZGF0ZV9wbXR1KHNrYiwg
c2ssIGluZm8pOwoJCQlpZiAoaW5ldC0+cG10dWRpc2MgIT0gSVBfUE1UVURJU0NfRE9OVCkg
ewoJCQkJZXJyID0gRU1TR1NJWkU7CgkJCQloYXJkZXJyID0gMTsKCQkJCWJyZWFrOwoJCQl9
CgkJCWdvdG8gb3V0OwoJCX0KCQllcnIgPSBFSE9TVFVOUkVBQ0g7CgkJaWYgKGNvZGUgPD0g
TlJfSUNNUF9VTlJFQUNIKSB7CgkJCWhhcmRlcnIgPSBpY21wX2Vycl9jb252ZXJ0W2NvZGVd
LmZhdGFsOwoJCQllcnIgPSBpY21wX2Vycl9jb252ZXJ0W2NvZGVdLmVycm5vOwoJCX0KCQli
cmVhazsKCWNhc2UgSUNNUF9SRURJUkVDVDoKCQlpcHY0X3NrX3JlZGlyZWN0KHNrYiwgc2sp
OwoJCWdvdG8gb3V0OwoJfQoKCS8qCgkgKiAgICAgIFJGQzExMjI6IE9LLiAgUGFzc2VzIElD
TVAgZXJyb3JzIGJhY2sgdG8gYXBwbGljYXRpb24sIGFzIHBlcgoJICoJNC4xLjMuMy4KCSAq
LwoJaWYgKCFpbmV0LT5yZWN2ZXJyKSB7CgkJaWYgKCFoYXJkZXJyIHx8IHNrLT5za19zdGF0
ZSAhPSBUQ1BfRVNUQUJMSVNIRUQpCgkJCWdvdG8gb3V0OwoJfSBlbHNlCgkJaXBfaWNtcF9l
cnJvcihzaywgc2tiLCBlcnIsIHVoLT5kZXN0LCBpbmZvLCAodTggKikodWgrMSkpOwoKCXNr
LT5za19lcnIgPSBlcnI7Cglzay0+c2tfZXJyb3JfcmVwb3J0KHNrKTsKb3V0OgoJc29ja19w
dXQoc2spOwp9Cgp2b2lkIHVkcF9lcnIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgdTMyIGluZm8p
CnsKCV9fdWRwNF9saWJfZXJyKHNrYiwgaW5mbywgJnVkcF90YWJsZSk7Cn0KCi8qCiAqIFRo
cm93IGF3YXkgYWxsIHBlbmRpbmcgZGF0YSBhbmQgY2FuY2VsIHRoZSBjb3JraW5nLiBTb2Nr
ZXQgaXMgbG9ja2VkLgogKi8Kdm9pZCB1ZHBfZmx1c2hfcGVuZGluZ19mcmFtZXMoc3RydWN0
IHNvY2sgKnNrKQp7CglzdHJ1Y3QgdWRwX3NvY2sgKnVwID0gdWRwX3NrKHNrKTsKCglpZiAo
dXAtPnBlbmRpbmcpIHsKCQl1cC0+bGVuID0gMDsKCQl1cC0+cGVuZGluZyA9IDA7CgkJaXBf
Zmx1c2hfcGVuZGluZ19mcmFtZXMoc2spOwoJfQp9CkVYUE9SVF9TWU1CT0wodWRwX2ZsdXNo
X3BlbmRpbmdfZnJhbWVzKTsKCi8qKgogKiAJdWRwNF9od2NzdW0gIC0gIGhhbmRsZSBvdXRn
b2luZyBIVyBjaGVja3N1bW1pbmcKICogCUBza2I6IAlza19idWZmIGNvbnRhaW5pbmcgdGhl
IGZpbGxlZC1pbiBVRFAgaGVhZGVyCiAqIAkgICAgICAgIChjaGVja3N1bSBmaWVsZCBtdXN0
IGJlIHplcm9lZCBvdXQpCiAqCUBzcmM6CXNvdXJjZSBJUCBhZGRyZXNzCiAqCUBkc3Q6CWRl
c3RpbmF0aW9uIElQIGFkZHJlc3MKICovCnZvaWQgdWRwNF9od2NzdW0oc3RydWN0IHNrX2J1
ZmYgKnNrYiwgX19iZTMyIHNyYywgX19iZTMyIGRzdCkKewoJc3RydWN0IHVkcGhkciAqdWgg
PSB1ZHBfaGRyKHNrYik7CglpbnQgb2Zmc2V0ID0gc2tiX3RyYW5zcG9ydF9vZmZzZXQoc2ti
KTsKCWludCBsZW4gPSBza2ItPmxlbiAtIG9mZnNldDsKCWludCBobGVuID0gbGVuOwoJX193
c3VtIGNzdW0gPSAwOwoKCWlmICghc2tiX2hhc19mcmFnX2xpc3Qoc2tiKSkgewoJCS8qCgkJ
ICogT25seSBvbmUgZnJhZ21lbnQgb24gdGhlIHNvY2tldC4KCQkgKi8KCQlza2ItPmNzdW1f
c3RhcnQgPSBza2JfdHJhbnNwb3J0X2hlYWRlcihza2IpIC0gc2tiLT5oZWFkOwoJCXNrYi0+
Y3N1bV9vZmZzZXQgPSBvZmZzZXRvZihzdHJ1Y3QgdWRwaGRyLCBjaGVjayk7CgkJdWgtPmNo
ZWNrID0gfmNzdW1fdGNwdWRwX21hZ2ljKHNyYywgZHN0LCBsZW4sCgkJCQkJICAgICAgIElQ
UFJPVE9fVURQLCAwKTsKCX0gZWxzZSB7CgkJc3RydWN0IHNrX2J1ZmYgKmZyYWdzOwoKCQkv
KgoJCSAqIEhXLWNoZWNrc3VtIHdvbid0IHdvcmsgYXMgdGhlcmUgYXJlIHR3byBvciBtb3Jl
CgkJICogZnJhZ21lbnRzIG9uIHRoZSBzb2NrZXQgc28gdGhhdCBhbGwgY3N1bXMgb2Ygc2tf
YnVmZnMKCQkgKiBzaG91bGQgYmUgdG9nZXRoZXIKCQkgKi8KCQlza2Jfd2Fsa19mcmFncyhz
a2IsIGZyYWdzKSB7CgkJCWNzdW0gPSBjc3VtX2FkZChjc3VtLCBmcmFncy0+Y3N1bSk7CgkJ
CWhsZW4gLT0gZnJhZ3MtPmxlbjsKCQl9CgoJCWNzdW0gPSBza2JfY2hlY2tzdW0oc2tiLCBv
ZmZzZXQsIGhsZW4sIGNzdW0pOwoJCXNrYi0+aXBfc3VtbWVkID0gQ0hFQ0tTVU1fTk9ORTsK
CgkJdWgtPmNoZWNrID0gY3N1bV90Y3B1ZHBfbWFnaWMoc3JjLCBkc3QsIGxlbiwgSVBQUk9U
T19VRFAsIGNzdW0pOwoJCWlmICh1aC0+Y2hlY2sgPT0gMCkKCQkJdWgtPmNoZWNrID0gQ1NV
TV9NQU5HTEVEXzA7Cgl9Cn0KRVhQT1JUX1NZTUJPTF9HUEwodWRwNF9od2NzdW0pOwoKLyog
RnVuY3Rpb24gdG8gc2V0IFVEUCBjaGVja3N1bSBmb3IgYW4gSVB2NCBVRFAgcGFja2V0LiBU
aGlzIGlzIGludGVuZGVkCiAqIGZvciB0aGUgc2ltcGxlIGNhc2UgbGlrZSB3aGVuIHNldHRp
bmcgdGhlIGNoZWNrc3VtIGZvciBhIFVEUCB0dW5uZWwuCiAqLwp2b2lkIHVkcF9zZXRfY3N1
bShib29sIG5vY2hlY2ssIHN0cnVjdCBza19idWZmICpza2IsCgkJICBfX2JlMzIgc2FkZHIs
IF9fYmUzMiBkYWRkciwgaW50IGxlbikKewoJc3RydWN0IHVkcGhkciAqdWggPSB1ZHBfaGRy
KHNrYik7CgoJaWYgKG5vY2hlY2spCgkJdWgtPmNoZWNrID0gMDsKCWVsc2UgaWYgKHNrYl9p
c19nc28oc2tiKSkKCQl1aC0+Y2hlY2sgPSB+dWRwX3Y0X2NoZWNrKGxlbiwgc2FkZHIsIGRh
ZGRyLCAwKTsKCWVsc2UgaWYgKHNrYl9kc3Qoc2tiKSAmJiBza2JfZHN0KHNrYiktPmRldiAm
JgoJCSAoc2tiX2RzdChza2IpLT5kZXYtPmZlYXR1cmVzICYgTkVUSUZfRl9WNF9DU1VNKSkg
ewoKCQlCVUdfT04oc2tiLT5pcF9zdW1tZWQgPT0gQ0hFQ0tTVU1fUEFSVElBTCk7CgoJCXNr
Yi0+aXBfc3VtbWVkID0gQ0hFQ0tTVU1fUEFSVElBTDsKCQlza2ItPmNzdW1fc3RhcnQgPSBz
a2JfdHJhbnNwb3J0X2hlYWRlcihza2IpIC0gc2tiLT5oZWFkOwoJCXNrYi0+Y3N1bV9vZmZz
ZXQgPSBvZmZzZXRvZihzdHJ1Y3QgdWRwaGRyLCBjaGVjayk7CgkJdWgtPmNoZWNrID0gfnVk
cF92NF9jaGVjayhsZW4sIHNhZGRyLCBkYWRkciwgMCk7Cgl9IGVsc2UgewoJCV9fd3N1bSBj
c3VtOwoKCQlCVUdfT04oc2tiLT5pcF9zdW1tZWQgPT0gQ0hFQ0tTVU1fUEFSVElBTCk7CgoJ
CXVoLT5jaGVjayA9IDA7CgkJY3N1bSA9IHNrYl9jaGVja3N1bShza2IsIDAsIGxlbiwgMCk7
CgkJdWgtPmNoZWNrID0gdWRwX3Y0X2NoZWNrKGxlbiwgc2FkZHIsIGRhZGRyLCBjc3VtKTsK
CQlpZiAodWgtPmNoZWNrID09IDApCgkJCXVoLT5jaGVjayA9IENTVU1fTUFOR0xFRF8wOwoK
CQlza2ItPmlwX3N1bW1lZCA9IENIRUNLU1VNX1VOTkVDRVNTQVJZOwoJfQp9CkVYUE9SVF9T
WU1CT0wodWRwX3NldF9jc3VtKTsKCnN0YXRpYyBpbnQgdWRwX3NlbmRfc2tiKHN0cnVjdCBz
a19idWZmICpza2IsIHN0cnVjdCBmbG93aTQgKmZsNCkKewoJc3RydWN0IHNvY2sgKnNrID0g
c2tiLT5zazsKCXN0cnVjdCBpbmV0X3NvY2sgKmluZXQgPSBpbmV0X3NrKHNrKTsKCXN0cnVj
dCB1ZHBoZHIgKnVoOwoJaW50IGVyciA9IDA7CglpbnQgaXNfdWRwbGl0ZSA9IElTX1VEUExJ
VEUoc2spOwoJaW50IG9mZnNldCA9IHNrYl90cmFuc3BvcnRfb2Zmc2V0KHNrYik7CglpbnQg
bGVuID0gc2tiLT5sZW4gLSBvZmZzZXQ7CglfX3dzdW0gY3N1bSA9IDA7CgoJLyoKCSAqIENy
ZWF0ZSBhIFVEUCBoZWFkZXIKCSAqLwoJdWggPSB1ZHBfaGRyKHNrYik7Cgl1aC0+c291cmNl
ID0gaW5ldC0+aW5ldF9zcG9ydDsKCXVoLT5kZXN0ID0gZmw0LT5mbDRfZHBvcnQ7Cgl1aC0+
bGVuID0gaHRvbnMobGVuKTsKCXVoLT5jaGVjayA9IDA7CgoJaWYgKGlzX3VkcGxpdGUpICAJ
CQkJIC8qICAgICBVRFAtTGl0ZSAgICAgICovCgkJY3N1bSA9IHVkcGxpdGVfY3N1bShza2Ip
OwoKCWVsc2UgaWYgKHNrLT5za19ub19jaGVja190eCkgeyAgIC8qIFVEUCBjc3VtIGRpc2Fi
bGVkICovCgoJCXNrYi0+aXBfc3VtbWVkID0gQ0hFQ0tTVU1fTk9ORTsKCQlnb3RvIHNlbmQ7
CgoJfSBlbHNlIGlmIChza2ItPmlwX3N1bW1lZCA9PSBDSEVDS1NVTV9QQVJUSUFMKSB7IC8q
IFVEUCBoYXJkd2FyZSBjc3VtICovCgoJCXVkcDRfaHdjc3VtKHNrYiwgZmw0LT5zYWRkciwg
Zmw0LT5kYWRkcik7CgkJZ290byBzZW5kOwoKCX0gZWxzZQoJCWNzdW0gPSB1ZHBfY3N1bShz
a2IpOwoKCS8qIGFkZCBwcm90b2NvbC1kZXBlbmRlbnQgcHNldWRvLWhlYWRlciAqLwoJdWgt
PmNoZWNrID0gY3N1bV90Y3B1ZHBfbWFnaWMoZmw0LT5zYWRkciwgZmw0LT5kYWRkciwgbGVu
LAoJCQkJICAgICAgc2stPnNrX3Byb3RvY29sLCBjc3VtKTsKCWlmICh1aC0+Y2hlY2sgPT0g
MCkKCQl1aC0+Y2hlY2sgPSBDU1VNX01BTkdMRURfMDsKCnNlbmQ6CgllcnIgPSBpcF9zZW5k
X3NrYihzb2NrX25ldChzayksIHNrYik7CglpZiAoZXJyKSB7CgkJaWYgKGVyciA9PSAtRU5P
QlVGUyAmJiAhaW5ldC0+cmVjdmVycikgewoJCQlVRFBfSU5DX1NUQVRTX1VTRVIoc29ja19u
ZXQoc2spLAoJCQkJCSAgIFVEUF9NSUJfU05EQlVGRVJST1JTLCBpc191ZHBsaXRlKTsKCQkJ
ZXJyID0gMDsKCQl9Cgl9IGVsc2UKCQlVRFBfSU5DX1NUQVRTX1VTRVIoc29ja19uZXQoc2sp
LAoJCQkJICAgVURQX01JQl9PVVREQVRBR1JBTVMsIGlzX3VkcGxpdGUpOwoJcmV0dXJuIGVy
cjsKfQoKLyoKICogUHVzaCBvdXQgYWxsIHBlbmRpbmcgZGF0YSBhcyBvbmUgVURQIGRhdGFn
cmFtLiBTb2NrZXQgaXMgbG9ja2VkLgogKi8KaW50IHVkcF9wdXNoX3BlbmRpbmdfZnJhbWVz
KHN0cnVjdCBzb2NrICpzaykKewoJc3RydWN0IHVkcF9zb2NrICAqdXAgPSB1ZHBfc2soc2sp
OwoJc3RydWN0IGluZXRfc29jayAqaW5ldCA9IGluZXRfc2soc2spOwoJc3RydWN0IGZsb3dp
NCAqZmw0ID0gJmluZXQtPmNvcmsuZmwudS5pcDQ7CglzdHJ1Y3Qgc2tfYnVmZiAqc2tiOwoJ
aW50IGVyciA9IDA7CgoJc2tiID0gaXBfZmluaXNoX3NrYihzaywgZmw0KTsKCWlmICghc2ti
KQoJCWdvdG8gb3V0OwoKCWVyciA9IHVkcF9zZW5kX3NrYihza2IsIGZsNCk7CgpvdXQ6Cgl1
cC0+bGVuID0gMDsKCXVwLT5wZW5kaW5nID0gMDsKCXJldHVybiBlcnI7Cn0KRVhQT1JUX1NZ
TUJPTCh1ZHBfcHVzaF9wZW5kaW5nX2ZyYW1lcyk7CgppbnQgdWRwX3NlbmRtc2coc3RydWN0
IGtpb2NiICppb2NiLCBzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBtc2doZHIgKm1zZywKCQlz
aXplX3QgbGVuKQp7CglzdHJ1Y3QgaW5ldF9zb2NrICppbmV0ID0gaW5ldF9zayhzayk7Cglz
dHJ1Y3QgdWRwX3NvY2sgKnVwID0gdWRwX3NrKHNrKTsKCXN0cnVjdCBmbG93aTQgZmw0X3N0
YWNrOwoJc3RydWN0IGZsb3dpNCAqZmw0OwoJaW50IHVsZW4gPSBsZW47CglzdHJ1Y3QgaXBj
bV9jb29raWUgaXBjOwoJc3RydWN0IHJ0YWJsZSAqcnQgPSBOVUxMOwoJaW50IGZyZWUgPSAw
OwoJaW50IGNvbm5lY3RlZCA9IDA7CglfX2JlMzIgZGFkZHIsIGZhZGRyLCBzYWRkcjsKCV9f
YmUxNiBkcG9ydDsKCXU4ICB0b3M7CglpbnQgZXJyLCBpc191ZHBsaXRlID0gSVNfVURQTElU
RShzayk7CglpbnQgY29ya3JlcSA9IHVwLT5jb3JrZmxhZyB8fCBtc2ctPm1zZ19mbGFncyZN
U0dfTU9SRTsKCWludCAoKmdldGZyYWcpKHZvaWQgKiwgY2hhciAqLCBpbnQsIGludCwgaW50
LCBzdHJ1Y3Qgc2tfYnVmZiAqKTsKCXN0cnVjdCBza19idWZmICpza2I7CglzdHJ1Y3QgaXBf
b3B0aW9uc19kYXRhIG9wdF9jb3B5OwoKCWlmIChsZW4gPiAweEZGRkYpCgkJcmV0dXJuIC1F
TVNHU0laRTsKCgkvKgoJICoJQ2hlY2sgdGhlIGZsYWdzLgoJICovCgoJaWYgKG1zZy0+bXNn
X2ZsYWdzICYgTVNHX09PQikgLyogTWlycm9yIEJTRCBlcnJvciBtZXNzYWdlIGNvbXBhdGli
aWxpdHkgKi8KCQlyZXR1cm4gLUVPUE5PVFNVUFA7CgoJaXBjLm9wdCA9IE5VTEw7CglpcGMu
dHhfZmxhZ3MgPSAwOwoJaXBjLnR0bCA9IDA7CglpcGMudG9zID0gLTE7CgoJZ2V0ZnJhZyA9
IGlzX3VkcGxpdGUgPyB1ZHBsaXRlX2dldGZyYWcgOiBpcF9nZW5lcmljX2dldGZyYWc7CgoJ
Zmw0ID0gJmluZXQtPmNvcmsuZmwudS5pcDQ7CglpZiAodXAtPnBlbmRpbmcpIHsKCQkvKgoJ
CSAqIFRoZXJlIGFyZSBwZW5kaW5nIGZyYW1lcy4KCQkgKiBUaGUgc29ja2V0IGxvY2sgbXVz
dCBiZSBoZWxkIHdoaWxlIGl0J3MgY29ya2VkLgoJCSAqLwoJCWxvY2tfc29jayhzayk7CgkJ
aWYgKGxpa2VseSh1cC0+cGVuZGluZykpIHsKCQkJaWYgKHVubGlrZWx5KHVwLT5wZW5kaW5n
ICE9IEFGX0lORVQpKSB7CgkJCQlyZWxlYXNlX3NvY2soc2spOwoJCQkJcmV0dXJuIC1FSU5W
QUw7CgkJCX0KCQkJZ290byBkb19hcHBlbmRfZGF0YTsKCQl9CgkJcmVsZWFzZV9zb2NrKHNr
KTsKCX0KCXVsZW4gKz0gc2l6ZW9mKHN0cnVjdCB1ZHBoZHIpOwoKCS8qCgkgKglHZXQgYW5k
IHZlcmlmeSB0aGUgYWRkcmVzcy4KCSAqLwoJaWYgKG1zZy0+bXNnX25hbWUpIHsKCQlERUNM
QVJFX1NPQ0tBRERSKHN0cnVjdCBzb2NrYWRkcl9pbiAqLCB1c2luLCBtc2ctPm1zZ19uYW1l
KTsKCQlpZiAobXNnLT5tc2dfbmFtZWxlbiA8IHNpemVvZigqdXNpbikpCgkJCXJldHVybiAt
RUlOVkFMOwoJCWlmICh1c2luLT5zaW5fZmFtaWx5ICE9IEFGX0lORVQpIHsKCQkJaWYgKHVz
aW4tPnNpbl9mYW1pbHkgIT0gQUZfVU5TUEVDKQoJCQkJcmV0dXJuIC1FQUZOT1NVUFBPUlQ7
CgkJfQoKCQlkYWRkciA9IHVzaW4tPnNpbl9hZGRyLnNfYWRkcjsKCQlkcG9ydCA9IHVzaW4t
PnNpbl9wb3J0OwoJCWlmIChkcG9ydCA9PSAwKQoJCQlyZXR1cm4gLUVJTlZBTDsKCX0gZWxz
ZSB7CgkJaWYgKHNrLT5za19zdGF0ZSAhPSBUQ1BfRVNUQUJMSVNIRUQpCgkJCXJldHVybiAt
RURFU1RBRERSUkVROwoJCWRhZGRyID0gaW5ldC0+aW5ldF9kYWRkcjsKCQlkcG9ydCA9IGlu
ZXQtPmluZXRfZHBvcnQ7CgkJLyogT3BlbiBmYXN0IHBhdGggZm9yIGNvbm5lY3RlZCBzb2Nr
ZXQuCgkJICAgUm91dGUgd2lsbCBub3QgYmUgdXNlZCwgaWYgYXQgbGVhc3Qgb25lIG9wdGlv
biBpcyBzZXQuCgkJICovCgkJY29ubmVjdGVkID0gMTsKCX0KCWlwYy5hZGRyID0gaW5ldC0+
aW5ldF9zYWRkcjsKCglpcGMub2lmID0gc2stPnNrX2JvdW5kX2Rldl9pZjsKCglzb2NrX3R4
X3RpbWVzdGFtcChzaywgJmlwYy50eF9mbGFncyk7CgoJaWYgKG1zZy0+bXNnX2NvbnRyb2xs
ZW4pIHsKCQllcnIgPSBpcF9jbXNnX3NlbmQoc29ja19uZXQoc2spLCBtc2csICZpcGMsCgkJ
CQkgICBzay0+c2tfZmFtaWx5ID09IEFGX0lORVQ2KTsKCQlpZiAoZXJyKQoJCQlyZXR1cm4g
ZXJyOwoJCWlmIChpcGMub3B0KQoJCQlmcmVlID0gMTsKCQljb25uZWN0ZWQgPSAwOwoJfQoJ
aWYgKCFpcGMub3B0KSB7CgkJc3RydWN0IGlwX29wdGlvbnNfcmN1ICppbmV0X29wdDsKCgkJ
cmN1X3JlYWRfbG9jaygpOwoJCWluZXRfb3B0ID0gcmN1X2RlcmVmZXJlbmNlKGluZXQtPmlu
ZXRfb3B0KTsKCQlpZiAoaW5ldF9vcHQpIHsKCQkJbWVtY3B5KCZvcHRfY29weSwgaW5ldF9v
cHQsCgkJCSAgICAgICBzaXplb2YoKmluZXRfb3B0KSArIGluZXRfb3B0LT5vcHQub3B0bGVu
KTsKCQkJaXBjLm9wdCA9ICZvcHRfY29weS5vcHQ7CgkJfQoJCXJjdV9yZWFkX3VubG9jaygp
OwoJfQoKCXNhZGRyID0gaXBjLmFkZHI7CglpcGMuYWRkciA9IGZhZGRyID0gZGFkZHI7CgoJ
aWYgKGlwYy5vcHQgJiYgaXBjLm9wdC0+b3B0LnNycikgewoJCWlmICghZGFkZHIpCgkJCXJl
dHVybiAtRUlOVkFMOwoJCWZhZGRyID0gaXBjLm9wdC0+b3B0LmZhZGRyOwoJCWNvbm5lY3Rl
ZCA9IDA7Cgl9Cgl0b3MgPSBnZXRfcnR0b3MoJmlwYywgaW5ldCk7CglpZiAoc29ja19mbGFn
KHNrLCBTT0NLX0xPQ0FMUk9VVEUpIHx8CgkgICAgKG1zZy0+bXNnX2ZsYWdzICYgTVNHX0RP
TlRST1VURSkgfHwKCSAgICAoaXBjLm9wdCAmJiBpcGMub3B0LT5vcHQuaXNfc3RyaWN0cm91
dGUpKSB7CgkJdG9zIHw9IFJUT19PTkxJTks7CgkJY29ubmVjdGVkID0gMDsKCX0KCglpZiAo
aXB2NF9pc19tdWx0aWNhc3QoZGFkZHIpKSB7CgkJaWYgKCFpcGMub2lmKQoJCQlpcGMub2lm
ID0gaW5ldC0+bWNfaW5kZXg7CgkJaWYgKCFzYWRkcikKCQkJc2FkZHIgPSBpbmV0LT5tY19h
ZGRyOwoJCWNvbm5lY3RlZCA9IDA7Cgl9IGVsc2UgaWYgKCFpcGMub2lmKQoJCWlwYy5vaWYg
PSBpbmV0LT51Y19pbmRleDsKCglpZiAoY29ubmVjdGVkKQoJCXJ0ID0gKHN0cnVjdCBydGFi
bGUgKilza19kc3RfY2hlY2soc2ssIDApOwoKCWlmIChydCA9PSBOVUxMKSB7CgkJc3RydWN0
IG5ldCAqbmV0ID0gc29ja19uZXQoc2spOwoKCQlmbDQgPSAmZmw0X3N0YWNrOwoJCWZsb3dp
NF9pbml0X291dHB1dChmbDQsIGlwYy5vaWYsIHNrLT5za19tYXJrLCB0b3MsCgkJCQkgICBS
VF9TQ09QRV9VTklWRVJTRSwgc2stPnNrX3Byb3RvY29sLAoJCQkJICAgaW5ldF9za19mbG93
aV9mbGFncyhzayksCgkJCQkgICBmYWRkciwgc2FkZHIsIGRwb3J0LCBpbmV0LT5pbmV0X3Nw
b3J0KTsKCgkJc2VjdXJpdHlfc2tfY2xhc3NpZnlfZmxvdyhzaywgZmxvd2k0X3RvX2Zsb3dp
KGZsNCkpOwoJCXJ0ID0gaXBfcm91dGVfb3V0cHV0X2Zsb3cobmV0LCBmbDQsIHNrKTsKCQlp
ZiAoSVNfRVJSKHJ0KSkgewoJCQllcnIgPSBQVFJfRVJSKHJ0KTsKCQkJcnQgPSBOVUxMOwoJ
CQlpZiAoZXJyID09IC1FTkVUVU5SRUFDSCkKCQkJCUlQX0lOQ19TVEFUUyhuZXQsIElQU1RB
VFNfTUlCX09VVE5PUk9VVEVTKTsKCQkJZ290byBvdXQ7CgkJfQoKCQllcnIgPSAtRUFDQ0VT
OwoJCWlmICgocnQtPnJ0X2ZsYWdzICYgUlRDRl9CUk9BRENBU1QpICYmCgkJICAgICFzb2Nr
X2ZsYWcoc2ssIFNPQ0tfQlJPQURDQVNUKSkKCQkJZ290byBvdXQ7CgkJaWYgKGNvbm5lY3Rl
ZCkKCQkJc2tfZHN0X3NldChzaywgZHN0X2Nsb25lKCZydC0+ZHN0KSk7Cgl9CgoJaWYgKG1z
Zy0+bXNnX2ZsYWdzJk1TR19DT05GSVJNKQoJCWdvdG8gZG9fY29uZmlybTsKYmFja19mcm9t
X2NvbmZpcm06CgoJc2FkZHIgPSBmbDQtPnNhZGRyOwoJaWYgKCFpcGMuYWRkcikKCQlkYWRk
ciA9IGlwYy5hZGRyID0gZmw0LT5kYWRkcjsKCgkvKiBMb2NrbGVzcyBmYXN0IHBhdGggZm9y
IHRoZSBub24tY29ya2luZyBjYXNlLiAqLwoJaWYgKCFjb3JrcmVxKSB7CgkJc2tiID0gaXBf
bWFrZV9za2Ioc2ssIGZsNCwgZ2V0ZnJhZywgbXNnLCB1bGVuLAoJCQkJICBzaXplb2Yoc3Ry
dWN0IHVkcGhkciksICZpcGMsICZydCwKCQkJCSAgbXNnLT5tc2dfZmxhZ3MpOwoJCWVyciA9
IFBUUl9FUlIoc2tiKTsKCQlpZiAoIUlTX0VSUl9PUl9OVUxMKHNrYikpCgkJCWVyciA9IHVk
cF9zZW5kX3NrYihza2IsIGZsNCk7CgkJZ290byBvdXQ7Cgl9CgoJbG9ja19zb2NrKHNrKTsK
CWlmICh1bmxpa2VseSh1cC0+cGVuZGluZykpIHsKCQkvKiBUaGUgc29ja2V0IGlzIGFscmVh
ZHkgY29ya2VkIHdoaWxlIHByZXBhcmluZyBpdC4gKi8KCQkvKiAuLi4gd2hpY2ggaXMgYW4g
ZXZpZGVudCBhcHBsaWNhdGlvbiBidWcuIC0tQU5LICovCgkJcmVsZWFzZV9zb2NrKHNrKTsK
CgkJbmV0X2RiZ19yYXRlbGltaXRlZCgiY29yayBhcHAgYnVnIDJcbiIpOwoJCWVyciA9IC1F
SU5WQUw7CgkJZ290byBvdXQ7Cgl9CgkvKgoJICoJTm93IGNvcmsgdGhlIHNvY2tldCB0byBw
ZW5kIGRhdGEuCgkgKi8KCWZsNCA9ICZpbmV0LT5jb3JrLmZsLnUuaXA0OwoJZmw0LT5kYWRk
ciA9IGRhZGRyOwoJZmw0LT5zYWRkciA9IHNhZGRyOwoJZmw0LT5mbDRfZHBvcnQgPSBkcG9y
dDsKCWZsNC0+Zmw0X3Nwb3J0ID0gaW5ldC0+aW5ldF9zcG9ydDsKCXVwLT5wZW5kaW5nID0g
QUZfSU5FVDsKCmRvX2FwcGVuZF9kYXRhOgoJdXAtPmxlbiArPSB1bGVuOwoJZXJyID0gaXBf
YXBwZW5kX2RhdGEoc2ssIGZsNCwgZ2V0ZnJhZywgbXNnLCB1bGVuLAoJCQkgICAgIHNpemVv
ZihzdHJ1Y3QgdWRwaGRyKSwgJmlwYywgJnJ0LAoJCQkgICAgIGNvcmtyZXEgPyBtc2ctPm1z
Z19mbGFnc3xNU0dfTU9SRSA6IG1zZy0+bXNnX2ZsYWdzKTsKCWlmIChlcnIpCgkJdWRwX2Zs
dXNoX3BlbmRpbmdfZnJhbWVzKHNrKTsKCWVsc2UgaWYgKCFjb3JrcmVxKQoJCWVyciA9IHVk
cF9wdXNoX3BlbmRpbmdfZnJhbWVzKHNrKTsKCWVsc2UgaWYgKHVubGlrZWx5KHNrYl9xdWV1
ZV9lbXB0eSgmc2stPnNrX3dyaXRlX3F1ZXVlKSkpCgkJdXAtPnBlbmRpbmcgPSAwOwoJcmVs
ZWFzZV9zb2NrKHNrKTsKCm91dDoKCWlwX3J0X3B1dChydCk7CglpZiAoZnJlZSkKCQlrZnJl
ZShpcGMub3B0KTsKCWlmICghZXJyKQoJCXJldHVybiBsZW47CgkvKgoJICogRU5PQlVGUyA9
IG5vIGtlcm5lbCBtZW0sIFNPQ0tfTk9TUEFDRSA9IG5vIHNuZGJ1ZiBzcGFjZS4gIFJlcG9y
dGluZwoJICogRU5PQlVGUyBtaWdodCBub3QgYmUgZ29vZCAoaXQncyBub3QgdHVuYWJsZSBw
ZXIgc2UpLCBidXQgb3RoZXJ3aXNlCgkgKiB3ZSBkb24ndCBoYXZlIGEgZ29vZCBzdGF0aXN0
aWMgKElwT3V0RGlzY2FyZHMgYnV0IGl0IGNhbiBiZSB0b28gbWFueQoJICogdGhpbmdzKS4g
IFdlIGNvdWxkIGFkZCBhbm90aGVyIG5ldyBzdGF0IGJ1dCBhdCBsZWFzdCBmb3Igbm93IHRo
YXQKCSAqIHNlZW1zIGxpa2Ugb3ZlcmtpbGwuCgkgKi8KCWlmIChlcnIgPT0gLUVOT0JVRlMg
fHwgdGVzdF9iaXQoU09DS19OT1NQQUNFLCAmc2stPnNrX3NvY2tldC0+ZmxhZ3MpKSB7CgkJ
VURQX0lOQ19TVEFUU19VU0VSKHNvY2tfbmV0KHNrKSwKCQkJCVVEUF9NSUJfU05EQlVGRVJS
T1JTLCBpc191ZHBsaXRlKTsKCX0KCXJldHVybiBlcnI7Cgpkb19jb25maXJtOgoJZHN0X2Nv
bmZpcm0oJnJ0LT5kc3QpOwoJaWYgKCEobXNnLT5tc2dfZmxhZ3MmTVNHX1BST0JFKSB8fCBs
ZW4pCgkJZ290byBiYWNrX2Zyb21fY29uZmlybTsKCWVyciA9IDA7Cglnb3RvIG91dDsKfQpF
WFBPUlRfU1lNQk9MKHVkcF9zZW5kbXNnKTsKCmludCB1ZHBfc2VuZHBhZ2Uoc3RydWN0IHNv
Y2sgKnNrLCBzdHJ1Y3QgcGFnZSAqcGFnZSwgaW50IG9mZnNldCwKCQkgc2l6ZV90IHNpemUs
IGludCBmbGFncykKewoJc3RydWN0IGluZXRfc29jayAqaW5ldCA9IGluZXRfc2soc2spOwoJ
c3RydWN0IHVkcF9zb2NrICp1cCA9IHVkcF9zayhzayk7CglpbnQgcmV0OwoKCWlmIChmbGFn
cyAmIE1TR19TRU5EUEFHRV9OT1RMQVNUKQoJCWZsYWdzIHw9IE1TR19NT1JFOwoKCWlmICgh
dXAtPnBlbmRpbmcpIHsKCQlzdHJ1Y3QgbXNnaGRyIG1zZyA9IHsJLm1zZ19mbGFncyA9IGZs
YWdzfE1TR19NT1JFIH07CgoJCS8qIENhbGwgdWRwX3NlbmRtc2cgdG8gc3BlY2lmeSBkZXN0
aW5hdGlvbiBhZGRyZXNzIHdoaWNoCgkJICogc2VuZHBhZ2UgaW50ZXJmYWNlIGNhbid0IHBh
c3MuCgkJICogVGhpcyB3aWxsIHN1Y2NlZWQgb25seSB3aGVuIHRoZSBzb2NrZXQgaXMgY29u
bmVjdGVkLgoJCSAqLwoJCXJldCA9IHVkcF9zZW5kbXNnKE5VTEwsIHNrLCAmbXNnLCAwKTsK
CQlpZiAocmV0IDwgMCkKCQkJcmV0dXJuIHJldDsKCX0KCglsb2NrX3NvY2soc2spOwoKCWlm
ICh1bmxpa2VseSghdXAtPnBlbmRpbmcpKSB7CgkJcmVsZWFzZV9zb2NrKHNrKTsKCgkJbmV0
X2RiZ19yYXRlbGltaXRlZCgidWRwIGNvcmsgYXBwIGJ1ZyAzXG4iKTsKCQlyZXR1cm4gLUVJ
TlZBTDsKCX0KCglyZXQgPSBpcF9hcHBlbmRfcGFnZShzaywgJmluZXQtPmNvcmsuZmwudS5p
cDQsCgkJCSAgICAgcGFnZSwgb2Zmc2V0LCBzaXplLCBmbGFncyk7CglpZiAocmV0ID09IC1F
T1BOT1RTVVBQKSB7CgkJcmVsZWFzZV9zb2NrKHNrKTsKCQlyZXR1cm4gc29ja19ub19zZW5k
cGFnZShzay0+c2tfc29ja2V0LCBwYWdlLCBvZmZzZXQsCgkJCQkJc2l6ZSwgZmxhZ3MpOwoJ
fQoJaWYgKHJldCA8IDApIHsKCQl1ZHBfZmx1c2hfcGVuZGluZ19mcmFtZXMoc2spOwoJCWdv
dG8gb3V0OwoJfQoKCXVwLT5sZW4gKz0gc2l6ZTsKCWlmICghKHVwLT5jb3JrZmxhZyB8fCAo
ZmxhZ3MmTVNHX01PUkUpKSkKCQlyZXQgPSB1ZHBfcHVzaF9wZW5kaW5nX2ZyYW1lcyhzayk7
CglpZiAoIXJldCkKCQlyZXQgPSBzaXplOwpvdXQ6CglyZWxlYXNlX3NvY2soc2spOwoJcmV0
dXJuIHJldDsKfQoKCi8qKgogKglmaXJzdF9wYWNrZXRfbGVuZ3RoCS0gcmV0dXJuIGxlbmd0
aCBvZiBmaXJzdCBwYWNrZXQgaW4gcmVjZWl2ZSBxdWV1ZQogKglAc2s6IHNvY2tldAogKgog
KglEcm9wcyBhbGwgYmFkIGNoZWNrc3VtIGZyYW1lcywgdW50aWwgYSB2YWxpZCBvbmUgaXMg
Zm91bmQuCiAqCVJldHVybnMgdGhlIGxlbmd0aCBvZiBmb3VuZCBza2IsIG9yIDAgaWYgbm9u
ZSBpcyBmb3VuZC4KICovCnN0YXRpYyB1bnNpZ25lZCBpbnQgZmlyc3RfcGFja2V0X2xlbmd0
aChzdHJ1Y3Qgc29jayAqc2spCnsKCXN0cnVjdCBza19idWZmX2hlYWQgbGlzdF9raWxsLCAq
cmN2cSA9ICZzay0+c2tfcmVjZWl2ZV9xdWV1ZTsKCXN0cnVjdCBza19idWZmICpza2I7Cgl1
bnNpZ25lZCBpbnQgcmVzOwoKCV9fc2tiX3F1ZXVlX2hlYWRfaW5pdCgmbGlzdF9raWxsKTsK
CglzcGluX2xvY2tfYmgoJnJjdnEtPmxvY2spOwoJd2hpbGUgKChza2IgPSBza2JfcGVlayhy
Y3ZxKSkgIT0gTlVMTCAmJgoJCXVkcF9saWJfY2hlY2tzdW1fY29tcGxldGUoc2tiKSkgewoJ
CVVEUF9JTkNfU1RBVFNfQkgoc29ja19uZXQoc2spLCBVRFBfTUlCX0NTVU1FUlJPUlMsCgkJ
CQkgSVNfVURQTElURShzaykpOwoJCVVEUF9JTkNfU1RBVFNfQkgoc29ja19uZXQoc2spLCBV
RFBfTUlCX0lORVJST1JTLAoJCQkJIElTX1VEUExJVEUoc2spKTsKCQlhdG9taWNfaW5jKCZz
ay0+c2tfZHJvcHMpOwoJCV9fc2tiX3VubGluayhza2IsIHJjdnEpOwoJCV9fc2tiX3F1ZXVl
X3RhaWwoJmxpc3Rfa2lsbCwgc2tiKTsKCX0KCXJlcyA9IHNrYiA/IHNrYi0+bGVuIDogMDsK
CXNwaW5fdW5sb2NrX2JoKCZyY3ZxLT5sb2NrKTsKCglpZiAoIXNrYl9xdWV1ZV9lbXB0eSgm
bGlzdF9raWxsKSkgewoJCWJvb2wgc2xvdyA9IGxvY2tfc29ja19mYXN0KHNrKTsKCgkJX19z
a2JfcXVldWVfcHVyZ2UoJmxpc3Rfa2lsbCk7CgkJc2tfbWVtX3JlY2xhaW1fcGFydGlhbChz
ayk7CgkJdW5sb2NrX3NvY2tfZmFzdChzaywgc2xvdyk7Cgl9CglyZXR1cm4gcmVzOwp9Cgov
KgogKglJT0NUTCByZXF1ZXN0cyBhcHBsaWNhYmxlIHRvIHRoZSBVRFAgcHJvdG9jb2wKICov
CgppbnQgdWRwX2lvY3RsKHN0cnVjdCBzb2NrICpzaywgaW50IGNtZCwgdW5zaWduZWQgbG9u
ZyBhcmcpCnsKCXN3aXRjaCAoY21kKSB7CgljYXNlIFNJT0NPVVRROgoJewoJCWludCBhbW91
bnQgPSBza193bWVtX2FsbG9jX2dldChzayk7CgoJCXJldHVybiBwdXRfdXNlcihhbW91bnQs
IChpbnQgX191c2VyICopYXJnKTsKCX0KCgljYXNlIFNJT0NJTlE6Cgl7CgkJdW5zaWduZWQg
aW50IGFtb3VudCA9IGZpcnN0X3BhY2tldF9sZW5ndGgoc2spOwoKCQlpZiAoYW1vdW50KQoJ
CQkvKgoJCQkgKiBXZSB3aWxsIG9ubHkgcmV0dXJuIHRoZSBhbW91bnQKCQkJICogb2YgdGhp
cyBwYWNrZXQgc2luY2UgdGhhdCBpcyBhbGwKCQkJICogdGhhdCB3aWxsIGJlIHJlYWQuCgkJ
CSAqLwoJCQlhbW91bnQgLT0gc2l6ZW9mKHN0cnVjdCB1ZHBoZHIpOwoKCQlyZXR1cm4gcHV0
X3VzZXIoYW1vdW50LCAoaW50IF9fdXNlciAqKWFyZyk7Cgl9CgoJZGVmYXVsdDoKCQlyZXR1
cm4gLUVOT0lPQ1RMQ01EOwoJfQoKCXJldHVybiAwOwp9CkVYUE9SVF9TWU1CT0wodWRwX2lv
Y3RsKTsKCi8qCiAqIAlUaGlzIHNob3VsZCBiZSBlYXN5LCBpZiB0aGVyZSBpcyBzb21ldGhp
bmcgdGhlcmUgd2UKICogCXJldHVybiBpdCwgb3RoZXJ3aXNlIHdlIGJsb2NrLgogKi8KCmlu
dCB1ZHBfcmVjdm1zZyhzdHJ1Y3Qga2lvY2IgKmlvY2IsIHN0cnVjdCBzb2NrICpzaywgc3Ry
dWN0IG1zZ2hkciAqbXNnLAoJCXNpemVfdCBsZW4sIGludCBub2Jsb2NrLCBpbnQgZmxhZ3Ms
IGludCAqYWRkcl9sZW4pCnsKCXN0cnVjdCBpbmV0X3NvY2sgKmluZXQgPSBpbmV0X3NrKHNr
KTsKCURFQ0xBUkVfU09DS0FERFIoc3RydWN0IHNvY2thZGRyX2luICosIHNpbiwgbXNnLT5t
c2dfbmFtZSk7CglzdHJ1Y3Qgc2tfYnVmZiAqc2tiOwoJdW5zaWduZWQgaW50IHVsZW4sIGNv
cGllZDsKCWludCBwZWVrZWQsIG9mZiA9IDA7CglpbnQgZXJyOwoJaW50IGlzX3VkcGxpdGUg
PSBJU19VRFBMSVRFKHNrKTsKCWJvb2wgc2xvdzsKCglpZiAoZmxhZ3MgJiBNU0dfRVJSUVVF
VUUpCgkJcmV0dXJuIGlwX3JlY3ZfZXJyb3Ioc2ssIG1zZywgbGVuLCBhZGRyX2xlbik7Cgp0
cnlfYWdhaW46Cglza2IgPSBfX3NrYl9yZWN2X2RhdGFncmFtKHNrLCBmbGFncyB8IChub2Js
b2NrID8gTVNHX0RPTlRXQUlUIDogMCksCgkJCQkgICZwZWVrZWQsICZvZmYsICZlcnIpOwoJ
aWYgKCFza2IpCgkJZ290byBvdXQ7CgoJdWxlbiA9IHNrYi0+bGVuIC0gc2l6ZW9mKHN0cnVj
dCB1ZHBoZHIpOwoJY29waWVkID0gbGVuOwoJaWYgKGNvcGllZCA+IHVsZW4pCgkJY29waWVk
ID0gdWxlbjsKCWVsc2UgaWYgKGNvcGllZCA8IHVsZW4pCgkJbXNnLT5tc2dfZmxhZ3MgfD0g
TVNHX1RSVU5DOwoKCS8qCgkgKiBJZiBjaGVja3N1bSBpcyBuZWVkZWQgYXQgYWxsLCB0cnkg
dG8gZG8gaXQgd2hpbGUgY29weWluZyB0aGUKCSAqIGRhdGEuICBJZiB0aGUgZGF0YSBpcyB0
cnVuY2F0ZWQsIG9yIGlmIHdlIG9ubHkgd2FudCBhIHBhcnRpYWwKCSAqIGNvdmVyYWdlIGNo
ZWNrc3VtIChVRFAtTGl0ZSksIGRvIGl0IGJlZm9yZSB0aGUgY29weS4KCSAqLwoKCWlmIChj
b3BpZWQgPCB1bGVuIHx8IFVEUF9TS0JfQ0Ioc2tiKS0+cGFydGlhbF9jb3YpIHsKCQlpZiAo
dWRwX2xpYl9jaGVja3N1bV9jb21wbGV0ZShza2IpKQoJCQlnb3RvIGNzdW1fY29weV9lcnI7
Cgl9CgoJaWYgKHNrYl9jc3VtX3VubmVjZXNzYXJ5KHNrYikpCgkJZXJyID0gc2tiX2NvcHlf
ZGF0YWdyYW1fbXNnKHNrYiwgc2l6ZW9mKHN0cnVjdCB1ZHBoZHIpLAoJCQkJCSAgICBtc2cs
IGNvcGllZCk7CgllbHNlIHsKCQllcnIgPSBza2JfY29weV9hbmRfY3N1bV9kYXRhZ3JhbV9t
c2coc2tiLCBzaXplb2Yoc3RydWN0IHVkcGhkciksCgkJCQkJCSAgICAgbXNnKTsKCgkJaWYg
KGVyciA9PSAtRUlOVkFMKQoJCQlnb3RvIGNzdW1fY29weV9lcnI7Cgl9CgoJaWYgKHVubGlr
ZWx5KGVycikpIHsKCQl0cmFjZV9rZnJlZV9za2Ioc2tiLCB1ZHBfcmVjdm1zZyk7CgkJaWYg
KCFwZWVrZWQpIHsKCQkJYXRvbWljX2luYygmc2stPnNrX2Ryb3BzKTsKCQkJVURQX0lOQ19T
VEFUU19VU0VSKHNvY2tfbmV0KHNrKSwKCQkJCQkgICBVRFBfTUlCX0lORVJST1JTLCBpc191
ZHBsaXRlKTsKCQl9CgkJZ290byBvdXRfZnJlZTsKCX0KCglpZiAoIXBlZWtlZCkKCQlVRFBf
SU5DX1NUQVRTX1VTRVIoc29ja19uZXQoc2spLAoJCQkJVURQX01JQl9JTkRBVEFHUkFNUywg
aXNfdWRwbGl0ZSk7CgoJc29ja19yZWN2X3RzX2FuZF9kcm9wcyhtc2csIHNrLCBza2IpOwoK
CS8qIENvcHkgdGhlIGFkZHJlc3MuICovCglpZiAoc2luKSB7CgkJc2luLT5zaW5fZmFtaWx5
ID0gQUZfSU5FVDsKCQlzaW4tPnNpbl9wb3J0ID0gdWRwX2hkcihza2IpLT5zb3VyY2U7CgkJ
c2luLT5zaW5fYWRkci5zX2FkZHIgPSBpcF9oZHIoc2tiKS0+c2FkZHI7CgkJbWVtc2V0KHNp
bi0+c2luX3plcm8sIDAsIHNpemVvZihzaW4tPnNpbl96ZXJvKSk7CgkJKmFkZHJfbGVuID0g
c2l6ZW9mKCpzaW4pOwoJfQoJaWYgKGluZXQtPmNtc2dfZmxhZ3MpCgkJaXBfY21zZ19yZWN2
KG1zZywgc2tiKTsKCgllcnIgPSBjb3BpZWQ7CglpZiAoZmxhZ3MgJiBNU0dfVFJVTkMpCgkJ
ZXJyID0gdWxlbjsKCm91dF9mcmVlOgoJc2tiX2ZyZWVfZGF0YWdyYW1fbG9ja2VkKHNrLCBz
a2IpOwpvdXQ6CglyZXR1cm4gZXJyOwoKY3N1bV9jb3B5X2VycjoKCXNsb3cgPSBsb2NrX3Nv
Y2tfZmFzdChzayk7CglpZiAoIXNrYl9raWxsX2RhdGFncmFtKHNrLCBza2IsIGZsYWdzKSkg
ewoJCVVEUF9JTkNfU1RBVFNfVVNFUihzb2NrX25ldChzayksIFVEUF9NSUJfQ1NVTUVSUk9S
UywgaXNfdWRwbGl0ZSk7CgkJVURQX0lOQ19TVEFUU19VU0VSKHNvY2tfbmV0KHNrKSwgVURQ
X01JQl9JTkVSUk9SUywgaXNfdWRwbGl0ZSk7Cgl9Cgl1bmxvY2tfc29ja19mYXN0KHNrLCBz
bG93KTsKCglpZiAobm9ibG9jaykKCQlyZXR1cm4gLUVBR0FJTjsKCgkvKiBzdGFydGluZyBv
dmVyIGZvciBhIG5ldyBwYWNrZXQgKi8KCW1zZy0+bXNnX2ZsYWdzICY9IH5NU0dfVFJVTkM7
Cglnb3RvIHRyeV9hZ2FpbjsKfQoKCmludCB1ZHBfZGlzY29ubmVjdChzdHJ1Y3Qgc29jayAq
c2ssIGludCBmbGFncykKewoJc3RydWN0IGluZXRfc29jayAqaW5ldCA9IGluZXRfc2soc2sp
OwoJLyoKCSAqCTEwMDMuMWcgLSBicmVhayBhc3NvY2lhdGlvbi4KCSAqLwoKCXNrLT5za19z
dGF0ZSA9IFRDUF9DTE9TRTsKCWluZXQtPmluZXRfZGFkZHIgPSAwOwoJaW5ldC0+aW5ldF9k
cG9ydCA9IDA7Cglzb2NrX3Jwc19yZXNldF9yeGhhc2goc2spOwoJc2stPnNrX2JvdW5kX2Rl
dl9pZiA9IDA7CglpZiAoIShzay0+c2tfdXNlcmxvY2tzICYgU09DS19CSU5EQUREUl9MT0NL
KSkKCQlpbmV0X3Jlc2V0X3NhZGRyKHNrKTsKCglpZiAoIShzay0+c2tfdXNlcmxvY2tzICYg
U09DS19CSU5EUE9SVF9MT0NLKSkgewoJCXNrLT5za19wcm90LT51bmhhc2goc2spOwoJCWlu
ZXQtPmluZXRfc3BvcnQgPSAwOwoJfQoJc2tfZHN0X3Jlc2V0KHNrKTsKCXJldHVybiAwOwp9
CkVYUE9SVF9TWU1CT0wodWRwX2Rpc2Nvbm5lY3QpOwoKdm9pZCB1ZHBfbGliX3VuaGFzaChz
dHJ1Y3Qgc29jayAqc2spCnsKCWlmIChza19oYXNoZWQoc2spKSB7CgkJc3RydWN0IHVkcF90
YWJsZSAqdWRwdGFibGUgPSBzay0+c2tfcHJvdC0+aC51ZHBfdGFibGU7CgkJc3RydWN0IHVk
cF9oc2xvdCAqaHNsb3QsICpoc2xvdDI7CgoJCWhzbG90ICA9IHVkcF9oYXNoc2xvdCh1ZHB0
YWJsZSwgc29ja19uZXQoc2spLAoJCQkJICAgICAgdWRwX3NrKHNrKS0+dWRwX3BvcnRfaGFz
aCk7CgkJaHNsb3QyID0gdWRwX2hhc2hzbG90Mih1ZHB0YWJsZSwgdWRwX3NrKHNrKS0+dWRw
X3BvcnRhZGRyX2hhc2gpOwoKCQlzcGluX2xvY2tfYmgoJmhzbG90LT5sb2NrKTsKCQlpZiAo
c2tfbnVsbHNfZGVsX25vZGVfaW5pdF9yY3Uoc2spKSB7CgkJCWhzbG90LT5jb3VudC0tOwoJ
CQlpbmV0X3NrKHNrKS0+aW5ldF9udW0gPSAwOwoJCQlzb2NrX3Byb3RfaW51c2VfYWRkKHNv
Y2tfbmV0KHNrKSwgc2stPnNrX3Byb3QsIC0xKTsKCgkJCXNwaW5fbG9jaygmaHNsb3QyLT5s
b2NrKTsKCQkJaGxpc3RfbnVsbHNfZGVsX2luaXRfcmN1KCZ1ZHBfc2soc2spLT51ZHBfcG9y
dGFkZHJfbm9kZSk7CgkJCWhzbG90Mi0+Y291bnQtLTsKCQkJc3Bpbl91bmxvY2soJmhzbG90
Mi0+bG9jayk7CgkJfQoJCXNwaW5fdW5sb2NrX2JoKCZoc2xvdC0+bG9jayk7Cgl9Cn0KRVhQ
T1JUX1NZTUJPTCh1ZHBfbGliX3VuaGFzaCk7CgovKgogKiBpbmV0X3Jjdl9zYWRkciB3YXMg
Y2hhbmdlZCwgd2UgbXVzdCByZWhhc2ggc2Vjb25kYXJ5IGhhc2gKICovCnZvaWQgdWRwX2xp
Yl9yZWhhc2goc3RydWN0IHNvY2sgKnNrLCB1MTYgbmV3aGFzaCkKewoJaWYgKHNrX2hhc2hl
ZChzaykpIHsKCQlzdHJ1Y3QgdWRwX3RhYmxlICp1ZHB0YWJsZSA9IHNrLT5za19wcm90LT5o
LnVkcF90YWJsZTsKCQlzdHJ1Y3QgdWRwX2hzbG90ICpoc2xvdCwgKmhzbG90MiwgKm5oc2xv
dDI7CgoJCWhzbG90MiA9IHVkcF9oYXNoc2xvdDIodWRwdGFibGUsIHVkcF9zayhzayktPnVk
cF9wb3J0YWRkcl9oYXNoKTsKCQluaHNsb3QyID0gdWRwX2hhc2hzbG90Mih1ZHB0YWJsZSwg
bmV3aGFzaCk7CgkJdWRwX3NrKHNrKS0+dWRwX3BvcnRhZGRyX2hhc2ggPSBuZXdoYXNoOwoJ
CWlmIChoc2xvdDIgIT0gbmhzbG90MikgewoJCQloc2xvdCA9IHVkcF9oYXNoc2xvdCh1ZHB0
YWJsZSwgc29ja19uZXQoc2spLAoJCQkJCSAgICAgdWRwX3NrKHNrKS0+dWRwX3BvcnRfaGFz
aCk7CgkJCS8qIHdlIG11c3QgbG9jayBwcmltYXJ5IGNoYWluIHRvbyAqLwoJCQlzcGluX2xv
Y2tfYmgoJmhzbG90LT5sb2NrKTsKCgkJCXNwaW5fbG9jaygmaHNsb3QyLT5sb2NrKTsKCQkJ
aGxpc3RfbnVsbHNfZGVsX2luaXRfcmN1KCZ1ZHBfc2soc2spLT51ZHBfcG9ydGFkZHJfbm9k
ZSk7CgkJCWhzbG90Mi0+Y291bnQtLTsKCQkJc3Bpbl91bmxvY2soJmhzbG90Mi0+bG9jayk7
CgoJCQlzcGluX2xvY2soJm5oc2xvdDItPmxvY2spOwoJCQlobGlzdF9udWxsc19hZGRfaGVh
ZF9yY3UoJnVkcF9zayhzayktPnVkcF9wb3J0YWRkcl9ub2RlLAoJCQkJCQkgJm5oc2xvdDIt
PmhlYWQpOwoJCQluaHNsb3QyLT5jb3VudCsrOwoJCQlzcGluX3VubG9jaygmbmhzbG90Mi0+
bG9jayk7CgoJCQlzcGluX3VubG9ja19iaCgmaHNsb3QtPmxvY2spOwoJCX0KCX0KfQpFWFBP
UlRfU1lNQk9MKHVkcF9saWJfcmVoYXNoKTsKCnN0YXRpYyB2b2lkIHVkcF92NF9yZWhhc2go
c3RydWN0IHNvY2sgKnNrKQp7Cgl1MTYgbmV3X2hhc2ggPSB1ZHA0X3BvcnRhZGRyX2hhc2go
c29ja19uZXQoc2spLAoJCQkJCSAgaW5ldF9zayhzayktPmluZXRfcmN2X3NhZGRyLAoJCQkJ
CSAgaW5ldF9zayhzayktPmluZXRfbnVtKTsKCXVkcF9saWJfcmVoYXNoKHNrLCBuZXdfaGFz
aCk7Cn0KCnN0YXRpYyBpbnQgX191ZHBfcXVldWVfcmN2X3NrYihzdHJ1Y3Qgc29jayAqc2ss
IHN0cnVjdCBza19idWZmICpza2IpCnsKCWludCByYzsKCglpZiAoaW5ldF9zayhzayktPmlu
ZXRfZGFkZHIpIHsKCQlzb2NrX3Jwc19zYXZlX3J4aGFzaChzaywgc2tiKTsKCQlza19tYXJr
X25hcGlfaWQoc2ssIHNrYik7CgkJc2tfaW5jb21pbmdfY3B1X3VwZGF0ZShzayk7Cgl9CgoJ
cmMgPSBzb2NrX3F1ZXVlX3Jjdl9za2Ioc2ssIHNrYik7CglpZiAocmMgPCAwKSB7CgkJaW50
IGlzX3VkcGxpdGUgPSBJU19VRFBMSVRFKHNrKTsKCgkJLyogTm90ZSB0aGF0IGFuIEVOT01F
TSBlcnJvciBpcyBjaGFyZ2VkIHR3aWNlICovCgkJaWYgKHJjID09IC1FTk9NRU0pCgkJCVVE
UF9JTkNfU1RBVFNfQkgoc29ja19uZXQoc2spLCBVRFBfTUlCX1JDVkJVRkVSUk9SUywKCQkJ
CQkgaXNfdWRwbGl0ZSk7CgkJVURQX0lOQ19TVEFUU19CSChzb2NrX25ldChzayksIFVEUF9N
SUJfSU5FUlJPUlMsIGlzX3VkcGxpdGUpOwoJCWtmcmVlX3NrYihza2IpOwoJCXRyYWNlX3Vk
cF9mYWlsX3F1ZXVlX3Jjdl9za2IocmMsIHNrKTsKCQlyZXR1cm4gLTE7Cgl9CgoJcmV0dXJu
IDA7Cgp9CgpzdGF0aWMgc3RydWN0IHN0YXRpY19rZXkgdWRwX2VuY2FwX25lZWRlZCBfX3Jl
YWRfbW9zdGx5Owp2b2lkIHVkcF9lbmNhcF9lbmFibGUodm9pZCkKewoJaWYgKCFzdGF0aWNf
a2V5X2VuYWJsZWQoJnVkcF9lbmNhcF9uZWVkZWQpKQoJCXN0YXRpY19rZXlfc2xvd19pbmMo
JnVkcF9lbmNhcF9uZWVkZWQpOwp9CkVYUE9SVF9TWU1CT0wodWRwX2VuY2FwX2VuYWJsZSk7
CgovKiByZXR1cm5zOgogKiAgLTE6IGVycm9yCiAqICAgMDogc3VjY2VzcwogKiAgPjA6ICJ1
ZHAgZW5jYXAiIHByb3RvY29sIHJlc3VibWlzc2lvbgogKgogKiBOb3RlIHRoYXQgaW4gdGhl
IHN1Y2Nlc3MgYW5kIGVycm9yIGNhc2VzLCB0aGUgc2tiIGlzIGFzc3VtZWQgdG8KICogaGF2
ZSBlaXRoZXIgYmVlbiByZXF1ZXVlZCBvciBmcmVlZC4KICovCmludCB1ZHBfcXVldWVfcmN2
X3NrYihzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBza19idWZmICpza2IpCnsKCXN0cnVjdCB1
ZHBfc29jayAqdXAgPSB1ZHBfc2soc2spOwoJaW50IHJjOwoJaW50IGlzX3VkcGxpdGUgPSBJ
U19VRFBMSVRFKHNrKTsKCgkvKgoJICoJQ2hhcmdlIGl0IHRvIHRoZSBzb2NrZXQsIGRyb3Bw
aW5nIGlmIHRoZSBxdWV1ZSBpcyBmdWxsLgoJICovCglpZiAoIXhmcm00X3BvbGljeV9jaGVj
ayhzaywgWEZSTV9QT0xJQ1lfSU4sIHNrYikpCgkJZ290byBkcm9wOwoJbmZfcmVzZXQoc2ti
KTsKCglpZiAoc3RhdGljX2tleV9mYWxzZSgmdWRwX2VuY2FwX25lZWRlZCkgJiYgdXAtPmVu
Y2FwX3R5cGUpIHsKCQlpbnQgKCplbmNhcF9yY3YpKHN0cnVjdCBzb2NrICpzaywgc3RydWN0
IHNrX2J1ZmYgKnNrYik7CgoJCS8qCgkJICogVGhpcyBpcyBhbiBlbmNhcHN1bGF0aW9uIHNv
Y2tldCBzbyBwYXNzIHRoZSBza2IgdG8KCQkgKiB0aGUgc29ja2V0J3MgdWRwX2VuY2FwX3Jj
digpIGhvb2suIE90aGVyd2lzZSwganVzdAoJCSAqIGZhbGwgdGhyb3VnaCBhbmQgcGFzcyB0
aGlzIHVwIHRoZSBVRFAgc29ja2V0LgoJCSAqIHVwLT5lbmNhcF9yY3YoKSByZXR1cm5zIHRo
ZSBmb2xsb3dpbmcgdmFsdWU6CgkJICogPTAgaWYgc2tiIHdhcyBzdWNjZXNzZnVsbHkgcGFz
c2VkIHRvIHRoZSBlbmNhcAoJCSAqICAgIGhhbmRsZXIgb3Igd2FzIGRpc2NhcmRlZCBieSBp
dC4KCQkgKiA+MCBpZiBza2Igc2hvdWxkIGJlIHBhc3NlZCBvbiB0byBVRFAuCgkJICogPDAg
aWYgc2tiIHNob3VsZCBiZSByZXN1Ym1pdHRlZCBhcyBwcm90byAtTgoJCSAqLwoKCQkvKiBp
ZiB3ZSdyZSBvdmVybHkgc2hvcnQsIGxldCBVRFAgaGFuZGxlIGl0ICovCgkJZW5jYXBfcmN2
ID0gQUNDRVNTX09OQ0UodXAtPmVuY2FwX3Jjdik7CgkJaWYgKHNrYi0+bGVuID4gc2l6ZW9m
KHN0cnVjdCB1ZHBoZHIpICYmIGVuY2FwX3JjdiAhPSBOVUxMKSB7CgkJCWludCByZXQ7CgoJ
CQkvKiBWZXJpZnkgY2hlY2tzdW0gYmVmb3JlIGdpdmluZyB0byBlbmNhcCAqLwoJCQlpZiAo
dWRwX2xpYl9jaGVja3N1bV9jb21wbGV0ZShza2IpKQoJCQkJZ290byBjc3VtX2Vycm9yOwoK
CQkJcmV0ID0gZW5jYXBfcmN2KHNrLCBza2IpOwoJCQlpZiAocmV0IDw9IDApIHsKCQkJCVVE
UF9JTkNfU1RBVFNfQkgoc29ja19uZXQoc2spLAoJCQkJCQkgVURQX01JQl9JTkRBVEFHUkFN
UywKCQkJCQkJIGlzX3VkcGxpdGUpOwoJCQkJcmV0dXJuIC1yZXQ7CgkJCX0KCQl9CgoJCS8q
IEZBTExUSFJPVUdIIC0tIGl0J3MgYSBVRFAgUGFja2V0ICovCgl9CgoJLyoKCSAqIAlVRFAt
TGl0ZSBzcGVjaWZpYyB0ZXN0cywgaWdub3JlZCBvbiBVRFAgc29ja2V0cwoJICovCglpZiAo
KGlzX3VkcGxpdGUgJiBVRFBMSVRFX1JFQ1ZfQ0MpICAmJiAgVURQX1NLQl9DQihza2IpLT5w
YXJ0aWFsX2NvdikgewoKCQkvKgoJCSAqIE1JQiBzdGF0aXN0aWNzIG90aGVyIHRoYW4gaW5j
cmVtZW50aW5nIHRoZSBlcnJvciBjb3VudCBhcmUKCQkgKiBkaXNhYmxlZCBmb3IgdGhlIGZv
bGxvd2luZyB0d28gdHlwZXMgb2YgZXJyb3JzOiB0aGVzZSBkZXBlbmQKCQkgKiBvbiB0aGUg
YXBwbGljYXRpb24gc2V0dGluZ3MsIG5vdCBvbiB0aGUgZnVuY3Rpb25pbmcgb2YgdGhlCgkJ
ICogcHJvdG9jb2wgc3RhY2sgYXMgc3VjaC4KCQkgKgoJCSAqIFJGQyAzODI4IGhlcmUgcmVj
b21tZW5kcyAoc2VjIDMuMyk6ICJUaGVyZSBzaG91bGQgYWxzbyBiZSBhCgkJICogd2F5IC4u
LiB0byAuLi4gYXQgbGVhc3QgbGV0IHRoZSByZWNlaXZpbmcgYXBwbGljYXRpb24gYmxvY2sK
CQkgKiBkZWxpdmVyeSBvZiBwYWNrZXRzIHdpdGggY292ZXJhZ2UgdmFsdWVzIGxlc3MgdGhh
biBhIHZhbHVlCgkJICogcHJvdmlkZWQgYnkgdGhlIGFwcGxpY2F0aW9uLiIKCQkgKi8KCQlp
ZiAodXAtPnBjcmxlbiA9PSAwKSB7ICAgICAgICAgIC8qIGZ1bGwgY292ZXJhZ2Ugd2FzIHNl
dCAgKi8KCQkJbmV0X2RiZ19yYXRlbGltaXRlZCgiVURQTGl0ZTogcGFydGlhbCBjb3ZlcmFn
ZSAlZCB3aGlsZSBmdWxsIGNvdmVyYWdlICVkIHJlcXVlc3RlZFxuIiwKCQkJCQkgICAgVURQ
X1NLQl9DQihza2IpLT5jc2Nvdiwgc2tiLT5sZW4pOwoJCQlnb3RvIGRyb3A7CgkJfQoJCS8q
IFRoZSBuZXh0IGNhc2UgaW52b2x2ZXMgdmlvbGF0aW5nIHRoZSBtaW4uIGNvdmVyYWdlIHJl
cXVlc3RlZAoJCSAqIGJ5IHRoZSByZWNlaXZlci4gVGhpcyBpcyBzdWJ0bGU6IGlmIHJlY2Vp
dmVyIHdhbnRzIHggYW5kIHggaXMKCQkgKiBncmVhdGVyIHRoYW4gdGhlIGJ1ZmZlcnNpemUv
TVRVIHRoZW4gcmVjZWl2ZXIgd2lsbCBjb21wbGFpbgoJCSAqIHRoYXQgaXQgd2FudHMgeCB3
aGlsZSBzZW5kZXIgZW1pdHMgcGFja2V0cyBvZiBzbWFsbGVyIHNpemUgeS4KCQkgKiBUaGVy
ZWZvcmUgdGhlIGFib3ZlIC4uLigpLT5wYXJ0aWFsX2NvdiBzdGF0ZW1lbnQgaXMgZXNzZW50
aWFsLgoJCSAqLwoJCWlmIChVRFBfU0tCX0NCKHNrYiktPmNzY292ICA8ICB1cC0+cGNybGVu
KSB7CgkJCW5ldF9kYmdfcmF0ZWxpbWl0ZWQoIlVEUExpdGU6IGNvdmVyYWdlICVkIHRvbyBz
bWFsbCwgbmVlZCBtaW4gJWRcbiIsCgkJCQkJICAgIFVEUF9TS0JfQ0Ioc2tiKS0+Y3Njb3Ys
IHVwLT5wY3JsZW4pOwoJCQlnb3RvIGRyb3A7CgkJfQoJfQoKCWlmIChyY3VfYWNjZXNzX3Bv
aW50ZXIoc2stPnNrX2ZpbHRlcikgJiYKCSAgICB1ZHBfbGliX2NoZWNrc3VtX2NvbXBsZXRl
KHNrYikpCgkJZ290byBjc3VtX2Vycm9yOwoKCglpZiAoc2tfcmN2cXVldWVzX2Z1bGwoc2ss
IHNrLT5za19yY3ZidWYpKSB7CgkJVURQX0lOQ19TVEFUU19CSChzb2NrX25ldChzayksIFVE
UF9NSUJfUkNWQlVGRVJST1JTLAoJCQkJIGlzX3VkcGxpdGUpOwoJCWdvdG8gZHJvcDsKCX0K
CglyYyA9IDA7CgoJaXB2NF9wa3RpbmZvX3ByZXBhcmUoc2ssIHNrYik7CgliaF9sb2NrX3Nv
Y2soc2spOwoJaWYgKCFzb2NrX293bmVkX2J5X3VzZXIoc2spKQoJCXJjID0gX191ZHBfcXVl
dWVfcmN2X3NrYihzaywgc2tiKTsKCWVsc2UgaWYgKHNrX2FkZF9iYWNrbG9nKHNrLCBza2Is
IHNrLT5za19yY3ZidWYpKSB7CgkJYmhfdW5sb2NrX3NvY2soc2spOwoJCWdvdG8gZHJvcDsK
CX0KCWJoX3VubG9ja19zb2NrKHNrKTsKCglyZXR1cm4gcmM7Cgpjc3VtX2Vycm9yOgoJVURQ
X0lOQ19TVEFUU19CSChzb2NrX25ldChzayksIFVEUF9NSUJfQ1NVTUVSUk9SUywgaXNfdWRw
bGl0ZSk7CmRyb3A6CglVRFBfSU5DX1NUQVRTX0JIKHNvY2tfbmV0KHNrKSwgVURQX01JQl9J
TkVSUk9SUywgaXNfdWRwbGl0ZSk7CglhdG9taWNfaW5jKCZzay0+c2tfZHJvcHMpOwoJa2Zy
ZWVfc2tiKHNrYik7CglyZXR1cm4gLTE7Cn0KCgpzdGF0aWMgdm9pZCBmbHVzaF9zdGFjayhz
dHJ1Y3Qgc29jayAqKnN0YWNrLCB1bnNpZ25lZCBpbnQgY291bnQsCgkJCXN0cnVjdCBza19i
dWZmICpza2IsIHVuc2lnbmVkIGludCBmaW5hbCkKewoJdW5zaWduZWQgaW50IGk7CglzdHJ1
Y3Qgc2tfYnVmZiAqc2tiMSA9IE5VTEw7CglzdHJ1Y3Qgc29jayAqc2s7CgoJZm9yIChpID0g
MDsgaSA8IGNvdW50OyBpKyspIHsKCQlzayA9IHN0YWNrW2ldOwoJCWlmIChsaWtlbHkoc2ti
MSA9PSBOVUxMKSkKCQkJc2tiMSA9IChpID09IGZpbmFsKSA/IHNrYiA6IHNrYl9jbG9uZShz
a2IsIEdGUF9BVE9NSUMpOwoKCQlpZiAoIXNrYjEpIHsKCQkJYXRvbWljX2luYygmc2stPnNr
X2Ryb3BzKTsKCQkJVURQX0lOQ19TVEFUU19CSChzb2NrX25ldChzayksIFVEUF9NSUJfUkNW
QlVGRVJST1JTLAoJCQkJCSBJU19VRFBMSVRFKHNrKSk7CgkJCVVEUF9JTkNfU1RBVFNfQkgo
c29ja19uZXQoc2spLCBVRFBfTUlCX0lORVJST1JTLAoJCQkJCSBJU19VRFBMSVRFKHNrKSk7
CgkJfQoKCQlpZiAoc2tiMSAmJiB1ZHBfcXVldWVfcmN2X3NrYihzaywgc2tiMSkgPD0gMCkK
CQkJc2tiMSA9IE5VTEw7CgoJCXNvY2tfcHV0KHNrKTsKCX0KCWlmICh1bmxpa2VseShza2Ix
KSkKCQlrZnJlZV9za2Ioc2tiMSk7Cn0KCi8qIEZvciBUQ1Agc29ja2V0cywgc2tfcnhfZHN0
IGlzIHByb3RlY3RlZCBieSBzb2NrZXQgbG9jawogKiBGb3IgVURQLCB3ZSB1c2UgeGNoZygp
IHRvIGd1YXJkIGFnYWluc3QgY29uY3VycmVudCBjaGFuZ2VzLgogKi8Kc3RhdGljIHZvaWQg
dWRwX3NrX3J4X2RzdF9zZXQoc3RydWN0IHNvY2sgKnNrLCBzdHJ1Y3QgZHN0X2VudHJ5ICpk
c3QpCnsKCXN0cnVjdCBkc3RfZW50cnkgKm9sZDsKCglkc3RfaG9sZChkc3QpOwoJb2xkID0g
eGNoZygmc2stPnNrX3J4X2RzdCwgZHN0KTsKCWRzdF9yZWxlYXNlKG9sZCk7Cn0KCi8qCiAq
CU11bHRpY2FzdHMgYW5kIGJyb2FkY2FzdHMgZ28gdG8gZWFjaCBsaXN0ZW5lci4KICoKICoJ
Tm90ZTogY2FsbGVkIG9ubHkgZnJvbSB0aGUgQkggaGFuZGxlciBjb250ZXh0LgogKi8Kc3Rh
dGljIGludCBfX3VkcDRfbGliX21jYXN0X2RlbGl2ZXIoc3RydWN0IG5ldCAqbmV0LCBzdHJ1
Y3Qgc2tfYnVmZiAqc2tiLAoJCQkJICAgIHN0cnVjdCB1ZHBoZHIgICp1aCwKCQkJCSAgICBf
X2JlMzIgc2FkZHIsIF9fYmUzMiBkYWRkciwKCQkJCSAgICBzdHJ1Y3QgdWRwX3RhYmxlICp1
ZHB0YWJsZSwKCQkJCSAgICBpbnQgcHJvdG8pCnsKCXN0cnVjdCBzb2NrICpzaywgKnN0YWNr
WzI1NiAvIHNpemVvZihzdHJ1Y3Qgc29jayAqKV07CglzdHJ1Y3QgaGxpc3RfbnVsbHNfbm9k
ZSAqbm9kZTsKCXVuc2lnbmVkIHNob3J0IGhudW0gPSBudG9ocyh1aC0+ZGVzdCk7CglzdHJ1
Y3QgdWRwX2hzbG90ICpoc2xvdCA9IHVkcF9oYXNoc2xvdCh1ZHB0YWJsZSwgbmV0LCBobnVt
KTsKCWludCBkaWYgPSBza2ItPmRldi0+aWZpbmRleDsKCXVuc2lnbmVkIGludCBjb3VudCA9
IDAsIG9mZnNldCA9IG9mZnNldG9mKHR5cGVvZigqc2spLCBza19udWxsc19ub2RlKTsKCXVu
c2lnbmVkIGludCBoYXNoMiA9IDAsIGhhc2gyX2FueSA9IDAsIHVzZV9oYXNoMiA9IChoc2xv
dC0+Y291bnQgPiAxMCk7Cglib29sIGlubmVyX2ZsdXNoZWQgPSBmYWxzZTsKCglpZiAodXNl
X2hhc2gyKSB7CgkJaGFzaDJfYW55ID0gdWRwNF9wb3J0YWRkcl9oYXNoKG5ldCwgaHRvbmwo
SU5BRERSX0FOWSksIGhudW0pICYKCQkJICAgIHVkcF90YWJsZS5tYXNrOwoJCWhhc2gyID0g
dWRwNF9wb3J0YWRkcl9oYXNoKG5ldCwgZGFkZHIsIGhudW0pICYgdWRwX3RhYmxlLm1hc2s7
CnN0YXJ0X2xvb2t1cDoKCQloc2xvdCA9ICZ1ZHBfdGFibGUuaGFzaDJbaGFzaDJdOwoJCW9m
ZnNldCA9IG9mZnNldG9mKHR5cGVvZigqc2spLCBfX3NrX2NvbW1vbi5za2NfcG9ydGFkZHJf
bm9kZSk7Cgl9CgoJc3Bpbl9sb2NrKCZoc2xvdC0+bG9jayk7Cglza19udWxsc19mb3JfZWFj
aF9lbnRyeV9vZmZzZXQoc2ssIG5vZGUsICZoc2xvdC0+aGVhZCwgb2Zmc2V0KSB7CgkJaWYg
KF9fdWRwX2lzX21jYXN0X3NvY2sobmV0LCBzaywKCQkJCQl1aC0+ZGVzdCwgZGFkZHIsCgkJ
CQkJdWgtPnNvdXJjZSwgc2FkZHIsCgkJCQkJZGlmLCBobnVtKSkgewoJCQlpZiAodW5saWtl
bHkoY291bnQgPT0gQVJSQVlfU0laRShzdGFjaykpKSB7CgkJCQlmbHVzaF9zdGFjayhzdGFj
aywgY291bnQsIHNrYiwgfjApOwoJCQkJaW5uZXJfZmx1c2hlZCA9IHRydWU7CgkJCQljb3Vu
dCA9IDA7CgkJCX0KCQkJc3RhY2tbY291bnQrK10gPSBzazsKCQkJc29ja19ob2xkKHNrKTsK
CQl9Cgl9CgoJc3Bpbl91bmxvY2soJmhzbG90LT5sb2NrKTsKCgkvKiBBbHNvIGxvb2t1cCAq
OnBvcnQgaWYgd2UgYXJlIHVzaW5nIGhhc2gyIGFuZCBoYXZlbid0IGRvbmUgc28geWV0LiAq
LwoJaWYgKHVzZV9oYXNoMiAmJiBoYXNoMiAhPSBoYXNoMl9hbnkpIHsKCQloYXNoMiA9IGhh
c2gyX2FueTsKCQlnb3RvIHN0YXJ0X2xvb2t1cDsKCX0KCgkvKgoJICogZG8gdGhlIHNsb3cg
d29yayB3aXRoIG5vIGxvY2sgaGVsZAoJICovCglpZiAoY291bnQpIHsKCQlmbHVzaF9zdGFj
ayhzdGFjaywgY291bnQsIHNrYiwgY291bnQgLSAxKTsKCX0gZWxzZSB7CgkJaWYgKCFpbm5l
cl9mbHVzaGVkKQoJCQlVRFBfSU5DX1NUQVRTX0JIKG5ldCwgVURQX01JQl9JR05PUkVETVVM
VEksCgkJCQkJIHByb3RvID09IElQUFJPVE9fVURQTElURSk7CgkJY29uc3VtZV9za2Ioc2ti
KTsKCX0KCXJldHVybiAwOwp9CgovKiBJbml0aWFsaXplIFVEUCBjaGVja3N1bS4gSWYgZXhp
dGVkIHdpdGggemVybyB2YWx1ZSAoc3VjY2VzcyksCiAqIENIRUNLU1VNX1VOTkVDRVNTQVJZ
IG1lYW5zLCB0aGF0IG5vIG1vcmUgY2hlY2tzIGFyZSByZXF1aXJlZC4KICogT3RoZXJ3aXNl
LCBjc3VtIGNvbXBsZXRpb24gcmVxdWlyZXMgY2hhY2tzdW1taW5nIHBhY2tldCBib2R5LAog
KiBpbmNsdWRpbmcgdWRwIGhlYWRlciBhbmQgZm9sZGluZyBpdCB0byBza2ItPmNzdW0uCiAq
LwpzdGF0aWMgaW5saW5lIGludCB1ZHA0X2NzdW1faW5pdChzdHJ1Y3Qgc2tfYnVmZiAqc2ti
LCBzdHJ1Y3QgdWRwaGRyICp1aCwKCQkJCSBpbnQgcHJvdG8pCnsKCWludCBlcnI7CgoJVURQ
X1NLQl9DQihza2IpLT5wYXJ0aWFsX2NvdiA9IDA7CglVRFBfU0tCX0NCKHNrYiktPmNzY292
ID0gc2tiLT5sZW47CgoJaWYgKHByb3RvID09IElQUFJPVE9fVURQTElURSkgewoJCWVyciA9
IHVkcGxpdGVfY2hlY2tzdW1faW5pdChza2IsIHVoKTsKCQlpZiAoZXJyKQoJCQlyZXR1cm4g
ZXJyOwoJfQoKCXJldHVybiBza2JfY2hlY2tzdW1faW5pdF96ZXJvX2NoZWNrKHNrYiwgcHJv
dG8sIHVoLT5jaGVjaywKCQkJCQkgICAgaW5ldF9jb21wdXRlX3BzZXVkbyk7Cn0KCi8qCiAq
CUFsbCB3ZSBuZWVkIHRvIGRvIGlzIGdldCB0aGUgc29ja2V0LCBhbmQgdGhlbiBkbyBhIGNo
ZWNrc3VtLgogKi8KCmludCBfX3VkcDRfbGliX3JjdihzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBz
dHJ1Y3QgdWRwX3RhYmxlICp1ZHB0YWJsZSwKCQkgICBpbnQgcHJvdG8pCnsKCXN0cnVjdCBz
b2NrICpzazsKCXN0cnVjdCB1ZHBoZHIgKnVoOwoJdW5zaWduZWQgc2hvcnQgdWxlbjsKCXN0
cnVjdCBydGFibGUgKnJ0ID0gc2tiX3J0YWJsZShza2IpOwoJX19iZTMyIHNhZGRyLCBkYWRk
cjsKCXN0cnVjdCBuZXQgKm5ldCA9IGRldl9uZXQoc2tiLT5kZXYpOwoKCS8qCgkgKiAgVmFs
aWRhdGUgdGhlIHBhY2tldC4KCSAqLwoJaWYgKCFwc2tiX21heV9wdWxsKHNrYiwgc2l6ZW9m
KHN0cnVjdCB1ZHBoZHIpKSkKCQlnb3RvIGRyb3A7CQkvKiBObyBzcGFjZSBmb3IgaGVhZGVy
LiAqLwoKCXVoICAgPSB1ZHBfaGRyKHNrYik7Cgl1bGVuID0gbnRvaHModWgtPmxlbik7Cglz
YWRkciA9IGlwX2hkcihza2IpLT5zYWRkcjsKCWRhZGRyID0gaXBfaGRyKHNrYiktPmRhZGRy
OwoKCWlmICh1bGVuID4gc2tiLT5sZW4pCgkJZ290byBzaG9ydF9wYWNrZXQ7CgoJaWYgKHBy
b3RvID09IElQUFJPVE9fVURQKSB7CgkJLyogVURQIHZhbGlkYXRlcyB1bGVuLiAqLwoJCWlm
ICh1bGVuIDwgc2l6ZW9mKCp1aCkgfHwgcHNrYl90cmltX3Jjc3VtKHNrYiwgdWxlbikpCgkJ
CWdvdG8gc2hvcnRfcGFja2V0OwoJCXVoID0gdWRwX2hkcihza2IpOwoJfQoKCWlmICh1ZHA0
X2NzdW1faW5pdChza2IsIHVoLCBwcm90bykpCgkJZ290byBjc3VtX2Vycm9yOwoKCXNrID0g
c2tiX3N0ZWFsX3NvY2soc2tiKTsKCWlmIChzaykgewoJCXN0cnVjdCBkc3RfZW50cnkgKmRz
dCA9IHNrYl9kc3Qoc2tiKTsKCQlpbnQgcmV0OwoKCQlpZiAodW5saWtlbHkoc2stPnNrX3J4
X2RzdCAhPSBkc3QpKQoJCQl1ZHBfc2tfcnhfZHN0X3NldChzaywgZHN0KTsKCgkJcmV0ID0g
dWRwX3F1ZXVlX3Jjdl9za2Ioc2ssIHNrYik7CgkJc29ja19wdXQoc2spOwoJCS8qIGEgcmV0
dXJuIHZhbHVlID4gMCBtZWFucyB0byByZXN1Ym1pdCB0aGUgaW5wdXQsIGJ1dAoJCSAqIGl0
IHdhbnRzIHRoZSByZXR1cm4gdG8gYmUgLXByb3RvY29sLCBvciAwCgkJICovCgkJaWYgKHJl
dCA+IDApCgkJCXJldHVybiAtcmV0OwoJCXJldHVybiAwOwoJfQoKCWlmIChydC0+cnRfZmxh
Z3MgJiAoUlRDRl9CUk9BRENBU1R8UlRDRl9NVUxUSUNBU1QpKQoJCXJldHVybiBfX3VkcDRf
bGliX21jYXN0X2RlbGl2ZXIobmV0LCBza2IsIHVoLAoJCQkJCQlzYWRkciwgZGFkZHIsIHVk
cHRhYmxlLCBwcm90byk7CgoJc2sgPSBfX3VkcDRfbGliX2xvb2t1cF9za2Ioc2tiLCB1aC0+
c291cmNlLCB1aC0+ZGVzdCwgdWRwdGFibGUpOwoJaWYgKHNrICE9IE5VTEwpIHsKCQlpbnQg
cmV0OwoKCQlpZiAodWRwX3NrKHNrKS0+Y29udmVydF9jc3VtICYmIHVoLT5jaGVjayAmJiAh
SVNfVURQTElURShzaykpCgkJCXNrYl9jaGVja3N1bV90cnlfY29udmVydChza2IsIElQUFJP
VE9fVURQLCB1aC0+Y2hlY2ssCgkJCQkJCSBpbmV0X2NvbXB1dGVfcHNldWRvKTsKCgkJcmV0
ID0gdWRwX3F1ZXVlX3Jjdl9za2Ioc2ssIHNrYik7CgkJc29ja19wdXQoc2spOwoKCQkvKiBh
IHJldHVybiB2YWx1ZSA+IDAgbWVhbnMgdG8gcmVzdWJtaXQgdGhlIGlucHV0LCBidXQKCQkg
KiBpdCB3YW50cyB0aGUgcmV0dXJuIHRvIGJlIC1wcm90b2NvbCwgb3IgMAoJCSAqLwoJCWlm
IChyZXQgPiAwKQoJCQlyZXR1cm4gLXJldDsKCQlyZXR1cm4gMDsKCX0KCglpZiAoIXhmcm00
X3BvbGljeV9jaGVjayhOVUxMLCBYRlJNX1BPTElDWV9JTiwgc2tiKSkKCQlnb3RvIGRyb3A7
CgluZl9yZXNldChza2IpOwoKCS8qIE5vIHNvY2tldC4gRHJvcCBwYWNrZXQgc2lsZW50bHks
IGlmIGNoZWNrc3VtIGlzIHdyb25nICovCglpZiAodWRwX2xpYl9jaGVja3N1bV9jb21wbGV0
ZShza2IpKQoJCWdvdG8gY3N1bV9lcnJvcjsKCglVRFBfSU5DX1NUQVRTX0JIKG5ldCwgVURQ
X01JQl9OT1BPUlRTLCBwcm90byA9PSBJUFBST1RPX1VEUExJVEUpOwoJaWNtcF9zZW5kKHNr
YiwgSUNNUF9ERVNUX1VOUkVBQ0gsIElDTVBfUE9SVF9VTlJFQUNILCAwKTsKCgkvKgoJICog
SG1tLiAgV2UgZ290IGFuIFVEUCBwYWNrZXQgdG8gYSBwb3J0IHRvIHdoaWNoIHdlCgkgKiBk
b24ndCB3YW5uYSBsaXN0ZW4uICBJZ25vcmUgaXQuCgkgKi8KCWtmcmVlX3NrYihza2IpOwoJ
cmV0dXJuIDA7CgpzaG9ydF9wYWNrZXQ6CgluZXRfZGJnX3JhdGVsaW1pdGVkKCJVRFAlczog
c2hvcnQgcGFja2V0OiBGcm9tICVwSTQ6JXUgJWQvJWQgdG8gJXBJNDoldVxuIiwKCQkJICAg
IHByb3RvID09IElQUFJPVE9fVURQTElURSA/ICJMaXRlIiA6ICIiLAoJCQkgICAgJnNhZGRy
LCBudG9ocyh1aC0+c291cmNlKSwKCQkJICAgIHVsZW4sIHNrYi0+bGVuLAoJCQkgICAgJmRh
ZGRyLCBudG9ocyh1aC0+ZGVzdCkpOwoJZ290byBkcm9wOwoKY3N1bV9lcnJvcjoKCS8qCgkg
KiBSRkMxMTIyOiBPSy4gIERpc2NhcmRzIHRoZSBiYWQgcGFja2V0IHNpbGVudGx5IChhcyBm
YXIgYXMKCSAqIHRoZSBuZXR3b3JrIGlzIGNvbmNlcm5lZCwgYW55d2F5KSBhcyBwZXIgNC4x
LjMuNCAoTVVTVCkuCgkgKi8KCW5ldF9kYmdfcmF0ZWxpbWl0ZWQoIlVEUCVzOiBiYWQgY2hl
Y2tzdW0uIEZyb20gJXBJNDoldSB0byAlcEk0OiV1IHVsZW4gJWRcbiIsCgkJCSAgICBwcm90
byA9PSBJUFBST1RPX1VEUExJVEUgPyAiTGl0ZSIgOiAiIiwKCQkJICAgICZzYWRkciwgbnRv
aHModWgtPnNvdXJjZSksICZkYWRkciwgbnRvaHModWgtPmRlc3QpLAoJCQkgICAgdWxlbik7
CglVRFBfSU5DX1NUQVRTX0JIKG5ldCwgVURQX01JQl9DU1VNRVJST1JTLCBwcm90byA9PSBJ
UFBST1RPX1VEUExJVEUpOwpkcm9wOgoJVURQX0lOQ19TVEFUU19CSChuZXQsIFVEUF9NSUJf
SU5FUlJPUlMsIHByb3RvID09IElQUFJPVE9fVURQTElURSk7CglrZnJlZV9za2Ioc2tiKTsK
CXJldHVybiAwOwp9CgovKiBXZSBjYW4gb25seSBlYXJseSBkZW11eCBtdWx0aWNhc3QgaWYg
dGhlcmUgaXMgYSBzaW5nbGUgbWF0Y2hpbmcgc29ja2V0LgogKiBJZiBtb3JlIHRoYW4gb25l
IHNvY2tldCBmb3VuZCByZXR1cm5zIE5VTEwKICovCnN0YXRpYyBzdHJ1Y3Qgc29jayAqX191
ZHA0X2xpYl9tY2FzdF9kZW11eF9sb29rdXAoc3RydWN0IG5ldCAqbmV0LAoJCQkJCQkgIF9f
YmUxNiBsb2NfcG9ydCwgX19iZTMyIGxvY19hZGRyLAoJCQkJCQkgIF9fYmUxNiBybXRfcG9y
dCwgX19iZTMyIHJtdF9hZGRyLAoJCQkJCQkgIGludCBkaWYpCnsKCXN0cnVjdCBzb2NrICpz
aywgKnJlc3VsdDsKCXN0cnVjdCBobGlzdF9udWxsc19ub2RlICpub2RlOwoJdW5zaWduZWQg
c2hvcnQgaG51bSA9IG50b2hzKGxvY19wb3J0KTsKCXVuc2lnbmVkIGludCBjb3VudCwgc2xv
dCA9IHVkcF9oYXNoZm4obmV0LCBobnVtLCB1ZHBfdGFibGUubWFzayk7CglzdHJ1Y3QgdWRw
X2hzbG90ICpoc2xvdCA9ICZ1ZHBfdGFibGUuaGFzaFtzbG90XTsKCgkvKiBEbyBub3QgYm90
aGVyIHNjYW5uaW5nIGEgdG9vIGJpZyBsaXN0ICovCglpZiAoaHNsb3QtPmNvdW50ID4gMTAp
CgkJcmV0dXJuIE5VTEw7CgoJcmN1X3JlYWRfbG9jaygpOwpiZWdpbjoKCWNvdW50ID0gMDsK
CXJlc3VsdCA9IE5VTEw7Cglza19udWxsc19mb3JfZWFjaF9yY3Uoc2ssIG5vZGUsICZoc2xv
dC0+aGVhZCkgewoJCWlmIChfX3VkcF9pc19tY2FzdF9zb2NrKG5ldCwgc2ssCgkJCQkJbG9j
X3BvcnQsIGxvY19hZGRyLAoJCQkJCXJtdF9wb3J0LCBybXRfYWRkciwKCQkJCQlkaWYsIGhu
dW0pKSB7CgkJCXJlc3VsdCA9IHNrOwoJCQkrK2NvdW50OwoJCX0KCX0KCS8qCgkgKiBpZiB0
aGUgbnVsbHMgdmFsdWUgd2UgZ290IGF0IHRoZSBlbmQgb2YgdGhpcyBsb29rdXAgaXMKCSAq
IG5vdCB0aGUgZXhwZWN0ZWQgb25lLCB3ZSBtdXN0IHJlc3RhcnQgbG9va3VwLgoJICogV2Ug
cHJvYmFibHkgbWV0IGFuIGl0ZW0gdGhhdCB3YXMgbW92ZWQgdG8gYW5vdGhlciBjaGFpbi4K
CSAqLwoJaWYgKGdldF9udWxsc192YWx1ZShub2RlKSAhPSBzbG90KQoJCWdvdG8gYmVnaW47
CgoJaWYgKHJlc3VsdCkgewoJCWlmIChjb3VudCAhPSAxIHx8CgkJICAgIHVubGlrZWx5KCFh
dG9taWNfaW5jX25vdF96ZXJvX2hpbnQoJnJlc3VsdC0+c2tfcmVmY250LCAyKSkpCgkJCXJl
c3VsdCA9IE5VTEw7CgkJZWxzZSBpZiAodW5saWtlbHkoIV9fdWRwX2lzX21jYXN0X3NvY2so
bmV0LCByZXN1bHQsCgkJCQkJCSAgICAgICBsb2NfcG9ydCwgbG9jX2FkZHIsCgkJCQkJCSAg
ICAgICBybXRfcG9ydCwgcm10X2FkZHIsCgkJCQkJCSAgICAgICBkaWYsIGhudW0pKSkgewoJ
CQlzb2NrX3B1dChyZXN1bHQpOwoJCQlyZXN1bHQgPSBOVUxMOwoJCX0KCX0KCXJjdV9yZWFk
X3VubG9jaygpOwoJcmV0dXJuIHJlc3VsdDsKfQoKLyogRm9yIHVuaWNhc3Qgd2Ugc2hvdWxk
IG9ubHkgZWFybHkgZGVtdXggY29ubmVjdGVkIHNvY2tldHMgb3Igd2UgY2FuCiAqIGJyZWFr
IGZvcndhcmRpbmcgc2V0dXBzLiAgVGhlIGNoYWlucyBoZXJlIGNhbiBiZSBsb25nIHNvIG9u
bHkgY2hlY2sKICogaWYgdGhlIGZpcnN0IHNvY2tldCBpcyBhbiBleGFjdCBtYXRjaCBhbmQg
aWYgbm90IG1vdmUgb24uCiAqLwpzdGF0aWMgc3RydWN0IHNvY2sgKl9fdWRwNF9saWJfZGVt
dXhfbG9va3VwKHN0cnVjdCBuZXQgKm5ldCwKCQkJCQkgICAgX19iZTE2IGxvY19wb3J0LCBf
X2JlMzIgbG9jX2FkZHIsCgkJCQkJICAgIF9fYmUxNiBybXRfcG9ydCwgX19iZTMyIHJtdF9h
ZGRyLAoJCQkJCSAgICBpbnQgZGlmKQp7CglzdHJ1Y3Qgc29jayAqc2ssICpyZXN1bHQ7Cglz
dHJ1Y3QgaGxpc3RfbnVsbHNfbm9kZSAqbm9kZTsKCXVuc2lnbmVkIHNob3J0IGhudW0gPSBu
dG9ocyhsb2NfcG9ydCk7Cgl1bnNpZ25lZCBpbnQgaGFzaDIgPSB1ZHA0X3BvcnRhZGRyX2hh
c2gobmV0LCBsb2NfYWRkciwgaG51bSk7Cgl1bnNpZ25lZCBpbnQgc2xvdDIgPSBoYXNoMiAm
IHVkcF90YWJsZS5tYXNrOwoJc3RydWN0IHVkcF9oc2xvdCAqaHNsb3QyID0gJnVkcF90YWJs
ZS5oYXNoMltzbG90Ml07CglJTkVUX0FERFJfQ09PS0lFKGFjb29raWUsIHJtdF9hZGRyLCBs
b2NfYWRkcik7Cgljb25zdCBfX3BvcnRwYWlyIHBvcnRzID0gSU5FVF9DT01CSU5FRF9QT1JU
UyhybXRfcG9ydCwgaG51bSk7CgoJcmN1X3JlYWRfbG9jaygpOwoJcmVzdWx0ID0gTlVMTDsK
CXVkcF9wb3J0YWRkcl9mb3JfZWFjaF9lbnRyeV9yY3Uoc2ssIG5vZGUsICZoc2xvdDItPmhl
YWQpIHsKCQlpZiAoSU5FVF9NQVRDSChzaywgbmV0LCBhY29va2llLAoJCQkgICAgICAgcm10
X2FkZHIsIGxvY19hZGRyLCBwb3J0cywgZGlmKSkKCQkJcmVzdWx0ID0gc2s7CgkJLyogT25s
eSBjaGVjayBmaXJzdCBzb2NrZXQgaW4gY2hhaW4gKi8KCQlicmVhazsKCX0KCglpZiAocmVz
dWx0KSB7CgkJaWYgKHVubGlrZWx5KCFhdG9taWNfaW5jX25vdF96ZXJvX2hpbnQoJnJlc3Vs
dC0+c2tfcmVmY250LCAyKSkpCgkJCXJlc3VsdCA9IE5VTEw7CgkJZWxzZSBpZiAodW5saWtl
bHkoIUlORVRfTUFUQ0goc2ssIG5ldCwgYWNvb2tpZSwKCQkJCQkgICAgICBybXRfYWRkciwg
bG9jX2FkZHIsCgkJCQkJICAgICAgcG9ydHMsIGRpZikpKSB7CgkJCXNvY2tfcHV0KHJlc3Vs
dCk7CgkJCXJlc3VsdCA9IE5VTEw7CgkJfQoJfQoJcmN1X3JlYWRfdW5sb2NrKCk7CglyZXR1
cm4gcmVzdWx0Owp9Cgp2b2lkIHVkcF92NF9lYXJseV9kZW11eChzdHJ1Y3Qgc2tfYnVmZiAq
c2tiKQp7CglzdHJ1Y3QgbmV0ICpuZXQgPSBkZXZfbmV0KHNrYi0+ZGV2KTsKCWNvbnN0IHN0
cnVjdCBpcGhkciAqaXBoOwoJY29uc3Qgc3RydWN0IHVkcGhkciAqdWg7CglzdHJ1Y3Qgc29j
ayAqc2s7CglzdHJ1Y3QgZHN0X2VudHJ5ICpkc3Q7CglpbnQgZGlmID0gc2tiLT5kZXYtPmlm
aW5kZXg7CgoJLyogdmFsaWRhdGUgdGhlIHBhY2tldCAqLwoJaWYgKCFwc2tiX21heV9wdWxs
KHNrYiwgc2tiX3RyYW5zcG9ydF9vZmZzZXQoc2tiKSArIHNpemVvZihzdHJ1Y3QgdWRwaGRy
KSkpCgkJcmV0dXJuOwoKCWlwaCA9IGlwX2hkcihza2IpOwoJdWggPSB1ZHBfaGRyKHNrYik7
CgoJaWYgKHNrYi0+cGt0X3R5cGUgPT0gUEFDS0VUX0JST0FEQ0FTVCB8fAoJICAgIHNrYi0+
cGt0X3R5cGUgPT0gUEFDS0VUX01VTFRJQ0FTVCkKCQlzayA9IF9fdWRwNF9saWJfbWNhc3Rf
ZGVtdXhfbG9va3VwKG5ldCwgdWgtPmRlc3QsIGlwaC0+ZGFkZHIsCgkJCQkJCSAgIHVoLT5z
b3VyY2UsIGlwaC0+c2FkZHIsIGRpZik7CgllbHNlIGlmIChza2ItPnBrdF90eXBlID09IFBB
Q0tFVF9IT1NUKQoJCXNrID0gX191ZHA0X2xpYl9kZW11eF9sb29rdXAobmV0LCB1aC0+ZGVz
dCwgaXBoLT5kYWRkciwKCQkJCQkgICAgIHVoLT5zb3VyY2UsIGlwaC0+c2FkZHIsIGRpZik7
CgllbHNlCgkJcmV0dXJuOwoKCWlmICghc2spCgkJcmV0dXJuOwoKCXNrYi0+c2sgPSBzazsK
CXNrYi0+ZGVzdHJ1Y3RvciA9IHNvY2tfZWZyZWU7Cglkc3QgPSBzay0+c2tfcnhfZHN0OwoK
CWlmIChkc3QpCgkJZHN0ID0gZHN0X2NoZWNrKGRzdCwgMCk7CglpZiAoZHN0KQoJCXNrYl9k
c3Rfc2V0X25vcmVmKHNrYiwgZHN0KTsKfQoKaW50IHVkcF9yY3Yoc3RydWN0IHNrX2J1ZmYg
KnNrYikKewoJcmV0dXJuIF9fdWRwNF9saWJfcmN2KHNrYiwgJnVkcF90YWJsZSwgSVBQUk9U
T19VRFApOwp9Cgp2b2lkIHVkcF9kZXN0cm95X3NvY2soc3RydWN0IHNvY2sgKnNrKQp7Cglz
dHJ1Y3QgdWRwX3NvY2sgKnVwID0gdWRwX3NrKHNrKTsKCWJvb2wgc2xvdyA9IGxvY2tfc29j
a19mYXN0KHNrKTsKCXVkcF9mbHVzaF9wZW5kaW5nX2ZyYW1lcyhzayk7Cgl1bmxvY2tfc29j
a19mYXN0KHNrLCBzbG93KTsKCWlmIChzdGF0aWNfa2V5X2ZhbHNlKCZ1ZHBfZW5jYXBfbmVl
ZGVkKSAmJiB1cC0+ZW5jYXBfdHlwZSkgewoJCXZvaWQgKCplbmNhcF9kZXN0cm95KShzdHJ1
Y3Qgc29jayAqc2spOwoJCWVuY2FwX2Rlc3Ryb3kgPSBBQ0NFU1NfT05DRSh1cC0+ZW5jYXBf
ZGVzdHJveSk7CgkJaWYgKGVuY2FwX2Rlc3Ryb3kpCgkJCWVuY2FwX2Rlc3Ryb3koc2spOwoJ
fQp9CgovKgogKglTb2NrZXQgb3B0aW9uIGNvZGUgZm9yIFVEUAogKi8KaW50IHVkcF9saWJf
c2V0c29ja29wdChzdHJ1Y3Qgc29jayAqc2ssIGludCBsZXZlbCwgaW50IG9wdG5hbWUsCgkJ
ICAgICAgIGNoYXIgX191c2VyICpvcHR2YWwsIHVuc2lnbmVkIGludCBvcHRsZW4sCgkJICAg
ICAgIGludCAoKnB1c2hfcGVuZGluZ19mcmFtZXMpKHN0cnVjdCBzb2NrICopKQp7CglzdHJ1
Y3QgdWRwX3NvY2sgKnVwID0gdWRwX3NrKHNrKTsKCWludCB2YWwsIHZhbGJvb2w7CglpbnQg
ZXJyID0gMDsKCWludCBpc191ZHBsaXRlID0gSVNfVURQTElURShzayk7CgoJaWYgKG9wdGxl
biA8IHNpemVvZihpbnQpKQoJCXJldHVybiAtRUlOVkFMOwoKCWlmIChnZXRfdXNlcih2YWws
IChpbnQgX191c2VyICopb3B0dmFsKSkKCQlyZXR1cm4gLUVGQVVMVDsKCgl2YWxib29sID0g
dmFsID8gMSA6IDA7CgoJc3dpdGNoIChvcHRuYW1lKSB7CgljYXNlIFVEUF9DT1JLOgoJCWlm
ICh2YWwgIT0gMCkgewoJCQl1cC0+Y29ya2ZsYWcgPSAxOwoJCX0gZWxzZSB7CgkJCXVwLT5j
b3JrZmxhZyA9IDA7CgkJCWxvY2tfc29jayhzayk7CgkJCXB1c2hfcGVuZGluZ19mcmFtZXMo
c2spOwoJCQlyZWxlYXNlX3NvY2soc2spOwoJCX0KCQlicmVhazsKCgljYXNlIFVEUF9FTkNB
UDoKCQlzd2l0Y2ggKHZhbCkgewoJCWNhc2UgMDoKCQljYXNlIFVEUF9FTkNBUF9FU1BJTlVE
UDoKCQljYXNlIFVEUF9FTkNBUF9FU1BJTlVEUF9OT05fSUtFOgoJCQl1cC0+ZW5jYXBfcmN2
ID0geGZybTRfdWRwX2VuY2FwX3JjdjsKCQkJLyogRkFMTFRIUk9VR0ggKi8KCQljYXNlIFVE
UF9FTkNBUF9MMlRQSU5VRFA6CgkJCXVwLT5lbmNhcF90eXBlID0gdmFsOwoJCQl1ZHBfZW5j
YXBfZW5hYmxlKCk7CgkJCWJyZWFrOwoJCWRlZmF1bHQ6CgkJCWVyciA9IC1FTk9QUk9UT09Q
VDsKCQkJYnJlYWs7CgkJfQoJCWJyZWFrOwoKCWNhc2UgVURQX05PX0NIRUNLNl9UWDoKCQl1
cC0+bm9fY2hlY2s2X3R4ID0gdmFsYm9vbDsKCQlicmVhazsKCgljYXNlIFVEUF9OT19DSEVD
SzZfUlg6CgkJdXAtPm5vX2NoZWNrNl9yeCA9IHZhbGJvb2w7CgkJYnJlYWs7CgoJLyoKCSAq
IAlVRFAtTGl0ZSdzIHBhcnRpYWwgY2hlY2tzdW0gY292ZXJhZ2UgKFJGQyAzODI4KS4KCSAq
LwoJLyogVGhlIHNlbmRlciBzZXRzIGFjdHVhbCBjaGVja3N1bSBjb3ZlcmFnZSBsZW5ndGgg
dmlhIHRoaXMgb3B0aW9uLgoJICogVGhlIGNhc2UgY292ZXJhZ2UgPiBwYWNrZXQgbGVuZ3Ro
IGlzIGhhbmRsZWQgYnkgc2VuZCBtb2R1bGUuICovCgljYXNlIFVEUExJVEVfU0VORF9DU0NP
VjoKCQlpZiAoIWlzX3VkcGxpdGUpICAgICAgICAgLyogRGlzYWJsZSB0aGUgb3B0aW9uIG9u
IFVEUCBzb2NrZXRzICovCgkJCXJldHVybiAtRU5PUFJPVE9PUFQ7CgkJaWYgKHZhbCAhPSAw
ICYmIHZhbCA8IDgpIC8qIElsbGVnYWwgY292ZXJhZ2U6IHVzZSBkZWZhdWx0ICg4KSAqLwoJ
CQl2YWwgPSA4OwoJCWVsc2UgaWYgKHZhbCA+IFVTSFJUX01BWCkKCQkJdmFsID0gVVNIUlRf
TUFYOwoJCXVwLT5wY3NsZW4gPSB2YWw7CgkJdXAtPnBjZmxhZyB8PSBVRFBMSVRFX1NFTkRf
Q0M7CgkJYnJlYWs7CgoJLyogVGhlIHJlY2VpdmVyIHNwZWNpZmllcyBhIG1pbmltdW0gY2hl
Y2tzdW0gY292ZXJhZ2UgdmFsdWUuIFRvIG1ha2UKCSAqIHNlbnNlLCB0aGlzIHNob3VsZCBi
ZSBzZXQgdG8gYXQgbGVhc3QgOCAoYXMgZG9uZSBiZWxvdykuIElmIHplcm8gaXMKCSAqIHVz
ZWQsIHRoaXMgYWdhaW4gbWVhbnMgZnVsbCBjaGVja3N1bSBjb3ZlcmFnZS4gICAgICAgICAg
ICAgICAgICAgICAqLwoJY2FzZSBVRFBMSVRFX1JFQ1ZfQ1NDT1Y6CgkJaWYgKCFpc191ZHBs
aXRlKSAgICAgICAgIC8qIERpc2FibGUgdGhlIG9wdGlvbiBvbiBVRFAgc29ja2V0cyAqLwoJ
CQlyZXR1cm4gLUVOT1BST1RPT1BUOwoJCWlmICh2YWwgIT0gMCAmJiB2YWwgPCA4KSAvKiBB
dm9pZCBzaWxseSBtaW5pbWFsIHZhbHVlcy4gICAgICAgKi8KCQkJdmFsID0gODsKCQllbHNl
IGlmICh2YWwgPiBVU0hSVF9NQVgpCgkJCXZhbCA9IFVTSFJUX01BWDsKCQl1cC0+cGNybGVu
ID0gdmFsOwoJCXVwLT5wY2ZsYWcgfD0gVURQTElURV9SRUNWX0NDOwoJCWJyZWFrOwoKCWRl
ZmF1bHQ6CgkJZXJyID0gLUVOT1BST1RPT1BUOwoJCWJyZWFrOwoJfQoKCXJldHVybiBlcnI7
Cn0KRVhQT1JUX1NZTUJPTCh1ZHBfbGliX3NldHNvY2tvcHQpOwoKaW50IHVkcF9zZXRzb2Nr
b3B0KHN0cnVjdCBzb2NrICpzaywgaW50IGxldmVsLCBpbnQgb3B0bmFtZSwKCQkgICBjaGFy
IF9fdXNlciAqb3B0dmFsLCB1bnNpZ25lZCBpbnQgb3B0bGVuKQp7CglpZiAobGV2ZWwgPT0g
U09MX1VEUCAgfHwgIGxldmVsID09IFNPTF9VRFBMSVRFKQoJCXJldHVybiB1ZHBfbGliX3Nl
dHNvY2tvcHQoc2ssIGxldmVsLCBvcHRuYW1lLCBvcHR2YWwsIG9wdGxlbiwKCQkJCQkgIHVk
cF9wdXNoX3BlbmRpbmdfZnJhbWVzKTsKCXJldHVybiBpcF9zZXRzb2Nrb3B0KHNrLCBsZXZl
bCwgb3B0bmFtZSwgb3B0dmFsLCBvcHRsZW4pOwp9CgojaWZkZWYgQ09ORklHX0NPTVBBVApp
bnQgY29tcGF0X3VkcF9zZXRzb2Nrb3B0KHN0cnVjdCBzb2NrICpzaywgaW50IGxldmVsLCBp
bnQgb3B0bmFtZSwKCQkJICBjaGFyIF9fdXNlciAqb3B0dmFsLCB1bnNpZ25lZCBpbnQgb3B0
bGVuKQp7CglpZiAobGV2ZWwgPT0gU09MX1VEUCAgfHwgIGxldmVsID09IFNPTF9VRFBMSVRF
KQoJCXJldHVybiB1ZHBfbGliX3NldHNvY2tvcHQoc2ssIGxldmVsLCBvcHRuYW1lLCBvcHR2
YWwsIG9wdGxlbiwKCQkJCQkgIHVkcF9wdXNoX3BlbmRpbmdfZnJhbWVzKTsKCXJldHVybiBj
b21wYXRfaXBfc2V0c29ja29wdChzaywgbGV2ZWwsIG9wdG5hbWUsIG9wdHZhbCwgb3B0bGVu
KTsKfQojZW5kaWYKCmludCB1ZHBfbGliX2dldHNvY2tvcHQoc3RydWN0IHNvY2sgKnNrLCBp
bnQgbGV2ZWwsIGludCBvcHRuYW1lLAoJCSAgICAgICBjaGFyIF9fdXNlciAqb3B0dmFsLCBp
bnQgX191c2VyICpvcHRsZW4pCnsKCXN0cnVjdCB1ZHBfc29jayAqdXAgPSB1ZHBfc2soc2sp
OwoJaW50IHZhbCwgbGVuOwoKCWlmIChnZXRfdXNlcihsZW4sIG9wdGxlbikpCgkJcmV0dXJu
IC1FRkFVTFQ7CgoJbGVuID0gbWluX3QodW5zaWduZWQgaW50LCBsZW4sIHNpemVvZihpbnQp
KTsKCglpZiAobGVuIDwgMCkKCQlyZXR1cm4gLUVJTlZBTDsKCglzd2l0Y2ggKG9wdG5hbWUp
IHsKCWNhc2UgVURQX0NPUks6CgkJdmFsID0gdXAtPmNvcmtmbGFnOwoJCWJyZWFrOwoKCWNh
c2UgVURQX0VOQ0FQOgoJCXZhbCA9IHVwLT5lbmNhcF90eXBlOwoJCWJyZWFrOwoKCWNhc2Ug
VURQX05PX0NIRUNLNl9UWDoKCQl2YWwgPSB1cC0+bm9fY2hlY2s2X3R4OwoJCWJyZWFrOwoK
CWNhc2UgVURQX05PX0NIRUNLNl9SWDoKCQl2YWwgPSB1cC0+bm9fY2hlY2s2X3J4OwoJCWJy
ZWFrOwoKCS8qIFRoZSBmb2xsb3dpbmcgdHdvIGNhbm5vdCBiZSBjaGFuZ2VkIG9uIFVEUCBz
b2NrZXRzLCB0aGUgcmV0dXJuIGlzCgkgKiBhbHdheXMgMCAod2hpY2ggY29ycmVzcG9uZHMg
dG8gdGhlIGZ1bGwgY2hlY2tzdW0gY292ZXJhZ2Ugb2YgVURQKS4gKi8KCWNhc2UgVURQTElU
RV9TRU5EX0NTQ09WOgoJCXZhbCA9IHVwLT5wY3NsZW47CgkJYnJlYWs7CgoJY2FzZSBVRFBM
SVRFX1JFQ1ZfQ1NDT1Y6CgkJdmFsID0gdXAtPnBjcmxlbjsKCQlicmVhazsKCglkZWZhdWx0
OgoJCXJldHVybiAtRU5PUFJPVE9PUFQ7Cgl9CgoJaWYgKHB1dF91c2VyKGxlbiwgb3B0bGVu
KSkKCQlyZXR1cm4gLUVGQVVMVDsKCWlmIChjb3B5X3RvX3VzZXIob3B0dmFsLCAmdmFsLCBs
ZW4pKQoJCXJldHVybiAtRUZBVUxUOwoJcmV0dXJuIDA7Cn0KRVhQT1JUX1NZTUJPTCh1ZHBf
bGliX2dldHNvY2tvcHQpOwoKaW50IHVkcF9nZXRzb2Nrb3B0KHN0cnVjdCBzb2NrICpzaywg
aW50IGxldmVsLCBpbnQgb3B0bmFtZSwKCQkgICBjaGFyIF9fdXNlciAqb3B0dmFsLCBpbnQg
X191c2VyICpvcHRsZW4pCnsKCWlmIChsZXZlbCA9PSBTT0xfVURQICB8fCAgbGV2ZWwgPT0g
U09MX1VEUExJVEUpCgkJcmV0dXJuIHVkcF9saWJfZ2V0c29ja29wdChzaywgbGV2ZWwsIG9w
dG5hbWUsIG9wdHZhbCwgb3B0bGVuKTsKCXJldHVybiBpcF9nZXRzb2Nrb3B0KHNrLCBsZXZl
bCwgb3B0bmFtZSwgb3B0dmFsLCBvcHRsZW4pOwp9CgojaWZkZWYgQ09ORklHX0NPTVBBVApp
bnQgY29tcGF0X3VkcF9nZXRzb2Nrb3B0KHN0cnVjdCBzb2NrICpzaywgaW50IGxldmVsLCBp
bnQgb3B0bmFtZSwKCQkJCSBjaGFyIF9fdXNlciAqb3B0dmFsLCBpbnQgX191c2VyICpvcHRs
ZW4pCnsKCWlmIChsZXZlbCA9PSBTT0xfVURQICB8fCAgbGV2ZWwgPT0gU09MX1VEUExJVEUp
CgkJcmV0dXJuIHVkcF9saWJfZ2V0c29ja29wdChzaywgbGV2ZWwsIG9wdG5hbWUsIG9wdHZh
bCwgb3B0bGVuKTsKCXJldHVybiBjb21wYXRfaXBfZ2V0c29ja29wdChzaywgbGV2ZWwsIG9w
dG5hbWUsIG9wdHZhbCwgb3B0bGVuKTsKfQojZW5kaWYKLyoqCiAqIAl1ZHBfcG9sbCAtIHdh
aXQgZm9yIGEgVURQIGV2ZW50LgogKglAZmlsZSAtIGZpbGUgc3RydWN0CiAqCUBzb2NrIC0g
c29ja2V0CiAqCUB3YWl0IC0gcG9sbCB0YWJsZQogKgogKglUaGlzIGlzIHNhbWUgYXMgZGF0
YWdyYW0gcG9sbCwgZXhjZXB0IGZvciB0aGUgc3BlY2lhbCBjYXNlIG9mCiAqCWJsb2NraW5n
IHNvY2tldHMuIElmIGFwcGxpY2F0aW9uIGlzIHVzaW5nIGEgYmxvY2tpbmcgZmQKICoJYW5k
IGEgcGFja2V0IHdpdGggY2hlY2tzdW0gZXJyb3IgaXMgaW4gdGhlIHF1ZXVlOwogKgl0aGVu
IGl0IGNvdWxkIGdldCByZXR1cm4gZnJvbSBzZWxlY3QgaW5kaWNhdGluZyBkYXRhIGF2YWls
YWJsZQogKglidXQgdGhlbiBibG9jayB3aGVuIHJlYWRpbmcgaXQuIEFkZCBzcGVjaWFsIGNh
c2UgY29kZQogKgl0byB3b3JrIGFyb3VuZCB0aGVzZSBhcmd1YWJseSBicm9rZW4gYXBwbGlj
YXRpb25zLgogKi8KdW5zaWduZWQgaW50IHVkcF9wb2xsKHN0cnVjdCBmaWxlICpmaWxlLCBz
dHJ1Y3Qgc29ja2V0ICpzb2NrLCBwb2xsX3RhYmxlICp3YWl0KQp7Cgl1bnNpZ25lZCBpbnQg
bWFzayA9IGRhdGFncmFtX3BvbGwoZmlsZSwgc29jaywgd2FpdCk7CglzdHJ1Y3Qgc29jayAq
c2sgPSBzb2NrLT5zazsKCglzb2NrX3Jwc19yZWNvcmRfZmxvdyhzayk7CgoJLyogQ2hlY2sg
Zm9yIGZhbHNlIHBvc2l0aXZlcyBkdWUgdG8gY2hlY2tzdW0gZXJyb3JzICovCglpZiAoKG1h
c2sgJiBQT0xMUkROT1JNKSAmJiAhKGZpbGUtPmZfZmxhZ3MgJiBPX05PTkJMT0NLKSAmJgoJ
ICAgICEoc2stPnNrX3NodXRkb3duICYgUkNWX1NIVVRET1dOKSAmJiAhZmlyc3RfcGFja2V0
X2xlbmd0aChzaykpCgkJbWFzayAmPSB+KFBPTExJTiB8IFBPTExSRE5PUk0pOwoKCXJldHVy
biBtYXNrOwoKfQpFWFBPUlRfU1lNQk9MKHVkcF9wb2xsKTsKCnN0cnVjdCBwcm90byB1ZHBf
cHJvdCA9IHsKCS5uYW1lCQkgICA9ICJVRFAiLAoJLm93bmVyCQkgICA9IFRISVNfTU9EVUxF
LAoJLmNsb3NlCQkgICA9IHVkcF9saWJfY2xvc2UsCgkuY29ubmVjdAkgICA9IGlwNF9kYXRh
Z3JhbV9jb25uZWN0LAoJLmRpc2Nvbm5lY3QJICAgPSB1ZHBfZGlzY29ubmVjdCwKCS5pb2N0
bAkJICAgPSB1ZHBfaW9jdGwsCgkuZGVzdHJveQkgICA9IHVkcF9kZXN0cm95X3NvY2ssCgku
c2V0c29ja29wdAkgICA9IHVkcF9zZXRzb2Nrb3B0LAoJLmdldHNvY2tvcHQJICAgPSB1ZHBf
Z2V0c29ja29wdCwKCS5zZW5kbXNnCSAgID0gdWRwX3NlbmRtc2csCgkucmVjdm1zZwkgICA9
IHVkcF9yZWN2bXNnLAoJLnNlbmRwYWdlCSAgID0gdWRwX3NlbmRwYWdlLAoJLmJhY2tsb2df
cmN2CSAgID0gX191ZHBfcXVldWVfcmN2X3NrYiwKCS5yZWxlYXNlX2NiCSAgID0gaXA0X2Rh
dGFncmFtX3JlbGVhc2VfY2IsCgkuaGFzaAkJICAgPSB1ZHBfbGliX2hhc2gsCgkudW5oYXNo
CQkgICA9IHVkcF9saWJfdW5oYXNoLAoJLnJlaGFzaAkJICAgPSB1ZHBfdjRfcmVoYXNoLAoJ
LmdldF9wb3J0CSAgID0gdWRwX3Y0X2dldF9wb3J0LAoJLm1lbW9yeV9hbGxvY2F0ZWQgID0g
JnVkcF9tZW1vcnlfYWxsb2NhdGVkLAoJLnN5c2N0bF9tZW0JICAgPSBzeXNjdGxfdWRwX21l
bSwKCS5zeXNjdGxfd21lbQkgICA9ICZzeXNjdGxfdWRwX3dtZW1fbWluLAoJLnN5c2N0bF9y
bWVtCSAgID0gJnN5c2N0bF91ZHBfcm1lbV9taW4sCgkub2JqX3NpemUJICAgPSBzaXplb2Yo
c3RydWN0IHVkcF9zb2NrKSwKCS5zbGFiX2ZsYWdzCSAgID0gU0xBQl9ERVNUUk9ZX0JZX1JD
VSwKCS5oLnVkcF90YWJsZQkgICA9ICZ1ZHBfdGFibGUsCiNpZmRlZiBDT05GSUdfQ09NUEFU
CgkuY29tcGF0X3NldHNvY2tvcHQgPSBjb21wYXRfdWRwX3NldHNvY2tvcHQsCgkuY29tcGF0
X2dldHNvY2tvcHQgPSBjb21wYXRfdWRwX2dldHNvY2tvcHQsCiNlbmRpZgoJLmNsZWFyX3Nr
CSAgID0gc2tfcHJvdF9jbGVhcl9wb3J0YWRkcl9udWxscywKfTsKRVhQT1JUX1NZTUJPTCh1
ZHBfcHJvdCk7CgovKiAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0gKi8KI2lmZGVmIENPTkZJR19QUk9D
X0ZTCgpzdGF0aWMgc3RydWN0IHNvY2sgKnVkcF9nZXRfZmlyc3Qoc3RydWN0IHNlcV9maWxl
ICpzZXEsIGludCBzdGFydCkKewoJc3RydWN0IHNvY2sgKnNrOwoJc3RydWN0IHVkcF9pdGVy
X3N0YXRlICpzdGF0ZSA9IHNlcS0+cHJpdmF0ZTsKCXN0cnVjdCBuZXQgKm5ldCA9IHNlcV9m
aWxlX25ldChzZXEpOwoKCWZvciAoc3RhdGUtPmJ1Y2tldCA9IHN0YXJ0OyBzdGF0ZS0+YnVj
a2V0IDw9IHN0YXRlLT51ZHBfdGFibGUtPm1hc2s7CgkgICAgICsrc3RhdGUtPmJ1Y2tldCkg
ewoJCXN0cnVjdCBobGlzdF9udWxsc19ub2RlICpub2RlOwoJCXN0cnVjdCB1ZHBfaHNsb3Qg
KmhzbG90ID0gJnN0YXRlLT51ZHBfdGFibGUtPmhhc2hbc3RhdGUtPmJ1Y2tldF07CgoJCWlm
IChobGlzdF9udWxsc19lbXB0eSgmaHNsb3QtPmhlYWQpKQoJCQljb250aW51ZTsKCgkJc3Bp
bl9sb2NrX2JoKCZoc2xvdC0+bG9jayk7CgkJc2tfbnVsbHNfZm9yX2VhY2goc2ssIG5vZGUs
ICZoc2xvdC0+aGVhZCkgewoJCQlpZiAoIW5ldF9lcShzb2NrX25ldChzayksIG5ldCkpCgkJ
CQljb250aW51ZTsKCQkJaWYgKHNrLT5za19mYW1pbHkgPT0gc3RhdGUtPmZhbWlseSkKCQkJ
CWdvdG8gZm91bmQ7CgkJfQoJCXNwaW5fdW5sb2NrX2JoKCZoc2xvdC0+bG9jayk7Cgl9Cglz
ayA9IE5VTEw7CmZvdW5kOgoJcmV0dXJuIHNrOwp9CgpzdGF0aWMgc3RydWN0IHNvY2sgKnVk
cF9nZXRfbmV4dChzdHJ1Y3Qgc2VxX2ZpbGUgKnNlcSwgc3RydWN0IHNvY2sgKnNrKQp7Cglz
dHJ1Y3QgdWRwX2l0ZXJfc3RhdGUgKnN0YXRlID0gc2VxLT5wcml2YXRlOwoJc3RydWN0IG5l
dCAqbmV0ID0gc2VxX2ZpbGVfbmV0KHNlcSk7CgoJZG8gewoJCXNrID0gc2tfbnVsbHNfbmV4
dChzayk7Cgl9IHdoaWxlIChzayAmJiAoIW5ldF9lcShzb2NrX25ldChzayksIG5ldCkgfHwg
c2stPnNrX2ZhbWlseSAhPSBzdGF0ZS0+ZmFtaWx5KSk7CgoJaWYgKCFzaykgewoJCWlmIChz
dGF0ZS0+YnVja2V0IDw9IHN0YXRlLT51ZHBfdGFibGUtPm1hc2spCgkJCXNwaW5fdW5sb2Nr
X2JoKCZzdGF0ZS0+dWRwX3RhYmxlLT5oYXNoW3N0YXRlLT5idWNrZXRdLmxvY2spOwoJCXJl
dHVybiB1ZHBfZ2V0X2ZpcnN0KHNlcSwgc3RhdGUtPmJ1Y2tldCArIDEpOwoJfQoJcmV0dXJu
IHNrOwp9CgpzdGF0aWMgc3RydWN0IHNvY2sgKnVkcF9nZXRfaWR4KHN0cnVjdCBzZXFfZmls
ZSAqc2VxLCBsb2ZmX3QgcG9zKQp7CglzdHJ1Y3Qgc29jayAqc2sgPSB1ZHBfZ2V0X2ZpcnN0
KHNlcSwgMCk7CgoJaWYgKHNrKQoJCXdoaWxlIChwb3MgJiYgKHNrID0gdWRwX2dldF9uZXh0
KHNlcSwgc2spKSAhPSBOVUxMKQoJCQktLXBvczsKCXJldHVybiBwb3MgPyBOVUxMIDogc2s7
Cn0KCnN0YXRpYyB2b2lkICp1ZHBfc2VxX3N0YXJ0KHN0cnVjdCBzZXFfZmlsZSAqc2VxLCBs
b2ZmX3QgKnBvcykKewoJc3RydWN0IHVkcF9pdGVyX3N0YXRlICpzdGF0ZSA9IHNlcS0+cHJp
dmF0ZTsKCXN0YXRlLT5idWNrZXQgPSBNQVhfVURQX1BPUlRTOwoKCXJldHVybiAqcG9zID8g
dWRwX2dldF9pZHgoc2VxLCAqcG9zLTEpIDogU0VRX1NUQVJUX1RPS0VOOwp9CgpzdGF0aWMg
dm9pZCAqdWRwX3NlcV9uZXh0KHN0cnVjdCBzZXFfZmlsZSAqc2VxLCB2b2lkICp2LCBsb2Zm
X3QgKnBvcykKewoJc3RydWN0IHNvY2sgKnNrOwoKCWlmICh2ID09IFNFUV9TVEFSVF9UT0tF
TikKCQlzayA9IHVkcF9nZXRfaWR4KHNlcSwgMCk7CgllbHNlCgkJc2sgPSB1ZHBfZ2V0X25l
eHQoc2VxLCB2KTsKCgkrKypwb3M7CglyZXR1cm4gc2s7Cn0KCnN0YXRpYyB2b2lkIHVkcF9z
ZXFfc3RvcChzdHJ1Y3Qgc2VxX2ZpbGUgKnNlcSwgdm9pZCAqdikKewoJc3RydWN0IHVkcF9p
dGVyX3N0YXRlICpzdGF0ZSA9IHNlcS0+cHJpdmF0ZTsKCglpZiAoc3RhdGUtPmJ1Y2tldCA8
PSBzdGF0ZS0+dWRwX3RhYmxlLT5tYXNrKQoJCXNwaW5fdW5sb2NrX2JoKCZzdGF0ZS0+dWRw
X3RhYmxlLT5oYXNoW3N0YXRlLT5idWNrZXRdLmxvY2spOwp9CgppbnQgdWRwX3NlcV9vcGVu
KHN0cnVjdCBpbm9kZSAqaW5vZGUsIHN0cnVjdCBmaWxlICpmaWxlKQp7CglzdHJ1Y3QgdWRw
X3NlcV9hZmluZm8gKmFmaW5mbyA9IFBERV9EQVRBKGlub2RlKTsKCXN0cnVjdCB1ZHBfaXRl
cl9zdGF0ZSAqczsKCWludCBlcnI7CgoJZXJyID0gc2VxX29wZW5fbmV0KGlub2RlLCBmaWxl
LCAmYWZpbmZvLT5zZXFfb3BzLAoJCQkgICBzaXplb2Yoc3RydWN0IHVkcF9pdGVyX3N0YXRl
KSk7CglpZiAoZXJyIDwgMCkKCQlyZXR1cm4gZXJyOwoKCXMgPSAoKHN0cnVjdCBzZXFfZmls
ZSAqKWZpbGUtPnByaXZhdGVfZGF0YSktPnByaXZhdGU7CglzLT5mYW1pbHkJCT0gYWZpbmZv
LT5mYW1pbHk7CglzLT51ZHBfdGFibGUJCT0gYWZpbmZvLT51ZHBfdGFibGU7CglyZXR1cm4g
ZXJyOwp9CkVYUE9SVF9TWU1CT0wodWRwX3NlcV9vcGVuKTsKCi8qIC0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLSAqLwppbnQgdWRwX3Byb2NfcmVnaXN0ZXIoc3RydWN0IG5ldCAqbmV0LCBzdHJ1Y3Qg
dWRwX3NlcV9hZmluZm8gKmFmaW5mbykKewoJc3RydWN0IHByb2NfZGlyX2VudHJ5ICpwOwoJ
aW50IHJjID0gMDsKCglhZmluZm8tPnNlcV9vcHMuc3RhcnQJCT0gdWRwX3NlcV9zdGFydDsK
CWFmaW5mby0+c2VxX29wcy5uZXh0CQk9IHVkcF9zZXFfbmV4dDsKCWFmaW5mby0+c2VxX29w
cy5zdG9wCQk9IHVkcF9zZXFfc3RvcDsKCglwID0gcHJvY19jcmVhdGVfZGF0YShhZmluZm8t
Pm5hbWUsIFNfSVJVR08sIG5ldC0+cHJvY19uZXQsCgkJCSAgICAgYWZpbmZvLT5zZXFfZm9w
cywgYWZpbmZvKTsKCWlmICghcCkKCQlyYyA9IC1FTk9NRU07CglyZXR1cm4gcmM7Cn0KRVhQ
T1JUX1NZTUJPTCh1ZHBfcHJvY19yZWdpc3Rlcik7Cgp2b2lkIHVkcF9wcm9jX3VucmVnaXN0
ZXIoc3RydWN0IG5ldCAqbmV0LCBzdHJ1Y3QgdWRwX3NlcV9hZmluZm8gKmFmaW5mbykKewoJ
cmVtb3ZlX3Byb2NfZW50cnkoYWZpbmZvLT5uYW1lLCBuZXQtPnByb2NfbmV0KTsKfQpFWFBP
UlRfU1lNQk9MKHVkcF9wcm9jX3VucmVnaXN0ZXIpOwoKLyogLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
ICovCnN0YXRpYyB2b2lkIHVkcDRfZm9ybWF0X3NvY2soc3RydWN0IHNvY2sgKnNwLCBzdHJ1
Y3Qgc2VxX2ZpbGUgKmYsCgkJaW50IGJ1Y2tldCkKewoJc3RydWN0IGluZXRfc29jayAqaW5l
dCA9IGluZXRfc2soc3ApOwoJX19iZTMyIGRlc3QgPSBpbmV0LT5pbmV0X2RhZGRyOwoJX19i
ZTMyIHNyYyAgPSBpbmV0LT5pbmV0X3Jjdl9zYWRkcjsKCV9fdTE2IGRlc3RwCSAgPSBudG9o
cyhpbmV0LT5pbmV0X2Rwb3J0KTsKCV9fdTE2IHNyY3AJICA9IG50b2hzKGluZXQtPmluZXRf
c3BvcnQpOwoKCXNlcV9wcmludGYoZiwgIiU1ZDogJTA4WDolMDRYICUwOFg6JTA0WCIKCQki
ICUwMlggJTA4WDolMDhYICUwMlg6JTA4bFggJTA4WCAlNXUgJThkICVsdSAlZCAlcEsgJWQi
LAoJCWJ1Y2tldCwgc3JjLCBzcmNwLCBkZXN0LCBkZXN0cCwgc3AtPnNrX3N0YXRlLAoJCXNr
X3dtZW1fYWxsb2NfZ2V0KHNwKSwKCQlza19ybWVtX2FsbG9jX2dldChzcCksCgkJMCwgMEws
IDAsCgkJZnJvbV9rdWlkX211bmdlZChzZXFfdXNlcl9ucyhmKSwgc29ja19pX3VpZChzcCkp
LAoJCTAsIHNvY2tfaV9pbm8oc3ApLAoJCWF0b21pY19yZWFkKCZzcC0+c2tfcmVmY250KSwg
c3AsCgkJYXRvbWljX3JlYWQoJnNwLT5za19kcm9wcykpOwp9CgppbnQgdWRwNF9zZXFfc2hv
dyhzdHJ1Y3Qgc2VxX2ZpbGUgKnNlcSwgdm9pZCAqdikKewoJc2VxX3NldHdpZHRoKHNlcSwg
MTI3KTsKCWlmICh2ID09IFNFUV9TVEFSVF9UT0tFTikKCQlzZXFfcHV0cyhzZXEsICIgIHNs
ICBsb2NhbF9hZGRyZXNzIHJlbV9hZGRyZXNzICAgc3QgdHhfcXVldWUgIgoJCQkgICAicnhf
cXVldWUgdHIgdG0tPndoZW4gcmV0cm5zbXQgICB1aWQgIHRpbWVvdXQgIgoJCQkgICAiaW5v
ZGUgcmVmIHBvaW50ZXIgZHJvcHMiKTsKCWVsc2UgewoJCXN0cnVjdCB1ZHBfaXRlcl9zdGF0
ZSAqc3RhdGUgPSBzZXEtPnByaXZhdGU7CgoJCXVkcDRfZm9ybWF0X3NvY2sodiwgc2VxLCBz
dGF0ZS0+YnVja2V0KTsKCX0KCXNlcV9wYWQoc2VxLCAnXG4nKTsKCXJldHVybiAwOwp9Cgpz
dGF0aWMgY29uc3Qgc3RydWN0IGZpbGVfb3BlcmF0aW9ucyB1ZHBfYWZpbmZvX3NlcV9mb3Bz
ID0gewoJLm93bmVyICAgID0gVEhJU19NT0RVTEUsCgkub3BlbiAgICAgPSB1ZHBfc2VxX29w
ZW4sCgkucmVhZCAgICAgPSBzZXFfcmVhZCwKCS5sbHNlZWsgICA9IHNlcV9sc2VlaywKCS5y
ZWxlYXNlICA9IHNlcV9yZWxlYXNlX25ldAp9OwoKLyogLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tICov
CnN0YXRpYyBzdHJ1Y3QgdWRwX3NlcV9hZmluZm8gdWRwNF9zZXFfYWZpbmZvID0gewoJLm5h
bWUJCT0gInVkcCIsCgkuZmFtaWx5CQk9IEFGX0lORVQsCgkudWRwX3RhYmxlCT0gJnVkcF90
YWJsZSwKCS5zZXFfZm9wcwk9ICZ1ZHBfYWZpbmZvX3NlcV9mb3BzLAoJLnNlcV9vcHMJPSB7
CgkJLnNob3cJCT0gdWRwNF9zZXFfc2hvdywKCX0sCn07CgpzdGF0aWMgaW50IF9fbmV0X2lu
aXQgdWRwNF9wcm9jX2luaXRfbmV0KHN0cnVjdCBuZXQgKm5ldCkKewoJcmV0dXJuIHVkcF9w
cm9jX3JlZ2lzdGVyKG5ldCwgJnVkcDRfc2VxX2FmaW5mbyk7Cn0KCnN0YXRpYyB2b2lkIF9f
bmV0X2V4aXQgdWRwNF9wcm9jX2V4aXRfbmV0KHN0cnVjdCBuZXQgKm5ldCkKewoJdWRwX3By
b2NfdW5yZWdpc3RlcihuZXQsICZ1ZHA0X3NlcV9hZmluZm8pOwp9CgpzdGF0aWMgc3RydWN0
IHBlcm5ldF9vcGVyYXRpb25zIHVkcDRfbmV0X29wcyA9IHsKCS5pbml0ID0gdWRwNF9wcm9j
X2luaXRfbmV0LAoJLmV4aXQgPSB1ZHA0X3Byb2NfZXhpdF9uZXQsCn07CgppbnQgX19pbml0
IHVkcDRfcHJvY19pbml0KHZvaWQpCnsKCXJldHVybiByZWdpc3Rlcl9wZXJuZXRfc3Vic3lz
KCZ1ZHA0X25ldF9vcHMpOwp9Cgp2b2lkIHVkcDRfcHJvY19leGl0KHZvaWQpCnsKCXVucmVn
aXN0ZXJfcGVybmV0X3N1YnN5cygmdWRwNF9uZXRfb3BzKTsKfQojZW5kaWYgLyogQ09ORklH
X1BST0NfRlMgKi8KCnN0YXRpYyBfX2luaXRkYXRhIHVuc2lnbmVkIGxvbmcgdWhhc2hfZW50
cmllczsKc3RhdGljIGludCBfX2luaXQgc2V0X3VoYXNoX2VudHJpZXMoY2hhciAqc3RyKQp7
Cglzc2l6ZV90IHJldDsKCglpZiAoIXN0cikKCQlyZXR1cm4gMDsKCglyZXQgPSBrc3RydG91
bChzdHIsIDAsICZ1aGFzaF9lbnRyaWVzKTsKCWlmIChyZXQpCgkJcmV0dXJuIDA7CgoJaWYg
KHVoYXNoX2VudHJpZXMgJiYgdWhhc2hfZW50cmllcyA8IFVEUF9IVEFCTEVfU0laRV9NSU4p
CgkJdWhhc2hfZW50cmllcyA9IFVEUF9IVEFCTEVfU0laRV9NSU47CglyZXR1cm4gMTsKfQpf
X3NldHVwKCJ1aGFzaF9lbnRyaWVzPSIsIHNldF91aGFzaF9lbnRyaWVzKTsKCnZvaWQgX19p
bml0IHVkcF90YWJsZV9pbml0KHN0cnVjdCB1ZHBfdGFibGUgKnRhYmxlLCBjb25zdCBjaGFy
ICpuYW1lKQp7Cgl1bnNpZ25lZCBpbnQgaTsKCgl0YWJsZS0+aGFzaCA9IGFsbG9jX2xhcmdl
X3N5c3RlbV9oYXNoKG5hbWUsCgkJCQkJICAgICAgMiAqIHNpemVvZihzdHJ1Y3QgdWRwX2hz
bG90KSwKCQkJCQkgICAgICB1aGFzaF9lbnRyaWVzLAoJCQkJCSAgICAgIDIxLCAvKiBvbmUg
c2xvdCBwZXIgMiBNQiAqLwoJCQkJCSAgICAgIDAsCgkJCQkJICAgICAgJnRhYmxlLT5sb2cs
CgkJCQkJICAgICAgJnRhYmxlLT5tYXNrLAoJCQkJCSAgICAgIFVEUF9IVEFCTEVfU0laRV9N
SU4sCgkJCQkJICAgICAgNjQgKiAxMDI0KTsKCgl0YWJsZS0+aGFzaDIgPSB0YWJsZS0+aGFz
aCArICh0YWJsZS0+bWFzayArIDEpOwoJZm9yIChpID0gMDsgaSA8PSB0YWJsZS0+bWFzazsg
aSsrKSB7CgkJSU5JVF9ITElTVF9OVUxMU19IRUFEKCZ0YWJsZS0+aGFzaFtpXS5oZWFkLCBp
KTsKCQl0YWJsZS0+aGFzaFtpXS5jb3VudCA9IDA7CgkJc3Bpbl9sb2NrX2luaXQoJnRhYmxl
LT5oYXNoW2ldLmxvY2spOwoJfQoJZm9yIChpID0gMDsgaSA8PSB0YWJsZS0+bWFzazsgaSsr
KSB7CgkJSU5JVF9ITElTVF9OVUxMU19IRUFEKCZ0YWJsZS0+aGFzaDJbaV0uaGVhZCwgaSk7
CgkJdGFibGUtPmhhc2gyW2ldLmNvdW50ID0gMDsKCQlzcGluX2xvY2tfaW5pdCgmdGFibGUt
Pmhhc2gyW2ldLmxvY2spOwoJfQp9Cgp2b2lkIF9faW5pdCB1ZHBfaW5pdCh2b2lkKQp7Cgl1
bnNpZ25lZCBsb25nIGxpbWl0OwoKCXVkcF90YWJsZV9pbml0KCZ1ZHBfdGFibGUsICJVRFAi
KTsKCWxpbWl0ID0gbnJfZnJlZV9idWZmZXJfcGFnZXMoKSAvIDg7CglsaW1pdCA9IG1heChs
aW1pdCwgMTI4VUwpOwoJc3lzY3RsX3VkcF9tZW1bMF0gPSBsaW1pdCAvIDQgKiAzOwoJc3lz
Y3RsX3VkcF9tZW1bMV0gPSBsaW1pdDsKCXN5c2N0bF91ZHBfbWVtWzJdID0gc3lzY3RsX3Vk
cF9tZW1bMF0gKiAyOwoKCXN5c2N0bF91ZHBfcm1lbV9taW4gPSBTS19NRU1fUVVBTlRVTTsK
CXN5c2N0bF91ZHBfd21lbV9taW4gPSBTS19NRU1fUVVBTlRVTTsKfQo=
--------------030904000408010905020400--
