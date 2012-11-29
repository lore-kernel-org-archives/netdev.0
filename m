From: Jason Wang <jasowang@redhat.com>
Subject: Re: "tuntap: multiqueue support" causes udev fork bombs
Date: Thu, 29 Nov 2012 13:47:04 +0800
Message-ID: <4146845.d5imC0scLB@jason-thinkpad-t430s>
References: <50B5E6A5.6040009@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, rmilasan@suse.cz,
	Jiri Slaby <jirislaby@gmail.com>, maxk@qualcomm.com,
	vtun@office.satix.net
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50B5E6A5.6040009@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, November 28, 2012 11:25:41 AM Jiri Slaby wrote:
> Hi,
> 
> with this commit:
> commit c8d68e6be1c3b242f1c598595830890b65cea64a
> Author: Jason Wang <jasowang@redhat.com>
> Date:   Wed Oct 31 19:46:00 2012 +0000
> 
>     tuntap: multiqueue support
> 
> 
> I see fork bombs from udev. It is trying to create 2048 processes. 1024
> for tx, 1024 for rx. OOM killer indeed steps in and kills everything.

Hi, thanks for the reporting, could you pls try the following patch?

---

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b44d7b7..cc3f878 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -492,9 +492,6 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 
 	tun_set_real_num_queues(tun);
 
-	if (tun->numqueues == 1)
-		netif_carrier_on(tun->dev);
-
 	/* device is allowed to go away first, so no need to hold extra
 	 * refcnt.
 	 */
@@ -1611,6 +1608,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			TUN_USER_FEATURES;
 		dev->features = dev->hw_features;
 
+		err = tun_attach(tun, file);
+		if (err < 0)
+			goto err_free_dev;
+
 		err = register_netdevice(tun->dev);
 		if (err < 0)
 			goto err_free_dev;
@@ -1620,9 +1621,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		    device_create_file(&tun->dev->dev, &dev_attr_group))
 			pr_err("Failed to create tun sysfs files\n");
 
-		err = tun_attach(tun, file);
-		if (err < 0)
-			goto err_free_dev;
+		netif_carrier_on(tun->dev);
 	}
 
 	tun_debug(KERN_INFO, tun, "tun_set_iff\n");
