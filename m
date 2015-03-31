From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Tue, 31 Mar 2015 13:08:31 +0200
Message-ID: <1427800111.2057.18.camel@sipsolutions.net>
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
	 <CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
	 <1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com>
	 <1423147286.31870.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=WaKLV=r6qWaWAEfyDr2pqMWpm4NDmnek92TEVndnxRQ@mail.gmail.com>
	 <1423230001.31870.128.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423230785.31870.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkazCOin7VWLfrHUjtgKDPV6T+sFsk5FPS7D-morr4FZQ@mail.gmail.com>
	 <CA+BoTQn3KRym0qCJ+fLav5LQgjfiN_-Eqz0xPSc2eXJ-ijNjQw@mail.gmail.com>
	 <1423494690.31870.189.camel@edumazet-glaptop2.roam.corp.google.com>
	 (sfid-20150209_161141_280698_3CDB7CE7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Kazior <michal.kazior@tieto.com>,
	Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52040 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753751AbbCaLIh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 07:08:37 -0400
In-Reply-To: <1423494690.31870.189.camel@edumazet-glaptop2.roam.corp.google.com> (sfid-20150209_161141_280698_3CDB7CE7)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To revive an old thread ...

On Mon, 2015-02-09 at 07:11 -0800, Eric Dumazet wrote:


> Ideally the formula would be in TCP something very fast to compute :
> 
> amount = (sk->sk_pacing_rate >> 10) + sk->tx_completion_delay_cushion;
> limit = max(2 * skb->truesize, amount);
> limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
> 
> So a 'problematic' driver would have to do the math (64 bit maths) like
> this :
> 
> 
> sk->tx_completion_delay_cushion = ewma_tx_delay * sk->sk_pacing_rate;

The whole notion with "ewma_tx_delay" seems very wrong to me. Measuring
something while also trying to control it (or something closely related)
seems a bit strange, but perhaps you meant to measure something
different than what Michal implemented.

What he implemented was measuring the time it takes from submission to
the hardware queues, but that seems to create a bad feedback cycle:
Allowing it as extra transmit "cushion" will, IIUC, cause TCP to submit
more data to the queues, which will in turn cause the next packets to be
potentially delayed more (since there are still waiting ones) thus
causing a longer delay to be measured, which in turn allows even more
data to be submitted etc.

IOW, while traffic is flowing this will likely cause feedback that
completely removes the point of this, no? Leaving only
sysctl_tcp_limit_output_bytes as the limit (*).

It seems it'd be better to provide a calculated estimate, perhaps based
on current transmit rate and (if available) CCA/TXOP acquisition time.

johannes

(*) Which, btw, isn't all that big given that a maximally sized A-MPDU
is like 1MB containing close to that much actual data! Don't think that
can actually be done at current transmit rates though.
