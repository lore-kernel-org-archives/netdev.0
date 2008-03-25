From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: [RFC][LAPB] write_queue limit in lapb_data_request
Date: Tue, 25 Mar 2008 10:45:41 +0300
Message-ID: <8496f91a0803250045k2fc4040dg74126f30c1487fd@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:53433 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbYCYHpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 03:45:43 -0400
Received: by py-out-1112.google.com with SMTP id u52so4764435pyb.10
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2008 00:45:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

LAPB doesn't check for write_queue length in lapb_data_request(). So
in some conditions it may grow unlimited. There is a potential problem
for small systems.

It seems like this for me:

345 int lapb_data_request(struct net_device *dev, struct sk_buff *skb)
346 {
347         struct lapb_cb *lapb = lapb_devtostruct(dev);
348         int rc = LAPB_BADTOKEN;
349
350         if (!lapb)
351                 goto out;
352
353         rc = LAPB_NOTCONNECTED;
354         if (lapb->state != LAPB_STATE_3 && lapb->state != LAPB_STATE_4)
355                 goto out_put;
356
+
+            if (lapb->write_queue.qlen >= LAPB_WRITE_QUEUE_MAX)
+                    goto out_put;
+
357         skb_queue_tail(&lapb->write_queue, skb);
358         lapb_kick(lapb);
359         rc = LAPB_OK;
360 out_put:
361         lapb_put(lapb);
362 out:
363         return rc;
364 }
