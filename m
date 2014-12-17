From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP Statistics (Web10G)
Date: Tue, 16 Dec 2014 19:44:17 -0800
Message-ID: <87y4q79bzi.fsf@tassilo.jf.intel.com>
References: <549070D3.5050808@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>
To: rapier <rapier@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37972 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbaLQDoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 22:44:18 -0500
In-Reply-To: <549070D3.5050808@psc.edu> (rapier@psc.edu's message of "Tue, 16
	Dec 2014 12:50:11 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rapier <rapier@psc.edu> writes:
> +
> +void tcp_estats_update_rtt(struct sock *sk, unsigned long rtt_sample)
> +{
> +	struct tcp_estats *stats = tcp_sk(sk)->tcp_stats;
> +	struct tcp_estats_path_table *path_table = stats->tables.path_table;
> +	unsigned long rtt_sample_msec = rtt_sample/1000;
> +	u32 rto;
> +
> +	if (path_table == NULL)
> +		return;
> +
> +	path_table->SampleRTT = rtt_sample_msec;
> +
> +	if (rtt_sample_msec > path_table->MaxRTT)
> +		path_table->MaxRTT = rtt_sample_msec;
> +	if (rtt_sample_msec < path_table->MinRTT)
> +		path_table->MinRTT = rtt_sample_msec;
> +
> +	path_table->CountRTT++;
> +	path_table->SumRTT += rtt_sample_msec;
> +
> +	rto = jiffies_to_msecs(inet_csk(sk)->icsk_rto);
> +	if (rto > path_table->MaxRTO)
> +		path_table->MaxRTO = rto;
> +	if (rto < path_table->MinRTO)
> +		path_table->MinRTO = rto;

Looking through your hooks it seem that many basically do simple
value profiling in a very open coded way.

Perhaps you could simplify things a lot by just having a couple of trace
points for these values (e.g. trace_change_rtt). Then have a library
of different data profiling types.

Then you could register a new value oriented trace point type with
different backend for whatever you currently need from the value: like
min/max/avg/ or full histogram or even reservoir sampling or EWMA.

I guess such a generic infrastructure would be useful elsewhere too.

One challenge would be how to associate such value profiles with
sockets, but I'm sure this could be done in some nice generic
way too.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
