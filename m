From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: memory leak in gigaset_initcshw
Date: Fri, 05 Feb 2016 19:36:01 +0100
Message-ID: <1454697361.28847.39.camel@tiscali.nl>
References: <CACT4Y+Y+P7-pM0D4HTz4ZF6i+Rya22eOkPdnrv_OmDCMB7eQtg@mail.gmail.com>
	 <1454516189.14366.8.camel@tiscali.nl>
	 <1454526665.14366.22.camel@tiscali.nl>
	 <CACT4Y+aDi8L_GELzVv7QM8YdtMD7q-wH4uO7LhioeSvaEU5PJg@mail.gmail.com>
	 <1454591389.14366.49.camel@tiscali.nl>
	 <CACT4Y+aXo83LjyOjVG2ihyR94kex-z+=Of+x8o4i+0q8964-1g@mail.gmail.com>
	 <1454593604.14366.65.camel@tiscali.nl>
	 <CACT4Y+b2z0NHVPQbyYP1CA_80hXxhk+VOG6dzduMEsi+27Pi7Q@mail.gmail.com>
	 <1454598375.14366.72.camel@tiscali.nl>
	 <CACT4Y+aNN8AAtRSvxxrP5RfsTZdd49odnQ_GRq86Y=jXr=pANw@mail.gmail.com>
	 <1454688387.28847.34.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454688387.28847.34.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On vr, 2016-02-05 at 17:06 +0100, Paul Bolle wrote:
> If that would happen, then cs can be reused while the previous
> > cs->hw.ser is not freed yet. Just a guess.
> 
> I'll have to ponder on that a bit, sorry.

This is from the hit-the-code-until-it-confesses department:
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -373,13 +373,9 @@ static void gigaset_freecshw(struct cardstate *cs)
 
 static void gigaset_device_release(struct device *dev)
 {
-       struct cardstate *cs = dev_get_drvdata(dev);
-
-       if (!cs)
-               return;
+       struct ser_cardstate *scs = dev_get_drvdata(dev);
        dev_set_drvdata(dev, NULL);
-       kfree(cs->hw.ser);
-       cs->hw.ser = NULL;
+       kfree(scs);
 }
 
 /*
@@ -408,7 +404,7 @@ static int gigaset_initcshw(struct cardstate *cs)
                cs->hw.ser = NULL;
                return rc;
        }
-       dev_set_drvdata(&cs->hw.ser->dev.dev, cs);
+       dev_set_drvdata(&cs->hw.ser->dev.dev, scs);
 
        tasklet_init(&cs->write_tasklet,
                     gigaset_modem_fill, (unsigned long) cs);

Does that make any difference?


Paul Bolle
