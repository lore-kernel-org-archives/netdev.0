From: Lin Ming <ming.m.lin@intel.com>
Subject: Re: [PATCH -v2] netconsole: switch init_netconsole() to
 late_initcall if build-in
Date: Tue, 13 Sep 2011 16:38:50 +0800
Message-ID: <1315903130.3375.7.camel@snb>
References: <1315899939.3402.2.camel@snb>
	 <20110913010158.1652cdee.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Andrew Morton <akpm00@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110913010158.1652cdee.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-09-13 at 16:01 +0800, Andrew Morton wrote:
> On Tue, 13 Sep 2011 15:45:39 +0800 Lin Ming <ming.m.lin@intel.com> wrote:
> 
> > Commit 88491d8(drivers/net: Kconfig & Makefile cleanup) causes a
> > regression that netconsole does not work if netconsole and network
> > device driver are build into kernel, because netconsole is linked
> > before network device driver.
> > 
> > Andrew Morton suggested to fix this with initcall ordering.
> > Fixes it by switching init_netconsole() to late_initcall if build-in.
> > 
> > Signed-off-by: Lin Ming <ming.m.lin@intel.com>
> > ---
> >  drivers/net/netconsole.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> > index dfc8272..914be29 100644
> > --- a/drivers/net/netconsole.c
> > +++ b/drivers/net/netconsole.c
> > @@ -799,5 +799,9 @@ static void __exit cleanup_netconsole(void)
> >  	}
> >  }
> >  
> > +#ifdef MODULE
> >  module_init(init_netconsole);
> >  module_exit(cleanup_netconsole);
> > +#else
> > +late_initcall(init_netconsole);
> > +#endif /* !MODULE */
> 
> The ifdefs (which should have used CONFIG_MODULE) aren't needed. 
> Because late_initcall() and module_init() are identical if
> CONFIG_MODULE, and because one day we might want to run the exitcalls
> for built-in code (UML actually does this at present).

Thanks for comments.
Updated as below.

>From 035af5dca36a3b9e255758a46214e0e6d2b5b6a3 Mon Sep 17 00:00:00 2001
From: Lin Ming <ming.m.lin@intel.com>
Date: Tue, 13 Sep 2011 16:35:46 +0800
Subject: [PATCH -v3] netconsole: switch init_netconsole() to late_initcall

Commit 88491d8(drivers/net: Kconfig & Makefile cleanup) causes a
regression that netconsole does not work if netconsole and network
device driver are build into kernel, because netconsole is linked
before network device driver.

Andrew Morton suggested to fix this with initcall ordering.
Fixes it by switching init_netconsole() to late_initcall.

Signed-off-by: Lin Ming <ming.m.lin@intel.com>
---
 drivers/net/netconsole.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index dfc8272..ed2a397 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -799,5 +799,11 @@ static void __exit cleanup_netconsole(void)
 	}
 }
 
-module_init(init_netconsole);
+/*
+ * Use late_initcall to ensure netconsole is
+ * initialized after network device driver if built-in.
+ *
+ * late_initcall() and module_init() are identical if built as module.
+ */
+late_initcall(init_netconsole);
 module_exit(cleanup_netconsole);
-- 
1.7.2.5
