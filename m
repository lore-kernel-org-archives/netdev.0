From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set was
 called
Date: Wed, 14 Aug 2013 16:52:34 +0800
Message-ID: <520B4552.2000607@windriver.com>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com> <1375866296-15079-2-git-send-email-fan.du@windriver.com> <52021177.6020306@redhat.com> <520213F2.5090401@windriver.com> <520214C6.6000307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Daniel Borkmann <dborkman@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: <tglx@linutronix.de>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <520214C6.6000307@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From e3929d4fdfad5b40fd8cad0e217597670d1aef54 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Wed, 14 Aug 2013 16:39:23 +0800
Subject: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set =
was called

When clock_was_set is called in case of system wall time change
or host resume from suspend state, use this notifier for places
where interested in this action, e.g Ipsec SA lifetime management.

Signed-off-by: Fan Du <fan.du@windriver.com>

v3:
   -Beautify notifier with register/unregister API exported for other s=
ubsystem.

---
  include/linux/hrtimer.h |    3 +++
  kernel/hrtimer.c        |   19 +++++++++++++++++++
  2 files changed, 22 insertions(+)

diff --git a/include/linux/hrtimer.h b/include/linux/hrtimer.h
index d19a5c2..f0404e4 100644
--- a/include/linux/hrtimer.h
+++ b/include/linux/hrtimer.h
@@ -461,4 +461,7 @@ extern u64 ktime_divns(const ktime_t kt, s64 div);
  /* Show pending timers: */
  extern void sysrq_timer_list_show(void);

+extern int register_clock_change_notifier(struct notifier_block *nb);
+extern int unregister_clock_change_notifier(struct notifier_block *nb)=
;
+
  #endif
diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
index 383319b..c6e6405 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -755,6 +755,24 @@ static inline void retrigger_next_event(void *arg)=
 { }

  #endif /* CONFIG_HIGH_RES_TIMERS */

+static ATOMIC_NOTIFIER_HEAD(clock_change_notifier_list);
+static int call_clock_change_notifiers(void)
+{
+	return atomic_notifier_call_chain(&clock_change_notifier_list, 0, 0);
+}
+
+int register_clock_change_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&clock_change_notifier_list, nb=
);
+}
+EXPORT_SYMBOL_GPL(register_clock_change_notifier);
+
+int unregister_clock_change_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&clock_change_notifier_list, =
nb);
+}
+EXPORT_SYMBOL_GPL(unregister_clock_change_notifier);
+
  /*
   * Clock realtime was set
   *
@@ -773,6 +791,7 @@ void clock_was_set(void)
  	on_each_cpu(retrigger_next_event, NULL, 1);
  #endif
  	timerfd_clock_was_set();
+	call_clock_change_notifiers();
  }

  /*
--=20
1.7.9.5


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
