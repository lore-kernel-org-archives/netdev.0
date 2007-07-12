From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [RFC 1/3] lro: Generic LRO for TCP traffic
Date: Thu, 12 Jul 2007 13:54:42 +0200
Message-ID: <200707121354.43407.ossthema@de.ibm.com>
References: <200707111621.34376.ossthema@de.ibm.com> <20070712080137.GA25699@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:34999 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568AbXGLMUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 08:20:46 -0400
In-Reply-To: <20070712080137.GA25699@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy

On Thursday 12 July 2007 10:01, Evgeniy Polyakov wrote:

> > +
> > +	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack || tcph->psh
> > +	    || tcph->rst || tcph->syn || tcph->fin)
> > +		return -1;
> 
> I think you do not want to break lro frame because of push flag - it is
> pretty common flag, which does not brak processing (and I'm not sure if
> it has any special meaning this days).
> 
> > +	if (INET_ECN_is_ce(ipv4_get_dsfield(iph)))
> > +		return -1;
> > +
> > +	if (tcph->doff != TCPH_LEN_WO_OPTIONS
> > +	    && tcph->doff != TCPH_LEN_W_TIMESTAMP)
> > +		return -1;
> > +
> > +	/* check tcp options (only timestamp allowed) */
> > +	if (tcph->doff == TCPH_LEN_W_TIMESTAMP) {
> > +		u32 *topt = (u32 *)(tcph + 1);
> > +
> > +		if (*topt != htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
> > +				   | (TCPOPT_TIMESTAMP << 8)
> > +				   | TCPOLEN_TIMESTAMP))
> > +			return -1;
> > +
> > +		/* timestamp should be in right order */
> > +		topt++;
> > +		if (lro_desc && (ntohl(lro_desc->tcp_rcv_tsval) > ntohl(*topt)))
> > +			return -1;
> 
> This still does not handle wrapping over 32 bits.
> What about
> if (lro_desc && after(ntohl(lro_desc->tcp_rcv_tsval), ntohl(*topt)))
> 	return -1;

Looks good, will change that

> 
> > +		/* timestamp reply should not be zero */
> > +		topt++;
> > +		if (*topt == 0)
> > +			return -1;
> > +	}
> > +
> > +	return 0;
> > +}
> 
> > +static struct net_lro_desc *lro_get_desc(struct net_lro_mgr *mgr,
> > +					 struct net_lro_desc *lro_arr,
> > +					 struct iphdr *iph,
> > +					 struct tcphdr *tcph)
> > +{
> > +	struct net_lro_desc *lro_desc = NULL;
> > +	struct net_lro_desc *tmp;
> > +	int max_desc = mgr->max_desc;
> > +	int i;
> > +
> > +	for (i = 0; i < max_desc; i++) {
> > +		tmp = &lro_arr[i];
> > +		if (tmp->active)
> > +			if (!lro_check_tcp_conn(tmp, iph, tcph)) {
> > +				lro_desc = tmp;
> > +				goto out;
> > +			}
> > +	}
> 
> Ugh... What about tree structure or hash here?
Our initial version was based on the following assumptions (remember, 8 elements...):

- given a quota of 64 packets, it makes no sense to use huge arrays for LRO descriptors
  (in our case 8 elements seem to work fine).
- trying to benefit from caching effects+branch prediction,
  + use the built in cacheline prefetch

I guess the array mechanism can be improved (finding free entries), but for the
initial version to see how the rest of the stack behaves with LRO
it might be ok this way.

Do you think a tree or hash would improve this with existing 
caching designs (for a small number of elements)?

> 
> > +	for (i = 0; i < max_desc; i++) {
> > +		if(!lro_arr[i].active) {
> > +			lro_desc = &lro_arr[i];
> > +			goto out;
> > +		}
> > +	}
> > +
> > +out:
> > +	return lro_desc;
> > +}
> 
> > +int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
> > +		   struct vlan_group *vgrp, u16 vlan_tag, void *priv)
> > +{
> > +	struct net_lro_desc *lro_desc;
> > +        struct iphdr *iph;
> > +        struct tcphdr *tcph;
> > +
> > +	if (!lro_mgr->get_ip_tcp_hdr
> > +	    || lro_mgr->get_ip_tcp_hdr(skb, &iph, &tcph, priv))
> > +		goto out;
> > +
> > +	lro_desc = lro_get_desc(lro_mgr, lro_mgr->lro_arr, iph, tcph);
> > +	if (!lro_desc)
> > +		goto out;
> 
> There is no protection of the descriptor array from accessing from
> different CPUs. Is it forbidden to share net_lro_mgr structure?
> 

Currently we assume that netpoll runs with one device only on one cpu
at a time, and if there are multiple receive queues that can be processed
in parallel the traffic is usually sorted per receive queue. It would make
sense to use an own LRO "Manager" for each queue (would speed up the lookup)

Regards,
Jan-Bernd

