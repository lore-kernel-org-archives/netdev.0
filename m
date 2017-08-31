From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH] net: frag limit checks need to use
 percpu_counter_compare
Date: Thu, 31 Aug 2017 08:58:02 -0700
Message-ID: <20170831085802.2d4cdc87@xeon-e3>
References: <150417481955.28907.15567119824187929000.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: liujian56@huawei.com, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35291 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751770AbdHaP6G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 11:58:06 -0400
Received: by mail-pf0-f171.google.com with SMTP id g13so131846pfm.2
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 08:58:06 -0700 (PDT)
In-Reply-To: <150417481955.28907.15567119824187929000.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Aug 2017 12:20:19 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> +static inline bool frag_mem_over_limit(struct netns_frags *nf, int thresh)
>  {
> -	return percpu_counter_read(&nf->mem);
> +	/* When reading counter here, __percpu_counter_compare() call
> +	 * will invoke __percpu_counter_sum() when needed.  Which
> +	 * depend on num_online_cpus()*batch size, as each CPU can
> +	 * potentential can hold a batch count.
> +	 *
> +	 * With many CPUs this heavier sum operation will
> +	 * unfortunately always occur.
> +	 */
> +	if (__percpu_counter_compare(&nf->mem, thresh,
> +				     frag_percpu_counter_batch) > 0)
> +		return true;
> +	else
> +		return false;

You don't need an if() here.

	return __percpu_counter_compare(&nf->mem, thresh,
				     frag_percpu_counter_batch) > 0;
