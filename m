From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel
 modules
Date: Fri, 25 Feb 2011 20:38:30 +0000
Message-ID: <1298666310.2554.47.camel@bwh-desktop>
References: <1298660879.2554.23.camel@bwh-desktop>
	 <20110225.111606.115927805.davem@davemloft.net>
	 <1298662216.2554.33.camel@bwh-desktop>
	 <20110225.114351.28809001.davem@davemloft.net>
	 <1298663585.2554.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: segoon@openwall.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298663585.2554.39.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-02-25 at 19:53 +0000, Ben Hutchings wrote:
> On Fri, 2011-02-25 at 11:43 -0800, David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Fri, 25 Feb 2011 19:30:16 +0000
> > 
> > > On Fri, 2011-02-25 at 11:16 -0800, David Miller wrote:
> > >> From: Ben Hutchings <bhutchings@solarflare.com>
> > >> Date: Fri, 25 Feb 2011 19:07:59 +0000
> > >> 
> > >> > You realise that module loading doesn't actually run in the context of
> > >> > request_module(), right?
> > >> 
> > >> Why is that a barrier?  We could simply pass a capability mask into
> > >> request_module if necessary.
> > >> 
> > >> It's an implementation detail, and not a deterrant to my suggested
> > >> scheme.
> > > 
> > > It's not an implementation detail.  modprobe currently runs with full
> > > capabilities; your proposal requires its capabilities to be limited to
> > > those of the capabilities of the process that triggered the
> > > request_module() (plus, presumably, CAP_SYS_MODULE).
> > 
> > The idea was that the kernel will be the entity that will inspect the
> > elf sections and validate the capability bits, not the userspace
> > module loader.
> 
> Yes, I understand that.
> 
> > Surely we if we can pass an arbitrary string out to the loading
> > process as part of the module loading context, we can pass along
> > capability bits as well.
> 
> If you want insert_module() to be able to deny loading some modules
> based on the capabilities of the process calling request_module() then
> you either have to *reduce* the capabilities given to modprobe or create
> some extra process state, separate from the usual capability state,
> specifically for this purpose.

I bet something like this (plus Vasiliy's changes to static module
aliases) would cover 99.9% of legitimate uses of this feature:

diff --git a/net/core/dev.c b/net/core/dev.c
index 54aaca6..0d09baa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1120,8 +1120,20 @@ void dev_load(struct net *net, const char *name)
 	dev = dev_get_by_name_rcu(net, name);
 	rcu_read_unlock();
 
-	if (!dev && capable(CAP_NET_ADMIN))
-		request_module("%s", name);
+	if (!dev && capable(CAP_NET_ADMIN)) {
+		/* Check whether the name looks like one that a net
+		 * driver will generate initially.  If not, require a
+		 * module alias with a suitable prefix, so that this
+		 * can't be used to load arbitrary modules.
+		 */
+		if ((strncmp(name, "eth", 3) == 0 &&
+		     isdigit((unsigned char)name[3])) ||
+		    (strncmp(name, "wlan", 4) == 0 &&
+		     isdigit((unsigned char)name[4])))
+			request_module("%s", name);
+		else
+			request_module("netdev-%s", name);
+	}
 }
 EXPORT_SYMBOL(dev_load);
 
---

Note that we don't have to care about interfaces that get renamed from
eth%d or wlan%d, since renaming is triggered asynchronously and
therefore can't be used in conjunction with the auto-loading feature.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
