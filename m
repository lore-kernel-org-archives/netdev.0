From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: forcedeth and kernel 2.6.5 has "no link"
Date: Fri, 16 Apr 2004 21:06:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40802EC0.2070108@colorfullife.com>
References: <20040416183844.GA2923@gambit.implode.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050806000708040207010204"
Cc: c-d.hailfinger.kernel.2004@gmx.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Wong <kernel@implode.net>
In-Reply-To: <20040416183844.GA2923@gambit.implode.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050806000708040207010204
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

John Wong wrote:

>Under kernel 2.6.4, ethtool reports:
>
>Settings for eth0:
>        Link detected: yes
>
>This is with forcedeth 0.23
>
>Under kernel 2.6.5, ethtool reports:
>
>Settings for eth0:
>        Supports Wake-on: g
>        Wake-on: d
>        Link detected: no
>
>This is with forcedeth 0.25
>  
>
Odd. I'm not aware of any changes that might cause that difference. I'll 
check the diff.

>I had submitted the bugzilla id 2283.  2496 is something that I am
>experiencing too.
>  
>
Could you try the attached patch?


--
    Manfred

--------------050806000708040207010204
Content-Type: text/plain;
 name="patch-forced-test"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forced-test"

--- 2.6/drivers/net/forcedeth.c	2004-04-10 09:52:45.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2004-04-13 18:58:59.000000000 +0200
@@ -1263,6 +1263,14 @@
 				dev->name, id1, id2, i);
 		np->phyaddr = i;
 
+		if (id1 == 0x0015 && (id2 &0xfff0) == 0xf440) {
+			printk(KERN_DEBUG "%s: open: Found ICS, applying workaround.\n", dev->name);
+        		/* workaround for ICS1893 PHY */
+            		mii_rw(dev, i, 0x0018, 0xD200);
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			schedule_timeout(HZ);
+		}
+
 		spin_lock_irq(&np->lock);
 		nv_update_linkspeed(dev);
 		spin_unlock_irq(&np->lock);

--------------050806000708040207010204--
