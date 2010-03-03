From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.33 dies on modprobe
Date: Wed, 3 Mar 2010 14:24:20 -0800
Message-ID: <20100303142420.accf985e.akpm@linux-foundation.org>
References: <20100228221257.GA8858@invalid>
	<2375c9f91002282022n29e83858jd8cadbb2e664b436@mail.gmail.com>
	<20100302185213.43a1a0d7.akpm@linux-foundation.org>
	<20100303221602.GA3264@invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: M G Berberich <berberic@fmi.uni-passau.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58125 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756394Ab0CCWYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 17:24:35 -0500
In-Reply-To: <20100303221602.GA3264@invalid>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Mar 2010 23:16:02 +0100
M G Berberich <berberic@fmi.uni-passau.de> wrote:

> Hello,
> 
> Am Dienstag, den 02. M__rz schrieb Andrew Morton:
> 
> > It could be that some kobject on that list has become invalid (memory
> > was freed, module was unloaded, etc) and later code stumbled across the
> > now-invalid object on that list and then crashed.
> > 
> > What we can do to find this is to add a diagnostic each time an object
> > is registered, and a diagnostic each time kset_find_obj() looks at the
> > objects.  Then we'll see which kobject caused the crash, then we can
> > look back and see where that kobject was registered from.
> 
> [...]
> 
> > This will generate a lot of output and we don't want to lose any of it.
> >  I'd suggest setting up netconsole so all the output can be reliably
> > saved: Documentation/networking/netconsole.txt
> 
> I have a serial connection to a netbook. Log attached.

drat, my patch didn't work.  Can you try this one please?

--- a/lib/kobject.c~a
+++ a/lib/kobject.c
@@ -126,6 +126,8 @@ static void kobj_kset_join(struct kobjec
 
 	kset_get(kobj->kset);
 	spin_lock(&kobj->kset->list_lock);
+	printk("kobj_kset_join:%p\n", kobj);
+	dump_stack();
 	list_add_tail(&kobj->entry, &kobj->kset->list);
 	spin_unlock(&kobj->kset->list_lock);
 }
@@ -751,9 +753,12 @@ struct kobject *kset_find_obj(struct kse
 
 	spin_lock(&kset->list_lock);
 	list_for_each_entry(k, &kset->list, entry) {
-		if (kobject_name(k) && !strcmp(kobject_name(k), name)) {
-			ret = kobject_get(k);
-			break;
+		if (kobject_name(k)) {
+			printk("kset_find_obj:%p\n", k);
+			if (!strcmp(kobject_name(k), name)) {
+				ret = kobject_get(k);
+				break;
+			}
 		}
 	}
 	spin_unlock(&kset->list_lock);
_

