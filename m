From: Pablo Neira <pablo@eurodev.net>
Subject: Re: iptables versioning feature causes ABI breakage
Date: Thu, 31 Mar 2005 02:13:43 +0200
Message-ID: <424B40B7.50402@eurodev.net>
References: <1111666300.1037.40.camel@jzny.localdomain>	
	<42432E51.1080309@eurodev.net>
	<1111789452.1089.725.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090602000808000302030400"
Cc: netdev <netdev@oss.sgi.com>, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>, Harald Welte <laforge@gnumonks.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: hadi@znyx.com
In-Reply-To: <1111789452.1089.725.camel@jzny.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090602000808000302030400
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Jamal Hadi Salim wrote:
> On Thu, 2005-03-24 at 16:17, Pablo Neira wrote:
>>I was also involved in that change together with Rusty around january. 
>>It's a new infrastructure to extend matches/targets without breaking 
>>backward compatibility with previous releases of target/matches/iptables.
> 
> I think in the future this will go fine; all actions have a version
> field as well that is set to 0 at the moment.

Hm, it's not set to 0, it's set to the highest revision of the target 
found in the kernel.

tc qdisc add dev eth0 ingress
tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 match ip src 
10.0.2.24/32 flowid 1:16 action ipt -j MARK --and-mark 0x1

That example works fine and those options are only available in the 
brand new revision of MARK.

>>Your patch for tc to fix the problem looks fine. BTW, you can now use 
>>extended MARK features like --and-mark and --or-mark ;->
>>
> 
> cool.
> 
> Would you like to pay for your sins;-> by looking at my code to see it
> doesnt break or miss things?

I've found some problems, attached a patch to fix some things:

- a leak in option handling
- it doesn't check that the target received the correct parameters 
(m->final_check).

--
Pablo

--------------090602000808000302030400
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== tc/m_ipt.c 1.5 vs edited =====
--- 1.5/tc/m_ipt.c	2005-03-24 12:53:31 +01:00
+++ edited/tc/m_ipt.c	2005-03-31 02:05:42 +02:00
@@ -69,6 +69,7 @@
 };
 
 static struct iptables_target *t_list = NULL;
+static struct option *opts = original_opts;
 static unsigned int global_option_offset = 0;
 #define OPTION_OFFSET 256
 
@@ -169,18 +170,13 @@
 	return result;
 }
 
-static struct option *
-copy_options(struct option *oldopts)
+static void free_opts(struct option *opts)
 {
-	struct option *merge;
-	unsigned int num_old;
-	for (num_old = 0; oldopts[num_old].name; num_old++) ;
-	merge = malloc(sizeof (struct option) * (num_old + 1));
-	if (NULL == merge)
-		return NULL;
-	memcpy(merge, oldopts, num_old * sizeof (struct option));
-	memset(merge + num_old, 0, sizeof (struct option));
-	return merge;
+	if (opts != original_opts) {
+		free(opts);
+		opts = original_opts;
+		global_option_offset = 0;
+	}
 }
 
 static struct option *
@@ -385,7 +381,6 @@
 	int c;
 	int rargc = *argc_p;
 	char **argv = *argv_p;
-	struct option *opts;
 	int argc = 0, iargc = 0;
 	char k[16];
 	int res = -1;
@@ -409,11 +404,6 @@
 		return -1;
 	}
 
-	opts = copy_options(original_opts);
-
-	if (NULL == opts)
-		return -1;
-
 	while (1) {
 		c = getopt_long(argc, argv, "j:", opts, NULL);
 		if (c == -1)
@@ -440,23 +430,14 @@
 		default:
 			memset(&fw, 0, sizeof (fw));
 			if (m) {
-				unsigned int fake_flags = 0;
 				m->parse(c - m->option_offset, argv, 0,
-					 &fake_flags, NULL, &m->t);
+					 &m->tflags, NULL, &m->t);
 			} else {
 				fprintf(stderr," failed to find target %s\n\n", optarg);
 				return -1;
 
 			}
 			ok++;
-
-			/*m->final_check(m->t); -- Is this necessary?
-			** useful when theres depencies
-			** eg ipt_TCPMSS.c has have the TCP match loaded
-			** before this can be used;
-			**  also seems the ECN target needs it 
-			*/
-
 			break;
 
 		}
@@ -466,6 +447,7 @@
 		if (matches(argv[optind], "index") == 0) {
 			if (get_u32(&index, argv[optind + 1], 10)) {
 				fprintf(stderr, "Illegal \"index\"\n");
+				free_opts(opts);
 				return -1;
 			}
 			iok++;
@@ -479,6 +461,10 @@
 		return -1;
 	}
 
+	/* check that we passed the correct parameters to the target */
+	if (m)
+		m->final_check(m->tflags);
+
 	{
 		struct tcmsg *t = NLMSG_DATA(n);
 		if (t->tcm_parent != TC_H_ROOT
@@ -519,6 +505,7 @@
 	*argv_p = argv;
 	
 	optind = 1;
+	free_opts(opts);
 
 	return 0;
 
@@ -529,16 +516,10 @@
 {
 	struct rtattr *tb[TCA_IPT_MAX + 1];
 	struct ipt_entry_target *t = NULL;
-	struct option *opts;
 
 	if (arg == NULL)
 		return -1;
 
-	opts = copy_options(original_opts);
-
-	if (NULL == opts)
-		return -1;
-
 	parse_rtattr_nested(tb, TCA_IPT_MAX, arg);
 
 	if (tb[TCA_IPT_TABLE] == NULL) {
@@ -601,6 +582,7 @@
 		fprintf(f, " \n");
 
 	}
+	free_opts(opts);
 
 	return 0;
 }

--------------090602000808000302030400--
