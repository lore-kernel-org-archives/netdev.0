From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2.6] ip_nat_ftp - manip at the right place
Date: Sun, 24 Oct 2004 15:27:46 +0300 (EEST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <Pine.LNX.4.58.0410241522230.1177@u.domain.uli>
References: <Pine.LNX.4.58.0409111042580.1315@u.domain.uli>
	<20040911215746.GF19871@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040911215746.GF19871@obroa-skai.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


	Hello,

On Sat, 11 Sep 2004, Harald Welte wrote:

> I agree with this change, but shouldn't we make it consistently over all
> NAT helpers?  In case you didn't check yet, and assuming that this is
> applicable to other helpers as well:  Please include patches for other
> protocol helpers as well.

	I can live with the appended patch, I hope it is correct.

Signed-off-by: Julian Anastasov <ja@ssi.bg>

diff -ur v2.6.9/linux/net/ipv4/netfilter/ip_nat_core.c linux/net/ipv4/netfilter/ip_nat_core.c
--- v2.6.9/linux/net/ipv4/netfilter/ip_nat_core.c	2004-10-19 10:00:36.000000000 +0300
+++ linux/net/ipv4/netfilter/ip_nat_core.c	2004-10-24 14:52:39.334958976 +0300
@@ -728,7 +728,7 @@
 	    struct sk_buff **pskb)
 {
 	unsigned int i;
-	struct ip_nat_helper *helper;
+	struct ip_nat_helper *helper = NULL;
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	int proto = (*pskb)->nh.iph->protocol;
 
@@ -751,9 +751,9 @@
 				READ_UNLOCK(&ip_nat_lock);
 				return NF_DROP;
 			}
+			helper = info->helper;
 		}
 	}
-	helper = info->helper;
 	READ_UNLOCK(&ip_nat_lock);
 
 	if (helper) {
diff -ur v2.6.9/linux/net/ipv4/netfilter/ip_nat_ftp.c linux/net/ipv4/netfilter/ip_nat_ftp.c
--- v2.6.9/linux/net/ipv4/netfilter/ip_nat_ftp.c	2004-10-19 10:00:36.000000000 +0300
+++ linux/net/ipv4/netfilter/ip_nat_ftp.c	2004-10-24 14:52:39.335958824 +0300
@@ -54,6 +54,8 @@
 	IP_NF_ASSERT(master);
 
 	IP_NF_ASSERT(!(info->initialized & (1<<HOOK2MANIP(hooknum))));
+	if (!(info->initialized & (1<<HOOK2MANIP(hooknum))))
+		return NF_ACCEPT;
 
 	DEBUGP("nat_expected: We have a connection!\n");
 	exp_ftp_info = &ct->master->help.exp_ftp_info;
