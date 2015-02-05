From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Thu, 5 Feb 2015 14:44:01 +0100
Message-ID: <CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:46204 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757688AbbBENoD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:44:03 -0500
Received: by mail-we0-f172.google.com with SMTP id x3so2215396wes.3
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:44:01 -0800 (PST)
In-Reply-To: <1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5 February 2015 at 14:19, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Thu, 2015-02-05 at 04:57 -0800, Eric Dumazet wrote:
>
>> The intention is to control the queues to the following :
>>
>> 1 ms of buffering, but limited to a configurable value.
>>
>> On a 40Gbps flow, 1ms represents 5 MB, which is insane.
>>
>> We do not want to queue 5 MB of traffic, this would destroy latencie=
s
>> for all concurrent flows. (Or would require having fq_codel or fq as
>> packet schedulers, instead of default pfifo_fast)
>>
>> This is why having 1.5 ms delay between the transmit and TX completi=
on
>> is a problem in your case.

I do get your point. But 1.5ms is really tough on Wi-Fi.

Just look at this:

; ping 192.168.1.2 -c 3
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=3D1 ttl=3D64 time=3D1.83 ms
64 bytes from 192.168.1.2: icmp_seq=3D2 ttl=3D64 time=3D2.02 ms
64 bytes from 192.168.1.2: icmp_seq=3D3 ttl=3D64 time=3D1.98 ms

; ping 192.168.1.2 -c 3 -Q 224
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=3D1 ttl=3D64 time=3D0.939 ms
64 bytes from 192.168.1.2: icmp_seq=3D2 ttl=3D64 time=3D0.906 ms
64 bytes from 192.168.1.2: icmp_seq=3D3 ttl=3D64 time=3D0.946 ms

This was run with no load so batching code in the driver itself should
have no measurable effect. The channel was near-ideal: low noise
floor, cabled rf, no other traffic.

The lower latency ping is when 802.11 QoS Voice Access Category is
used. I also get 400mbps instead of 250mbps in this case with 5 flows
(net/master).

Dealing with black box firmware blobs is a pain.


> Note that TCP stack could detect when this happens, *if* ACK where
> delivered before the TX completions, or when TX completion happens,
> we could detect that the clone of the freed packet was freed.
>
> In my test, when I did "ethtool -C eth0 tx-usecs 1024 tx-frames 64", =
and
> disabling GSO, TCP stack sends a bunch of packets (a bit less than 64=
),
> blocks on tcp_limit_output_bytes.
>
> Then we receive 2 stretch ACKS after ~50 usec.
>
> TCP stack tries to push again some packets but blocks on
> tcp_limit_output_bytes again.
>
> 1ms later, TX completion happens, tcp_wfree() is called, and TCP stac=
k
> push following ~60 packets.
>
>
> TCP could  eventually dynamically adjust the tcp_limit_output_bytes,
> using a per flow dynamic value, but I would rather not add a kludge i=
n
> TCP stack only to deal with a possible bug in ath10k driver.
>
> niu has a similar issue and simply had to call skb_orphan() :
>
> drivers/net/ethernet/sun/niu.c:6669:            skb_orphan(skb);

Ok. I tried calling skb_orphan() right after I submit each Tx frame
(similar to niu which does this in start_xmit):

--- a/drivers/net/wireless/ath/ath10k/htt_tx.c
+++ b/drivers/net/wireless/ath/ath10k/htt_tx.c
@@ -564,6 +564,8 @@ int ath10k_htt_tx(struct ath10k_htt *htt, struct
sk_buff *msdu)
        if (res)
                goto err_unmap_msdu;

+       skb_orphan(msdu);
+
        return 0;

 err_unmap_msdu:


Now, with {net/master + ath10k GRO + the above} I get 620mbps on a
single flow (even better then before). Wow.

Does this look ok/safe as a solution to you?


Micha=C5=82
