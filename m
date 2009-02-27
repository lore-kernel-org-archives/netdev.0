From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] iptables: lock free counters
Date: Fri, 27 Feb 2009 15:02:10 +0100
Message-ID: <49A7F262.8040805@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499DEF49.3040602@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Stephen Hemminger a =E9crit :
>> The reader/writer lock in ip_tables is acquired in the critical path=
 of
>> processing packets and is one of the reasons just loading iptables c=
an cause
>> a 20% performance loss. The rwlock serves two functions:
>>
>> 1) it prevents changes to table state (xt_replace) while table is in=
 use.
>>    This is now handled by doing rcu on the xt_table. When table is
>>    replaced, the new table(s) are put in and the old one table(s) ar=
e freed
>>    after RCU period.
>>
>> 2) it provides synchronization when accesing the counter values.
>>    This is now handled by swapping in new table_info entries for eac=
h cpu
>>    then summing the old values, and putting the result back onto one
>>    cpu.  On a busy system it may cause sampling to occur at differen=
t
>>    times on each cpu, but no packet/byte counts are lost in the proc=
ess.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Sucessfully tested on my dual quad core machine too, but iptables onl=
y (no ipv6 here)
>=20
> BTW, my new "tbench 8" result is 2450 MB/s, (it was 2150 MB/s not so =
long ago)
>=20
> Thanks Stephen, thats very cool stuff, yet another rwlock out of kern=
el :)
>

While testing multicast flooding stuff, I found that "iptables -nvL" ca=
n=20
have a *very* slow response time on my dual quad core machine...

   LatencyTOP version 0.5       (C) 2008 Intel Corporation

Cause                                                Maximum     Percen=
tage
synchronize_rcu synchronize_net do_ipt_get_ctl nf_1878.6 msec          =
3.1 %
Scheduler: waiting for cpu                        160.3 msec         13=
=2E6 %
do_get_write_access journal_get_write_access __ext 11.0 msec          0=
=2E0 %
do_get_write_access journal_get_write_access __ext  7.7 msec          0=
=2E0 %
poll_schedule_timeout do_select core_sys_select sy  4.9 msec          0=
=2E0 %
do_wait sys_wait4 sys_waitpid sysenter_do_call      3.4 msec          0=
=2E1 %
call_usermodehelper_exec request_module netlink_cr  1.6 msec          0=
=2E0 %
__skb_recv_datagram skb_recv_datagram raw_recvmsg   1.5 msec          0=
=2E0 %
do_wait sys_wait4 sysenter_do_call                  0.7 msec          0=
=2E0 %


# time iptables -nvL
Chain INPUT (policy ACCEPT 416M packets, 64G bytes)
 pkts bytes target     prot opt in     out     source               des=
tination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               des=
tination

Chain OUTPUT (policy ACCEPT 401M packets, 62G bytes)
 pkts bytes target     prot opt in     out     source               des=
tination

real    0m1.810s
user    0m0.000s
sys     0m0.001s


CONFIG_NO_HZ=3Dy
CONFIG_HZ_1000=3Dy
CONFIG_HZ=3D1000

One cpu is 100% handling softirqs, could it be the problem ?

Cpu0  :  1.0%us, 14.7%sy,  0.0%ni, 83.3%id,  0.0%wa,  0.0%hi,  1.0%si, =
 0.0%st
Cpu1  :  3.6%us, 23.2%sy,  0.0%ni, 71.6%id,  0.0%wa,  0.0%hi,  1.7%si, =
 0.0%st
Cpu2  :  0.0%us,  0.0%sy,  0.0%ni,  0.0%id,  0.0%wa,  0.0%hi,100.0%si, =
 0.0%st
Cpu3  :  2.7%us, 23.9%sy,  0.0%ni, 71.1%id,  0.7%wa,  0.0%hi,  1.7%si, =
 0.0%st
Cpu4  :  1.3%us, 14.3%sy,  0.0%ni, 83.3%id,  0.0%wa,  0.0%hi,  1.0%si, =
 0.0%st
Cpu5  :  1.0%us, 14.2%sy,  0.0%ni, 83.4%id,  0.0%wa,  0.0%hi,  1.3%si, =
 0.0%st
Cpu6  :  0.3%us,  7.0%sy,  0.0%ni, 92.4%id,  0.0%wa,  0.0%hi,  0.3%si, =
 0.0%st
Cpu7  :  0.7%us,  8.0%sy,  0.0%ni, 90.0%id,  0.7%wa,  0.0%hi,  0.7%si, =
 0.0%st

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
