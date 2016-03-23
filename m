From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: net/sctp: stack-out-of-bounds in sctp_getsockopt
Date: Wed, 23 Mar 2016 18:38:18 +0100
Message-ID: <20160323173818.GA11724@salvia>
References: <56f16034.890c620a.e04dc.ffffc770@mx.google.com>
 <1458660088.10868.19.camel@edumazet-glaptop3.roam.corp.google.com>
 <1458660478.10868.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAP=GMUFA-qAOxF1W=aeWDYBiR-GSohJYGHiMDsrqwsD0xdg3_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, kaber@trash.net,
	kadlec@blackhole.kfki.hu, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org,
	Vladislav Yasevich <vyasevich@gmail.com>,
	nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Baozeng <sploving1@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAP=GMUFA-qAOxF1W=aeWDYBiR-GSohJYGHiMDsrqwsD0xdg3_Q@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Mar 24, 2016 at 12:42:43AM +0800, Baozeng wrote:
> 2016-03-22 23:27 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
> > Untested patch would be :
> >
> > diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> > index 67b2e27999aa..fceb7354d169 100644
> > --- a/net/bridge/netfilter/ebtables.c
> > +++ b/net/bridge/netfilter/ebtables.c
> > @@ -346,7 +346,7 @@ find_inlist_lock(struct list_head *head, const char *name, const char *prefix,
> >  {
> >         return try_then_request_module(
> >                         find_inlist_lock_noload(head, name, error, mutex),
> > -                       "%s%s", prefix, name);
> > +                       "%.*s%s", EBT_TABLE_MAXNAMELEN, prefix, name);
> >  }
> >
> >  static inline struct ebt_table *
> >
> >
> 
> Thanks for your quick patch. I tested it but it still reproduce the
> bug. We should limit the length of the name,
> not the prefix. The following patch fixs it.

Could you give a try to this patch? Thanks.

--ibTvN161/egqYuK8
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="x.patch"

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 67b2e27..1e3a707 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1521,6 +1521,8 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	if (copy_from_user(&tmp, user, sizeof(tmp)))
 		return -EFAULT;
 
+	tmp.name[sizeof(tmp.name) - 1] = '\0';
+
 	t = find_table_lock(net, tmp.name, &ret, &ebt_mutex);
 	if (!t)
 		return ret;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index a2002ff..06e9fb7 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -960,6 +960,7 @@ static int get_entries(struct net *net, struct arpt_get_entries __user *uptr,
 			 sizeof(struct arpt_get_entries) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, NFPROTO_ARP, get.name);
 	if (!IS_ERR_OR_NULL(t)) {
@@ -1654,6 +1655,7 @@ static int compat_get_entries(struct net *net,
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	xt_compat_lock(NFPROTO_ARP);
 	t = xt_find_table_lock(net, NFPROTO_ARP, get.name);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 45b1d97..4642dc2 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1146,6 +1146,7 @@ get_entries(struct net *net, struct ipt_get_entries __user *uptr,
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, AF_INET, get.name);
 	if (!IS_ERR_OR_NULL(t)) {
@@ -1925,6 +1926,7 @@ compat_get_entries(struct net *net, struct compat_ipt_get_entries __user *uptr,
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	xt_compat_lock(AF_INET);
 	t = xt_find_table_lock(net, AF_INET, get.name);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 85c0942..db47815 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1158,6 +1158,7 @@ get_entries(struct net *net, struct ip6t_get_entries __user *uptr,
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, AF_INET6, get.name);
 	if (!IS_ERR_OR_NULL(t)) {
@@ -1934,6 +1935,7 @@ compat_get_entries(struct net *net, struct compat_ip6t_get_entries __user *uptr,
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
+	get.name[sizeof(get.name) - 1] = '\0';
 
 	xt_compat_lock(AF_INET6);
 	t = xt_find_table_lock(net, AF_INET6, get.name);

--ibTvN161/egqYuK8--
