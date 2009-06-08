From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/5] sunrpc/auth_gss: Call rcu_barrier() on module
 unload.
Date: Mon, 08 Jun 2009 13:00:49 -0400
Message-ID: <1244480449.5040.4.camel@heimdal.trondhjem.org>
References: <20090608130959.10052.54590.stgit@localhost>
	 <20090608131148.10052.39869.stgit@localhost>
	 <20090608162656.GF6961@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org,
	vladislav.yasevich-VXdhtT5mjnY@public.gmane.org, sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090608162656.GF6961-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-06-08 at 09:26 -0700, Paul E. McKenney wrote:
> On Mon, Jun 08, 2009 at 03:11:48PM +0200, Jesper Dangaard Brouer wrote:
> > As the module uses rcu_call() we should make sure that all
> > rcu callback has been completed before removing the code.
> 
> Good improvement!!!  Assuming that gss_svc_shutdown() and
> rpcauth_unregister() prevent any future RCU callbacks to be registered,
> this patch will fix things up.
> 
> Acked-by: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> > Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
> > ---
> > 
> >  net/sunrpc/auth_gss/auth_gss.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > index e630b38..66d458f 100644
> > --- a/net/sunrpc/auth_gss/auth_gss.c
> > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > @@ -1548,6 +1548,7 @@ static void __exit exit_rpcsec_gss(void)
> >  {
> >  	gss_svc_shutdown();
> >  	rpcauth_unregister(&authgss_ops);
> > +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
> >  }
> > 
> >  MODULE_LICENSE("GPL");
> > 

Hmm... If this is about ensuring that all the call_rcu() callbacks
complete before we remove the module, then don't we also need similar
barriers in net/sunrpc/sunrpc_syms.c:cleanup_sunrpc() and in
fs/nfs/inode.c:exit_nfs_fs()?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
