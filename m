From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.4 sunrpc oops.
Date: Wed, 21 Apr 2004 13:45:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421174525.GA7859@fieldses.org>
References: <20040315194642.GB19555@redhat.com> <20040315203853.GF3114@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040315203853.GF3114@fieldses.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 15, 2004 at 03:38:53PM -0500, J. Bruce Fields wrote:
> On Mon, Mar 15, 2004 at 07:46:42PM +0000, Dave Jones wrote:
> > modprobe auth_rpcgss
> > rmmod auth_rpcgss
> > rmmod sunrpc
> > *bang*
> > 
> > Seems to survive rmmod sunrpc usually, so it's the auth_rpcgcc
> > module leaving something around long after its dead perhaps?
> 
> Yes, this is my fault, apologies.  I'll follow up with a patch as soon
> as I've made one....--Bruce Fields

Ugh, sorry for the delay.

--b.

Unregister svcauth_gss caches on exit from gss module; fixes an oops on rmmod.


 include/linux/sunrpc/svcauth_gss.h |    1 +
 net/sunrpc/auth_gss/auth_gss.c     |    1 +
 net/sunrpc/auth_gss/svcauth_gss.c  |    7 +++++++
 3 files changed, 9 insertions(+)

diff -puN include/linux/sunrpc/svcauth_gss.h~nfsd_gss_rmmod_fix include/linux/sunrpc/svcauth_gss.h
--- linux-2.6.6-rc1/include/linux/sunrpc/svcauth_gss.h~nfsd_gss_rmmod_fix	2004-04-21 13:42:56.000000000 -0400
+++ linux-2.6.6-rc1-bfields/include/linux/sunrpc/svcauth_gss.h	2004-04-21 13:42:56.000000000 -0400
@@ -20,6 +20,7 @@
 #include <linux/sunrpc/auth_gss.h>
 
 int gss_svc_init(void);
+void gss_svc_shutdown(void);
 int svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name);
 
 #endif /* __KERNEL__ */
diff -puN net/sunrpc/auth_gss/auth_gss.c~nfsd_gss_rmmod_fix net/sunrpc/auth_gss/auth_gss.c
--- linux-2.6.6-rc1/net/sunrpc/auth_gss/auth_gss.c~nfsd_gss_rmmod_fix	2004-04-21 13:42:56.000000000 -0400
+++ linux-2.6.6-rc1-bfields/net/sunrpc/auth_gss/auth_gss.c	2004-04-21 13:42:56.000000000 -0400
@@ -998,6 +998,7 @@ out:
 
 static void __exit exit_rpcsec_gss(void)
 {
+	gss_svc_shutdown();
 	gss_mech_unregister_all();
 	rpcauth_unregister(&authgss_ops);
 }
diff -puN net/sunrpc/auth_gss/svcauth_gss.c~nfsd_gss_rmmod_fix net/sunrpc/auth_gss/svcauth_gss.c
--- linux-2.6.6-rc1/net/sunrpc/auth_gss/svcauth_gss.c~nfsd_gss_rmmod_fix	2004-04-21 13:42:56.000000000 -0400
+++ linux-2.6.6-rc1-bfields/net/sunrpc/auth_gss/svcauth_gss.c	2004-04-21 13:42:56.000000000 -0400
@@ -1086,3 +1086,10 @@ gss_svc_init(void)
 	svc_auth_register(RPC_AUTH_GSS, &svcauthops_gss);
 	return 0;
 }
+
+void
+gss_svc_shutdown(void)
+{
+	cache_unregister(&rsc_cache);
+	cache_unregister(&rsi_cache);
+}

_
