From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v4 net 0/3]: ipv6: Reduce the number of fib6_lookup() calls from ip6_pol_route()
Date: Fri, 10 Oct 2014 11:48:05 -0700
Message-ID: <1412966888-31384-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:61525 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751871AbaJJSsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 14:48:16 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id s9AIlLX1031982
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:48:15 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by m0004347.ppops.net with ESMTP id 1pxkqwg66p-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:48:15 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 fda9ef4850ad11e487590002c9521c9e-1dbfc3e0 for <netdev@vger.kernel.org>;	Fri,
 10 Oct 2014 11:48:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch set is trying to reduce the number of fib6_lookup()
calls from ip6_pol_route().

I have adapted davem's udpflood and kbench_mod test
(https://git.kernel.org/pub/scm/linux/kernel/git/davem/net_test_tools.git) to
support IPv6 and here is the result:


Before:
[root]# for i in $(seq 1 3); do time ./udpflood -l 20000000 -c 250 2401:face:face:face::2; done

real    0m34.190s
user    0m3.047s
sys     0m31.108s

real    0m34.635s
user    0m3.125s
sys     0m31.475s

real    0m34.517s
user    0m3.034s
sys     0m31.449s

[root]# insmod ip6_route_kbench.ko oif=2 src=2401:face:face:face::1 dst=2401:face:face:face::2
[  660.160976] ip6_route_kbench: ip6_route_output tdiff: 933
[  660.207261] ip6_route_kbench: ip6_route_output tdiff: 988
[  660.253492] ip6_route_kbench: ip6_route_output tdiff: 896
[  660.298862] ip6_route_kbench: ip6_route_output tdiff: 898

After:
[root]# for i in $(seq 1 3); do time ./udpflood -l 20000000 -c 250 2401:face:face:face::2; done

real    0m32.695s
user    0m2.925s
sys     0m29.737s

real    0m32.636s
user    0m3.007s
sys     0m29.596s

real    0m32.797s
user    0m2.866s
sys     0m29.898s

[root]# insmod ip6_route_kbench.ko oif=2 src=2401:face:face:face::1 dst=2401:face:face:face::2
[  881.220793] ip6_route_kbench: ip6_route_output tdiff: 684
[  881.253477] ip6_route_kbench: ip6_route_output tdiff: 640
[  881.286867] ip6_route_kbench: ip6_route_output tdiff: 630
[  881.320749] ip6_route_kbench: ip6_route_output tdiff: 653


/****************************** udpflood.c ******************************/
/* It is an adaptation of the Eric Dumazet's and David Miller's
 * udpflood tool, by adding IPv6 support.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <malloc.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <stdint.h>
#include <assert.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define _GNU_SOURCE
#include <getopt.h>

typedef uint32_t u32;

static int debug =3D 0;

/* Allow -fstrict-aliasing */
typedef union sa_u {
	struct sockaddr_storage a46;
	struct sockaddr_in a4;
	struct sockaddr_in6 a6;
} sa_u;

static int usage(void)
{
	printf("usage: udpflood [ -l count ] [ -m message_size ] [ -c num_ip_addrs=
 ] IP_ADDRESS\n");
	return -1;
}

static u32 get_last32h(const sa_u *sa)
{
	if (sa->a46.ss_family =3D=3D PF_INET)
		return ntohl(sa->a4.sin_addr.s_addr);
	else
		return ntohl(sa->a6.sin6_addr.s6_addr32[3]);
}

static void set_last32h(sa_u *sa, u32 last32h)
{
	if (sa->a46.ss_family =3D=3D PF_INET)
		sa->a4.sin_addr.s_addr =3D htonl(last32h);
	else
		sa->a6.sin6_addr.s6_addr32[3] =3D htonl(last32h);
}

static void print_saddr(const sa_u *sa, const char *msg)
{
	char buf[64];

	if (!debug)
		return;

	switch (sa->a46.ss_family) {
	case PF_INET:
		inet_ntop(PF_INET, &(sa->a4.sin_addr.s_addr), buf,
			  sizeof(buf));
		break;
	case PF_INET6:
		inet_ntop(PF_INET6, &(sa->a6.sin6_addr), buf, sizeof(buf));
		break;
	}

	printf("%s: %s\n", msg, buf);
}

static int send_packets(const sa_u *sa, size_t num_addrs, int count, int ms=
g_sz)
{
	char *msg =3D malloc(msg_sz);
	sa_u saddr;
	u32 start_addr32h, end_addr32h, cur_addr32h;
	int fd, i, err;

	if (!msg)
		return -ENOMEM;

	memset(msg, 0, msg_sz);

	memcpy(&saddr, sa, sizeof(saddr));
	cur_addr32h =3D start_addr32h =3D get_last32h(&saddr);
	end_addr32h =3D start_addr32h + num_addrs;

	fd =3D socket(saddr.a46.ss_family, SOCK_DGRAM, 0);
	if (fd < 0) {
		perror("socket");
		err =3D fd;
		goto out_nofd;
	}

	/* connect to avoid the kernel spending time in figuring
	 * out the source address (i.e pin the src address)
	 */
	err =3D connect(fd, (struct sockaddr *) &saddr, sizeof(saddr));
	if (err < 0) {
		perror("connect");
		goto out;
	}

	print_saddr(&saddr, "start_addr");
	for (i =3D 0; i < count; i++) {
		print_saddr(&saddr, "sendto");
		err =3D sendto(fd, msg, msg_sz, 0, (struct sockaddr *)&saddr,
			     sizeof(saddr));
		if (err < 0) {
			perror("sendto");
			goto out;
		}

		if (++cur_addr32h >=3D end_addr32h)
			cur_addr32h =3D start_addr32h;
		set_last32h(&saddr, cur_addr32h);
	}

	err =3D 0;
out:
	close(fd);
out_nofd:
	free(msg);
	return err;
}

int main(int argc, char **argv, char **envp)
{
	int port, msg_sz, count, num_addrs, ret;

	sa_u start_addr;

	port =3D 6000;
	msg_sz =3D 32;
	count =3D 10000000;
	num_addrs =3D 1;

	while ((ret =3D getopt(argc, argv, "dl:s:p:c:")) >=3D 0) {
		switch (ret) {
		case 'l':
			sscanf(optarg, "%d", &count);
			break;
		case 's':
			sscanf(optarg, "%d", &msg_sz);
			break;
		case 'p':
			sscanf(optarg, "%d", &port);
			break;
		case 'c':
			sscanf(optarg, "%d", &num_addrs);
			break;
		case 'd':
			debug =3D 1;
			break;
		case '?':
			return usage();
		}
	}

	if (num_addrs < 1)
		return usage();

	if (!argv[optind])
		return usage();

	start_addr.a4.sin_port =3D htons(port);
	if (inet_pton(PF_INET, argv[optind], &start_addr.a4.sin_addr))
		start_addr.a46.ss_family =3D PF_INET;
	else if (inet_pton(PF_INET6, argv[optind], &start_addr.a6.sin6_addr.s6_add=
r))
		start_addr.a46.ss_family =3D PF_INET6;
	else
		return usage();

	return send_packets(&start_addr, num_addrs, count, msg_sz);
}

/****************** ip6_route_kbench_mod.c ******************/
#define pr_fmt(fmt) "ip6_route_kbench: " fmt

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/inet.h>
#include <linux/in6.h>

#include <net/route.h>
#include <net/ip6_route.h>

#include <linux/timex.h>
#include <uapi/linux/icmpv6.h>

/* We can't just use "get_cycles()" as on some platforms, such
 * as sparc64, that gives system cycles rather than cpu clock
 * cycles.
 */

#ifdef CONFIG_SPARC64
static inline unsigned long long get_tick(void)
{
	unsigned long long t;

	__asm__ __volatile__("rd %%tick, %0" : "=r" (t));
	return t;
}
#elif defined(CONFIG_X86)
static inline unsigned long long get_tick(void)
{
	unsigned long long t;

	rdtscll(t);

	return t;
}
#elif defined(CONFIG_POWERPC)
static inline unsigned long long get_tick(void)
{
	return get_cycles();
}
#else
#error Unsupported architecture, please implement get_tick()
#endif

#define DEFAULT_WARMUP_COUNT 100000

#define DEFAULT_DST_IP_ADDR	0x4a800001
#define DEFAULT_SRC_IP_ADDR	0x00000000
#define DEFAULT_OIF		0
#define DEFAULT_IIF		0
#define DEFAULT_MARK		0x00000000
#define DEFAULT_TOS		0x00

static int flow_oif = DEFAULT_OIF;
static int flow_iif = DEFAULT_IIF;
static u32 flow_mark = DEFAULT_MARK;
static struct in6_addr flow_dst_ip_addr;
static struct in6_addr flow_src_ip_addr;
static int flow_tos = DEFAULT_TOS;

static char dst_string[64];
static char src_string[64];

module_param_string(dst, dst_string, sizeof(dst_string), 0);
module_param_string(src, src_string, sizeof(src_string), 0);

static int __init flow_setup(void)
{
	if (dst_string[0] &&
	    !in6_pton(dst_string, -1, &flow_dst_ip_addr.s6_addr[0], -1, NULL)) {
		pr_info("cannot parse \"%s\"\n", dst_string);
		return -1;
	}

	if (src_string[0] &&
	    !in6_pton(src_string, -1, &flow_src_ip_addr.s6_addr[0], -1, NULL)) {
		pr_info("cannot parse \"%s\"\n", dst_string);
		return -1;
	}

	return 0;
}

module_param_named(oif, flow_oif, int, 0);
module_param_named(iif, flow_iif, int, 0);
module_param_named(mark, flow_mark, uint, 0);
module_param_named(tos, flow_tos, int, 0);

static int warmup_count = DEFAULT_WARMUP_COUNT;
module_param_named(count, warmup_count, int, 0);

static void flow_init(struct flowi6 *fl6)
{
	memset(fl6, 0, sizeof(*fl6));
	fl6->flowi6_proto = IPPROTO_ICMPV6;
	fl6->flowi6_oif = flow_oif;
	fl6->flowi6_iif = flow_iif;
	fl6->flowi6_mark = flow_mark;
	fl6->flowi6_tos = flow_tos;
	fl6->daddr = flow_dst_ip_addr;
	fl6->saddr = flow_src_ip_addr;
}

static struct sk_buff * fake_skb_get(void)
{
	struct ipv6hdr *hdr;
	struct sk_buff *skb;

	skb = alloc_skb(4096, GFP_KERNEL);
	if (!skb) {
		pr_info("Cannot alloc SKB for test\n");
		return NULL;
	}
	skb->dev = __dev_get_by_index(&init_net, flow_iif);
	if (skb->dev == NULL) {
		pr_info("Input device (%d) does not exist\n", flow_iif);
		goto err;
	}

	skb_reset_mac_header(skb);
	skb_reset_network_header(skb);
	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
	hdr = ipv6_hdr(skb);

	hdr->priority = 0;
	hdr->version = 6;
	memset(hdr->flow_lbl, 0, sizeof(hdr->flow_lbl));
	hdr->payload_len = htons(sizeof(struct icmp6hdr));
	hdr->nexthdr = IPPROTO_ICMPV6;
	hdr->saddr = flow_src_ip_addr;
	hdr->daddr = flow_dst_ip_addr;
	skb->protocol = htons(ETH_P_IPV6);
	skb->mark = flow_mark;

	return skb;
err:
	kfree_skb(skb);
	return NULL;
}

static void do_full_output_lookup_bench(void)
{
	unsigned long long t1, t2, tdiff;
	struct rt6_info *rt;
	struct flowi6 fl6;
	int i;

	rt = NULL;

	for (i = 0; i < warmup_count; i++) {
		flow_init(&fl6);

		rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl6);
		if (IS_ERR(rt))
			break;
		ip6_rt_put(rt);
	}
	if (IS_ERR(rt)) {
		pr_info("ip_route_output_key: err=%ld\n", PTR_ERR(rt));
		return;
	}

	flow_init(&fl6);

	t1 = get_tick();
	rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl6);
	t2 = get_tick();
	if (!IS_ERR(rt))
		ip6_rt_put(rt);

	tdiff = t2 - t1;
	pr_info("ip6_route_output tdiff: %llu\n", tdiff);
}

static void do_full_input_lookup_bench(void)
{
	unsigned long long t1, t2, tdiff;
	struct sk_buff *skb;
	struct rt6_info *rt;
	int err, i;

	skb = fake_skb_get();
	if (skb == NULL)
		goto out_free;

	err = 0;
	local_bh_disable();
	for (i = 0; i < warmup_count; i++) {
		ip6_route_input(skb);
		rt = (struct rt6_info *)skb_dst(skb);
		err = (!rt || rt == init_net.ipv6.ip6_null_entry);
		skb_dst_drop(skb);
		if (err)
			break;
	}
	local_bh_enable();

	if (err) {
		pr_info("Input route lookup fails\n");
		goto out_free;
	}

	local_bh_disable();
	t1 = get_tick();
	ip6_route_input(skb);
	t2 = get_tick();
	local_bh_enable();

	rt = (struct rt6_info *)skb_dst(skb);
	err = (!rt || rt == init_net.ipv6.ip6_null_entry);
	skb_dst_drop(skb);
	if (err) {
		pr_info("Input route lookup fails\n");
		goto out_free;
	}

	tdiff = t2 - t1;
	pr_info("ip6_route_input tdiff: %llu\n", tdiff);

out_free:
	kfree_skb(skb);
}

static void do_full_lookup_bench(void)
{
	if (!flow_iif)
		do_full_output_lookup_bench();
	else
		do_full_input_lookup_bench();
}

static void do_bench(void)
{
	do_full_lookup_bench();
	do_full_lookup_bench();
	do_full_lookup_bench();
	do_full_lookup_bench();
}

static int __init kbench_init(void)
{
	if (flow_setup())
		return -EINVAL;

	pr_info("flow [IIF(%d),OIF(%d),MARK(0x%08x),D("IP6_FMT"),"
		"S("IP6_FMT"),TOS(0x%02x)]\n",
		flow_iif, flow_oif, flow_mark,
		IP6_PRT(flow_dst_ip_addr),
		IP6_PRT(flow_src_ip_addr),
		flow_tos);

#if defined(CONFIG_X86)
	if (!cpu_has_tsc) {
		pr_err("X86 TSC is required, but is unavailable.\n");
		return -EINVAL;
	}
#endif

	pr_info("sizeof(struct rt6_info)==%zu\n", sizeof(struct rt6_info));

	do_bench();

	return -ENODEV;
}

static void __exit kbench_exit(void)
{
}

module_init(kbench_init);
module_exit(kbench_exit);
MODULE_LICENSE("GPL");
