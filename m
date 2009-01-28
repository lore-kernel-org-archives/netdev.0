From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Wed, 28 Jan 2009 14:55:51 +0100
Message-ID: <498063E7.5030106@cosmosbay.com>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net> <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497F5F86.9010101@hp.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones a =E9crit :
>>> I will give it a try and let folks know the results - unless told
>>> otherwise, I will ass-u-me I only need rerun the "full_iptables" te=
st
>>> case.
>>
>>
>> The runemomniagg2.sh script is still running, but the initial cycles
>> profile suggests that the main change is converting the write_lock
>> time into spinlock contention time with 78.39% of the cycles spent i=
n
>> ia64_spinlock_contention. When the script completes I'll upload the
>> profiles and the netperf results to the same base URL as in the
>> basenote under "contrack01/"
>=20
> The script completed - although at some point I hit an fd limit - I
> think I have an fd leak in netperf somewhere :( .
>=20
> Anyhow, there are still some netperfs that end-up kicking the bucket
> during the run - I suspect starvation because where in the other conf=
igs
> (no iptables, and empty iptables) each netperf seems to consume about
> 50% of a CPU - stands to reason - 64 netperfs, 32 cores - in the "ful=
l"
> case I see many netperfs consuming 100% of a CPU.  My gut is thinking
> that one or more netperf contexts gets stuck doing something on behal=
f
> of others.  There is also ksoftirqd time for a few of those processes=
=2E
>=20
> Anyhow, the spread on trans/s/netperf is now 600 to 500 or 6000, whic=
h
> does represent an improvement.
>

Yes indeed you have a speedup, tcp conntracking is OK.

You now hit the nf_conntrack_lock spinlock we have in generic conntrack=
 code=20
(net/netfilter/nf_conntrack_core.c)

nf_ct_refresh_acct() for instance has to lock it.

We really want some finer locking here.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
