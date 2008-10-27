From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 04/05]IPtablestng/UserSpace - patch user commands
Date: Mon, 27 Oct 2008 08:57:08 +0330 (IRST)
Message-ID: <20081027052708.48E96C64095@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

patching iptables.c/iptables-save.c/iptables-restore.c/iptables.8.in to care of classifier

this patch add the '-C' command to change the classifier of the chains and also he changes the manner that iptables.c defines 'chains' as targets. he uses from a new target named 'chain' to send the name of the chain that is used as a target. by this all of the chains can be used as target.
Output format of the 'iptables-save' cammand is changed to display the chain classifier. he like this:
*filter
:INPUT ACCEPT tuple [0:0]
:FORWARD ACCEPT linear [0:0]
:OUTPUT ACCEPT linear [0:0]
the last name is the name of the classifier. also aome changes in iptables-restore to be aware about the name of the classifier.
also by this patch users can use "CONTINUE & RETURN" as target.

diff --git a/iptables.c b/iptables.c
index cff8cf4..d2df3a9 100644
--- a/iptables.c
+++ b/iptables.c
@@ -76,9 +76,10 @@
 #define CMD_SET_POLICY		0x0400U
 #define CMD_RENAME_CHAIN	0x0800U
 #define CMD_LIST_RULES		0x1000U
-#define NUMBER_OF_CMD	14
+#define CMD_CHG_CLASSIFIER	0x2000U
+#define NUMBER_OF_CMD	15
 static const char cmdflags[] = { 'I', 'D', 'D', 'R', 'A', 'L', 'F', 'Z',
-				 'N', 'X', 'P', 'E', 'S' };
+				 'N', 'X', 'P', 'E', 'S', 'C' };
 
 #define OPTION_OFFSET 256
 
@@ -112,6 +113,7 @@ static struct option original_opts[] = {
 	{.name = "delete-chain",  .has_arg = 2, .val = 'X'},
 	{.name = "rename-chain",  .has_arg = 1, .val = 'E'},
 	{.name = "policy",        .has_arg = 1, .val = 'P'},
+	{.name = "classifier",	  .has_arg = 1, .val = 'C'},
 	{.name = "source",        .has_arg = 1, .val = 's'},
 	{.name = "destination",   .has_arg = 1, .val = 'd'},
 	{.name = "src",           .has_arg = 1, .val = 's'}, /* synonym */
@@ -169,7 +171,8 @@ static char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
 /*DEL_CHAIN*/ {'x','x','x','x','x',' ','x','x','x','x','x','x'},
 /*SET_POLICY*/{'x','x','x','x','x',' ','x','x','x','x','x',' '},
 /*RENAME*/    {'x','x','x','x','x',' ','x','x','x','x','x','x'},
-/*LIST_RULES*/{'x','x','x','x','x',' ','x','x','x','x','x','x'}
+/*LIST_RULES*/{'x','x','x','x','x',' ','x','x','x','x','x','x'},
+/*CLASSIFIER*/{'x','x','x','x','x',' ','x','x','x','x','x','x'}
 };
 
 static int inverse_for_options[NUMBER_OF_OPT] =
@@ -317,6 +320,9 @@ exit_printhelp(struct iptables_rule_match *matches)
 "            -X [chain]		Delete a user-defined chain\n"
 "  --policy  -P chain target\n"
 "				Change policy on chain to target\n"
+"  --classifier \n"
+"	     -C chain classifier\n"
+"				Change chain classifeir\n"
 "  --rename-chain\n"
 "            -E old-chain new-chain\n"
 "				Change chain name, (moving any references)\n"
@@ -650,24 +656,28 @@ print_header(unsigned int format, const char *chain, iptc_handle_t *handle)
 {
 	struct ipt_counters counters;
 	const char *pol = iptc_get_policy(chain, &counters, handle);
+	unsigned int refs;
+	char *classifier;
 	printf("Chain %s", chain);
-	if (pol) {
-		printf(" (policy %s", pol);
-		if (!(format & FMT_NOCOUNTS)) {
-			fputc(' ', stdout);
-			print_num(counters.pcnt, (format|FMT_NOTABLE));
-			fputs("packets, ", stdout);
-			print_num(counters.bcnt, (format|FMT_NOTABLE));
-			fputs("bytes", stdout);
-		}
-		printf(")\n");
-	} else {
-		unsigned int refs;
-		if (!iptc_get_references(&refs, chain, handle))
-			printf(" (ERROR obtaining refs)\n");
-		else
-			printf(" (%u references)\n", refs);
+		
+	printf(" (policy %s", pol);
+	if (!(format & FMT_NOCOUNTS)) {
+		fputc(' ', stdout);
+		print_num(counters.pcnt, (format|FMT_NOTABLE));
+		fputs("packets, ", stdout);
+		print_num(counters.bcnt, (format|FMT_NOTABLE));
+		fputs("bytes", stdout);
 	}
+	printf(")\n");
+		
+	if (!iptc_get_references(&refs, chain, handle))
+		printf(" (ERROR obtaining refs)\n");
+	else
+		printf(" (%u references)\n", refs);
+
+	classifier = iptc_get_classifier(chain, handle);
+	if(classifier) printf(" (classifier %s)\n", classifier);
+	else printf(" (can't optain classifier) \n");
 
 	if (format & FMT_LINENUMBERS)
 		printf(FMT("%-4s ", "%s "), "num");
@@ -717,7 +727,7 @@ print_match(const struct ipt_entry_match *m,
 
 /* e is called `fw' here for historical reasons */
 static void
-print_firewall(const struct ipt_entry *fw,
+print_firewall(const struct pktt_entry *fw,
 	       const char *targname,
 	       unsigned int num,
 	       unsigned int format,
@@ -731,10 +741,10 @@ print_firewall(const struct ipt_entry *fw,
 	if (!iptc_is_chain(targname, handle))
 		target = find_target(targname, TRY_LOAD);
 	else
-		target = find_target(IPT_STANDARD_TARGET, LOAD_MUST_SUCCEED);
+		target = find_target("chain", LOAD_MUST_SUCCEED);
 
 	t = ipt_get_target((struct ipt_entry *)fw);
-	flags = fw->ip.flags;
+	flags = fw->pkt_header.ip4.flags;
 
 	if (format & FMT_LINENUMBERS)
 		printf(FMT("%-4u ", "%u "), num+1);
@@ -747,19 +757,19 @@ print_firewall(const struct ipt_entry *fw,
 	if (!(format & FMT_NOTARGET))
 		printf(FMT("%-9s ", "%s "), targname);
 
-	fputc(fw->ip.invflags & IPT_INV_PROTO ? '!' : ' ', stdout);
+	fputc(fw->pkt_header.ip4.invflags & IPT_INV_PROTO ? '!' : ' ', stdout);
 	{
-		char *pname = proto_to_name(fw->ip.proto, format&FMT_NUMERIC);
+		char *pname = proto_to_name(fw->pkt_header.ip4.proto, format&FMT_NUMERIC);
 		if (pname)
 			printf(FMT("%-5s", "%s "), pname);
 		else
-			printf(FMT("%-5hu", "%hu "), fw->ip.proto);
+			printf(FMT("%-5hu", "%hu "), fw->pkt_header.ip4.proto);
 	}
 
 	if (format & FMT_OPTIONS) {
 		if (format & FMT_NOTABLE)
 			fputs("opt ", stdout);
-		fputc(fw->ip.invflags & IPT_INV_FRAG ? '!' : '-', stdout);
+		fputc(fw->pkt_header.ip4.invflags & IPT_INV_FRAG ? '!' : '-', stdout);
 		fputc(flags & IPT_F_FRAG ? 'f' : '-', stdout);
 		fputc(' ', stdout);
 	}
@@ -767,54 +777,54 @@ print_firewall(const struct ipt_entry *fw,
 	if (format & FMT_VIA) {
 		char iface[IFNAMSIZ+2];
 
-		if (fw->ip.invflags & IPT_INV_VIA_IN) {
+		if (fw->pkt_header.ip4.invflags & IPT_INV_VIA_IN) {
 			iface[0] = '!';
 			iface[1] = '\0';
 		}
 		else iface[0] = '\0';
 
-		if (fw->ip.iniface[0] != '\0') {
-			strcat(iface, fw->ip.iniface);
+		if (fw->pkt_header.ip4.iniface[0] != '\0') {
+			strcat(iface, fw->pkt_header.ip4.iniface);
 		}
 		else if (format & FMT_NUMERIC) strcat(iface, "*");
 		else strcat(iface, "any");
 		printf(FMT(" %-6s ","in %s "), iface);
 
-		if (fw->ip.invflags & IPT_INV_VIA_OUT) {
+		if (fw->pkt_header.ip4.invflags & IPT_INV_VIA_OUT) {
 			iface[0] = '!';
 			iface[1] = '\0';
 		}
 		else iface[0] = '\0';
 
-		if (fw->ip.outiface[0] != '\0') {
-			strcat(iface, fw->ip.outiface);
+		if (fw->pkt_header.ip4.outiface[0] != '\0') {
+			strcat(iface, fw->pkt_header.ip4.outiface);
 		}
 		else if (format & FMT_NUMERIC) strcat(iface, "*");
 		else strcat(iface, "any");
 		printf(FMT("%-6s ","out %s "), iface);
 	}
 
-	fputc(fw->ip.invflags & IPT_INV_SRCIP ? '!' : ' ', stdout);
-	if (fw->ip.smsk.s_addr == 0L && !(format & FMT_NUMERIC))
+	fputc(fw->pkt_header.ip4.invflags & IPT_INV_SRCIP ? '!' : ' ', stdout);
+	if (fw->pkt_header.ip4.smsk.s_addr == 0L && !(format & FMT_NUMERIC))
 		printf(FMT("%-19s ","%s "), "anywhere");
 	else {
 		if (format & FMT_NUMERIC)
-			sprintf(buf, "%s", ipaddr_to_numeric(&fw->ip.src));
+			sprintf(buf, "%s", ipaddr_to_numeric(&fw->pkt_header.ip4.src));
 		else
-			sprintf(buf, "%s", ipaddr_to_anyname(&fw->ip.src));
-		strcat(buf, ipmask_to_numeric(&fw->ip.smsk));
+			sprintf(buf, "%s", ipaddr_to_anyname(&fw->pkt_header.ip4.src));
+		strcat(buf, ipmask_to_numeric(&fw->pkt_header.ip4.smsk));
 		printf(FMT("%-19s ","%s "), buf);
 	}
 
-	fputc(fw->ip.invflags & IPT_INV_DSTIP ? '!' : ' ', stdout);
-	if (fw->ip.dmsk.s_addr == 0L && !(format & FMT_NUMERIC))
+	fputc(fw->pkt_header.ip4.invflags & IPT_INV_DSTIP ? '!' : ' ', stdout);
+	if (fw->pkt_header.ip4.dmsk.s_addr == 0L && !(format & FMT_NUMERIC))
 		printf(FMT("%-19s ","-> %s"), "anywhere");
 	else {
 		if (format & FMT_NUMERIC)
-			sprintf(buf, "%s", ipaddr_to_numeric(&fw->ip.dst));
+			sprintf(buf, "%s", ipaddr_to_numeric(&fw->pkt_header.ip4.dst));
 		else
-			sprintf(buf, "%s", ipaddr_to_anyname(&fw->ip.dst));
-		strcat(buf, ipmask_to_numeric(&fw->ip.dmsk));
+			sprintf(buf, "%s", ipaddr_to_anyname(&fw->pkt_header.ip4.dst));
+		strcat(buf, ipmask_to_numeric(&fw->pkt_header.ip4.dmsk));
 		printf(FMT("%-19s ","-> %s"), buf);
 	}
 
@@ -822,16 +832,16 @@ print_firewall(const struct ipt_entry *fw,
 		fputs("  ", stdout);
 
 #ifdef IPT_F_GOTO
-	if(fw->ip.flags & IPT_F_GOTO)
+	if(fw->pkt_header.ip4.flags & IPT_F_GOTO)
 		printf("[goto] ");
 #endif
 
-	IPT_MATCH_ITERATE(fw, print_match, &fw->ip, format & FMT_NUMERIC);
+	IPT_MATCH_ITERATE(fw, print_match, &fw->pkt_header.ip4, format & FMT_NUMERIC);
 
 	if (target) {
 		if (target->print)
 			/* Print the target information. */
-			target->print(&fw->ip, t, format & FMT_NUMERIC);
+			target->print(&fw->pkt_header.ip4, t, format & FMT_NUMERIC);
 	} else if (t->u.target_size != sizeof(*t))
 		printf("[%u bytes of unknown target data] ",
 		       (unsigned int)(t->u.target_size - sizeof(*t)));
@@ -864,9 +874,9 @@ append_entry(const ipt_chainlabel chain,
 	int ret = 1;
 
 	for (i = 0; i < nsaddrs; i++) {
-		fw->ip.src.s_addr = saddrs[i].s_addr;
+		fw->pkt_header.ip4.src.s_addr = saddrs[i].s_addr;
 		for (j = 0; j < ndaddrs; j++) {
-			fw->ip.dst.s_addr = daddrs[j].s_addr;
+			fw->pkt_header.ip4.dst.s_addr = daddrs[j].s_addr;
 			if (verbose)
 				print_firewall_line(fw, *handle);
 			ret &= iptc_append_entry(chain, fw, handle);
@@ -885,8 +895,8 @@ replace_entry(const ipt_chainlabel chain,
 	      int verbose,
 	      iptc_handle_t *handle)
 {
-	fw->ip.src.s_addr = saddr->s_addr;
-	fw->ip.dst.s_addr = daddr->s_addr;
+	fw->pkt_header.ip4.src.s_addr = saddr->s_addr;
+	fw->pkt_header.ip4.dst.s_addr = daddr->s_addr;
 
 	if (verbose)
 		print_firewall_line(fw, *handle);
@@ -908,9 +918,9 @@ insert_entry(const ipt_chainlabel chain,
 	int ret = 1;
 
 	for (i = 0; i < nsaddrs; i++) {
-		fw->ip.src.s_addr = saddrs[i].s_addr;
+		fw->pkt_header.ip4.src.s_addr = saddrs[i].s_addr;
 		for (j = 0; j < ndaddrs; j++) {
-			fw->ip.dst.s_addr = daddrs[j].s_addr;
+			fw->pkt_header.ip4.dst.s_addr = daddrs[j].s_addr;
 			if (verbose)
 				print_firewall_line(fw, *handle);
 			ret &= iptc_insert_entry(chain, fw, rulenum, handle);
@@ -970,9 +980,9 @@ delete_entry(const ipt_chainlabel chain,
 
 	mask = make_delete_mask(fw, matches);
 	for (i = 0; i < nsaddrs; i++) {
-		fw->ip.src.s_addr = saddrs[i].s_addr;
+		fw->pkt_header.ip4.src.s_addr = saddrs[i].s_addr;
 		for (j = 0; j < ndaddrs; j++) {
-			fw->ip.dst.s_addr = daddrs[j].s_addr;
+			fw->pkt_header.ip4.dst.s_addr = daddrs[j].s_addr;
 			if (verbose)
 				print_firewall_line(fw, *handle);
 			ret &= iptc_delete_entry(chain, fw, mask, handle);
@@ -1224,7 +1234,7 @@ static void print_ip(char *prefix, u_int32_t ip, u_int32_t mask, int invert)
 
 /* We want this to be readable, so only print out neccessary fields.
  * Because that's the kind of world I want to live in.  */
-void print_rule(const struct ipt_entry *e,
+void print_rule(const struct pktt_entry *e,
 		iptc_handle_t *h, const char *chain, int counters)
 {
 	struct ipt_entry_target *t;
@@ -1238,27 +1248,27 @@ void print_rule(const struct ipt_entry *e,
 	printf("-A %s ", chain);
 
 	/* Print IP part. */
-	print_ip("-s", e->ip.src.s_addr,e->ip.smsk.s_addr,
-			e->ip.invflags & IPT_INV_SRCIP);
+	print_ip("-s", e->pkt_header.ip4.src.s_addr,e->pkt_header.ip4.smsk.s_addr,
+			e->pkt_header.ip4.invflags & IPT_INV_SRCIP);
 
-	print_ip("-d", e->ip.dst.s_addr, e->ip.dmsk.s_addr,
-			e->ip.invflags & IPT_INV_DSTIP);
+	print_ip("-d", e->pkt_header.ip4.dst.s_addr, e->pkt_header.ip4.dmsk.s_addr,
+			e->pkt_header.ip4.invflags & IPT_INV_DSTIP);
 
-	print_iface('i', e->ip.iniface, e->ip.iniface_mask,
-		    e->ip.invflags & IPT_INV_VIA_IN);
+	print_iface('i', e->pkt_header.ip4.iniface, e->pkt_header.ip4.iniface_mask,
+		    e->pkt_header.ip4.invflags & IPT_INV_VIA_IN);
 
-	print_iface('o', e->ip.outiface, e->ip.outiface_mask,
-		    e->ip.invflags & IPT_INV_VIA_OUT);
+	print_iface('o', e->pkt_header.ip4.outiface, e->pkt_header.ip4.outiface_mask,
+		    e->pkt_header.ip4.invflags & IPT_INV_VIA_OUT);
 
-	print_proto(e->ip.proto, e->ip.invflags & IPT_INV_PROTO);
+	print_proto(e->pkt_header.ip4.proto, e->pkt_header.ip4.invflags & IPT_INV_PROTO);
 
-	if (e->ip.flags & IPT_F_FRAG)
+	if (e->pkt_header.ip4.flags & IPT_F_FRAG)
 		printf("%s-f ",
-		       e->ip.invflags & IPT_INV_FRAG ? "! " : "");
+		       e->pkt_header.ip4.invflags & IPT_INV_FRAG ? "! " : "");
 
 	/* Print matchinfo part */
 	if (e->target_offset) {
-		IPT_MATCH_ITERATE(e, print_match_save, &e->ip);
+		IPT_MATCH_ITERATE(e, print_match_save, &e->pkt_header.ip4);
 	}
 
 	/* print counters for iptables -R */
@@ -1269,7 +1279,7 @@ void print_rule(const struct ipt_entry *e,
 	target_name = iptc_get_target(e, h);
 	if (target_name && (*target_name != '\0'))
 #ifdef IPT_F_GOTO
-		printf("-%c %s ", e->ip.flags & IPT_F_GOTO ? 'g' : 'j', target_name);
+		printf("-%c %s ", e->pkt_header.ip4.flags & IPT_F_GOTO ? 'g' : 'j', target_name);
 #else
 		printf("-j %s ", target_name);
 #endif
@@ -1280,6 +1290,9 @@ void print_rule(const struct ipt_entry *e,
 		struct xtables_target *target
 			= find_target(t->u.user.name, TRY_LOAD);
 
+		if(!target && iptc_is_chain(t->u.user.name, *h))
+			target = find_target("chain", LOAD_MUST_SUCCEED);
+
 		if (!target) {
 			fprintf(stderr, "Can't find library for target `%s'\n",
 				t->u.user.name);
@@ -1287,7 +1300,7 @@ void print_rule(const struct ipt_entry *e,
 		}
 
 		if (target->save)
-			target->save(&e->ip, t);
+			target->save(&e->pkt_header.ip4, t);
 		else {
 			/* If the target size is greater than ipt_entry_target
 			 * there is something to be saved, we just don't know
@@ -1372,9 +1385,10 @@ generate_entry(const struct ipt_entry *fw,
 
 	e = fw_malloc(size + target->u.target_size);
 	*e = *fw;
-	e->target_offset = size;
-	e->next_offset = size + target->u.target_size;
-
+	//e->target_offset = size;
+	//e->next_offset = size + target->u.target_size;
+	e->size = size + target->u.target_size;
+	e->target_offset = size - sizeof(struct ipt_entry);
 	size = 0;
 	for (matchp = matches; matchp; matchp = matchp->next) {
 		memcpy(e->elems + size, matchp->match->m, matchp->match->m->u.match_size);
@@ -1439,7 +1453,7 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 	int c, verbose = 0;
 	const char *chain = NULL;
 	const char *shostnetworkmask = NULL, *dhostnetworkmask = NULL;
-	const char *policy = NULL, *newname = NULL;
+	const char *policy = NULL, *newname = NULL, *classifier = NULL;
 	unsigned int rulenum = 0, options = 0, command = 0;
 	const char *pcnt = NULL, *bcnt = NULL;
 	int ret = 1;
@@ -1474,7 +1488,7 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 	opterr = 0;
 
 	while ((c = getopt_long(argc, argv,
-	   "-A:D:R:I:L::S::M:F::Z::N:X::E:P:Vh::o:p:s:d:j:i:fbvnt:m:xc:g:",
+	   "-A:D:R:I:L::S::M:F::Z::N:X::E:P:C:Vh::o:p:s:d:j:i:fbvnt:m:xc:g:",
 					   opts, NULL)) != -1) {
 		switch (c) {
 			/*
@@ -1611,7 +1625,18 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 					   "-%c requires a chain and a policy",
 					   cmd2char(CMD_SET_POLICY));
 			break;
-
+		case 'C':
+			add_command(&command, CMD_CHG_CLASSIFIER,
+						CMD_NONE, invert);
+			chain = optarg;
+			if (optind < argc && argv[optind][0] != '-'
+				&& argv[optind][0]!= '!')
+				classifier = argv[optind++];
+			else
+				exit_error(PARAMETER_PROBLEM,
+					"-%c requires a chain and a classifier",
+					cmd2char(CMD_CHG_CLASSIFIER));
+			break;
 		case 'h':
 			if (!optarg)
 				optarg = argv[optind];
@@ -1627,7 +1652,7 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 			 */
 		case 'p':
 			check_inverse(optarg, &invert, &optind, argc);
-			set_option(&options, OPT_PROTOCOL, &fw.ip.invflags,
+			set_option(&options, OPT_PROTOCOL, &fw.pkt_header.ip4.invflags,
 				   invert);
 
 			/* Canonicalize into lower case */
@@ -1635,39 +1660,39 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 				*protocol = tolower(*protocol);
 
 			protocol = argv[optind-1];
-			fw.ip.proto = parse_protocol(protocol);
+			fw.pkt_header.ip4.proto = parse_protocol(protocol);
 
-			if (fw.ip.proto == 0
-			    && (fw.ip.invflags & IPT_INV_PROTO))
+			if (fw.pkt_header.ip4.proto == 0
+			    && (fw.pkt_header.ip4.invflags & IPT_INV_PROTO))
 				exit_error(PARAMETER_PROBLEM,
 					   "rule would never match protocol");
 			break;
 
 		case 's':
 			check_inverse(optarg, &invert, &optind, argc);
-			set_option(&options, OPT_SOURCE, &fw.ip.invflags,
+			set_option(&options, OPT_SOURCE, &fw.pkt_header.ip4.invflags,
 				   invert);
 			shostnetworkmask = argv[optind-1];
 			break;
 
 		case 'd':
 			check_inverse(optarg, &invert, &optind, argc);
-			set_option(&options, OPT_DESTINATION, &fw.ip.invflags,
+			set_option(&options, OPT_DESTINATION, &fw.pkt_header.ip4.invflags,
 				   invert);
 			dhostnetworkmask = argv[optind-1];
 			break;
 
 #ifdef IPT_F_GOTO
 		case 'g':
-			set_option(&options, OPT_JUMP, &fw.ip.invflags,
+			set_option(&options, OPT_JUMP, &fw.pkt_header.ip4.invflags,
 				   invert);
-			fw.ip.flags |= IPT_F_GOTO;
+			fw.pkt_header.ip4.flags |= IPT_F_GOTO;
 			jumpto = parse_target(optarg);
 			break;
 #endif
 
 		case 'j':
-			set_option(&options, OPT_JUMP, &fw.ip.invflags,
+			set_option(&options, OPT_JUMP, &fw.pkt_header.ip4.invflags,
 				   invert);
 			jumpto = parse_target(optarg);
 			/* TRY_LOAD (may be chain name) */
@@ -1698,32 +1723,32 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 
 		case 'i':
 			check_inverse(optarg, &invert, &optind, argc);
-			set_option(&options, OPT_VIANAMEIN, &fw.ip.invflags,
+			set_option(&options, OPT_VIANAMEIN, &fw.pkt_header.ip4.invflags,
 				   invert);
 			parse_interface(argv[optind-1],
-					fw.ip.iniface,
-					fw.ip.iniface_mask);
+					fw.pkt_header.ip4.iniface,
+					fw.pkt_header.ip4.iniface_mask);
 			break;
 
 		case 'o':
 			check_inverse(optarg, &invert, &optind, argc);
-			set_option(&options, OPT_VIANAMEOUT, &fw.ip.invflags,
+			set_option(&options, OPT_VIANAMEOUT, &fw.pkt_header.ip4.invflags,
 				   invert);
 			parse_interface(argv[optind-1],
-					fw.ip.outiface,
-					fw.ip.outiface_mask);
+					fw.pkt_header.ip4.outiface,
+					fw.pkt_header.ip4.outiface_mask);
 			break;
 
 		case 'f':
-			set_option(&options, OPT_FRAGMENT, &fw.ip.invflags,
+			set_option(&options, OPT_FRAGMENT, &fw.pkt_header.ip4.invflags,
 				   invert);
-			fw.ip.flags |= IPT_F_FRAG;
+			fw.pkt_header.ip4.flags |= IPT_F_FRAG;
 			break;
 
 		case 'v':
 			if (!verbose)
 				set_option(&options, OPT_VERBOSE,
-					   &fw.ip.invflags, invert);
+					   &fw.pkt_header.ip4.invflags, invert);
 			verbose++;
 			break;
 
@@ -1756,7 +1781,7 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 		break;
 
 		case 'n':
-			set_option(&options, OPT_NUMERIC, &fw.ip.invflags,
+			set_option(&options, OPT_NUMERIC, &fw.pkt_header.ip4.invflags,
 				   invert);
 			break;
 
@@ -1768,7 +1793,7 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 			break;
 
 		case 'x':
-			set_option(&options, OPT_EXPANDED, &fw.ip.invflags,
+			set_option(&options, OPT_EXPANDED, &fw.pkt_header.ip4.invflags,
 				   invert);
 			break;
 
@@ -1781,7 +1806,7 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 			exit(0);
 
 		case '0':
-			set_option(&options, OPT_LINENUMBERS, &fw.ip.invflags,
+			set_option(&options, OPT_LINENUMBERS, &fw.pkt_header.ip4.invflags,
 				   invert);
 			break;
 
@@ -1791,7 +1816,7 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 
 		case 'c':
 
-			set_option(&options, OPT_COUNTERS, &fw.ip.invflags,
+			set_option(&options, OPT_COUNTERS, &fw.pkt_header.ip4.invflags,
 				   invert);
 			pcnt = optarg;
 			bcnt = strchr(pcnt + 1, ',');
@@ -1945,14 +1970,14 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 
 	if (shostnetworkmask)
 		ipparse_hostnetworkmask(shostnetworkmask, &saddrs,
-					&fw.ip.smsk, &nsaddrs);
+					&fw.pkt_header.ip4.smsk, &nsaddrs);
 
 	if (dhostnetworkmask)
 		ipparse_hostnetworkmask(dhostnetworkmask, &daddrs,
-					&fw.ip.dmsk, &ndaddrs);
+					&fw.pkt_header.ip4.dmsk, &ndaddrs);
 
 	if ((nsaddrs > 1 || ndaddrs > 1) &&
-	    (fw.ip.invflags & (IPT_INV_SRCIP | IPT_INV_DSTIP)))
+	    (fw.pkt_header.ip4.invflags & (IPT_INV_SRCIP | IPT_INV_DSTIP)))
 		exit_error(PARAMETER_PROBLEM, "! not allowed with multiple"
 			   " source or destination IP addresses");
 
@@ -2022,8 +2047,16 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 			|| iptc_is_chain(jumpto, *handle))) {
 			size_t size;
 
-			target = find_target(IPT_STANDARD_TARGET,
-					     LOAD_MUST_SUCCEED);
+			//target = find_target(IPT_STANDARD_TARGET,
+			//		     LOAD_MUST_SUCCEED);
+
+			/* chain is an specific target */
+			if(iptc_is_chain(jumpto, *handle))
+				target = find_target("chain",
+					LOAD_MUST_SUCCEED);
+			else
+				target = find_target(IPT_STANDARD_TARGET,
+					LOAD_MUST_SUCCEED);
 
 			size = sizeof(struct ipt_entry_target)
 				+ target->size;
@@ -2043,7 +2076,7 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 			 * existant OR if the user just misspelled a
 			 * chain. */
 #ifdef IPT_F_GOTO
-			if (fw.ip.flags & IPT_F_GOTO)
+			if (fw.pkt_header.ip4.flags & IPT_F_GOTO)
 				exit_error(PARAMETER_PROBLEM,
 					   "goto '%s' is not a chain\n", jumpto);
 #endif
@@ -2068,15 +2101,15 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 				   handle, matches);
 		break;
 	case CMD_DELETE_NUM:
-		ret = iptc_delete_num_entry(chain, rulenum - 1, handle);
+		ret = iptc_delete_num_entry(chain, rulenum /*- 1*/, handle);
 		break;
 	case CMD_REPLACE:
-		ret = replace_entry(chain, e, rulenum - 1,
+		ret = replace_entry(chain, e, rulenum /*- 1*/,
 				    saddrs, daddrs, options&OPT_VERBOSE,
 				    handle);
 		break;
 	case CMD_INSERT:
-		ret = insert_entry(chain, e, rulenum - 1,
+		ret = insert_entry(chain, e, rulenum /*- 1*/,
 				   nsaddrs, saddrs, ndaddrs, daddrs,
 				   options&OPT_VERBOSE,
 				   handle);
@@ -2122,6 +2155,9 @@ int do_command(int argc, char *argv[], char **table, iptc_handle_t *handle)
 	case CMD_SET_POLICY:
 		ret = iptc_set_policy(chain, policy, options&OPT_COUNTERS ? &fw.counters : NULL, handle);
 		break;
+	case CMD_CHG_CLASSIFIER:
+		ret = iptc_chg_classifier(chain, classifier, handle);
+		break;
 	default:
 		/* We should never reach this... */
 		exit_tryhelp(2);
diff --git a/iptables-save.c b/iptables-save.c
index ecccac4..031a583 100644
--- a/iptables-save.c
+++ b/iptables-save.c
@@ -82,16 +82,13 @@ static int do_output(const char *tablename)
 		for (chain = iptc_first_chain(&h);
 		     chain;
 		     chain = iptc_next_chain(&h)) {
+			struct ipt_counters count;
 
 			printf(":%s ", chain);
-			if (iptc_builtin(chain, h)) {
-				struct ipt_counters count;
-				printf("%s ",
-				       iptc_get_policy(chain, &count, &h));
-				printf("[%llu:%llu]\n", (unsigned long long)count.pcnt, (unsigned long long)count.bcnt);
-			} else {
-				printf("- [0:0]\n");
-			}
+			printf("%s ",
+			       iptc_get_policy(chain, &count, &h));
+			printf("%s ", iptc_get_classifier(chain, &h));
+			printf("[%llu:%llu]\n", (unsigned long long)count.pcnt, (unsigned long long)count.bcnt);
 		}
 
 
diff --git a/iptables.8.in b/iptables.8.in
index 0b945cb..0a65aa5 100644
--- a/iptables.8.in
+++ b/iptables.8.in
@@ -41,6 +41,8 @@ iptables \- administration tool for IPv4 packet filtering and NAT
 .br
 .BR "iptables [-t table] -P " "chain target [options]"
 .br
+.BR "iptables [-t table] -C " "chain classifeir "
+.br
 .BR "iptables [-t table] -E " "old-chain-name new-chain-name"
 .SH DESCRIPTION
 .B Iptables
@@ -58,10 +60,11 @@ table.
 A firewall rule specifies criteria for a packet and a target.  If the
 packet does not match, the next rule in the chain is the examined; if
 it does match, then the next rule is specified by the value of the
-target, which can be the name of a user-defined chain or one of the
+target, which can be the name of a chain or one of the
 special values 
 .IR ACCEPT ,
 .IR DROP ,
+.IR CONTINUE ,
 .IR QUEUE ,
 or
 .IR RETURN .
@@ -70,6 +73,8 @@ or
 means to let the packet through.
 .I DROP
 means to drop the packet on the floor.
+.I CONTINUE
+meane going to next rule
 .I QUEUE
 means to pass the packet to userspace.  (How the packet can be received
 by a userspace process differs by the particular queue handler.  2.4.x
@@ -234,8 +239,11 @@ non-builtin chain in the table.
 .TP
 .BI "-P, --policy " "chain target"
 Set the policy for the chain to the given target.  See the section
+.BI "-C, --classifier " "chain classifier"
+chaine the chain classifier
+.TP
 .B TARGETS
-for the legal targets.  Only built-in (non-user-defined) chains can have
+for the legal targets. In this version all of the chains can have
 policies, and neither built-in nor user-defined chains can be policy
 targets.
 .TP
diff --git a/iptables-restore.c b/iptables-restore.c
index 4b199d9..94c5d24 100644
--- a/iptables-restore.c
+++ b/iptables-restore.c
@@ -75,7 +75,7 @@ static iptc_handle_t create_handle(const char *tablename, const char *modprobe)
 	return handle;
 }
 
-static int parse_counters(char *string, struct ipt_counters *ctr)
+static int parse_counters(char *string, struct pktt_counters *ctr)
 {
 	unsigned long long pcnt, bcnt;
 	int ret;
@@ -247,7 +247,8 @@ main(int argc, char *argv[])
 
 		} else if ((buffer[0] == ':') && (in_table)) {
 			/* New chain. */
-			char *policy, *chain;
+			char *policy, *chain, *classifier;
+			struct pktt_counters count;
 
 			chain = strtok(buffer+1, " \t\n");
 			DEBUGP("line %u, chain '%s'\n", line, chain);
@@ -285,35 +286,46 @@ main(int argc, char *argv[])
 				exit(1);
 			}
 
-			if (strcmp(policy, "-") != 0) {
-				struct ipt_counters count;
-
-				if (counters) {
-					char *ctrs;
-					ctrs = strtok(NULL, " \t\n");
-
-					if (!ctrs || !parse_counters(ctrs, &count))
-						exit_error(PARAMETER_PROBLEM,
-							   "invalid policy counters "
-							   "for chain '%s'\n", chain);
-
-				} else {
-					memset(&count, 0,
-					       sizeof(struct ipt_counters));
-				}
+			classifier = strtok(NULL, " \t\n");
+			DEBUGP("line %u, classifier '%s'\n", line, classifier);
+			if(!classifier){
+				exit_error(PARAMETER_PROBLEM,
+					"%s: line %u classifier invalid\n",
+					program_name, line);
+				exit(1);
+			}
 
-				DEBUGP("Setting policy of chain %s to %s\n",
-					chain, policy);
+			if (counters) {
+				char *ctrs;
+				ctrs = strtok(NULL, " \t\n");
 
-				if (!iptc_set_policy(chain, policy, &count,
-						     &handle))
-					exit_error(OTHER_PROBLEM,
-						"Can't set policy `%s'"
-						" on `%s' line %u: %s\n",
-						chain, policy, line,
-						iptc_strerror(errno));
+				if (!ctrs || !parse_counters(ctrs, &count))
+					exit_error(PARAMETER_PROBLEM,
+						   "invalid policy counters "
+						   "for chain '%s'\n", chain);
+			} else {
+				memset(&count, 0,
+				       sizeof(struct ipt_counters));
 			}
 
+			DEBUGP("Setting policy of chain %s to %s\n",
+				chain, policy);
+
+			if (!iptc_set_policy(chain, policy, &count,
+					     &handle))
+				exit_error(OTHER_PROBLEM,
+					"Can't set policy `%s'"
+					" on `%s' line %u: %s\n",
+					chain, policy, line,
+					iptc_strerror(errno));
+
+			if(!iptc_chg_classifier(chain, classifier, &handle))
+				exit_error(OTHER_PROBLEM,
+					"Can't change classifier '%s'"
+					"to '%s' line %u: %s\n",
+					chain, classifier, line,
+					iptc_strerror(errno));
+
 			ret = 1;
 
 		} else if (in_table) {
diff --git a/xtables.c b/xtables.c
index 8241687..5aeb755 100644
--- a/xtables.c
+++ b/xtables.c
@@ -440,7 +440,8 @@ struct xtables_target *find_target(const char *name, enum xt_tryload tryload)
 	    || strcmp(name, XTC_LABEL_ACCEPT) == 0
 	    || strcmp(name, XTC_LABEL_DROP) == 0
 	    || strcmp(name, XTC_LABEL_QUEUE) == 0
-	    || strcmp(name, XTC_LABEL_RETURN) == 0)
+	    || strcmp(name, XTC_LABEL_RETURN) == 0
+	    || strcmp(name, XTC_LABEL_CONTINUE) ==0 )
 		name = "standard";
 
 	for (ptr = xtables_targets; ptr; ptr = ptr->next) {
@@ -526,12 +527,14 @@ static int compatible_revision(const char *name, u_int8_t revision, int opt)
 
 static int compatible_match_revision(const char *name, u_int8_t revision)
 {
-	return compatible_revision(name, revision, afinfo.so_rev_match);
+	//return compatible_revision(name, revision, afinfo.so_rev_match);
+	return 1;
 }
 
 static int compatible_target_revision(const char *name, u_int8_t revision)
 {
-	return compatible_revision(name, revision, afinfo.so_rev_target);
+	//return compatible_revision(name, revision, afinfo.so_rev_target);
+	return 1;
 }
 
 void xtables_register_match(struct xtables_match *me)

diff --git a/include/libiptc/libxtc.h b/include/libiptc/libxtc.h
index 031afb5..5487536 100644
--- a/include/libiptc/libxtc.h
+++ b/include/libiptc/libxtc.h
@@ -26,7 +26,7 @@ typedef char xt_chainlabel[32];
 #define XTC_LABEL_DROP    "DROP"
 #define XTC_LABEL_QUEUE   "QUEUE"
 #define XTC_LABEL_RETURN  "RETURN"
-
+#define XTC_LABEL_CONTINUE "CONTINUE"
 
 #ifdef __cplusplus
 }

