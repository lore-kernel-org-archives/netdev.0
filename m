From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Tue, 10 Feb 2015 04:54:56 -0800
Message-ID: <1423572896.28434.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	 <1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	 <1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	 <1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	 <1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	 <1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
	 <1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=u_xPuqTVOVaFTQNRrJ+UTXe89SY+=+7Y1LpxxrkRDfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:42420 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbbBJMzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 07:55:01 -0500
In-Reply-To: <CA+BoTQ=u_xPuqTVOVaFTQNRrJ+UTXe89SY+=+7Y1LpxxrkRDfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-10 at 11:33 +0100, Michal Kazior wrote:

> +       if (msdu->sk) {
> +               ewma_add(&ar->tx_delay_us,
> +                        ktime_to_ns(ktime_sub(ktime_get(), skb_cb->stamp)) /
> +                        NSEC_PER_USEC);
> +
> +               ACCESS_ONCE(msdu->sk->sk_tx_completion_delay_cushion) =
> +                               (ewma_read(&ar->tx_delay_us) *
> +                                msdu->sk->sk_pacing_rate) >> 20;
> +       }
> +

Hi Michal

This is almost it ;)

As I said you must do this using u64 arithmetics, we still support 32bit
kernels.

Also, >> 20 instead of / 1000000 introduces a 5% error, I would use a
plain divide, as the compiler will use a reciprocal divide (ie : a
multiply)

We use >> 10 instead of /1000 because a 2.4 % error is probably okay.

        ewma_add(&ar->tx_delay_us,
                 ktime_to_ns(ktime_sub(ktime_get(),
skb_cb->stamp)) /
	                        NSEC_PER_USEC);
	u64 val = (u64)ewma_read(&ar->tx_delay_us) *
                   msdu->sk->sk_pacing_rate;

	do_div(val, USEC_PER_SEC);
		
        ACCESS_ONCE(msdu->sk->sk_tx_completion_delay_cushion) =
                    (u32)val;
                 
(WRITE_ONCE() would be better for new kernels, but ACCESS_ONCE() is ok
since we probably want to backport to stable kernels)


Thanks
