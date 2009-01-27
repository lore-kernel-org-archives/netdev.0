From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 12:29:52 +0100
Message-ID: <497EF030.10504@cosmosbay.com>
References: <497E361B.30909@hp.com> <497E42F4.7080201@cosmosbay.com> <497E44F6.2010703@hp.com> <497ECF84.1030308@cosmosbay.com> <497ED0A2.6050707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497ED0A2.6050707@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> [PATCH] netfilter: Get rid of central rwlock in tcp conntracking
>>
>> TCP connection tracking suffers of huge contention on a global rwloc=
k,
>> used to protect tcp conntracking state.
>> As each tcp conntrack state have no relations between each others, w=
e
>> can switch to fine grained lock, using a spinlock per "struct ip_ct_=
tcp"
>>
>> tcp_print_conntrack() dont need to lock anything to read
>> ct->proto.tcp.state,
>> so speedup /proc/net/ip_conntrack as well.
>=20
> Thats an interesting test-case, but one lock per conntrack just for
> TCP tracking seems like overkill. We're trying to keep the conntrack
> stuctures as small as possible, so I'd prefer an array of spinlocks
> or something like that.

Yes, this is wise. Current sizeof(struct nf_conn) is 220 (0xdc) on 32 b=
its,
probably rounded to 0xE0 by SLAB/SLUB. I will provide a new patch using
an array of say 512 spinlocks. (512 spinlocks use 2048 bytes if non
debuging spinlocks, that spread to 32 x 64bytes cache lines)

However I wonder if for very large number of cpus we should at least as=
k conntrack=20
to use hardware aligned "struct nf_conn" to avoid false sharing

We might also use a generic SLAB_HWCACHE_ALIGN_IFMANYCPUS flag if same =
tactic
could help other kmem_cache_create() users


diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 90ce9dd..82332ce 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1167,8 +1167,10 @@ static int nf_conntrack_init_init_net(void)
 	       nf_conntrack_max);
=20
 	nf_conntrack_cachep =3D kmem_cache_create("nf_conntrack",
-						sizeof(struct nf_conn),
-						0, 0, NULL);
+						sizeof(struct nf_conn), 0,
+						num_possible_cpus() >=3D 32 ?
+							SLAB_HWCACHE_ALIGN : 0,
+						NULL);
 	if (!nf_conntrack_cachep) {
 		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
 		ret =3D -ENOMEM;

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
