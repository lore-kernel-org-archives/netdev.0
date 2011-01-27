From: Julia Lawall <julia@diku.dk>
Subject: question about nla_nest_cancel
Date: Thu, 27 Jan 2011 18:08:34 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1101271804530.13796@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:44337 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab1A0RIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 12:08:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find numerous occurrences of code like the following, in which nest ends 
up with the value NULL and then nla_nest_cancel is called with nest as the 
second argument.  But nla_nest_cancel just calls nlmsg_trim with the same 
second argument, and nlmsg_trim does nothing if its second argument is 
NULL.  Is there any reason to keep these calls?

thanks,
julia



static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
{
	struct tbf_sched_data *q = qdisc_priv(sch);
	struct nlattr *nest;
	struct tc_tbf_qopt opt;

	nest = nla_nest_start(skb, TCA_OPTIONS);
	if (nest == NULL)
		goto nla_put_failure;

	opt.limit = q->limit;
	opt.rate = q->R_tab->rate;
	if (q->P_tab)
		opt.peakrate = q->P_tab->rate;
	else
		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
	opt.mtu = q->mtu;
	opt.buffer = q->buffer;
	NLA_PUT(skb, TCA_TBF_PARMS, sizeof(opt), &opt);

	nla_nest_end(skb, nest);
	return skb->len;

nla_put_failure:
	nla_nest_cancel(skb, nest);
	return -1;
}
