From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: relax rtnl_dereference()
Date: Mon, 04 Oct 2010 11:00:12 +0200
Message-ID: <1286182812.18293.22.camel@edumazet-laptop>
References: <1285689517.3154.76.camel@edumazet-laptop>
	 <20100928180447.GA1880@del.dom.local> <1285757817.3561.2.camel@bigi>
	 <1285887509.2705.33.camel@edumazet-laptop> <1285933506.3553.176.camel@bigi>
	 <1285941388.2641.175.camel@edumazet-laptop>
	 <20101002093255.GA2049@del.dom.local>
	 <1286035915.2582.2472.camel@edumazet-laptop>
	 <20101003094221.GA2028@del.dom.local>
	 <1286181729.18293.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40975 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757Ab0JDJAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 05:00:17 -0400
Received: by mail-fx0-f46.google.com with SMTP id 14so1554478fxm.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 02:00:16 -0700 (PDT)
In-Reply-To: <1286181729.18293.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 octobre 2010 =C3=A0 10:42 +0200, Eric Dumazet a =C3=A9crit =
:

> BTW, rtnl_dereference() should be changed to use
> rcu_dereference_protected() instead of rcu_dereference_check() :
> If RTBL is held, there is no need to force a barrier.
>=20

[PATCH net-next] net: relax rtnl_dereference()

rtnl_dereference() is used in contexts where RTNL is held, to fetch an
RCU protected pointer.
=20
Updates to this pointer are prevented by RTNL, so we dont need
smp_read_barrier_depends() and the ACCESS_ONCE() provided in
rcu_dereference_check().

rtnl_dereference() is mainly a macro to document the locking invariant.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/rtnetlink.h |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 68c436b..d3c4efa 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -754,20 +754,22 @@ extern int lockdep_rtnl_is_held(void);
  * @p: The pointer to read, prior to dereferencing
  *
  * Do an rcu_dereference(p), but check caller either holds rcu_read_lo=
ck()
- * or RTNL
+ * or RTNL. Note : Please prefer rtnl_dereference() or rcu_dereference=
()
  */
 #define rcu_dereference_rtnl(p)					\
 	rcu_dereference_check(p, rcu_read_lock_held() ||	\
 				 lockdep_rtnl_is_held())
=20
 /**
- * rtnl_dereference - rcu_dereference with debug checking
+ * rtnl_dereference - fetch RCU pointer when updates are prevented by =
RTNL
  * @p: The pointer to read, prior to dereferencing
  *
- * Do an rcu_dereference(p), but check caller holds RTNL
+ * Return the value of the specified RCU-protected pointer, but omit
+ * both the smp_read_barrier_depends() and the ACCESS_ONCE(), because
+ * caller holds RTNL.
  */
 #define rtnl_dereference(p)					\
-	rcu_dereference_check(p, lockdep_rtnl_is_held())
+	rcu_dereference_protected(p, lockdep_rtnl_is_held())
=20
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);


