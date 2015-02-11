From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Wed, 11 Feb 2015 09:33:34 +0100
Message-ID: <CA+BoTQkRp38nttSJgKs4dzQrn-TXpPbh4i-01YCF0BJQWrFi=Q@mail.gmail.com>
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
	<1423574079.28434.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:46086 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbbBKIdp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 03:33:45 -0500
Received: by mail-wg0-f44.google.com with SMTP id z12so1880403wgg.3
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 00:33:43 -0800 (PST)
In-Reply-To: <1423574079.28434.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 February 2015 at 14:14, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> On Tue, 2015-02-10 at 11:33 +0100, Michal Kazior wrote:
>>                            ath10k_core_napi_dummy_poll, 64);
>> +       ewma_init(&ar->tx_delay_us, 16384, 8);
>
>
> 1) 16384 factor might be too big.
>
> 2) a weight of 8 seems too low given aggregation values used in wifi.
>
> On 32bit arches, the max range for ewma value would be 262144 usec,
> a quarter of a second...
>
> You could use a factor of 64 instead, and a weight of 16.

64/16 seems to work fine as well.

On a related note: I still wonder how to get single TCP flow to reach
line rate with ath10k (it still doesn't; I reach line rate with
multiple flows only). Isn't the tcp_limit_output_bytes just too small
for devices like Wi-Fi where you can send aggregates of even 64*3*1500
bytes long in a single shot and you can't expect even a single
tx-completion of it to come in before its transmitted entirely? You
effectively operate with bursts of traffic.

Some numbers:
 ath10k w/o cushion w/o aggregation 1 flow: UDP 65mbps, TCP 30mbps
 ath10k w/ cushion w/o aggregation 1 flow: UDP 65mbps, TCP 59mbps
 ath10k w/o cushion w/ aggregation 1 flow: UDP 650mbps, TCP 250mbps
 ath10k w/ cushion w/ aggregation 1 flow: UDP 650mbps, TCP 250mbps
 ath10k w/o cushion w/ aggregation 5 flows: UDP 650mbps, TCP 250mbps
 ath10k w/ cushion w/ aggregation 5 flows: UDP 650mbps, TCP 600mbps

"w/o aggregation" means forcing ath10k to use 1 A-MSDU and 1 A-MPDU
per aggregate so latencies due to aggregation itself should be pretty
much nil.

If I set tcp_limit_output_bytes to 700K+ I can get ath10k w/ cushion
w/ aggregation to reach 600mbps on a single flow.


Micha=C5=82
