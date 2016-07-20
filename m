From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: Add helper array register/unregister
 functions
Date: Wed, 20 Jul 2016 10:40:01 +0200
Message-ID: <20160720084000.GB1336@salvia>
References: <1468813163-18139-1-git-send-email-fgao@ikuai8.com>
 <CAML_gOeTMwf2fDTwwJ9MbjPvnSSx8PDxBy55xE+7EMo5yy5UcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
Cc: fgao@ikuai8.com, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gfree.wind@gmail.com
To: Liping Zhang <zlpnobody@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAML_gOeTMwf2fDTwwJ9MbjPvnSSx8PDxBy55xE+7EMo5yy5UcA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 20, 2016 at 08:51:17AM +0800, Liping Zhang wrote:
> 2016-07-18 11:39 GMT+08:00  <fgao@ikuai8.com>:
> > From: Gao Feng <fgao@ikuai8.com>
> >
> > Add nf_ct_helper_init, nf_conntrack_helpers_register/unregister
> > functions to enhance the conntrack helper codes.
> 
> I think this patch is breaking something ...
> 
> This irc:
> > -               if (ports[i] == IRC_PORT)
> > -                       sprintf(irc[i].name, "irc");
> > -               else
> > -                       sprintf(irc[i].name, "irc-%u", i);
> > -
> > -               ret = nf_conntrack_helper_register(&irc[i]);
> > +               nf_ct_helper_init(&irc[i], AF_INET, IPPROTO_TCP, "irc",
> > +                                 IRC_PORT, ports[i], &irc_exp_policy, 0, 0,
> > +                                 help, NULL, THIS_MODULE);
> > +       }
> 
> This sip:
> > -                       if (ports[i] == SIP_PORT)
> > -                               sprintf(sip[i][j].name, "sip");
> > -                       else
> > -                               sprintf(sip[i][j].name, "sip-%u", i);
> 
> And this tftp:
> > -                       if (ports[i] == TFTP_PORT)
> > -                               sprintf(tftp[i][j].name, "tftp");
> > -                       else
> > -                               sprintf(tftp[i][j].name, "tftp-%u", i);
> 
> For example, if the user install the nf_conntrack_tftp module an
> specify the ports to "69,10069",
> then the helper name is "tftp" and "tftp-1".
> 
> But apply this patch, the helper name will be changed to "tftp" and
> "tftp-10069", this may break the
> existing iptables rules which used the helper match or CT target.
>
> And this was already discussed  at
> https://patchwork.ozlabs.org/patch/622238/

Thanks for spotting this.

I'm going to collapse this patch that I'm attaching to Feng's work to
address this.

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=x

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 778f1fc..1eaac1f 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -60,7 +60,7 @@ struct nf_conntrack_helper *nf_conntrack_helper_try_module_get(const char *name,
 							       u8 protonum);
 void nf_ct_helper_init(struct nf_conntrack_helper *helper,
 		       u16 l3num, u16 protonum, const char *name,
-		       u16 default_port, u16 spec_port,
+		       u16 default_port, u16 spec_port, u32 id,
 		       const struct nf_conntrack_expect_policy *exp_pol,
 		       u32 expect_class_max, u32 data_len,
 		       int (*help)(struct sk_buff *skb, unsigned int protoff,
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index d47ada9..4314700 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -601,12 +601,12 @@ static int __init nf_conntrack_ftp_init(void)
 		 are tracked or not - YK */
 	for (i = 0; i < ports_c; i++) {
 		nf_ct_helper_init(&ftp[2 * i], AF_INET, IPPROTO_TCP, "ftp",
-				  FTP_PORT, ports[i], &ftp_exp_policy, 0,
-				  sizeof(struct nf_ct_ftp_master), help,
+				  FTP_PORT, ports[i], ports[i], &ftp_exp_policy,
+				  0, sizeof(struct nf_ct_ftp_master), help,
 				  nf_ct_ftp_from_nlattr, THIS_MODULE);
 		nf_ct_helper_init(&ftp[2 * i + 1], AF_INET6, IPPROTO_TCP, "ftp",
-				  FTP_PORT, ports[i], &ftp_exp_policy, 0,
-				  sizeof(struct nf_ct_ftp_master), help,
+				  FTP_PORT, ports[i], ports[i], &ftp_exp_policy,
+				  0, sizeof(struct nf_ct_ftp_master), help,
 				  nf_ct_ftp_from_nlattr, THIS_MODULE);
 	}
 
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index ed6c0e5..b989b81 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -467,7 +467,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_helper_unregister);
 
 void nf_ct_helper_init(struct nf_conntrack_helper *helper,
 		       u16 l3num, u16 protonum, const char *name,
-		       u16 default_port, u16 spec_port,
+		       u16 default_port, u16 spec_port, u32 id,
 		       const struct nf_conntrack_expect_policy *exp_pol,
 		       u32 expect_class_max, u32 data_len,
 		       int (*help)(struct sk_buff *skb, unsigned int protoff,
@@ -490,8 +490,7 @@ void nf_ct_helper_init(struct nf_conntrack_helper *helper,
 	if (spec_port == default_port)
 		snprintf(helper->name, sizeof(helper->name), "%s", name);
 	else
-		snprintf(helper->name, sizeof(helper->name), "%s-%u", name,
-			 spec_port);
+		snprintf(helper->name, sizeof(helper->name), "%s-%u", name, id);
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_init);
 
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index b93e5e7..1972a14 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -256,8 +256,8 @@ static int __init nf_conntrack_irc_init(void)
 
 	for (i = 0; i < ports_c; i++) {
 		nf_ct_helper_init(&irc[i], AF_INET, IPPROTO_TCP, "irc",
-				  IRC_PORT, ports[i], &irc_exp_policy, 0, 0,
-				  help, NULL, THIS_MODULE);
+				  IRC_PORT, ports[i], i, &irc_exp_policy,
+				  0, 0, help, NULL, THIS_MODULE);
 	}
 
 	ret = nf_conntrack_helpers_register(&irc[0], ports_c);
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index 536c208..9dcb9ee 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -195,11 +195,13 @@ static int __init nf_conntrack_sane_init(void)
 		 are tracked or not - YK */
 	for (i = 0; i < ports_c; i++) {
 		nf_ct_helper_init(&sane[2 * i], AF_INET, IPPROTO_TCP, "sane",
-				  SANE_PORT, ports[i], &sane_exp_policy, 0,
+				  SANE_PORT, ports[i], ports[i],
+				  &sane_exp_policy, 0,
 				  sizeof(struct nf_ct_sane_master), help, NULL,
 				  THIS_MODULE);
 		nf_ct_helper_init(&sane[2 * i + 1], AF_INET6, IPPROTO_TCP, "sane",
-				  SANE_PORT, ports[i], &sane_exp_policy, 0,
+				  SANE_PORT, ports[i], ports[i],
+				  &sane_exp_policy, 0,
 				  sizeof(struct nf_ct_sane_master), help, NULL,
 				  THIS_MODULE);
 	}
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 3feaab3..075286b 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1630,22 +1630,22 @@ static int __init nf_conntrack_sip_init(void)
 		memset(&sip[i], 0, sizeof(sip[i]));
 
 		nf_ct_helper_init(&sip[4 * i], AF_INET, IPPROTO_UDP, "sip",
-				  SIP_PORT, ports[i], &sip_exp_policy[0],
+				  SIP_PORT, ports[i], i, &sip_exp_policy[0],
 				  SIP_EXPECT_MAX,
 				  sizeof(struct nf_ct_sip_master), sip_help_udp,
 				  NULL, THIS_MODULE);
 		nf_ct_helper_init(&sip[4 * i + 1], AF_INET, IPPROTO_TCP, "sip",
-				  SIP_PORT, ports[i], &sip_exp_policy[0],
+				  SIP_PORT, ports[i], i, &sip_exp_policy[0],
 				  SIP_EXPECT_MAX,
 				  sizeof(struct nf_ct_sip_master), sip_help_tcp,
 				  NULL, THIS_MODULE);
 		nf_ct_helper_init(&sip[4 * i + 2], AF_INET6, IPPROTO_UDP, "sip",
-				  SIP_PORT, ports[i], &sip_exp_policy[0],
+				  SIP_PORT, ports[i], i, &sip_exp_policy[0],
 				  SIP_EXPECT_MAX,
 				  sizeof(struct nf_ct_sip_master), sip_help_udp,
 				  NULL, THIS_MODULE);
 		nf_ct_helper_init(&sip[4 * i + 3], AF_INET6, IPPROTO_TCP, "sip",
-				  SIP_PORT, ports[i], &sip_exp_policy[0],
+				  SIP_PORT, ports[i], i, &sip_exp_policy[0],
 				  SIP_EXPECT_MAX,
 				  sizeof(struct nf_ct_sip_master), sip_help_tcp,
 				  NULL, THIS_MODULE);
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 4d65321..b1227dc 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -118,11 +118,11 @@ static int __init nf_conntrack_tftp_init(void)
 
 	for (i = 0; i < ports_c; i++) {
 		nf_ct_helper_init(&tftp[2 * i], AF_INET, IPPROTO_UDP, "tftp",
-				  TFTP_PORT, ports[i], &tftp_exp_policy, 0, 0,
-				  tftp_help, NULL, THIS_MODULE);
+				  TFTP_PORT, ports[i], i, &tftp_exp_policy,
+				  0, 0, tftp_help, NULL, THIS_MODULE);
 		nf_ct_helper_init(&tftp[2 * i + 1], AF_INET6, IPPROTO_UDP, "tftp",
-				  TFTP_PORT, ports[i], &tftp_exp_policy, 0, 0,
-				  tftp_help, NULL, THIS_MODULE);
+				  TFTP_PORT, ports[i], i, &tftp_exp_policy,
+				  0, 0, tftp_help, NULL, THIS_MODULE);
 	}
 
 	ret = nf_conntrack_helpers_register(tftp, ports_c * 2);

--jI8keyz6grp/JLjh--
