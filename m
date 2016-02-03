From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: memory leak in gigaset_initcshw
Date: Wed, 03 Feb 2016 20:11:05 +0100
Message-ID: <1454526665.14366.22.camel@tiscali.nl>
References: <CACT4Y+Y+P7-pM0D4HTz4ZF6i+Rya22eOkPdnrv_OmDCMB7eQtg@mail.gmail.com>
	 <1454516189.14366.8.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud6.xs4all.net ([194.109.24.24]:57637 "EHLO
	lb1-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964955AbcBCTLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 14:11:09 -0500
In-Reply-To: <1454516189.14366.8.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dmitry,

On wo, 2016-02-03 at 17:16 +0100, Paul Bolle wrote:
> The above should provide me with enough information to figure out
> what's going on here.

I've instrumented ser_gigaset with some printk's. Basically I added the
stuff pasted at the end of this message. In 10.000 runs of the program
syzkaller generated the added printk's suggest that struct ser_cardstate
is freed every time.

(Note that this was done on a machine that, probably like the VM
syzkaller was running in, doesn't have the clunky hardware that this
driver manages attached.)

Before I dive deeper into this: can you reproduce this leak? Is it
perhaps a one in gazillion runs thing? Do you have the logs of a run
that warned about this leak at hand?

Thanks,


Paul Bolle

@@ -375,9 +377,12 @@ static void gigaset_device_release(struct device *dev)
 {
        struct cardstate *cs = dev_get_drvdata(dev);
 
-       if (!cs)
+       if (!cs) {
+               pr_info("%s: no cardstate", __func__);
                return;
+       }
        dev_set_drvdata(dev, NULL);
+       pr_info("%s: kfree(%p)", __func__, cs->hw.ser);
        kfree(cs->hw.ser);
        cs->hw.ser = NULL;
 }
@@ -392,6 +397,7 @@ static int gigaset_initcshw(struct cardstate *cs)
        struct ser_cardstate *scs;
 
        scs = kzalloc(sizeof(struct ser_cardstate), GFP_KERNEL);
+       pr_info("%s: scs = %p", __func__, scs);
        if (!scs) {
                pr_err("out of memory\n");
                return -ENOMEM;
