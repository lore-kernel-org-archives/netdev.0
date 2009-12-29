From: Fabio Ludovici <fabio.ludovici@yahoo.it>
Subject: Re: [RESEND PATCH 1/3] netem/iproute2 solving correlated loss issue
Date: Tue, 29 Dec 2009 21:00:53 +0100
Message-ID: <4B3A5FF5.30602@yahoo.it>
References: <4B3A5F84.4050603@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:62947 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbZL2UBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 15:01:00 -0500
Received: by fxm25 with SMTP id 25so5510450fxm.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 12:00:58 -0800 (PST)
In-Reply-To: <4B3A5F84.4050603@yahoo.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enhances netem module as follows:

- add deterministic loss generation according to a pattern that can be 
specified in a file in the iproute2 command line
- new statistical models for generation of correlated loss (the existing 
model does not work), including loss models commonly used in literature 
(bernoulli, Gilbert, Gilbert Elliot) and the new GI (General and 
Intuitive model)
- enhanced logging functionality for loss events in dmesg

Signed-off-by: Stefano Salsano <stefano.salsano@uniroma2.it>
Signed-off-by: Fabio Ludovici <fabio.ludovici@yahoo.it>
---
  include/linux/pkt_sched.h |   33 ++++++
  net/sched/sch_netem.c     |  277 
+++++++++++++++++++++++++++++++++++++++++++++
  2 files changed, 310 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d51a2b3..b492fd3 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -466,6 +466,10 @@ enum
      TCA_NETEM_DELAY_DIST,
      TCA_NETEM_REORDER,
      TCA_NETEM_CORRUPT,
+    TCA_NETEM_LOSS_GI,
+    TCA_NETEM_LOSS_GILBELL,
+    TCA_NETEM_LOSS_PATTERN,
+    TCA_NETEM_LOGGING,
      __TCA_NETEM_MAX,
  };

@@ -500,6 +504,35 @@ struct tc_netem_corrupt
      __u32    correlation;
  };

+struct tc_netem_loss_GI
+{
+    __u32    p13;
+    __u32    p31;
+    __u32    p32;
+    __u32    p23;
+    __u32   p14;
+};
+
+struct tc_netem_loss_gilbell
+{
+    __u32    p;
+    __u32    r;
+    __u32    h;
+    __u32    k;
+};
+
+struct tc_netem_loss_pattern
+{
+    __u16   pattern_length;
+    __u32   pattern_repetitions;
+    __u16   *user_pattern;
+};
+
+struct tc_netem_logging
+{
+    __u8 level;
+};
+
  #define NETEM_DIST_SCALE    8192

  /* DRR */
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 2b88295..c897ce3 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -62,6 +62,29 @@ struct netem_sched_data {
      u32 duplicate;
      u32 reorder;
      u32 corrupt;
+        // GI loss model transition probabilities
+    u32 p13;
+    u32 p31;
+    u32 p23;
+    u32 p32;
+    u32 p14;
+    // Gilbert and Gilbert-Elliot loss models parameters
+    u32 p;
+    u32 r;
+    u32 h;
+    u32 k;
+    // Markov chain state for GI, Gilbert and Gilbert-Elliot models
+    u8 chain_state;
+    // Deterministic pattern parameters
+    u16 pattern_length;        //deterministic loss length
+    u32 pattern_repetitions;    //deterministic loss pattern repetitions
+    u32 *kernel_pattern;         //deterministic loss pattern
+    // Logging parameters and variables
+    u8 logging_level;
+    u32 num_of_drops;        //number of dropped packets
+    u32 num_of_transmissions;   //number of correctly transmitted packets
+    u32 pattern_counter;        //deterministic loss counter
+    u32 repetitions_done;        //deterministic loss repetitions counter

      struct crndstate {
          u32 last;
@@ -159,6 +182,9 @@ static int netem_enqueue(struct sk_buff *skb, struct 
Qdisc *sch)
      struct sk_buff *skb2;
      int ret;
      int count = 1;
+
+    u32 GI_random;              //GI loss model random number
+    u32 gilbell_random;          //Gilbert-Elliot loss model random number

      pr_debug("netem_enqueue skb=%p\n", skb);

@@ -170,6 +196,159 @@ static int netem_enqueue(struct sk_buff *skb, 
struct Qdisc *sch)
      if (q->loss && q->loss >= get_crandom(&q->loss_cor))
          --count;

+    /* General and Intuitive loss generator, Gilbert-Elliot generator, 
deterministic pattern
+    ====================================
+
+    Sources: [1] S. Salsano, F. Ludovici, A. Ordine: "Definition of a 
general and
+    intuitive loss model for packet networks and its implementation in 
the Netem
+    module in the Linux kernel" available at
+ 
http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetEm2#TechnicalReports
+
+     ----------------------------------------------------------------
+
+     This code generates packet losses according to the 4-state Markov 
chain adopted
+         in the GI (General and Intuitive) loss model. To decide if a 
packet will be lost
+     a random value GI_random is compared to the transition 
probabilities outgoing from
+     the current state. The four states correspond to: successfully 
transmitted packets
+     within a gap period (State 1), isolated losses within a gap period 
(State 4),
+     lost packets within a burst period (State 3), successfully 
transmitted packets
+     within a burst period (State 2).
+        */
+
+        if (q->p13) {
+
+    GI_random=net_random();
+
+        switch (q->chain_state) {
+       case 1:
+        q->num_of_transmissions++;
+        if((0<GI_random)&&(GI_random<q->p13))    {
+            q->chain_state=3;
+            break;
+        }
+        else if((q->p13<GI_random)&&(GI_random<(4294967295u-q->p14)))    {
+            q->chain_state=1;
+            break;
+        }
+        else if(((4294967295u-q->p14)<GI_random) && 
(GI_random<4294967295u))    {
+            q->chain_state=4;
+            break;
+        }
+      case 2:
+               q->num_of_transmissions++;
+               if(GI_random<q->p23)    {
+            q->chain_state=3;
+            break;
+        }
+        else      {
+            q->chain_state=2;
+            break;
+        }
+        case 3:
+               --count;
+        q->num_of_drops++;
+        if (q->logging_level==1)
+            printk("netem loss event GI burst %d RFPLE %d\n",
+                q->num_of_drops, q->num_of_transmissions);
+        q->num_of_transmissions=0;
+            if((0<GI_random)&&(GI_random<q->p32)){
+            q->chain_state=2;
+            break;
+        }
+        else if((q->p32<GI_random) && (GI_random<(q->p31+q->p32))){
+        q->chain_state=1;
+        break;
+        }
+        else if(((q->p31+q->p32)<GI_random) && (GI_random<4294967295u)){
+        q->chain_state=3;
+        break;
+        }
+     case 4:
+            --count;
+             q->num_of_drops++;
+             q->chain_state=1;
+             if (q->logging_level==1)
+            printk("netem loss event GI isolated %d RFPLE %d\n",
+            q->num_of_drops, q->num_of_transmissions);
+        break;
+    }
+    }
+
+    /* Gilbert-Elliot loss generator algorithm
+    This code generates packet losses according to the Gilbert-Elliot loss
+    model and its special cases  (like the Gilbert or the Simple Gilbert)
+    */
+
+    if (q->p) {
+
+    switch(q->chain_state) {
+    case 1:
+        gilbell_random=net_random();
+        if(gilbell_random<4294967295u-q->k){
+        --count;
+        q->num_of_drops++;
+        if (q->logging_level==1)
+            printk("netem loss event gilbell %d RFPLE %d\n",
+            q->num_of_drops, q->num_of_transmissions);
+        q->num_of_transmissions=0;
+        }
+        else    {
+        q->num_of_transmissions++;
+        }
+          gilbell_random=net_random();
+        if(gilbell_random<q->p){
+        q->chain_state=2;
+        }
+        break;
+
+    case 2:
+        gilbell_random=net_random();
+        if(gilbell_random<4294967295u-q->h){
+        --count;
+        q->num_of_drops++;
+        if (q->logging_level==1)
+            printk("netem loss event gilbell %d RFPLE %d\n",
+                q->num_of_drops, q->num_of_transmissions);
+        q->num_of_transmissions=0;
+        }
+        else    {
+        q->num_of_transmissions++;
+        }
+        gilbell_random=net_random();
+        if(gilbell_random<q->r)    {
+            q->chain_state=1;
+        }
+        break;
+    }
+    }
+
+    /* Deterministic loss pattern algorithm
+    This code generates packet losses according to a deterministic 
sequence
+    of 0 and 1 where 0 represents a transmitted packet and 1 represents a
+    loss event. The pattern can be repeated for a fixed number of times or
+    indefinitely (if pattern_repetitions=0).
+    */
+
+    if ((0<q->pattern_length) & ((q->pattern_repetitions==0)||
+        (q->repetitions_done<q->pattern_repetitions)) &
+        (q->pattern_counter<q->pattern_length)){
+
+        if (0<q->kernel_pattern[q->pattern_counter-1]){
+        --count;
+        q->num_of_drops++;
+            if (q->logging_level==1)
+            printk("netem loss event deterministic %d RFPLE %d\n",
+                q->num_of_drops, q->num_of_transmissions);
+        q->num_of_transmissions=0;
+                }
+        else q->num_of_transmissions++;
+        q->pattern_counter++;
+        if (q->pattern_counter==q->pattern_length-1){
+        q->repetitions_done++;
+        q->pattern_counter=1;
+        }
+        }
+
      if (count == 0) {
          sch->qstats.drops++;
          kfree_skb(skb);
@@ -369,10 +548,72 @@ static void get_corrupt(struct Qdisc *sch, const 
struct nlattr *attr)
      init_crandom(&q->corrupt_cor, r->correlation);
  }

+static void get_loss_GI(struct Qdisc *sch, const struct nlattr *attr)
+{
+    struct netem_sched_data *q = qdisc_priv(sch);
+    const struct tc_netem_loss_GI *GI = nla_data(attr);
+
+    q->p13 = GI->p13;
+    q->p31 = GI->p31;
+    q->p32 = GI->p32;
+    q->p23 = GI->p23;
+    q->p14 = GI->p14;
+    q->num_of_drops=0;
+    q->num_of_transmissions=0;
+    q->chain_state=1;
+}
+
+static void get_loss_gilbell(struct Qdisc *sch, const struct nlattr *attr)
+{
+    struct netem_sched_data *q = qdisc_priv(sch);
+    const struct tc_netem_loss_gilbell *ge = nla_data(attr);
+
+    q->p = ge->p;
+    q->r = ge->r;
+    q->h = ge->h;
+    q->k = ge->k;
+    q->num_of_drops=0;
+    q->num_of_transmissions=0;
+    q->chain_state=1;
+}
+
+static void get_loss_pattern(struct Qdisc *sch, const struct nlattr *attr)
+{
+    struct netem_sched_data *q = qdisc_priv(sch);
+    const struct tc_netem_loss_pattern *pt = nla_data(attr);
+    int pattern_element;
+    q->pattern_length = pt->pattern_length;
+     q->pattern_repetitions = pt->pattern_repetitions;
+     q->kernel_pattern=kmalloc(q->pattern_length*sizeof(size_t),
+        GFP_KERNEL);
+
+    for (pattern_element=1; pattern_element<q->pattern_length;
+            pattern_element++)    {
+        q->kernel_pattern[pattern_element-1] =
+        pt->user_pattern[pattern_element-1];
+                            }
+    q->num_of_drops=0;
+    q->num_of_transmissions=0;
+    q->pattern_counter=1;
+    q->repetitions_done=0;
+}
+
+static void get_logging(struct Qdisc *sch, const struct nlattr *attr)
+{
+    struct netem_sched_data *q = qdisc_priv(sch);
+    const struct tc_netem_logging *lo = nla_data(attr);
+
+    q->logging_level = lo->level;
+}
+
  static const struct nla_policy netem_policy[TCA_NETEM_MAX + 1] = {
      [TCA_NETEM_CORR]    = { .len = sizeof(struct tc_netem_corr) },
      [TCA_NETEM_REORDER]    = { .len = sizeof(struct tc_netem_reorder) },
      [TCA_NETEM_CORRUPT]    = { .len = sizeof(struct tc_netem_corrupt) },
+    [TCA_NETEM_LOSS_GI]    = { .len = sizeof(struct tc_netem_loss_GI) },
+    [TCA_NETEM_LOSS_GILBELL]= { .len = sizeof(struct 
tc_netem_loss_gilbell) },
+    [TCA_NETEM_LOSS_PATTERN]= { .len = sizeof(struct 
tc_netem_loss_pattern) },
+    [TCA_NETEM_LOGGING]    = { .len = sizeof(struct tc_netem_logging) },
  };

  static int parse_attr(struct nlattr *tb[], int maxtype, struct nlattr 
*nla,
@@ -440,6 +681,18 @@ static int netem_change(struct Qdisc *sch, struct 
nlattr *opt)
      if (tb[TCA_NETEM_CORRUPT])
          get_corrupt(sch, tb[TCA_NETEM_CORRUPT]);

+    if (tb[TCA_NETEM_LOSS_GI])
+        get_loss_GI(sch, tb[TCA_NETEM_LOSS_GI]);
+
+    if (tb[TCA_NETEM_LOSS_GILBELL])
+        get_loss_gilbell(sch, tb[TCA_NETEM_LOSS_GILBELL]);
+
+    if (tb[TCA_NETEM_LOSS_PATTERN])
+        get_loss_pattern(sch, tb[TCA_NETEM_LOSS_PATTERN]);
+
+    if (tb[TCA_NETEM_LOGGING])
+        get_logging(sch, tb[TCA_NETEM_LOGGING]);
+
      return 0;
  }

@@ -571,6 +824,10 @@ static int netem_dump(struct Qdisc *sch, struct 
sk_buff *skb)
      struct tc_netem_corr cor;
      struct tc_netem_reorder reorder;
      struct tc_netem_corrupt corrupt;
+    struct tc_netem_loss_GI GI;
+    struct tc_netem_loss_gilbell gilbell;
+    struct tc_netem_loss_pattern pattern;
+    struct tc_netem_logging logging;

      qopt.latency = q->latency;
      qopt.jitter = q->jitter;
@@ -593,6 +850,26 @@ static int netem_dump(struct Qdisc *sch, struct 
sk_buff *skb)
      corrupt.correlation = q->corrupt_cor.rho;
      NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);

+    GI.p13=q->p13;
+    GI.p31=q->p31;
+    GI.p23=q->p23;
+    GI.p32=q->p32;
+    GI.p14=q->p14;
+    NLA_PUT(skb, TCA_NETEM_LOSS_GI, sizeof(GI), &GI);
+
+    gilbell.p=q->p;
+    gilbell.r=q->r;
+    gilbell.h=q->h;
+    gilbell.k=q->k;
+    NLA_PUT(skb, TCA_NETEM_LOSS_GILBELL, sizeof(gilbell), &gilbell);
+
+    pattern.pattern_length = q->pattern_length;
+    pattern.pattern_repetitions = q->pattern_repetitions;
+
+    NLA_PUT(skb, TCA_NETEM_LOSS_PATTERN, sizeof(pattern), &pattern);
+    logging.level=q->logging_level;
+    NLA_PUT(skb, TCA_NETEM_LOGGING, sizeof(logging), &logging);
+
      nla->nla_len = skb_tail_pointer(skb) - b;

      return skb->len;
-- 
1.6.3.3

-- 
Fabio Ludovici

