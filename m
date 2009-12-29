From: Fabio Ludovici <fabio.ludovici@yahoo.it>
Subject: Re: [RESEND PATCH 2/3] netem/iproute2 solving correlated loss issue
Date: Tue, 29 Dec 2009 21:01:35 +0100
Message-ID: <4B3A601F.7060504@yahoo.it>
References: <4B3A5F84.4050603@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:65144 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbZL2UBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 15:01:39 -0500
Received: by fxm25 with SMTP id 25so5510912fxm.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 12:01:37 -0800 (PST)
In-Reply-To: <4B3A5F84.4050603@yahoo.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enhances iproute2 to work the the following new features of netem:

- deterministic loss according to a pattern that can be specified in a 
file in the iproute2 command line
- new models for generation of correlated loss (the existing model does 
not work)
- parameter converter between intuitive parameters and Markov transition 
probabilities (query mode)
- enhanced logging functionality for loss events in dmesg

Examples of new iproute2 syntax is reported hereafter (see the man page 
for the full list):

1) generate loss according to a deterministic pattern:

tc qdisc add/change dev eth0 root netem loss_pattern filename

2) generate loss according to different loss models including the ones 
commonly used in the literature (bernoulli, gilbert, gilbert-elliot...) 
and the new GI (General and Intuitive) model

tc qdisc add/change dev eth0 root netem loss_bern       p
tc qdisc add/change dev eth0 root netem loss_gilb       p r [1-h]
tc qdisc add/change dev eth0 root netem loss_gilbell    p r [1-h [1-k]]
tc qdisc add/change dev eth0 root netem loss_GI         ploss 
[burst_length [density [pisol [good_burst_length]]]]
tc qdisc add/change dev eth0 root netem loss_GI_tran    p13 p31 [p32 p23 
[p14]]

3) parameter converter between intuitive and Markov transition 
probabilities (query mode)

this applies to loss_GI and loss_GI_tran options. If the query label is 
specified before the model label the transition probabilities or the GI 
parameters that corresponds to the specified input parameters are 
calculated and printed to screen, but no operation is done on the qdisc. 
In this way the user can understands what he would obtain with certain 
input parameters without necessarily make changes to the network's 
behaviour.

4) enable enhanced logging in dmesg:

tc qdisc add/change dev eth0 root netem logging 1 loss_GI 5 10

for each loss event the kernel logs will include a line like "netem2 
loss event loss_GI 30 RFPLE 15" where RFPLE stands for "Received From 
Previous Loss Event" and it counts the number y of good packets received 
between two loss events while x is the number of all lost packets

Signed-off-by: Stefano Salsano <stefano.salsano@uniroma2.it>
Signed-off-by: Fabio Ludovici <fabio.ludovici@yahoo.it>
---
  include/linux/pkt_sched.h |   33 ++++
  tc/q_netem.c              |  396 
+++++++++++++++++++++++++++++++++++++++++++++
  2 files changed, 429 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d51a2b3..85232c5 100644
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
diff --git a/tc/q_netem.c b/tc/q_netem.c
index 33b3d2a..5ad1ab3 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -32,6 +32,12 @@ static void explain(void)
  "                 [ delay TIME [ JITTER [CORRELATION]]]\n" \
  "                 [ distribution {uniform|normal|pareto|paretonormal} 
]\n" \
  "                 [ drop PERCENT [CORRELATION]] \n" \
+"                 [ loss_GI ploss [burst_length [density [pisol 
[good_burst_length]]]]] \n" \
+"                 [ loss_GI_tran p13 p31 [p32 p23 [p14]]] \n" \
+"                 [ loss_bern p] \n" \
+"                 [ loss_gilb p r [1-h]] \n" \
+"                 [ loss_gilbell p r [1-h [1-k]]] \n" \
+"                 [ loss_pattern [filename [repetitions]]] \n" \
  "                 [ corrupt PERCENT [CORRELATION]] \n" \
  "                 [ duplicate PERCENT [CORRELATION]]\n" \
  "                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n");
@@ -133,14 +139,23 @@ static int netem_parse_opt(struct qdisc_util *qu, 
int argc, char **argv,
      struct tc_netem_corr cor;
      struct tc_netem_reorder reorder;
      struct tc_netem_corrupt corrupt;
+    struct tc_netem_loss_GI GI;
+    struct tc_netem_loss_gilbell gilbell;
+    struct tc_netem_loss_pattern pattern;
+    struct tc_netem_logging logging;
      __s16 *dist_data = NULL;
      int present[__TCA_NETEM_MAX];
+    int query=0;

      memset(&opt, 0, sizeof(opt));
      opt.limit = 1000;
      memset(&cor, 0, sizeof(cor));
      memset(&reorder, 0, sizeof(reorder));
      memset(&corrupt, 0, sizeof(corrupt));
+    memset(&GI, 0, sizeof(GI));
+    memset(&gilbell, 0, sizeof(gilbell));
+    memset(&pattern, 0, sizeof(pattern));
+    memset(&logging, 0, sizeof(logging));
      memset(present, 0, sizeof(present));

      while (argc > 0) {
@@ -150,6 +165,15 @@ static int netem_parse_opt(struct qdisc_util *qu, 
int argc, char **argv,
                  explain1("limit");
                  return -1;
              }
+        } else if (matches(*argv, "logging") == 0) {
+            NEXT_ARG();
+            ++present[TCA_NETEM_LOGGING];
+            if (get_size(&logging.level, *argv)) {
+                explain1("logging");
+                return -1;
+            }
+        } else if (matches(*argv, "query") == 0) {
+              query=1;
          } else if (matches(*argv, "latency") == 0 ||
                 matches(*argv, "delay") == 0) {
              NEXT_ARG();
@@ -189,6 +213,315 @@ static int netem_parse_opt(struct qdisc_util *qu, 
int argc, char **argv,
                      return -1;
                  }
              }
+        } else if (matches(*argv, "loss_GI") == 0)  {
+          NEXT_ARG();
+          double p13=0;
+          double p31=1;
+          double p32=0;
+          double p23=1;
+          double p14=0;
+          double ploss=0;
+          double burst_length=1;
+          double rho=1;
+          double pisol=0;
+          double good_burst_length=1;
+
+          ploss=strtod(*argv,(char **)NULL)/100;
+
+          if (NEXT_IS_NUMBER()) {
+            NEXT_ARG();
+            burst_length=strtod(*argv,(char **)NULL);
+
+            if (NEXT_IS_NUMBER()) {
+              NEXT_ARG();
+              rho=strtod(*argv,(char **)NULL)/100;
+
+              if (ploss>rho) {
+            printf("\nError: ploss>density \n");
+            break;
+              }
+
+              if(NEXT_IS_NUMBER()) {
+            NEXT_ARG();
+            pisol=strtod(*argv,(char **)NULL)/100;
+
+            if (pisol>ploss) {
+              printf("\nError: pisol>ploss \n");
+              break;
+            }
+
+            if (ploss>(rho-pisol*(rho-1))) {
+              printf("\nError: ploss>density-pisol(density-1) \n");
+              break;
+            }
+
+            if(NEXT_IS_NUMBER()) {
+              NEXT_ARG();
+              good_burst_length=strtod(*argv,(char **)NULL);
+              if(good_burst_length>burst_length) {
+                printf("\nError: good burst length>burst length \n ");
+                break;
+              }
+            }
+              }
+            }
+          }
+
+          if(burst_length==0) {
+            p13=ploss;
+            p31=1-ploss;
+          }
+
+          else if((burst_length!=0) & (rho==1) & (pisol==0)) {
+            p13=ploss/(burst_length*(1-ploss));
+            p31=1/burst_length;
+          }
+
+          else if ((burst_length!=0) & (rho!=1) & (pisol==0)) {
+            p13=(-ploss)/(burst_length*ploss-burst_length*rho);
+            p31=1/(burst_length*rho);
+          }
+
+          else if ((burst_length!=0) & (rho!=1) & (pisol!=0)) {
+            p13=(pisol-ploss)/(burst_length*(pisol-1)*(rho-ploss));
+            p31=1/(burst_length*rho);
+            p14=pisol/(1-pisol);
+          }
+
+          if((burst_length!=0) & (rho!=1)) {
+            if(good_burst_length==0) {
+              p23=(burst_length*rho-1) / (burst_length-1);
+              p32=(1+rho*rho*burst_length-rho-burst_length*rho) /
+            (rho-rho*burst_length);
+            }
+          }
+          else {
+            p23=1/good_burst_length;
+            p32=(1-rho) / (rho*good_burst_length);
+          }
+
+          if (burst_length==0) burst_length=1/p31;
+          printf("\nTransition probabilities are:\n ");
+          printf("--------------------------------");
+          printf("\np13 is %.3f%% ", 100*p13);
+          printf("\np31 is %.3f%% ", 100*p31);
+          printf("\np32 is %.3f%% ", 100*p32);
+          printf("\np23 is %.3f%% ", 100*p23);
+          printf("\np14 is %.3f%%\n ", 100*p14);
+
+          printf("\nGI (General and Intuitive) parameters will be: \n");
+          printf("--------------------------------");
+          printf("\nploss is %.3f%% ", 100*ploss);
+          printf("\nburst length is %.3f", burst_length);
+          printf("\nburst density is %.3f%% ", 100*rho);
+          printf("\nisolated ploss is %.3f%% ", 100*pisol);
+          printf("\ngood burst length is %.3f\n ", good_burst_length);
+
+          if(query==0) {
+            present[TCA_NETEM_LOSS_GI] = 1;
+            GI.p13=4294967295u*p13;
+            GI.p31=4294967295u*p31;
+            GI.p32=4294967295u*p32;
+            GI.p23=4294967295u*p23;
+            GI.p14=4294967295u*p14;
+          }
+
+          if(query==1) return -1;
+
+        } else if (matches(*argv, "loss_GI_tran") == 0)  {
+          double p13=0;
+          double p31=1;
+          double p32=0;
+          double p23=1;
+          double p14=0;
+          double ploss;
+          double burst_length;
+          double rho=1;
+          double pisol=0;
+          double good_burst_length=1;
+
+          NEXT_ARG();
+          p13=strtod(*argv,(char **)NULL)/100;
+          if (NEXT_IS_NUMBER()) {
+            NEXT_ARG();
+            p31=strtod(*argv,(char **)NULL)/100;
+            if (NEXT_IS_NUMBER()) {
+              NEXT_ARG();
+              p32=strtod(*argv,(char **)NULL)/100;
+              if (NEXT_IS_NUMBER()) {
+            NEXT_ARG();
+            p23=strtod(*argv,(char **)NULL)/100;
+            if (NEXT_IS_NUMBER()) {
+              NEXT_ARG();
+              p14=strtod(*argv,(char **)NULL)/100;
+            }
+              }
+            }
+          }
+          else p31=1-p13;
+
+          printf("\nTransition probabilities are:\n ");
+          printf("--------------------------------");
+          printf("\np13 is %.3f%% ", 100*p13);
+          printf("\np31 is %.3f%% ", 100*p31);
+          printf("\np32 is %.3f%% ", 100*p32);
+          printf("\np23 is %.3f%% ", 100*p23);
+          printf("\np14 is %.3f%%\n ", 100*p14);
+
+          ploss=(p13*p23+p14*p23*p31) / 
(p13*p23+p23*p31+p14*p23*p31+p13*p32);
+          burst_length=(p32+p23) / (p23*p31);
+          rho=(p13*p23) / (p13*p23+p13*p32);
+          pisol=(p14*p23*p31) / (p14*p23*p31+p23*p31);
+          good_burst_length=1/p23;
+
+          printf("\nGI (General and Intuitive) parameters will be: \n");
+          printf("--------------------------------");
+          printf("\nploss is %.3f%%", 100*ploss);
+          printf("\nburst length is %.3f", burst_length);
+          printf("\nburst density is %.3f%% ", 100*rho);
+          printf("\nisolated ploss is %.3f%% ", 100*pisol);
+          printf("\ngood burst length is %.3f\n ", good_burst_length);
+
+          if(query==0)    {
+            present[TCA_NETEM_LOSS_GI] = 1;
+            GI.p13=4294967295u*p13;
+            GI.p31=4294967295u*p31;
+            GI.p32=4294967295u*p32;
+            GI.p23=4294967295u*p23;
+            GI.p14=4294967295u*p14;
+          }
+
+          if(query==1) return -1;
+
+        } else if (matches(*argv, "loss_gilb") == 0)  {
+
+          double p=0;
+          double r=0;
+          double h=0;
+
+          NEXT_ARG();
+          p=strtod(*argv,(char **)NULL)/100;
+
+          NEXT_ARG();
+          r=strtod(*argv,(char **)NULL)/100;
+
+          if (NEXT_IS_NUMBER())    {
+            NEXT_ARG();
+            h=(100-strtod(*argv,(char **)NULL))/100;
+          }
+
+          present[TCA_NETEM_LOSS_GILBELL] = 1;
+          gilbell.p=4294967295u*p;
+          gilbell.r=4294967295u*r;
+          gilbell.h=4294967295u*h;
+
+        } else if (matches(*argv, "loss_gilbell") == 0)  {
+
+          double p=0;
+          double r=0;
+          double h=0;
+          double k=1;
+
+          NEXT_ARG();
+          p=strtod(*argv,(char **)NULL)/100;
+
+          NEXT_ARG();
+          r=strtod(*argv,(char **)NULL)/100;
+
+          if (NEXT_IS_NUMBER()) {
+            NEXT_ARG();
+            h=(100-strtod(*argv,(char **)NULL))/100;
+
+            if (NEXT_IS_NUMBER()) {
+              NEXT_ARG();
+              k=(100-strtod(*argv,(char **)NULL))/100;
+            }
+          }
+
+          present[TCA_NETEM_LOSS_GILBELL] = 1;
+          gilbell.p=4294967295u*p;
+          gilbell.r=4294967295u*r;
+          gilbell.h=4294967295u*h;
+          gilbell.k=4294967295u*k;
+
+        } else if (matches(*argv, "loss_bern") == 0)  {
+
+          double p=0;
+          double r=0;
+          double ploss=0;
+          double burst_length=1;
+          double p13=0;
+          double p31=0;
+
+          NEXT_ARG();
+          p=strtod(*argv,(char **)NULL)/100;
+          r=1-p;
+
+          ploss=p/(p+r);
+          burst_length=1/r;
+
+          p13=p;
+          p31=r;
+
+          printf("\nTransition probabilities are:\n ");
+          printf("--------------------------------");
+          printf("\np13 is %.3f%% ", 100*p13);
+          printf("\np31 is %.3f%% ", 100*p31);
+          printf("\np32 is 0.000%% ");
+          printf("\np23 is 100.000%% ");
+          printf("\np14 is 0.000%%\n ");
+
+          printf("\nGI (General and Intuitive) parameters will be: \n");
+          printf("--------------------------------");
+          printf("\nploss is %.3f%% ", 100*ploss);
+          printf("\nburst length is %.3f", burst_length);
+          printf("\nburst density is 100.000%% ");
+          printf("\nisolated ploss is 0.000%% ");
+          printf("\ngood burst length is 1.000%%\n ");
+
+          if(query==0)    {
+            present[TCA_NETEM_LOSS_GI] = 1;
+            GI.p13=4294967295u*p13;
+            GI.p31=4294967295u*p31;
+            GI.p32=0;
+            GI.p23=4294967295u;
+            GI.p14=0;
+          }
+
+          if(query==1) return -1;
+
+        } else if (matches(*argv, "loss_pattern") == 0)  {
+          NEXT_ARG();
+
+          int i;
+
+          FILE *sequence;
+
+          sequence=fopen(*argv, "r");
+
+          if (sequence == NULL) {
+            printf("Could not open the file %s \n", *argv);
+            exit(1);  }
+
+          fseek(sequence, 0, SEEK_END);
+          fgetpos(sequence, &pattern.pattern_length);
+          rewind(sequence);
+
+          pattern.user_pattern=malloc(pattern.pattern_length*sizeof(int));
+          pattern.pattern_repetitions=0;
+
+          for(i=1; i<pattern.pattern_length; i++) {
+            if(fgetc(sequence)=='1') pattern.user_pattern[i-1]=1;
+            else pattern.user_pattern[i-1]=0; }
+
+          fclose(sequence);
+
+          if (NEXT_IS_NUMBER()) {
+            NEXT_ARG();
+            pattern.pattern_repetitions=strtod(*argv,(char **)NULL);
+                        }
+          present[TCA_NETEM_LOSS_PATTERN] = 1;
+
          } else if (matches(*argv, "reorder") == 0) {
              NEXT_ARG();
              present[TCA_NETEM_REORDER] = 1;
@@ -292,6 +625,22 @@ static int netem_parse_opt(struct qdisc_util *qu, 
int argc, char **argv,
          addattr_l(n, 1024, TCA_NETEM_CORRUPT, &corrupt, 
sizeof(corrupt)) < 0)
          return -1;

+    if (present[TCA_NETEM_LOSS_GI] &&
+        addattr_l(n, 1024, TCA_NETEM_LOSS_GI, &GI, sizeof(GI)) < 0)
+        return -1;
+
+    if (present[TCA_NETEM_LOSS_GILBELL] &&
+        addattr_l(n, 1024, TCA_NETEM_LOSS_GILBELL, &gilbell, 
sizeof(gilbell)) < 0)
+        return -1;
+
+    if (present[TCA_NETEM_LOSS_PATTERN] &&
+        addattr_l(n, 1024, TCA_NETEM_LOSS_PATTERN, &pattern, 
sizeof(pattern)) < 0)
+        return -1;
+
+    if (present[TCA_NETEM_LOGGING] &&
+        addattr_l(n, 1024, TCA_NETEM_LOGGING, &logging, 
sizeof(logging)) < 0)
+        return -1;
+
      if (dist_data) {
          if (addattr_l(n, MAX_DIST * sizeof(dist_data[0]),
                    TCA_NETEM_DELAY_DIST,
@@ -308,6 +657,10 @@ static int netem_print_opt(struct qdisc_util *qu, 
FILE *f, struct rtattr *opt)
      const struct tc_netem_corr *cor = NULL;
      const struct tc_netem_reorder *reorder = NULL;
      const struct tc_netem_corrupt *corrupt = NULL;
+    const struct tc_netem_loss_GI *GI = NULL;
+    const struct tc_netem_loss_gilbell *gilbell = NULL;
+    const struct tc_netem_loss_pattern *pattern = NULL;
+    const struct tc_netem_logging *logging = NULL;
      struct tc_netem_qopt qopt;
      int len = RTA_PAYLOAD(opt) - sizeof(qopt);
      SPRINT_BUF(b1);
@@ -341,6 +694,26 @@ static int netem_print_opt(struct qdisc_util *qu, 
FILE *f, struct rtattr *opt)
                  return -1;
              corrupt = RTA_DATA(tb[TCA_NETEM_CORRUPT]);
          }
+        if (tb[TCA_NETEM_LOSS_GI]) {
+            if (RTA_PAYLOAD(tb[TCA_NETEM_LOSS_GI]) < sizeof(*GI))
+                return -1;
+            GI = RTA_DATA(tb[TCA_NETEM_LOSS_GI]);
+        }
+        if (tb[TCA_NETEM_LOSS_GILBELL]) {
+            if (RTA_PAYLOAD(tb[TCA_NETEM_LOSS_GILBELL]) < 
sizeof(*gilbell))
+                return -1;
+            gilbell = RTA_DATA(tb[TCA_NETEM_LOSS_GILBELL]);
+        }
+        if (tb[TCA_NETEM_LOSS_PATTERN]) {
+            if (RTA_PAYLOAD(tb[TCA_NETEM_LOSS_PATTERN]) < 
sizeof(*pattern))
+                return -1;
+            pattern = RTA_DATA(tb[TCA_NETEM_LOSS_PATTERN]);
+        }
+        if (tb[TCA_NETEM_LOGGING]) {
+            if (RTA_PAYLOAD(tb[TCA_NETEM_LOGGING]) < sizeof(*logging))
+                return -1;
+            logging = RTA_DATA(tb[TCA_NETEM_LOGGING]);
+        }
      }

      fprintf(f, "limit %d", qopt.limit);
@@ -387,6 +760,29 @@ static int netem_print_opt(struct qdisc_util *qu, 
FILE *f, struct rtattr *opt)
      if (qopt.gap)
          fprintf(f, " gap %lu", (unsigned long)qopt.gap);

+    if (GI && GI->p13) {
+        fprintf(f, " p13 %s", sprint_percent(GI->p13, b1));
+        fprintf(f, " p31 %s", sprint_percent(GI->p31, b1));
+        fprintf(f, " p32 %s", sprint_percent(GI->p32, b1));
+        fprintf(f, " p23 %s", sprint_percent(GI->p23, b1));
+        fprintf(f, " p14 %s", sprint_percent(GI->p14, b1));
+            }
+
+    if (gilbell && gilbell->p) {
+        fprintf(f, " p %s", sprint_percent(gilbell->p, b1));
+        fprintf(f, " r %s", sprint_percent(gilbell->r, b1));
+        fprintf(f, " h %s", sprint_percent(gilbell->h, b1));
+        if (gilbell->k)
+          fprintf(f, " k %s", sprint_percent(gilbell->k, b1));
+            }
+
+    if(logging && logging->level)
+      fprintf(f, " logging %d", logging->level);
+    if(pattern && pattern->pattern_length)
+      fprintf(f, " pattern_length %d", pattern->pattern_length);
+    if(pattern && pattern->pattern_repetitions)
+      fprintf(f, " pattern_repetitions %d", pattern->pattern_repetitions);
+
      return 0;
  }

-- 
1.6.3.3

-- 
Fabio Ludovici

