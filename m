From: George Bakos <gbakos@alpinista.org>
Subject: Re: [PATCH net-next] filter: add MOD operation
Date: Sat, 8 Sep 2012 20:31:13 +0000
Message-ID: <20120908203113.1bc74838@arrowsmith>
References: <20120905213941.03c85968@arrowsmith>
	<C71A36A8-08D2-4D3D-AF2B-EF89FEECE1A6@alum.mit.edu>
	<20120906073615.693d14e0@arrowsmith>
	<46AB14E3-73F4-41FA-8086-F1D663AF4549@alum.mit.edu>
	<20120907074910.2df46817@arrowsmith>
	<20120908030311.GM17289@tassilo.jf.intel.com>
	<1347091415.1234.317.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/.EZz=gPmBHfGNi5CmR5D7ox"
Cc: netdev@vger.kernel.org, Jay Schulist <jschlst@samba.org>,
	Andi Kleen <ak@linux.intel.com>, tcpdump-workers@lists.tcpdump.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <tcpdump-workers-bounces@lists.tcpdump.org>
In-Reply-To: <1347091415.1234.317.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sandelman.ca/mailman/options/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=unsubscribe>
List-Archive: <http://lists.sandelman.ca/pipermail/tcpdump-workers>
List-Post: <mailto:tcpdump-workers@lists.tcpdump.org>
List-Help: <mailto:tcpdump-workers-request@lists.tcpdump.org?subject=help>
List-Subscribe: <https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=subscribe>
Sender: tcpdump-workers-bounces@lists.tcpdump.org
Errors-To: tcpdump-workers-bounces@lists.tcpdump.org
List-Id: netdev.vger.kernel.org

--MP_/.EZz=gPmBHfGNi5CmR5D7ox
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Here's a patch to libpcap-1.3 to test against. I still need to
include changes to man pages.

g

On Sat, 08 Sep 2012 10:03:35 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> On Fri, 2012-09-07 at 20:03 -0700, Andi Kleen wrote:
> > On Fri, Sep 07, 2012 at 07:49:10AM +0000, George Bakos wrote:
> > > Gents,
> > > Any fundamental reason why the following (, etc.) shouldn't be
> > > included in net/core/filter.c?
> > > 
> > >                 case BPF_S_ALU_MOD_X:
> > >                         if (X == 0)
> > >                                 return 0;
> > >                         A %= X;
> > >                         continue;
> > 
> > Copying netdev.
> > 
> > In principle no reason against it, but you may need to update
> > the various BPF JITs too that Linux now has too.
> 
> Hi Andi, thanks for the forward
> 
> In recent commit ffe06c17afbb was added ALU_XOR_X,
> so we could add ALU_MOD_X as well.
> 
> ALU_MOD_K is a bit more complex as we cant use an ancillary, and must
> instead use a new BPF_OP code :
> 
> /* alu/jmp fields */
> #define BPF_OP(code)    ((code) & 0xf0)
> #define         BPF_ADD         0x00
> #define         BPF_SUB         0x10
> #define         BPF_MUL         0x20
> #define         BPF_DIV         0x30
> #define         BPF_OR          0x40
> #define         BPF_AND         0x50
> #define         BPF_LSH         0x60
> #define         BPF_RSH         0x70
> #define         BPF_NEG         0x80
> 
> So I guess we could use
> 
> #define         BPF_MOD         0x90
> 
> About the various arches JIT, there is no hurry :
> We can update them later.
> 
> At JIT 'compile' time, if we find a not yet handled instruction, we fall
> back to the net/core/filter.c interpreter.
> 
> If the following patch is accepted, I'll do the x86 part as a followup.
> 
> Thanks !
> 
> [PATCH net-next] filter: add MOD operation
> 
> Add a new ALU opcode, to compute a modulus.
> 
> Commit ffe06c17afbbb used an ancillary to implement XOR_X,
> but here we reserve one of the available ALU opcode to implement both
> MOD_X and MOD_K
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Suggested-by: George Bakos <gbakos@alpinista.org>
> Cc: Jay Schulist <jschlst@samba.org>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Cc: Andi Kleen <ak@linux.intel.com>
> ---
>  include/linux/filter.h |    4 ++++
>  net/core/filter.c      |   15 +++++++++++++++
>  2 files changed, 19 insertions(+)
> 
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 82b0135..3cf5fd5 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -74,6 +74,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
>  #define         BPF_LSH         0x60
>  #define         BPF_RSH         0x70
>  #define         BPF_NEG         0x80
> +#define		BPF_MOD		0x90
> +
>  #define         BPF_JA          0x00
>  #define         BPF_JEQ         0x10
>  #define         BPF_JGT         0x20
> @@ -196,6 +198,8 @@ enum {
>  	BPF_S_ALU_MUL_K,
>  	BPF_S_ALU_MUL_X,
>  	BPF_S_ALU_DIV_X,
> +	BPF_S_ALU_MOD_K,
> +	BPF_S_ALU_MOD_X,
>  	BPF_S_ALU_AND_K,
>  	BPF_S_ALU_AND_X,
>  	BPF_S_ALU_OR_K,
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 907efd2..fbe3a8d 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -167,6 +167,14 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
>  		case BPF_S_ALU_DIV_K:
>  			A = reciprocal_divide(A, K);
>  			continue;
> +		case BPF_S_ALU_MOD_X:
> +			if (X == 0)
> +				return 0;
> +			A %= X;
> +			continue;
> +		case BPF_S_ALU_MOD_K:
> +			A %= K;
> +			continue;
>  		case BPF_S_ALU_AND_X:
>  			A &= X;
>  			continue;
> @@ -469,6 +477,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>  		[BPF_ALU|BPF_MUL|BPF_K]  = BPF_S_ALU_MUL_K,
>  		[BPF_ALU|BPF_MUL|BPF_X]  = BPF_S_ALU_MUL_X,
>  		[BPF_ALU|BPF_DIV|BPF_X]  = BPF_S_ALU_DIV_X,
> +		[BPF_ALU|BPF_MOD|BPF_K]  = BPF_S_ALU_MOD_K,
> +		[BPF_ALU|BPF_MOD|BPF_X]  = BPF_S_ALU_MOD_X,
>  		[BPF_ALU|BPF_AND|BPF_K]  = BPF_S_ALU_AND_K,
>  		[BPF_ALU|BPF_AND|BPF_X]  = BPF_S_ALU_AND_X,
>  		[BPF_ALU|BPF_OR|BPF_K]   = BPF_S_ALU_OR_K,
> @@ -531,6 +541,11 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>  				return -EINVAL;
>  			ftest->k = reciprocal_value(ftest->k);
>  			break;
> +		case BPF_S_ALU_MOD_K:
> +			/* check for division by zero */
> +			if (ftest->k == 0)
> +				return -EINVAL;
> +			break;
>  		case BPF_S_LD_MEM:
>  		case BPF_S_LDX_MEM:
>  		case BPF_S_ST:
> 
> 


-- 

--MP_/.EZz=gPmBHfGNi5CmR5D7ox
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=libpcap-1.3.0-with-modulus.patch

diff -Naur libpcap-1.3.0/bpf/net/bpf_filter.c libpcap-1.3.0-with-modulus/bpf/net/bpf_filter.c
--- libpcap-1.3.0/bpf/net/bpf_filter.c	2012-03-29 12:57:32.000000000 +0000
+++ libpcap-1.3.0-with-modulus/bpf/net/bpf_filter.c	2012-08-31 01:36:53.206825554 +0000
@@ -469,6 +469,12 @@
 			A /= X;
 			continue;
 
+		case BPF_ALU|BPF_MOD|BPF_X:
+			if (X == 0)
+				return 0;
+			A %= X;
+			continue;
+
 		case BPF_ALU|BPF_AND|BPF_X:
 			A &= X;
 			continue;
@@ -501,6 +507,10 @@
 			A /= pc->k;
 			continue;
 
+		case BPF_ALU|BPF_MOD|BPF_K:
+			A %= pc->k;
+			continue;
+
 		case BPF_ALU|BPF_AND|BPF_K:
 			A &= pc->k;
 			continue;
@@ -621,6 +631,13 @@
 				 */
 				if (BPF_SRC(p->code) == BPF_K && p->k == 0)
 					return 0;
+				break;
+			case BPF_MOD:
+				/*
+				 * Check for illegal modulus 0.
+				 */
+				if (BPF_SRC(p->code) == BPF_K && p->k == 0)
+					return 0;
 				break;
 			default:
 				return 0;
diff -Naur libpcap-1.3.0/bpf_image.c libpcap-1.3.0-with-modulus/bpf_image.c
--- libpcap-1.3.0/bpf_image.c	2012-03-29 12:57:32.000000000 +0000
+++ libpcap-1.3.0-with-modulus/bpf_image.c	2012-08-31 01:36:53.225825770 +0000
@@ -216,6 +216,11 @@
 		fmt = "x";
 		break;
 
+	case BPF_ALU|BPF_MOD|BPF_X:
+		op = "mod";
+		fmt = "x";
+		break;
+
 	case BPF_ALU|BPF_AND|BPF_X:
 		op = "and";
 		fmt = "x";
@@ -256,6 +261,11 @@
 		fmt = "#%d";
 		break;
 
+	case BPF_ALU|BPF_MOD|BPF_K:
+		op = "mod";
+		fmt = "#%d";
+		break;
+
 	case BPF_ALU|BPF_AND|BPF_K:
 		op = "and";
 		fmt = "#0x%x";
diff -Naur libpcap-1.3.0/grammar.y libpcap-1.3.0-with-modulus/grammar.y
--- libpcap-1.3.0/grammar.y	2012-03-29 12:57:32.000000000 +0000
+++ libpcap-1.3.0-with-modulus/grammar.y	2012-08-31 01:36:53.196825439 +0000
@@ -617,6 +617,7 @@
 	| arth '*' arth			{ $$ = gen_arth(BPF_MUL, $1, $3); }
 	| arth '/' arth			{ $$ = gen_arth(BPF_DIV, $1, $3); }
 	| arth '&' arth			{ $$ = gen_arth(BPF_AND, $1, $3); }
+	| arth '%' arth			{ $$ = gen_arth(BPF_MOD, $1, $3); }
 	| arth '|' arth			{ $$ = gen_arth(BPF_OR, $1, $3); }
 	| arth LSH arth			{ $$ = gen_arth(BPF_LSH, $1, $3); }
 	| arth RSH arth			{ $$ = gen_arth(BPF_RSH, $1, $3); }
diff -Naur libpcap-1.3.0/optimize.c libpcap-1.3.0-with-modulus/optimize.c
--- libpcap-1.3.0/optimize.c	2012-03-29 12:57:32.000000000 +0000
+++ libpcap-1.3.0-with-modulus/optimize.c	2012-08-31 01:36:53.188825347 +0000
@@ -666,6 +666,12 @@
 		a /= b;
 		break;
 
+	case BPF_MOD:
+		if (b == 0)
+			bpf_error("illegal modulus 0");
+		a %= b;
+		break;
+
 	case BPF_AND:
 		a &= b;
 		break;
@@ -1044,6 +1050,7 @@
 	case BPF_ALU|BPF_SUB|BPF_K:
 	case BPF_ALU|BPF_MUL|BPF_K:
 	case BPF_ALU|BPF_DIV|BPF_K:
+	case BPF_ALU|BPF_MOD|BPF_K:
 	case BPF_ALU|BPF_AND|BPF_K:
 	case BPF_ALU|BPF_OR|BPF_K:
 	case BPF_ALU|BPF_LSH|BPF_K:
@@ -1079,6 +1086,7 @@
 	case BPF_ALU|BPF_SUB|BPF_X:
 	case BPF_ALU|BPF_MUL|BPF_X:
 	case BPF_ALU|BPF_DIV|BPF_X:
+	case BPF_ALU|BPF_MOD|BPF_X:
 	case BPF_ALU|BPF_AND|BPF_X:
 	case BPF_ALU|BPF_OR|BPF_X:
 	case BPF_ALU|BPF_LSH|BPF_X:
@@ -1112,7 +1120,7 @@
 				vstore(s, &val[A_ATOM], val[X_ATOM], alter);
 				break;
 			}
-			else if (op == BPF_MUL || op == BPF_DIV ||
+			else if (op == BPF_MUL || op == BPF_DIV || op == BPF_MOD ||
 				 op == BPF_AND || op == BPF_LSH || op == BPF_RSH) {
 				s->code = BPF_LD|BPF_IMM;
 				s->k = 0;
diff -Naur libpcap-1.3.0/pcap/bpf.h libpcap-1.3.0-with-modulus/pcap/bpf.h
--- libpcap-1.3.0/pcap/bpf.h	2012-06-12 16:55:36.000000000 +0000
+++ libpcap-1.3.0-with-modulus/pcap/bpf.h	2012-08-31 01:36:53.199825471 +0000
@@ -1235,6 +1235,7 @@
 #define		BPF_LSH		0x60
 #define		BPF_RSH		0x70
 #define		BPF_NEG		0x80
+#define		BPF_MOD		0x90
 #define		BPF_JA		0x00
 #define		BPF_JEQ		0x10
 #define		BPF_JGT		0x20
diff -Naur libpcap-1.3.0/scanner.l libpcap-1.3.0-with-modulus/scanner.l
--- libpcap-1.3.0/scanner.l	2012-03-29 12:57:32.000000000 +0000
+++ libpcap-1.3.0-with-modulus/scanner.l	2012-08-31 01:36:53.225825770 +0000
@@ -329,7 +329,7 @@
 sls		return SLS;
 
 [ \r\n\t]		;
-[+\-*/:\[\]!<>()&|=]	return yytext[0];
+[+\-*/:\[\]!<>()&|=%]	return yytext[0];
 ">="			return GEQ;
 "<="			return LEQ;
 "!="			return NEQ;
@@ -387,7 +387,7 @@
 [A-Za-z0-9]([-_.A-Za-z0-9]*[.A-Za-z0-9])? {
 			 yylval.s = sdup((char *)yytext); return ID; }
 "\\"[^ !()\n\t]+	{ yylval.s = sdup((char *)yytext + 1); return ID; }
-[^ \[\]\t\n\-_.A-Za-z0-9!<>()&|=]+ {
+[^ \[\]\t\n\-_.A-Za-z0-9!<>()&|=%]+ {
 			bpf_error("illegal token: %s", yytext); }
 .			{ bpf_error("illegal char '%c'", *yytext); }
 %%

--MP_/.EZz=gPmBHfGNi5CmR5D7ox
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
tcpdump-workers mailing list
tcpdump-workers@lists.tcpdump.org
https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers

--MP_/.EZz=gPmBHfGNi5CmR5D7ox--
