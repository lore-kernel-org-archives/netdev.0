From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
	at 0000000000000370
Date: Mon, 21 Jul 2008 21:06:46 +0200
Message-ID: <20080721190646.GA19044@elte.hu>
References: <20080721134506.GA27598@elte.hu> <20080721143023.GA32451@elte.hu> <20080721150446.GA17746@elte.hu> <20080721.082419.70392960.davem@davemloft.net> <4884D2F1.2030704@telenet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	wireless <linux-wireless@vger.kernel.org>, j@w1.fi
To: Ian Schram <ischram@telenet.be>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754513AbYGUTH3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4884D2F1.2030704@telenet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ian Schram <ischram@telenet.be> wrote:

> I was looking at this out of interest, but I'm in no way familiar with 
> the code.

thanks Ian for the patch, i'll test it.

Note that it was whitespace damaged, find below a tidied up version of 
the patch that i've applied to tip/out-of-tree.

	Ingo

----------------------->
commit 2f77dd3a3b5c3a27298fa0a09d8703c09c633fc6
Author: Ian Schram <ischram@telenet.be>
Date:   Mon Jul 21 20:18:25 2008 +0200

    mac80211_hwsim.c: fix: BUG: unable to handle kernel NULL pointer dereference at 0000000000000370
    
    I was looking at this out of interest, but I'm in no way familiar with
    the code.
    
    Looks to me that the error handling code in mac80211_hwsim is awkward.
    Which leads to it calling ieee80211_unregister_hw even when
    ieee80211_register_hw failed.
    
    The function has a for loop where it generates all simulated radios.
    when something fails, the error handling will call mac80211_hwsim_free
    which frees all simulated radios who's pointer isn't zero. However the
    information stored is insufficient to determine whether or not the call
    to ieee80211_register_hw succeeded or not for a specific radio. The
    included patch makes init_mac80211_hwsim clean up the current simulated
    radio, and then calls into mac80211_hwsim_free to clean up all the
    radios that did succeed.
    
    This however doesn't explain why the rate control registration failed..
    build tested this, but had some problems reproducing the original
    problem.
    
    Signed-off-by: Ian Schram <ischram@telenet.be>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/wireless/mac80211_hwsim.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 913dc9f..5816230 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -364,8 +364,7 @@ static void mac80211_hwsim_free(void)
 			struct mac80211_hwsim_data *data;
 			data = hwsim_radios[i]->priv;
 			ieee80211_unregister_hw(hwsim_radios[i]);
-			if (!IS_ERR(data->dev))
-				device_unregister(data->dev);
+			device_unregister(data->dev);
 			ieee80211_free_hw(hwsim_radios[i]);
 		}
 	}
@@ -437,7 +436,7 @@ static int __init init_mac80211_hwsim(void)
 			       "mac80211_hwsim: device_create_drvdata "
 			       "failed (%ld)\n", PTR_ERR(data->dev));
 			err = -ENOMEM;
-			goto failed;
+			goto failed_drvdata;
 		}
 		data->dev->driver = &mac80211_hwsim_driver;
 
@@ -461,7 +460,7 @@ static int __init init_mac80211_hwsim(void)
 		if (err < 0) {
 			printk(KERN_DEBUG "mac80211_hwsim: "
 			       "ieee80211_register_hw failed (%d)\n", err);
-			goto failed;
+			goto failed_hw;
 		}
 
 		printk(KERN_DEBUG "%s: hwaddr %s registered\n",
@@ -479,9 +478,9 @@ static int __init init_mac80211_hwsim(void)
 	rtnl_lock();
 
 	err = dev_alloc_name(hwsim_mon, hwsim_mon->name);
-	if (err < 0) {
+	if (err < 0)
 		goto failed_mon;
-	}
+
 
 	err = register_netdevice(hwsim_mon);
 	if (err < 0)
@@ -494,7 +493,14 @@ static int __init init_mac80211_hwsim(void)
 failed_mon:
 	rtnl_unlock();
 	free_netdev(hwsim_mon);
+	mac80211_hwsim_free();
+	return err;
 
+failed_hw:
+	device_unregister(data->dev);
+failed_drvdata:
+	ieee80211_free_hw(hw);
+	hwsim_radios[i] = 0;
 failed:
 	mac80211_hwsim_free();
 	return err;
