From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: [PATCH 06/16] tcp: Move timestamps from inetpeer to metrics cache.
Date: Wed, 11 Jul 2012 00:14:50 +0800
Message-ID: <CAF1ivSZ--OKqu-PgTf82Rho4N8tUn+HCaDuh5V4p89KusHauWQ@mail.gmail.com>
References: <20120710.080726.1369956163447074824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:60859 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753794Ab2GJQPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 12:15:22 -0400
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id D8CD4DBC4A
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 00:14:53 +0800 (CST)
Received: by vcbf11 with SMTP id f11so125839vcb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 09:14:50 -0700 (PDT)
In-Reply-To: <20120710.080726.1369956163447074824.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 10, 2012 at 11:07 PM, David Miller <davem@davemloft.net> wrote:

> +
> +/* VJ's idea. Save last timestamp seen from this destination and hold
> + * it at least for normal timewait interval to use for duplicate
> + * segment detection in subsequent connections, before they enter
> + * synchronized state.
> + */
> +bool tcp_remember_stamp(struct sock *sk)
> +{
> +       struct dst_entry *dst = __sk_dst_get(sk);
> +       bool ret = false;
> +
> +       if (dst) {
> +               struct tcp_metrics_block *tm;
> +
> +               rcu_read_lock();
> +               tm = tcp_get_metrics(sk, dst, true);
> +               if (tm) {
> +                       struct tcp_sock *tp = tcp_sk(sk);
> +
> +                       if ((s32)(tm->tcpm_ts - tp->rx_opt.ts_recent) <= 0 ||
> +                           ((u32)get_seconds() - tm->tcpm_ts_stamp > TCP_PAWS_MSL &&
> +                            tm->tcpm_ts_stamp <= (u32)tp->rx_opt.ts_recent_stamp)) {
> +                               tm->tcpm_ts_stamp = (u32)tp->rx_opt.ts_recent_stamp;
> +                               tm->tcpm_ts = tp->rx_opt.ts_recent;
> +                       }
> +                       ret = true;
> +               }
> +               rcu_read_unlock();
> +       }

A trivial thing when "git am" this patch.

ERROR: trailing whitespace
#315: FILE: net/ipv4/tcp_metrics.c:595:
+^I}^I^I$

Regards,
Lin Ming

> +       return ret;
> +}
