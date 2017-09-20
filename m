From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 07:40:51 -0700
Message-ID: <1505918451.29839.97.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
         <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
         <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl>
         <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
         <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
         <07bde5d4-fab6-3ef9-f586-403dadbb0a2a@itcare.pl>
         <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
         <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl>
         <6c073f86-ab71-0a8f-7b9a-91d5ae5da214@itcare.pl>
         <7fee43ee-75b5-c2f5-cf8d-684ceefcd2d1@itcare.pl>
         <c278dec6-e018-62e0-a613-1fa79741aaab@itcare.pl>
         <cfc04422-51bd-0a28-6a8c-6b57179e8af2@itcare.pl>
         <3324f95f-7686-81e0-a973-1a9220c918fe@itcare.pl>
         <1505913075.29839.90.camel@edumazet-glaptop3.roam.corp.google.com>
         <07c29702-cd0b-32af-df0a-83ad24b8c785@itcare.pl>
         <1505914479.29839.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <686ea8f0-d9f8-82bc-ca68-f1d97614aa6b@itcare.pl>
         <1505915099.29839.95.camel@edumazet-glaptop3.roam.corp.google.com>
         <cf94cafb-07b0-f04d-016d-cbdb46b557c1@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Wei Wang <weiwan@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        edumazet@google.com
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37578 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751507AbdITOky (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:40:54 -0400
Received: by mail-pg0-f67.google.com with SMTP id v5so1748449pgn.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:40:54 -0700 (PDT)
In-Reply-To: <cf94cafb-07b0-f04d-016d-cbdb46b557c1@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-20 at 16:03 +0200, Paweł Staszewski wrote:
> Nit much more after adding this patch
> 
> https://bugzilla.kernel.org/attachment.cgi?id=258529
> 

This is why I suggested to replace the BUG() in another mail

So :

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f535779d9dc1dfe36934c2abba4e43d053ac5d6f..220cd12456754876edf2d3ef13195e82d70d5c74 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3331,7 +3331,15 @@ void netdev_run_todo(void);
  */
 static inline void dev_put(struct net_device *dev)
 {
-	this_cpu_dec(*dev->pcpu_refcnt);
+	int __percpu *pref = READ_ONCE(dev->pcpu_refcnt);
+
+	if (!pref) {
+		pr_err("no pcpu_refcnt on dev %p(%s) state %d dismantle %d\n",
+		       dev, dev->name, dev->reg_state, dev->dismantle);
+		for (;;)
+			cpu_relax();
+	}
+	this_cpu_dec(*pref);
 }
 
 /**
