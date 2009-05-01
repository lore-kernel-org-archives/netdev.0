From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter: use likely()  in xt_info_rdlock_bh()
Date: Fri, 01 May 2009 10:38:20 +0200
Message-ID: <49FAB4FC.6040907@cosmosbay.com>
References: <20090428092411.5331c4a1@nehalam>	<alpine.LFD.2.00.0904280931360.22156@localhost.localdomain>	<alpine.LFD.2.00.0904280954500.22156@localhost.localdomain> <20090428.223708.168741998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090428.223708.168741998.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Tue, 28 Apr 2009 09:55:32 -0700 (PDT)
>=20
>> On Tue, 28 Apr 2009, Linus Torvalds wrote:
>>> Ack.=20
>>>
>>> It could do with the update from Eric about how non-current CPU wri=
telocks=20
>>> only require preemp-disable around get_counters() (and then the=20
>>> local_bh_disable() only around the current-CPU case).
>> Btw, regardless, that's an incremental improvement, and does not neg=
ate=20
>> the "Ack" part.
>=20
> I've applied this, thanks everyone!

Small followup on this one, since the likely() were forgotten.
(I trimmed down CCed list, which was insane)

It makes a difference on my x86_32 machine, gcc-4.4.0

Thank you

[PATCH] netfilter: use likely() in xt_info_rdlock_bh()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilt=
er/x_tables.h
index 1b2e435..c9efe03 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -472,7 +472,7 @@ static inline void xt_info_rdlock_bh(void)
=20
 	local_bh_disable();
 	lock =3D &__get_cpu_var(xt_info_locks);
-	if (!lock->readers++)
+	if (likely(!lock->readers++))
 		spin_lock(&lock->lock);
 }
=20
@@ -480,7 +480,7 @@ static inline void xt_info_rdunlock_bh(void)
 {
 	struct xt_info_lock *lock =3D &__get_cpu_var(xt_info_locks);
=20
-	if (!--lock->readers)
+	if (likely(!--lock->readers))
 		spin_unlock(&lock->lock);
 	local_bh_enable();
 }

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
