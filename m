From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: =?UTF-8?B?UmU6IG5ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX3Byb3RvX3RjcC4=?=
 =?UTF-8?B?YzoxNjA2Ojk6IGVycm9yOiDigJhzdHJ1Y3QgbmZfcHJvdG9fbmV04oCZIGhhcyA=?=
 =?UTF-8?B?bm8gbWVtYmVyIG5hbWVkIOKAmHVzZXLigJk=?=
Date: Tue, 12 Jun 2012 19:03:31 +0800
Message-ID: <4FD72203.9090005@cn.fujitsu.com>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com> <20120611221521.GA27239@1984> <20120611.152344.1072167705198124284.davem@davemloft.net> <20120612002655.GA28155@1984> <4FD69F5E.3060900@cn.fujitsu.com> <20120612092940.GB30080@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, wfg@linux.intel.com,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52514 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751035Ab2FLLDF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 07:03:05 -0400
In-Reply-To: <20120612092940.GB30080@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8812=E6=97=A5 17:29, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:

>> nf_proto_net.users has different meaning when SYSCTL enabled or disa=
bled.
>>
>> when SYSCTL enabled,it means if both tcpv4 and tcpv6 register the sy=
sctl,
>> it is increased when register sysctl success and decreased when unre=
gister sysctl.
>> we can regard it as the refcnt of ctl_table.
>>
>> when SYSCTL disabled,it just used to identify if the proto's pernet =
data
>> has been initialized.
>=20
> We have to use two different counters for this. The conditional
> meaning of that variable is really confusing.
>=20
Hi David & Pablo

Please have a look at this patch and tell me if it's OK.
it base on Pable's patch.

diff --git a/include/net/netfilter/nf_conntrack_tcp.h b/include/net/net=
filter/nf_conntrack_tcp.h
index 8d16ebe..0945446 100644
--- a/include/net/netfilter/nf_conntrack_tcp.h
+++ b/include/net/netfilter/nf_conntrack_tcp.h
@@ -1,8 +1,16 @@
 #ifndef _NF_CONNTRACK_TCP_H_
 #define _NF_CONNTRACK_TCP_H_

-int nf_ct_tcp_kmemdup_sysctl_table(struct nf_proto_net *pn);
-int nf_ct_tcp_compat_kmemdup_sysctl_table(struct nf_proto_net *pn);
-void nf_ct_tcp_compat_kfree_sysctl_table(struct nf_proto_net *pn);
+#ifdef CONFIG_SYSCTL
+int nf_ct_tcpv4_init_sysctl(struct nf_proto_net *pn);
+int nf_ct_tcpv6_init_sysctl(struct nf_proto_net *pn);
+#else
+int nf_ct_tcpv4_init_sysctl(struct nf_proto_net *pn)
+{
+       pn->users++;
+       return 0;
+}

+#define nf_ct_tcpv6_init_sysctl nf_ct_tcpv4_init_sysctl
+#endif
 #endif
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_=
conntrack_proto_tcp.c
index cdf8b93..367153a 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1368,12 +1368,11 @@ static const struct nla_policy tcp_timeout_nla_=
policy[CTA_TIMEOUT_TCP_MAX+1] =3D {

 static int tcpv4_init_net(struct net *net)
 {
-       int i;
-       int ret =3D 0;
        struct nf_tcp_net *tn =3D tcp_pernet(net);
        struct nf_proto_net *pn =3D (struct nf_proto_net *)tn;

-       if (!pn->users++) {
+       if (!pn->users) {
+               int i;
                for (i =3D 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
                        tn->timeouts[i] =3D tcp_timeouts[i];

@@ -1382,25 +1381,16 @@ static int tcpv4_init_net(struct net *net)
                tn->tcp_max_retrans =3D nf_ct_tcp_max_retrans;
        }

-       ret =3D nf_ct_tcp_compat_kmemdup_sysctl_table(pn);
-       if (ret < 0)
-               return ret;
-
-       ret =3D nf_ct_tcp_kmemdup_sysctl_table(pn);
-       if (ret < 0) {
-               kfree(pn->ctl_compat_table);
-               pn->ctl_compat_table =3D NULL;
-       }
-       return ret;
+       return nf_ct_tcpv4_init_sysctl(pn);
 }

 static int tcpv6_init_net(struct net *net)
 {
-       int i;
        struct nf_tcp_net *tn =3D tcp_pernet(net);
        struct nf_proto_net *pn =3D (struct nf_proto_net *)tn;

-       if (!pn->users++) {
+       if (!pn->users) {
+               int i;
                for (i =3D 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
                        tn->timeouts[i] =3D tcp_timeouts[i];
                tn->tcp_loose =3D nf_ct_tcp_loose;
@@ -1408,7 +1398,7 @@ static int tcpv6_init_net(struct net *net)
                tn->tcp_max_retrans =3D nf_ct_tcp_max_retrans;
        }

-       return nf_ct_tcp_kmemdup_sysctl_table(pn);
+       return nf_ct_tcpv6_init_sysctl(pn);
 }

 struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =3D
diff --git a/net/netfilter/nf_conntrack_proto_tcp_sysctl.c b/net/netfil=
ter/nf_conntrack_proto_tcp_sysctl.c
index b9e027f..f038de4 100644
--- a/net/netfilter/nf_conntrack_proto_tcp_sysctl.c
+++ b/net/netfilter/nf_conntrack_proto_tcp_sysctl.c
@@ -182,7 +182,7 @@ static struct ctl_table tcp_compat_sysctl_table[] =3D=
 {
 };
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */

-int nf_ct_tcp_kmemdup_sysctl_table(struct nf_proto_net *pn)
+static int nf_ct_tcp_kmemdup_sysctl_table(struct nf_proto_net *pn)
 {
        struct nf_tcp_net *tn =3D (struct nf_tcp_net *)pn;

@@ -211,7 +211,7 @@ int nf_ct_tcp_kmemdup_sysctl_table(struct nf_proto_=
net *pn)
        return 0;
 }

-int nf_ct_tcp_compat_kmemdup_sysctl_table(struct nf_proto_net *pn)
+static int nf_ct_tcp_compat_kmemdup_sysctl_table(struct nf_proto_net *=
pn)
 {
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
        struct nf_tcp_net *tn =3D (struct nf_tcp_net *)pn;
@@ -245,3 +245,23 @@ void nf_ct_tcp_compat_kfree_sysctl_table(struct nf=
_proto_net *pn)
        pn->ctl_compat_table =3D NULL;
 #endif
 }
+
+int nf_ct_tcpv4_init_sysctl(struct nf_proto_net *pn)
+{
+       int ret;
+
+       ret =3D nf_ct_tcp_compat_kmemdup_sysctl_table(pn);
+       if (ret < 0)
+               return ret;
+
+       ret =3D nf_ct_tcp_kmemdup_sysctl_table(pn);
+       if (ret < 0)
+               nf_ct_tcp_compat_kfree_sysctl_table(pn);
+
+       return ret;
+}
+
+int nf_ct_tcpv6_init_sysctl(struct nf_proto_net *pn)
+{
+       return nf_ct_tcp_compat_kmemdup_sysctl_table(pn);
+}
