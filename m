From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 2/2] eHEA: Receive SKB Aggregation
Date: Thu, 5 Jul 2007 12:20:56 +0400
Message-ID: <20070705082056.GA358@2ka.mipt.ru>
References: <200707050926.30468.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56450 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784AbXGEIVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 04:21:07 -0400
Content-Disposition: inline
In-Reply-To: <200707050926.30468.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan-Bernd.

[ Dropped spambot/i.e. unrelated mail lists ]

On Thu, Jul 05, 2007 at 09:26:30AM +0200, Jan-Bernd Themann (ossthema@de.ibm.com) wrote:
> This patch enables the receive side processing to aggregate TCP packets within
> the HEA device driver. It analyses the packets already received after an
> interrupt arrived and forwards these as chains of SKBs for the same TCP
> connection with modified header field. We have seen a lower CPU load and
> improved throughput for small numbers of parallel TCP connections.
> As this feature is considered as experimental it is switched off by default
> and can be activated via a module parameter.

I've couple of comments on the driver, but mainly the fact of decreased
CPU usage itself - what was the magnitude of the win with this driver,
it looks like because of per-packet receive code path invocation is the
place of the latency...
Your implementation looks generic enough to be used by any driver, don't
you want to push it separately from eHEA driver?


> +static int lro_tcp_check(struct iphdr *iph, struct tcphdr *tcph,
> +			 int tcp_data_len, struct ehea_lro *lro)
> +{
> +	if (tcp_data_len == 0)
> +		return -1;
> +
> +	if (iph->ihl != IPH_LEN_WO_OPTIONS)
> +		return -1;
> +
> +	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack || tcph->psh
> +	    || tcph->rst || tcph->syn || tcph->fin)
> +		return -1;
> +
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
> +				   | (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP))
> +			return -1;
> +
> +		/* timestamp should be in right order */
> +		topt++;
> +		if (lro && (ntohl(lro->tcp_rcv_tsval) > ntohl(*topt)))
> +			return -1;

This should use before/after technique like PAWS in TCP code or there will be a
problem with wrapper timestamps.

> +
> +		/* timestamp reply should not be zero */
> +		topt++;
> +		if (*topt == 0)
> +			return -1;
> +	}
> +
> +	return 0;
> +}
> +
> +static void update_tcp_ip_header(struct ehea_lro *lro)
> +{
> +	struct iphdr *iph = lro->iph;
> +	struct tcphdr *tcph = lro->tcph;
> +	u32 *p;
> +
> +	tcph->ack_seq = lro->tcp_ack;
> +	tcph->window = lro->tcp_window;
> +
> +	if (lro->tcp_saw_tstamp) {
> +		p = (u32 *)(tcph + 1);
> +		*(p+2) = lro->tcp_rcv_tsecr;
> +	}
> +
> +	iph->tot_len = htons(lro->ip_tot_len);
> +	iph->check = 0;
> +	iph->check = ip_fast_csum((u8 *)lro->iph, iph->ihl);
> +}
> +
> +static void init_lro_desc(struct ehea_lro *lro, struct ehea_cqe *cqe,
> +			  struct sk_buff *skb, struct iphdr *iph,
> +			  struct tcphdr *tcph, u32 tcp_data_len)
> +{
> +	u32 *ptr;
> +
> +	lro->parent = skb;
> +	lro->iph = iph;
> +	lro->tcph = tcph;
> +	lro->tcp_next_seq = ntohl(tcph->seq) + tcp_data_len;
> +	lro->tcp_ack = ntohl(tcph->ack_seq);

How do you handle misordering or duplicate acks or resends?

> +	lro->skb_sg_cnt = 1;
> +	lro->ip_tot_len = ntohs(iph->tot_len);
> +
> +	if (tcph->doff == 8) {
> +		ptr = (u32 *)(tcph+1);
> +		lro->tcp_saw_tstamp = 1;
> +		lro->tcp_rcv_tsval = *(ptr+1);
> +		lro->tcp_rcv_tsecr = *(ptr+2);
> +	}
> +
> +	if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) {
> +		lro->vlan_packet = 1;
> +		lro->vlan_tag = cqe->vlan_tag;
> +	}
> +
> +	lro->active = 1;
> +}

-- 
	Evgeniy Polyakov
