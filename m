From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC 1/3] lro: Generic LRO for TCP traffic
Date: Thu, 12 Jul 2007 12:01:38 +0400
Message-ID: <20070712080137.GA25699@2ka.mipt.ru>
References: <200707111621.34376.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:32879 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757537AbXGLJ7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 05:59:08 -0400
Content-Disposition: inline
In-Reply-To: <200707111621.34376.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Jan-Bernd.

I have couple of comments over implementation besides one you saw
previous time.

On Wed, Jul 11, 2007 at 04:21:34PM +0200, Jan-Bernd Themann (ossthema@de.ibm.com) wrote:
> +static int lro_tcp_ip_check(struct sk_buff *skb, struct iphdr *iph,
> +			    struct tcphdr *tcph, struct net_lro_desc *lro_desc)
> +{
> +        /* check ip header: packet length */
> +        if (ntohs(iph->tot_len) > skb->len)
> +		return -1;
> +
> +	if (TCP_PAYLOAD_LENGTH(iph, tcph) == 0)
> +		return -1;
> +
> +	if (iph->ihl != IPH_LEN_WO_OPTIONS)
> +		return -1;
> +
> +	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack || tcph->psh
> +	    || tcph->rst || tcph->syn || tcph->fin)
> +		return -1;

I think you do not want to break lro frame because of push flag - it is
pretty common flag, which does not brak processing (and I'm not sure if
it has any special meaning this days).

> +	if (INET_ECN_is_ce(ipv4_get_dsfield(iph)))
> +		return -1;
> +
> +	if (tcph->doff != TCPH_LEN_WO_OPTIONS
> +	    && tcph->doff != TCPH_LEN_W_TIMESTAMP)
> +		return -1;
> +
> +	/* check tcp options (only timestamp allowed) */
> +	if (tcph->doff == TCPH_LEN_W_TIMESTAMP) {
> +		u32 *topt = (u32 *)(tcph + 1);
> +
> +		if (*topt != htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
> +				   | (TCPOPT_TIMESTAMP << 8)
> +				   | TCPOLEN_TIMESTAMP))
> +			return -1;
> +
> +		/* timestamp should be in right order */
> +		topt++;
> +		if (lro_desc && (ntohl(lro_desc->tcp_rcv_tsval) > ntohl(*topt)))
> +			return -1;

This still does not handle wrapping over 32 bits.
What about
if (lro_desc && after(ntohl(lro_desc->tcp_rcv_tsval), ntohl(*topt)))
	return -1;

> +		/* timestamp reply should not be zero */
> +		topt++;
> +		if (*topt == 0)
> +			return -1;
> +	}
> +
> +	return 0;
> +}

> +static struct net_lro_desc *lro_get_desc(struct net_lro_mgr *mgr,
> +					 struct net_lro_desc *lro_arr,
> +					 struct iphdr *iph,
> +					 struct tcphdr *tcph)
> +{
> +	struct net_lro_desc *lro_desc = NULL;
> +	struct net_lro_desc *tmp;
> +	int max_desc = mgr->max_desc;
> +	int i;
> +
> +	for (i = 0; i < max_desc; i++) {
> +		tmp = &lro_arr[i];
> +		if (tmp->active)
> +			if (!lro_check_tcp_conn(tmp, iph, tcph)) {
> +				lro_desc = tmp;
> +				goto out;
> +			}
> +	}

Ugh... What about tree structure or hash here?

> +	for (i = 0; i < max_desc; i++) {
> +		if(!lro_arr[i].active) {
> +			lro_desc = &lro_arr[i];
> +			goto out;
> +		}
> +	}
> +
> +out:
> +	return lro_desc;
> +}

> +int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
> +		   struct vlan_group *vgrp, u16 vlan_tag, void *priv)
> +{
> +	struct net_lro_desc *lro_desc;
> +        struct iphdr *iph;
> +        struct tcphdr *tcph;
> +
> +	if (!lro_mgr->get_ip_tcp_hdr
> +	    || lro_mgr->get_ip_tcp_hdr(skb, &iph, &tcph, priv))
> +		goto out;
> +
> +	lro_desc = lro_get_desc(lro_mgr, lro_mgr->lro_arr, iph, tcph);
> +	if (!lro_desc)
> +		goto out;

There is no protection of the descriptor array from accessing from
different CPUs. Is it forbidden to share net_lro_mgr structure?

-- 
	Evgeniy Polyakov
