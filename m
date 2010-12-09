From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tc: show format ABI changed
Date: Thu, 9 Dec 2010 20:25:48 +0100
Message-ID: <20101209192548.GA1863@del.dom.local>
References: <20101208145136.1ca3ece4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58102 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983Ab0LITZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 14:25:54 -0500
Received: by wwa36 with SMTP id 36so2827121wwa.1
        for <netdev@vger.kernel.org>; Thu, 09 Dec 2010 11:25:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101208145136.1ca3ece4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 08, 2010 at 02:51:36PM -0800, Stephen Hemminger wrote:
> Although well intentioned, the following patch should have not
> been applied since it changes the kernel ABI. It broke some scripts
> parsing the output format of tc commands.

I doubt you can blame this patch for changing any ABI. If there is
such a thing documented you would probably point us there. Otherwise,
it should be seen in the code, and tc has it all conditional:

        if (tbs[TCA_STATS_RATE_EST]) {
		...
                fprintf(fp, "\n%srate %s %upps ",
                        prefix, sprint_rate(re.bps, b1), re.pps);
        }
=20
        if (tbs[TCA_STATS_QUEUE]) {
		...
                if (!tbs[TCA_STATS_RATE_EST])
                        fprintf(fp, "\n%s", prefix);
                fprintf(fp, "backlog %s %up requeues %u ",
                        sprint_size(q.backlog, b1), q.qlen, q.requeues)=
;
        }

which suggests scripts should use similar logic.

Anyway, these are tc's printouts and it should handle source data
errors too. Since it's accepted it can't be wrong ;-)

Jarek P.

>=20
> Before HTB would report bogus zero values, now it reports
> nothing and that changes the output format.  Like the empty
> fields in /proc, I argue we can't play fast and loose with
> netlink responses.
>=20
> Not a big deal to fix the script in this case, in this case
> so don't revert it.
>=20
> commit d250a5f90e53f5e150618186230795352d154c88
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Fri Oct 2 10:32:18 2009 +0000
>=20
>     pkt_sched: gen_estimator: Dont report fake rate estimators
>    =20
>     Jarek Poplawski a =E9crit :
>     >
>     >
>     > Hmm... So you made me to do some "real" work here, and guess wh=
at?:
>     > there is one serious checkpatch warning! ;-) Plus, this new par=
ameter
>     > should be added to the function description. Otherwise:
>     > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>     >
>     > Thanks,
>     > Jarek P.
>     >
>     > PS: I guess full "Don't" would show we really mean it...
>    =20
>     Okay :) Here is the last round, before the night !
>    =20
>     Thanks again
>    =20
>     [RFC] pkt_sched: gen_estimator: Don't report fake rate estimators
>    =20
>     We currently send TCA_STATS_RATE_EST elements to netlink users, e=
ven if no estimator
>     is running.
>    =20
>     # tc -s -d qdisc
>     qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 =
0 1 1 1 1 1 1 1 1
>      Sent 112833764978 bytes 1495081739 pkt (dropped 0, overlimits 0 =
requeues 0)
>      rate 0bit 0pps backlog 0b 0p requeues 0
>    =20
>     User has no way to tell if the "rate 0bit 0pps" is a real estimat=
ion, or a fake
>     one (because no estimator is active)
>    =20
>     After this patch, tc command output is :
>     $ tc -s -d qdisc
>     qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 =
0 1 1 1 1 1 1 1 1
>      Sent 561075 bytes 1196 pkt (dropped 0, overlimits 0 requeues 0)
>      backlog 0b 0p requeues 0
>    =20
>     We add a parameter to gnet_stats_copy_rate_est() function so that
>     it can use gen_estimator_active(bstats, r), as suggested by Jarek=
=2E
>    =20
>     This parameter can be NULL if check is not necessary, (htb for
>     example has a mandatory rate estimator)
>    =20
>     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>     Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
