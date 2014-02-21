From: Raffaello Secchi <r.secchi@gmail.com>
Subject: [PATCH] NewCWV for Linux
Date: Fri, 21 Feb 2014 14:42:02 +0000
Message-ID: <CAKUix-7ou1vmQZdSO34jaOPcWiAjZYk5n3bhDZpU3sUJ+H6oKw@mail.gmail.com>
Reply-To: r.secchi@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org,
	"Hossain, Ziaul" <ziaul.hossain@abdn.ac.uk>,
	Gorry Fairhurst <gorry@erg.abdn.ac.uk>,
	Alexander.Zimmermann@netapp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:42480 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396AbaBUOmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 09:42:23 -0500
Received: by mail-wi0-f179.google.com with SMTP id bs8so899475wib.0
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 06:42:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sorry for posting from a different account (and creating problems to
this list anyway),
I could not handle replies from the previous account.

Of course we are going to sign this patch (please find the signed code below),
sorry for missing it the first time.

In reply to Alex's question:

At the moment the module supports Reno only. We thought we could add
a call-back in our "cong_avoid" to call another CC from our
tcp_newcwv_cong_avoid,
but then we realised that there could be incompatibilities with other CCs.

The best approach would be probably to modify the core TCP code using
conditional programming to add NewCWV. However, we thought this approach would
be more invasive than a module, which is meant for initial experimentation.

I'll be happy to rewrite a patch to modify core TCP files if you think
is the case.

Regards,

Raffaello


Signed-off-by: Raffaello Secchi <r.secchi@gmail.com>
Signed-off-by: Ziaul Hossain <zia@erg.abdn.ac.uk>
---
 net/ipv4/Kconfig      |   17 +++
 net/ipv4/Makefile     |    1 +
 net/ipv4/tcp_newcwv.c |  317 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 335 insertions(+)
 create mode 100644 net/ipv4/tcp_newcwv.c

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 05c57f0..72294d8 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -556,6 +556,23 @@ config TCP_CONG_ILLINOIS
     For further details see:
       http://www.ews.uiuc.edu/~shaoliu/tcpillinois/index.html

+config TCP_CONG_NEWCWV
+    tristate "TCP New-CWV"
+    default n
+    ---help---
+    TCP new-CWV is a send-side modification of TCP to improve
+    congestion control for rate-limited applications. new-CWV allows
+    faster restarts after long idle periods and better congestion control
+    during periods the cwnd cannot be fully utilised.
+
+    If you select this congestion control method, it is recommended
+    to disable tcp_slow_start_after_idle:
+
+    echo "0" > /proc/sys/net/ipv4/tcp_slow_start_after_idle
+
+    For further details see:
+      http://tools.ietf.org/html/draft-ietf-tcpm-newcwv-05
+
 choice
     prompt "Default TCP congestion control"
     default DEFAULT_CUBIC
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index f8c49ce..9424160 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -51,6 +51,7 @@ obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
 obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
+obj-$(CONFIG_TCP_CONG_NEWCWV) += tcp_newcwv.o
 obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o

diff --git a/net/ipv4/tcp_newcwv.c b/net/ipv4/tcp_newcwv.c
new file mode 100644
index 0000000..6f669e4
--- /dev/null
+++ b/net/ipv4/tcp_newcwv.c
@@ -0,0 +1,317 @@
+/*
+ * New-CWV implementation for Linux: draft-ietf-tcpm-newcwv-05.txt
+ */
+
+#include <linux/module.h>
+#include <net/tcp.h>
+
+#define UNDEF_PIPEACK                     -1
+#define PIPEACK_INIT              TCP_INFINITE_SSTHRESH
+#define TCP_RESTART_WINDOW        1
+#define FIVEMINS              (HZ*300)
+#define NO_OF_BINS                      4
+#define IS_VALID                        0x0002
+#define IS_RECOVERY                     0x0001
+#define nextbin(x)  (((x)+1) & 0x03)
+#define prevbin(x)  (((x)-1) & 0x03)
+
+/* contains newcwv state variables */
+struct newcwv {
+    int psample[NO_OF_BINS];    /* pipeACK samples circular buffer */
+    u32 time_stamp[NO_OF_BINS];    /* pipeACK sample timestamps */
+    int pipeack;        /* pipeACK value after filtering */
+    u8 rsvd;
+    u8 head;        /* index for psample array */
+    u16 flags;
+    u32 prior_in_flight;    /* Packets in flight for cwnd reduction */
+    u32 prior_retrans;    /* Retransmission before going into FR */
+    u32 prev_snd_una;    /* snd_una when last record kept */
+    u32 prev_snd_nxt;    /* snd_una when last record kept */
+    u32 cwnd_valid_ts;    /* last time cwnd was found 'validated' */
+    u32 psp;        /* pipeACK Sampling Period */
+};
+
+/* helper function for division */
+static u32 divide_or_zero(u32 dividend, u32 divisor)
+{
+    if (divisor == 0)
+        return 0;
+    else
+        return (u32) (dividend / divisor);
+}
+
+/* adds an element to the circular buffer for maximum filter */
+static void add_element(struct newcwv *nc, int val)
+{
+    nc->head = nextbin(nc->head);
+    nc->psample[nc->head] = val;
+    nc->time_stamp[nc->head] = tcp_time_stamp;
+}
+
+/* This fuction removes all the expired elements from the circular buffer
+ * and returns the maximum from the remaining elements
+ */
+static int remove_expired_element(struct newcwv *nc)
+{
+    int k = nc->head;
+    int tmp = nc->psample[nc->head];
+
+    while (nc->psample[k] != UNDEF_PIPEACK) {
+        /* remove expired */
+        if (nc->time_stamp[k] < tcp_time_stamp - nc->psp) {
+            nc->psample[k] = UNDEF_PIPEACK;
+            return tmp;
+        }
+
+        /* search the maximum */
+        if (nc->psample[k] > tmp)
+            tmp = nc->psample[k];
+
+        k = prevbin(k);
+        if (k == nc->head)
+            return tmp;
+    }
+
+    return tmp;
+}
+
+/* is TCP in the validated phase? */
+static inline bool tcp_is_in_vp(struct tcp_sock *tp, int pa)
+{
+    if (pa == UNDEF_PIPEACK)
+        return true;
+    else
+        return ((pa << 1) >= (tp->snd_cwnd * tp->mss_cache));
+}
+
+/* reduces the cwnd after 5mins of non-validated phase */
+static void datalim_closedown(struct sock *sk)
+{
+    struct newcwv *nc = inet_csk_ca(sk);
+    struct tcp_sock *tp = tcp_sk(sk);
+    u32 nc_ts;
+
+    nc_ts = nc->cwnd_valid_ts;
+    while ((tcp_time_stamp - nc_ts) > FIVEMINS) {
+        nc_ts += FIVEMINS;
+        nc->cwnd_valid_ts = nc_ts;
+        tp->snd_ssthresh =
+            max((3 * tp->snd_cwnd) >> 2, tp->snd_ssthresh);
+        tp->snd_cwnd =
+            max_t(u32, tp->snd_cwnd >> 1, TCP_INIT_CWND);
+    }
+}
+
+
+/* updates pipeack when an ACK is received */
+static void update_pipeack(struct sock *sk)
+{
+    struct newcwv *nc = inet_csk_ca(sk);
+    struct tcp_sock *tp = tcp_sk(sk);
+    int tmp_pipeack;
+
+    nc->psp = max(3 * (tp->srtt >> 3), (u32) HZ);
+
+    if (tp->snd_una >= nc->prev_snd_nxt) {
+
+        /* now get a new pipeack sample */
+        tmp_pipeack = tp->snd_una - nc->prev_snd_una;
+        nc->prev_snd_una = tp->snd_una;
+        nc->prev_snd_nxt = tp->snd_nxt;
+
+        /* create a new element at the end of current pmp */
+        if (tcp_time_stamp > nc->time_stamp[nc->head] + (nc->psp >> 2))
+            add_element(nc, tmp_pipeack);
+        else if (tmp_pipeack > nc->psample[nc->head])
+            nc->psample[nc->head] = tmp_pipeack;
+    }
+
+    nc->pipeack = remove_expired_element(nc);
+
+    /* check if cwnd is validated */
+    if (tcp_is_in_vp(tp, nc->pipeack)) {
+        nc->flags |= IS_VALID;
+        nc->cwnd_valid_ts = tcp_time_stamp;
+    } else {
+        nc->flags &= ~IS_VALID;
+        datalim_closedown(sk);
+    }
+}
+
+/* initialises newcwv variables */
+static void tcp_newcwv_init(struct sock *sk)
+{
+    struct newcwv *nc = inet_csk_ca(sk);
+    struct tcp_sock *tp = tcp_sk(sk);
+
+    nc->prev_snd_una = tp->snd_una;
+    nc->prev_snd_nxt = tp->snd_nxt;
+
+    nc->cwnd_valid_ts = tcp_time_stamp;
+    nc->flags = IS_VALID;
+
+    nc->psp = max(3 * (tp->srtt >> 3), (u32) HZ);
+
+    nc->head = 0;
+    nc->psample[0] = UNDEF_PIPEACK;
+    nc->pipeack = UNDEF_PIPEACK;
+}
+
+
+/* cong_avoid action: non dubious ACK received */
+static void tcp_newcwv_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
+{
+    struct newcwv *nc = inet_csk_ca(sk);
+    struct tcp_sock *tp = tcp_sk(sk);
+
+    nc->prior_in_flight = in_flight;
+    nc->prior_retrans = tp->total_retrans;
+
+    update_pipeack(sk);
+
+    /* Check if cwnd is validated */
+    if (!(nc->flags & IS_VALID) && !tcp_is_cwnd_limited(sk, in_flight))
+        return;
+
+    /* The following is the Reno behaviour */
+
+    /* In "safe" area, increase. */
+    if (tp->snd_cwnd <= tp->snd_ssthresh)
+        tcp_slow_start(tp);
+
+    /* In dangerous area, increase slowly. */
+    else
+        tcp_cong_avoid_ai(tp, tp->snd_cwnd);
+
+}
+
+/* newcwv actions in fast recovery */
+static void tcp_newcwv_enter_recovery(struct sock *sk)
+{
+    struct newcwv *nc = inet_csk_ca(sk);
+    struct tcp_sock *tp = tcp_sk(sk);
+    u32 pipeack;
+
+    nc->flags |= IS_RECOVERY;
+
+    pipeack = (nc->pipeack == UNDEF_PIPEACK) ? 0 : (u32)
+        nc->pipeack;
+    pipeack = divide_or_zero(pipeack, (u32) tp->mss_cache);
+    tp->snd_cwnd = max(pipeack, nc->prior_in_flight) >> 1;
+
+    /* make sure the min. value for cwnd is 1 */
+    tp->snd_cwnd = (tp->snd_cwnd < 1) ? 1 : tp->snd_cwnd;
+
+}
+
+/* newcwv actions at the end of recovery */
+static void tcp_newcwv_end_recovery(struct sock *sk)
+{
+    struct newcwv *nc = inet_csk_ca(sk);
+    struct tcp_sock *tp = tcp_sk(sk);
+    u32 retrans, pipeack;
+
+    pipeack = (nc->pipeack == UNDEF_PIPEACK) ? 0 : (u32)
+        nc->pipeack;
+
+    pipeack = divide_or_zero(pipeack, (u32) tp->mss_cache);
+    retrans = tp->total_retrans - nc->prior_retrans;
+    tp->snd_cwnd = (max(pipeack, nc->prior_in_flight) - retrans) >> 1;
+    if (tp->snd_cwnd < TCP_RESTART_WINDOW)
+        tp->snd_cwnd = TCP_RESTART_WINDOW;
+
+    tp->snd_ssthresh = tp->snd_cwnd;
+    nc->flags &= ~IS_RECOVERY;
+
+    /* restart cwv machine */
+    tcp_newcwv_init(sk);
+
+}
+
+/* newcwv actions corresponding to event */
+static void tcp_newcwv_event(struct sock *sk, enum tcp_ca_event event)
+{
+    struct newcwv *nc = inet_csk_ca(sk);
+    const struct inet_connection_sock *icsk = inet_csk(sk);
+
+    switch (event) {
+    case CA_EVENT_TX_START:
+        datalim_closedown(sk);
+        break;
+
+    case CA_EVENT_COMPLETE_CWR:
+        if (!(nc->flags & IS_VALID))
+            tcp_newcwv_end_recovery(sk);
+        break;
+
+    case CA_EVENT_LOSS:
+        tcp_newcwv_init(sk);
+        break;
+
+    case CA_EVENT_SLOW_ACK:
+
+        switch (icsk->icsk_ca_state) {
+        case TCP_CA_Recovery:
+            if (!nc->flags)
+                tcp_newcwv_enter_recovery(sk);
+            break;
+
+        case TCP_CA_Open:
+        case TCP_CA_Disorder:
+        default:
+            break;
+        }
+        break;
+
+    case CA_EVENT_CWND_RESTART:
+    case CA_EVENT_FAST_ACK:
+    default:
+        break;
+    }
+
+}
+
+/* Slow start threshold resetting after loss */
+u32 tcp_newcwv_ssthresh(struct sock *sk)
+{
+    const struct tcp_sock *tp = tcp_sk(sk);
+
+    /* This is tcp_packets_in_flight */
+    u32 prior_in_flight =
+        tp->packets_out - tp->sacked_out - tp->lost_out + tp->retrans_out;
+
+    return max(prior_in_flight >> 1U, 2U);
+}
+
+struct tcp_congestion_ops tcp_newcwv = {
+    .flags = TCP_CONG_NON_RESTRICTED,
+    .name = "newcwv",
+    .init = tcp_newcwv_init,
+    .owner = THIS_MODULE,
+    .ssthresh = tcp_newcwv_ssthresh,
+    .cong_avoid = tcp_newcwv_cong_avoid,
+    .cwnd_event = tcp_newcwv_event,
+    .min_cwnd = tcp_reno_min_cwnd,
+};
+
+/* newcwv registered as congestion control in Linux */
+static int __init tcp_newcwv_register(void)
+{
+    BUILD_BUG_ON(sizeof(struct newcwv) > ICSK_CA_PRIV_SIZE);
+    tcp_register_congestion_control(&tcp_newcwv);
+
+    return 0;
+}
+
+/* unregister when module is disabled */
+static void __exit tcp_newcwv_unregister(void)
+{
+    tcp_unregister_congestion_control(&tcp_newcwv);
+}
+
+module_init(tcp_newcwv_register);
+module_exit(tcp_newcwv_unregister);
+
+MODULE_AUTHOR("Ziaul Hossain, Raffaello Secchi");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("NewCwv Reno variant");
-- 
1.7.9.5
