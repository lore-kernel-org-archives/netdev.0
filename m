From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sockopt: Change getsockopt() of
 SO_BINDTODEVICE to return an interface name
Date: Fri, 02 Nov 2012 11:23:04 +0100
Message-ID: <1351851784.32673.2788.camel@edumazet-glaptop>
References: <509184D9.8030103@hp.com>  <5093940B.6020207@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60817 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933539Ab2KBKXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 06:23:09 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1317986bkc.19
        for <netdev@vger.kernel.org>; Fri, 02 Nov 2012 03:23:08 -0700 (PDT)
In-Reply-To: <5093940B.6020207@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-02 at 13:36 +0400, Pavel Emelyanov wrote:

> This still races with the device name change, potentially providing
> a name which never existed in the system, doesn't it?

It does.

Maybe add a seqlock_t, to avoid taking rtnl here.
(as it could bring interesting lockdep/deadlock issues)

Here is the write side. Read side is trivial.

diff --git a/net/core/dev.c b/net/core/dev.c
index b4978e2..0184ec9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -201,6 +201,8 @@ static struct list_head ptype_all __read_mostly;	/* Taps */
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
+DEFINE_SEQLOCK(devnet_rename_seq);
+
 static inline void dev_base_seq_inc(struct net *net)
 {
 	while (++net->dev_base_seq == 0);
@@ -1018,17 +1020,22 @@ int dev_change_name(struct net_device *dev, const char *newname)
 
 	memcpy(oldname, dev->name, IFNAMSIZ);
 
+	write_seqlock(&devnet_rename_seq);
 	err = dev_get_valid_name(net, dev, newname);
-	if (err < 0)
+	if (err < 0) {
+		write_sequnlock(&devnet_rename_seq);
 		return err;
-
+	}
 rollback:
 	ret = device_rename(&dev->dev, dev->name);
 	if (ret) {
 		memcpy(dev->name, oldname, IFNAMSIZ);
+		write_sequnlock(&devnet_rename_seq);
 		return ret;
 	}
 
+	write_sequnlock(&devnet_rename_seq);
+
 	write_lock_bh(&dev_base_lock);
 	hlist_del_rcu(&dev->name_hlist);
 	write_unlock_bh(&dev_base_lock);
@@ -1046,6 +1053,7 @@ rollback:
 		/* err >= 0 after dev_alloc_name() or stores the first errno */
 		if (err >= 0) {
 			err = ret;
+			write_seqlock(&devnet_rename_seq);
 			memcpy(dev->name, oldname, IFNAMSIZ);
 			goto rollback;
 		} else {
