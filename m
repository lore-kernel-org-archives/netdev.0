From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware	dropsrxpackets
Date: Fri, 15 May 2009 09:37:28 +0200
Message-ID: <4A0D1BB8.10204@cosmosbay.com>
References: <20090508195026.GB13017@hmsreliant.think-freely.org> <4A05230B.6070806@cosmosbay.com> <20090512163044.GD5019@hmsreliant.think-freely.org> <20090513182354.GH6752@linux.vnet.ibm.com> <20090514004548.GA14428@localhost.localdomain> <20090514010359.GL6752@linux.vnet.ibm.com> <20090514123300.GA7166@hmsreliant.think-freely.org> <20090514124407.GP3517@psychotron.englab.brq.redhat.com> <20090514172954.GA3867@hmsreliant.think-freely.org> <20090515065102.GB25620@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47289 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755927AbZEOHhy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 03:37:54 -0400
In-Reply-To: <20090515065102.GB25620@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko a =E9crit :
> Thu, May 14, 2009 at 07:29:54PM CEST, nhorman@tuxdriver.com wrote:
>> On Thu, May 14, 2009 at 02:44:08PM +0200, Jiri Pirko wrote:
>>>> +
>>>> +		/*
>>>> +		 * Clean the device list
>>>> +		 */
>>>> +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
>>> 		^^^^^^^^^^^^^^^^^^^^^^^
>>> This is meaningless here. Use list_for_each_entry_rcu only under rc=
u_read_lock.
>>> Also it would be good to use list_for_each_entry_safe here since yo=
u're
>>> modifying the list.
>>>
>> The definition of list_for_each_entry_rcu specifically says its safe=
 against
>> list-mutation primitives, so its fine.  Although you are correct, in=
 that its
>> safety is dependent on the protection of rcu_read_lock(), so I'll ad=
d that in.
>=20
> You are right that list_for_each_entry_rcu is safe against list-mutat=
ion
> primitives. But there's no need for this on the update side when you =
hold a writer
> spinlock. Here I think it's better (and also less confusing) to use o=
rdinary
> list_for_each_entry which in this case must be list_for_each_entry_sa=
fe.

Absolutely.

RCU is tricky, and must be well understood. Using the right verbs is re=
ally needed
to help everybody read the code and be able to understand it quickly an=
d maintain it
if needed.

In this particular case, the list_for_each_entry_rcu() is a litle bit m=
ore
expensive than regular list_for_each_entry(), as it includes additionna=
l barriers.

Just reading code like this :

+	spin_lock(&trace_state_lock);
+		rcu_read_lock();
+		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
+			if (new_stat->dev =3D=3D NULL) {
+				list_del_rcu(&new_stat->list);
+				call_rcu(&new_stat->rcu, free_dm_hw_stat);
+			}
+		}
+		rcu_read_unlock();
+	spin_unlock(&trace_state_lock);

We *know* something is wrong, as rcu_read_lock() is supposed to guard a=
 readside,
so having both rcu_read_lock() and list_del_rcu() is certainly wrong, w=
e dont have=20
to actually understand what is really done by the algorithm.

So following is much better : (but maybe not correct... I let you=20
check if list_for_each_entry_safe() would not be better here, since
you delete elements in a list while iterating in it)

Maybe you can add a break; after call_rcu() if you know only one elemen=
t
can match the "if (new_stat->dev =3D=3D NULL) " condition, and use norm=
al list_for_each_entry()

+	spin_lock(&trace_state_lock);
+		list_for_each_entry(new_stat, &hw_stats_list, list) {
+			if (new_stat->dev =3D=3D NULL) {
+				list_del_rcu(&new_stat->list);
+				call_rcu(&new_stat->rcu, free_dm_hw_stat);
+			}
+		}
+	spin_unlock(&trace_state_lock);

Even if the 'wrong' version was not buggy (no crashes or corruption), t=
he 'right' one
is a commonly used construct in kernel that most dev are able to read w=
ithout asking=20
themselves "is is correct or not ? Dont we have something strange here =
?"

Neil, you need to read more code playing with RCU to get familiar with =
it, we all did same
errors in the past :)


