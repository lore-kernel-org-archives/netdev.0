From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Sun, 27 May 2007 23:13:32 +0200
Message-ID: <200705272313.33129.mb@bu3sch.de>
References: <20070525172431.60affaca@freepuppy> <200705261901.18110.mb@bu3sch.de> <200705272125.25506.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705272125.25506.maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 27 May 2007 21:25:17 Maximilian Engelhardt wrote:
> 2.6.21.1:
> [  5] local 192.168.1.2 port 58414 connected with 192.168.1.1 port 5001
> [  5]  0.0-60.6 sec  1.13 MBytes    157 Kbits/sec
> [  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 57837
> [  4]  0.0-63.1 sec  2.82 MBytes    375 Kbits/sec

> 2.6.22-rc3:
> [  5] local 192.168.1.2 port 46557 connected with 192.168.1.1 port 5001
> [  5]  0.0-60.4 sec  58.9 MBytes  8.18 Mbits/sec
> [  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 51633
> [  4]  0.0-63.1 sec  7.27 MBytes    967 Kbits/sec

This is the diff between these two kernels.
I'm not sure why you see a much better TX throughput here.

Can you re-check to make sure it's not just some test-jitter?


--- linux-2.6.21.1/drivers/net/b44.c    2007-05-27 22:58:01.000000000 +0200
+++ linux-2.6.22-rc3/drivers/net/b44.c  2007-05-27 23:01:44.000000000 +0200
@@ -825,12 +825,11 @@
                        if (copy_skb == NULL)
                                goto drop_it_no_recycle;
 
-                       copy_skb->dev = bp->dev;
                        skb_reserve(copy_skb, 2);
                        skb_put(copy_skb, len);
                        /* DMA sync done above, copy just the actual packet */
-                       memcpy(copy_skb->data, skb->data+bp->rx_offset, len);
-
+                       skb_copy_from_linear_data_offset(skb, bp->rx_offset,
+                                                        copy_skb->data, len);
                        skb = copy_skb;
                }
                skb->ip_summed = CHECKSUM_NONE;
@@ -1007,7 +1006,8 @@
                        goto err_out;
                }
 
-               memcpy(skb_put(bounce_skb, len), skb->data, skb->len);
+               skb_copy_from_linear_data(skb, skb_put(bounce_skb, len),
+                                         skb->len);
                dev_kfree_skb_any(skb);
                skb = bounce_skb;
        }

-- 
Greetings Michael.
