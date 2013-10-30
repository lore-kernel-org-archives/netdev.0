From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [BUG 3.12.rc4] Oops: unable to handle kernel paging request
 during shutdown
Date: Wed, 30 Oct 2013 19:04:47 +0100
Message-ID: <20131030180447.GA9515@localhost>
References: <525BD08C.2080101@t-online.de>
 <CA+55aFwN++wO=rTFaH7m6YYQX+Fv3qDt6Hxs7UnPUJpFsrwSkA@mail.gmail.com>
 <CA+55aFy7TpvkVuPEOJ7Qqirwap1gXoD1_MrYLhgPAYuVpN8u=w@mail.gmail.com>
 <alpine.DEB.2.02.1310251221310.5266@ionos.tec.linutronix.de>
 <CA+55aFxw1Hm4QVeEigkByP5RppSL30oHnLoR16C=henf-a=uFQ@mail.gmail.com>
 <CA+55aFyb72qoZ1Tjpb+=q-6+GmwoOXjfntY_zZnf300gg3d1Hg@mail.gmail.com>
 <CA+55aFxuVpDo3LvmG9j-Hu7sENLTcsB6_CY2TA4mE-k+CuTeGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="xHFwDpU9dbj6ez1V"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>,
	Knut Petersen <Knut_Petersen@t-online.de>,
	Ingo Molnar <mingo@kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	=?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>,
	Greg KH <greg@kroah.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxuVpDo3LvmG9j-Hu7sENLTcsB6_CY2TA4mE-k+CuTeGg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Oct 27, 2013 at 08:39:47PM +0000, Linus Torvalds wrote:
> On Sun, Oct 27, 2013 at 8:20 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Appended is a warning I get with DEBUG_TIMER_OBJECTS. Seems to be a
> > device-mapper issue.
> 
> .. and here's another one. This time it looks like nf_conntrack_free()
> is freeing something that has a delayed work in it (again, likely an
> embedded 'struct kobject'). Looks like it is the
> 
>     kmem_cache_destroy(net->ct.nf_conntrack_cachep);
> 
> that triggers this. Which probably means that there are still slab
> entries on that slab cache or something, but I didn't dig any deeper..
> 
> David? Patrick? Pablo? Jozsef? Any ideas? This was immediately preceded by
> 
>   [ 1136.316280] kobject: 'nf_conntrack_ffff8800b74d0000'
> (ffff8801196fac78): kobject_uevent_env
>   [ 1136.316287] kobject: 'nf_conntrack_ffff8800b74d0000'
> (ffff8801196fac78): fill_kobj_path: path =
> '/kernel/slab/nf_conntrack_ffff8800b74d0000'
>   [ 1136.316331] kobject: 'nf_conntrack_ffff8800b74d0000'
> (ffff8801196fac78): kobject_release, parent           (null) (delayed)
> 
> and I think it's that delayed "kobject_release()" that triggers this.
> 
> Notice that kobject_release() can be delayed *without* the magic
> kobject debugging option by simply having a reference count on it from
> some external source. So this particular issue is probably triggered
> by my extra debug options in this case (I'm running with all those
> nasty "try to find bad object freeing" options, and doing module
> unloading etc), but can happen without it (it's just very hard to
> trigger in practice without the debug options).

nf_conntrack_free() is decrementing our object counter (net->ct.count)
before releasing the object. That counter is used in the
nf_conntrack_cleanup_net_list path to check if it's time to
kmem_cache_destroy our cache of conntrack objects. I think we have a
race there that should be easier to trigger (although still hard) with
CONFIG_DEBUG_OBJECTS_FREE as object releases become slowier.

--xHFwDpU9dbj6ez1V
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="linus.patch"

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5d892fe..d60cf16 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -764,9 +764,10 @@ void nf_conntrack_free(struct nf_conn *ct)
 	struct net *net = nf_ct_net(ct);
 
 	nf_ct_ext_destroy(ct);
-	atomic_dec(&net->ct.count);
 	nf_ct_ext_free(ct);
 	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
+	smp_mb__before_atomic_dec();
+	atomic_dec(&net->ct.count);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_free);
 

--xHFwDpU9dbj6ez1V--
