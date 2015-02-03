From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Tue, 3 Feb 2015 12:50:59 +0100
Message-ID: <CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	<1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	<1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:46073 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250AbbBCLvB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 06:51:01 -0500
Received: by mail-wi0-f175.google.com with SMTP id fb4so23671078wid.2
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 03:51:00 -0800 (PST)
In-Reply-To: <1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 February 2015 at 02:18, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Mon, 2015-02-02 at 10:52 -0800, Eric Dumazet wrote:
>
>> It seems to break ACK clocking badly (linux stack has a somewhat bug=
gy
>> tcp_tso_should_defer(), which relies on ACK being received smoothly,=
 as
>> no timer is setup to split the TSO packet.)
>
> Following patch might help the TSO split defer logic.
>
> It would avoid setting the TSO defer 'pseudo timer' twice, if/when TC=
P
> Small Queue logic prevented the xmit at the expiration of first 'time=
r'.
>
> This patch clears the tso_deferred variable only if we could really
> send something.
>
> Please try it, thanks !
[..patch..]

I've done a second round of tests. I've added the A-MSDU count
parameter I've mentioned in my other email into the mix.

 net - net/master (includes stretch ack patches)
 net-tso - net/master + your TSO defer patch
 net-gro - net/master + my ath10k GRO patch
 net-gro-tso - net/master + duh

Here's the best of amsdu count 1 and 3:

 ; for (i in */output.txt) { echo $i; for (j in (1 3)) { cat $i | awk
'x && /Mbits/ {y=3D$0}; x && y && !/Mbits/ {print y; x=3D0; y=3D""}; /s=
et
amsdu cnt to '$j'/{x=3D1}' | awk '{ if (x < $(NF-1)) {x=3D$(NF-1)} }
END{print "A-MSDU limit=3D'$j', " x " Mbits/sec"}' } }
 net-gro-tso/output.txt
 A-MSDU limit=3D1, 436 Mbits/sec
 A-MSDU limit=3D3, 284 Mbits/sec
 net-gro/output.txt
 A-MSDU limit=3D1, 444 Mbits/sec
 A-MSDU limit=3D3, 283 Mbits/sec
 net-tso/output.txt
 A-MSDU limit=3D1, 376 Mbits/sec
 A-MSDU limit=3D3, 251 Mbits/sec
 net/output.txt
 A-MSDU limit=3D1, 387 Mbits/sec
 A-MSDU limit=3D3, 260 Mbits/sec

IOW:
 - stretch acks / TSO defer don't seem to help much (when compared to
throughput results from yesterday)
 - GRO helps
 - disabling A-MSDU on sender helps
 - net/master+GRO still doesn't reach the performance from before the
regression (~600mbps w/ GRO)

You can grab logs and dumps here: http://www.filedropper.com/test2tar


Micha=C5=82
