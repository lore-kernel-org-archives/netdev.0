From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 24 Mar 2005 06:57:30 -0500
Message-ID: <1111665450.1037.27.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>
	 <1107174142.8021.121.camel@jzny.localdomain>
	 <00c301c524b4$938cd240$6e69690a@RIMAS>
	 <1110379135.1091.143.camel@jzny.localdomain>
	 <1110416767.1111.76.camel@jzny.localdomain>
	 <025501c52552$2dbf87c0$6e69690a@RIMAS>
	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>
	 <1111410890.1092.195.camel@jzny.localdomain>
	 <423F41AD.3010902@dsl.pipex.com>
	 <1111444869.1072.51.camel@jzny.localdomain>
	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>
	 <42408998.5000202@dsl.pipex.com>
	 <1111550254.1089.21.camel@jzny.localdomain>
	 <4241C478.5030309@dsl.pipex.com>
	 <1111607112.1072.48.camel@jzny.localdomain>
	 <4241D764.2030306@dsl.pipex.com>
	 <1111612042.1072.53.camel@jzny.localdomain>
	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@d
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-pt72hej80GDfO+r1v/E+"
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <1111663947.1037.24.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-pt72hej80GDfO+r1v/E+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-03-24 at 06:32, jamal wrote:

> 
> Need caffeine, I think i will find some workaround - I should probably
> put it in user space.
> 

Ok, try attached patch on tc - seems to work for me

cheers,
jamal

--=-pt72hej80GDfO+r1v/E+
Content-Disposition: attachment; filename=p_mipt
Content-Type: text/plain; name=p_mipt; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/tc/m_ipt.c	2005-03-14 17:23:54.000000000 -0500
+++ b/tc/m_ipt.c	2005-03-24 06:53:31.000000000 -0500
@@ -337,6 +337,17 @@
 	return &addr;
 }
 
+static void set_revision(char *name, u_int8_t revision)
+{
+	/* Old kernel sources don't have ".revision" field,
+	*  but we stole a byte from name. */
+	name[IPT_FUNCTION_MAXNAMELEN - 2] = '\0';
+	name[IPT_FUNCTION_MAXNAMELEN - 1] = revision;
+}
+
+/* 
+ * we may need to check for version mismatch
+*/
 int
 build_st(struct iptables_target *target, struct ipt_entry_target *t)
 {
@@ -350,8 +361,11 @@
 
 		if (NULL == t) {
 			target->t = fw_calloc(1, size);
-			target->init(target->t, &nfcache);
 			target->t->u.target_size = size;
+
+			if (target->init != NULL)
+				target->init(target->t, &nfcache);
+			set_revision(target->t->u.user.name, target->revision);
 		} else {
 			target->t = t;
 		}

--=-pt72hej80GDfO+r1v/E+--
