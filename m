From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/4] DST: Distributed storage documentation.
Date: Mon, 10 Dec 2007 23:03:43 +0300
Message-ID: <20071210200343.GA12635@2ka.mipt.ru>
References: <11972872501664@2ka.mipt.ru> <3ae72650712100451h6a84d6cfs9b3a2954c13c4612@mail.gmail.com> <20071210125839.GA16789@2ka.mipt.ru> <1197297108.6399.91.camel@lov.site> <20071210145055.GB7184@2ka.mipt.ru> <1197313348.6399.106.camel@lov.site> <20071210193304.GA24737@2ka.mipt.ru> <1197315895.6399.121.camel@lov.site> <20071210195145.GA29132@2ka.mipt.ru> <1197316609.6399.124.camel@lov.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Greg KH <greg@kroah.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35088 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539AbXLJUDu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 15:03:50 -0500
Content-Disposition: inline
In-Reply-To: <1197316609.6399.124.camel@lov.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 10, 2007 at 08:56:49PM +0100, Kay Sievers (kay.sievers@vrfy.org) wrote:
> On Mon, 2007-12-10 at 22:51 +0300, Evgeniy Polyakov wrote:
> > On Mon, Dec 10, 2007 at 08:44:55PM +0100, Kay Sievers (kay.sievers@vrfy.org) wrote:
> > > > > > Actually not - I have to set reference counter to something other than 1
> > > > > > or +/- 1, and thus will have to call kref_get() in a loop, which is a
> > > > > > very ugly step. Is there kref_set() or somethinglike that? At least not
> > > > > > in 2.6.22 what I'm using for now.
> > > > > 
> > > > > Yeah, a loop would look pretty ugly. How about just adding kref_set(),
> > > > > if you need it.
> > > > 
> > > > Well, then it distributed storage will not be able to build as
> > > > standalone module, and kref_set() itself will not be accepted as a single 
> > > > patch, since there are no in-kernel users :)
> > > > It is easily doable though.
> > > 
> > > Most rules have exceptions. :) Send a patch, so we can see how it looks
> > > like.
> > 
> > It looks really non-trivial :)
> 
> Yeah, it does. :)
> We miss an EXPORT_SYMBOL(), right?

Yep :)

diff --git a/include/linux/kref.h b/include/linux/kref.h
index 6fee353..5d18563 100644
--- a/include/linux/kref.h
+++ b/include/linux/kref.h
@@ -24,6 +24,7 @@ struct kref {
 	atomic_t refcount;
 };
 
+void kref_set(struct kref *kref, int num);
 void kref_init(struct kref *kref);
 void kref_get(struct kref *kref);
 int kref_put(struct kref *kref, void (*release) (struct kref *kref));
diff --git a/lib/kref.c b/lib/kref.c
index a6dc3ec..9ecd6e8 100644
--- a/lib/kref.c
+++ b/lib/kref.c
@@ -15,13 +15,23 @@
 #include <linux/module.h>
 
 /**
+ * kref_set - initialize object and set refcount to requested number.
+ * @kref: object in question.
+ * @num: initial reference counter
+ */
+void kref_set(struct kref *kref, int num)
+{
+	atomic_set(&kref->refcount, num);
+	smp_mb();
+}
+
+/**
  * kref_init - initialize object.
  * @kref: object in question.
  */
 void kref_init(struct kref *kref)
 {
-	atomic_set(&kref->refcount,1);
-	smp_mb();
+	kref_set(kref, 1);
 }
 
 /**
@@ -61,6 +71,7 @@ int kref_put(struct kref *kref, void (*release)(struct kref *kref))
 	return 0;
 }
 
+EXPORT_SYMBOL(kref_set);
 EXPORT_SYMBOL(kref_init);
 EXPORT_SYMBOL(kref_get);
 EXPORT_SYMBOL(kref_put);

-- 
	Evgeniy Polyakov
