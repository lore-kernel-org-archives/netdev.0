From: Ian Schram <ischram@telenet.be>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 20:18:25 +0200
Message-ID: <4884D2F1.2030704@telenet.be>
References: <20080721134506.GA27598@elte.hu>	<20080721143023.GA32451@elte.hu>	<20080721150446.GA17746@elte.hu> <20080721.082419.70392960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	wireless <linux-wireless@vger.kernel.org>, j@w1.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yorgi.telenet-ops.be ([195.130.133.69]:53982 "EHLO
	yorgi.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbYGUSSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 14:18:53 -0400
In-Reply-To: <20080721.082419.70392960.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was looking at this out of interest, but I'm in no way familiar with the code.

Looks to me that the error handling code in mac80211_hwsim is awkward. Which
leads to it calling ieee80211_unregister_hw even when ieee80211_register_hw failed.

The function has a for loop where it generates all simulated radios. when something
fails, the error handling will call mac80211_hwsim_free which frees all simulated radios
who's pointer isn't zero. However the information stored is insufficient to determine
whether or not the call to ieee80211_register_hw succeeded or not for a specific radio.
The included patch makes init_mac80211_hwsim clean up the current simulated radio,
and then calls into mac80211_hwsim_free to clean up all the radios that did succeed.

This however doesn't explain why the rate control registration failed.. build tested this,
but had some problems reproducing the original problem.

signed-off-by: Ian Schram <ischram@telenet.be>
--- a/mac80211_hwsim.c	2008-07-21 18:48:38.000000000 +0200
+++ b/mac80211_hwsim.c	2008-07-21 19:31:44.000000000 +0200
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
@@ -437,7 +436,7 @@ static int __init init_mac80211_hwsim(vo
  			       "mac80211_hwsim: device_create_drvdata "
  			       "failed (%ld)\n", PTR_ERR(data->dev));
  			err = -ENOMEM;
-			goto failed;
+			goto failed_drvdata;
  		}
  		data->dev->driver = &mac80211_hwsim_driver;

@@ -461,7 +460,7 @@ static int __init init_mac80211_hwsim(vo
  		if (err < 0) {
  			printk(KERN_DEBUG "mac80211_hwsim: "
  			       "ieee80211_register_hw failed (%d)\n", err);
-			goto failed;
+			goto failed_hw;
  		}

  		printk(KERN_DEBUG "%s: hwaddr %s registered\n",
@@ -479,9 +478,9 @@ static int __init init_mac80211_hwsim(vo
  	rtnl_lock();

  	err = dev_alloc_name(hwsim_mon, hwsim_mon->name);
-	if (err < 0) {
+	if (err < 0)
  		goto failed_mon;
-	}
+

  	err = register_netdevice(hwsim_mon);
  	if (err < 0)
@@ -494,7 +493,14 @@ static int __init init_mac80211_hwsim(vo
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


