From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Iproute2: update
Date: Mon, 17 Jan 2005 21:20:22 +0100
Message-ID: <20050117202022.GG26856@postel.suug.ch>
References: <20050112125903.64d42737@dxpl.pdx.osdl.net> <1105895352.1091.705.camel@jzny.localdomain> <1105897532.1097.749.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@znyx.com>
Content-Disposition: inline
In-Reply-To: <1105897532.1097.749.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jamal Hadi Salim <1105897532.1097.749.camel@jzny.localdomain> 2005-01-16 12:45
> --- a/tc/Makefile	2005-01-12 15:19:46.000000000 -0500
> +++ b/tc/Makefile	2005-01-15 12:59:03.994966464 -0500
> @@ -23,6 +23,12 @@
>  TCMODULES += m_gact.o
>  TCMODULES += m_mirred.o
>  TCMODULES += m_ipt.o
> +#pedit
> +TCMODULES += m_pedit.o 
> +TCMODULES += p_ip.o
> +TCMODULES += p_icmp.o
> +TCMODULES += p_tcp.o
> +TCMODULES += p_udp.o
>  
>  TCOBJ += $(TCMODULES)
>  
> @@ -31,8 +37,6 @@
>  TCLIB += tc_cbq.o
>  TCLIB += tc_estimator.o
>  
> -CFLAGS += -DCONFIG_GACT -DCONFIG_GACT_PROB
> -
>  
>  TCSO :=
>  TCSO += q_netem.so
> @@ -40,10 +44,13 @@
>    TCSO += q_atm.so
>  endif
>  
> +
>  NETEM_DIST := normal.dist pareto.dist paretonormal.dist
>  
> +IPT_INCL = /root/iptables-1.2.11/include

I moved this to configure:

--- 1.9/configure	2004-12-08 21:12:11 +01:00
+++ edited/configure	2005-01-17 20:55:38 +01:00
@@ -42,3 +42,17 @@
 	echo "TC_CONFIG_ACTION_MIRRED=y" >>Config
 fi
 
+if [ -e "tc/m_ipt.c" ]
+then
+	echo "   IPT found"
+	echo "Enter path to iptables source directory or \"disable\""
+	echo -n "Path: "
+	read PATH
+	if [ "$PATH" = "disable" ]
+	then
+		echo "TC_CONFIG_ACTION_IPT=n" >>Config
+	else
+		echo "TC_CONFIG_ACTION_IPT=y" >>Config
+		echo "IPT_INCL=${PATH}/include" >>Config
+	fi
+fi

and the Makefile part:

--- 1.21/tc/Makefile	2004-12-08 21:12:11 +01:00
+++ edited/tc/Makefile	2005-01-17 20:49:36 +01:00
@@ -21,7 +21,15 @@
 TCMODULES += q_hfsc.o
 TCMODULES += q_htb.o
 TCMODULES += m_gact.o
+ifeq ($(TC_CONFIG_ACTION_IPT),y)
+TCMODULES += m_ipt.o
+endif
 TCMODULES += m_mirred.o
+TCMODULES += m_pedit.o 
+TCMODULES += p_ip.o
+TCMODULES += p_icmp.o
+TCMODULES += p_tcp.o
+TCMODULES += p_udp.o
 
 TCOBJ += $(TCMODULES)
 
@@ -30,8 +38,7 @@
 TCLIB += tc_cbq.o
 TCLIB += tc_estimator.o
 
-CFLAGS += -DCONFIG_GACT -DCONFIG_GACT_PROB
-
+CFLAGS += -DCONFIG_GACT -DCONFIG_GACT_PROB -I$(IPT_INCL)
 
 TCSO :=
 TCSO += q_netem.so

> +struct m_pedit_util 
> +*get_pedit_kind(char *str)
> +{
> +	void *dlh;
> +	char buf[256];
> +	struct  m_pedit_util *p;
> +
> +	for (p = pedit_list; p; p = p->next) {
> +		if (strcmp(p->id, str) == 0)
> +			return p;
> +	}
> +
> +	snprintf(buf, sizeof(buf), "p_%s.so", str);
> +	dlh = dlopen(buf, RTLD_LAZY);
> +	if (dlh == NULL) {
> +		dlh = pBODY;
> +		if (dlh == NULL) {
> +			dlh = pBODY = dlopen(NULL, RTLD_LAZY);
> +			if (dlh == NULL)
> +				goto noexist;

I made pBODY a static variable within get_pedit_kind. same in m_action.c

> +noexist:
> +	p = malloc(sizeof(*p));
> +	if (p) {
> +		memset(p, 0, sizeof(*p));
> +		strncpy(p->id, str, 15);
> +		p->parse_peopt = pedit_parse_nopopt;
> +		goto reg;

Quite hacky ;->


> +int
> +pack_key32(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
> +{
> +	if (tkey->off > (tkey->off & ~3)) {
> +		fprintf(stderr,
> +			"pack_key32: 32 bit offsets must begin in 32bit boundaries\n");
> +		return -1;
> +	}
> +
> +	tkey->val = htonl(tkey->val & retain);
> +	tkey->mask = htonl(tkey->mask | ~retain);
> +	/* jamal remove this - it is not necessary given the if check above */
> +	tkey->off &= ~3;

Are there multiple of you? ;->

> +int
> +pack_key16(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
> +{
> +	int ind = 0, stride = 0;
> +	__u32 m[4] = {0xFFFF0000,0xFF0000FF,0x0000FFFF};

Missing check for 16bit boundry? You can also completely remove
theses issues by writing in 8bit chunks. OTOH, the user can
request you to do so, so no problem.

> +#if jamal
> +	} else if (strcmp(*argv, "help") == 0) {
> +		p_explain();
> +		return -1;
> +#endif

So you think you're the only one worth giving help? ;-> Just kidding.


> +	tail = (struct rtattr *) (((void *) n) + NLMSG_ALIGN(n->nlmsg_len));
> +	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
> +	addattr_l(n, MAX_MSG, TCA_PEDIT_PARMS,&sel, sizeof(sel.sel)+sel.sel.nkeys*sizeof(struct tc_pedit_key));
> +	tail->rta_len =
> +	    (((void *) n) + NLMSG_ALIGN(n->nlmsg_len)) - (void *) tail;

I changed this and all other occurences to use the NLMSG_TAIL macro (added in my tree)

+#define NLMSG_TAIL(nmsg) \
+       ((struct rtattr *) (((void *) (nmsg)) + NLMSG_ALIGN((nmsg)->nlmsg_len)))

> +struct m_pedit_util
> +{
> +	struct m_pedit_util *next;
> +	char    id[16];

I made this a PEDITKINDSIZ and made the strncpy's use it

I'll put this changes into my tree given you're fine with it and stephen
can pull them. As I said, the ipt code is still missing, I can merge
them into my tree as well if you want.
