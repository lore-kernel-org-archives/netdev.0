From: Stephen Hemminger <shemminger@osdl.org>
Subject: IP fragmentation bug from NFS
Date: Fri, 22 Sep 2006 13:35:12 -0700
Message-ID: <20060922133512.01a9e9d0@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27595 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964895AbWIVUfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 16:35:15 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k8MKZCnW030369
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 13:35:13 -0700
Received: from localhost.localdomain (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k8MKZCbn023902
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 13:35:12 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

http://bugzilla.kernel.org/show_bug.cgi?id=7018

Looking at this, it seems that when NFS hands UDP a fragmented (non-linear skb),
it traps because it tries to trim bytes off a non-linear skb. Not sure if skb_trim
needs fixing, or IP is broken..

---

ssize_t	ip_append_page(struct sock *sk, struct page *page,
		       int offset, size_t size, int flags)
{
	struct inet_sock *inet = inet_sk(sk);
	struct sk_buff *skb;
	struct rtable *rt;
	struct ip_options *opt = NULL;
	int hh_len;
	int mtu;
	int len;
	int err;
	unsigned int maxfraglen, fragheaderlen, fraggap;

	if (inet->hdrincl)
		return -EPERM;

	if (flags&MSG_PROBE)
		return 0;

	if (skb_queue_empty(&sk->sk_write_queue))
		return -EINVAL;

	rt = inet->cork.rt;
	if (inet->cork.flags & IPCORK_OPT)
		opt = inet->cork.opt;

	if (!(rt->u.dst.dev->features&NETIF_F_SG))
		return -EOPNOTSUPP;

	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
	mtu = inet->cork.fragsize;

	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;

	if (inet->cork.length + size > 0xFFFF - fragheaderlen) {
		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu);
		return -EMSGSIZE;
	}

	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
		return -EINVAL;

	inet->cork.length += size;
	if ((sk->sk_protocol == IPPROTO_UDP) &&
	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
	}


	while (size > 0) {
		int i;

		if (skb_is_gso(skb))
			len = size;
		else {

			/* Check if the remaining data fits into current packet. */
			len = mtu - skb->len;
			if (len < size)
				len = maxfraglen - skb->len;
		}
		if (len <= 0) {
			struct sk_buff *skb_prev;
			char *data;
			struct iphdr *iph;
			int alloclen;

			skb_prev = skb;
			fraggap = skb_prev->len - maxfraglen;

			alloclen = fragheaderlen + hh_len + fraggap + 15;
			skb = sock_wmalloc(sk, alloclen, 1, sk->sk_allocation);
			if (unlikely(!skb)) {
				err = -ENOBUFS;
				goto error;
			}

			/*
			 *	Fill in the control structures
			 */
			skb->ip_summed = CHECKSUM_NONE;
			skb->csum = 0;
			skb_reserve(skb, hh_len);

			/*
			 *	Find where to start putting bytes.
			 */
			data = skb_put(skb, fragheaderlen + fraggap);
			skb->nh.iph = iph = (struct iphdr *)data;
			data += fragheaderlen;
			skb->h.raw = data;

			if (fraggap) {
				skb->csum = skb_copy_and_csum_bits(
					skb_prev, maxfraglen,
					data, fraggap, 0);
				skb_prev->csum = csum_sub(skb_prev->csum,
							  skb->csum);
----->				pskb_trim_unique(skb_prev, maxfraglen);

				

-- 
Stephen Hemminger <shemminger@osdl.org>
