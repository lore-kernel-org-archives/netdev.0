From: Ian Morgan <imorgan@primordial.ca>
Subject: [NET/USB] ax88179_set_mac_addr: return only error or zero
Date: Wed, 15 Oct 2014 09:49:19 -0400
Message-ID: <CALgSy_dy8=WwTJ-GAkGY-DV=NeOOKEP7nMNO=0XyaP2wGwbkdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113fb70842e8860505766710
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:56760 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbaJONtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 09:49:41 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so17412500igb.8
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 06:49:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a113fb70842e8860505766710
Content-Type: text/plain; charset=UTF-8

(It's about a USB NIC, so not sure if this is suitable to the netdev
mailing list or the linux-usb mailing list, so you both get it.)

I had an issue with bonding one of these USB3 Gigabit NIC devices
because set_mac_addr was returning a positive value (6), and the
bonding driver thinks that any non-zero value is an error.

My proposed fix was to (I thought correctly) check for negative return
codes in bond_enslave() instead of any non-zero value.

I was told by the bonding driver maintainers that my proposed fix was
incorrect, and that the device driver should return only zero on
success, as other drivers do this and that assumption has been made.
I'm really not sure why the more vigilant check in the bonding driver
was "wrong" though. We all know the rule about assumptions ;-) But I
defer to their superior knowledge of kernel interfaces.

Anyhow, it would seem that the following patch is the "more
acceptable" solution, and is in line with what other drivers do:


--- linux-3.17/drivers/net/usb/ax88179_178a.c.orig  2014-10-05
15:23:04.000000000 -0400
+++ linux-3.17/drivers/net/usb/ax88179_178a.c   2014-10-15
09:07:31.217810217 -0400
@@ -937,6 +937,7 @@ static int ax88179_set_mac_addr(struct n
 {
        struct usbnet *dev = netdev_priv(net);
        struct sockaddr *addr = p;
+       int ret;

        if (netif_running(net))
                return -EBUSY;
@@ -946,8 +947,12 @@ static int ax88179_set_mac_addr(struct n
        memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);

        /* Set the MAC address */
-       return ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_NODE_ID, ETH_ALEN,
+       ret = ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_NODE_ID, ETH_ALEN,
                                 ETH_ALEN, net->dev_addr);
+       if (ret < 0)
+               return ret;
+
+       return 0;
 }

 static const struct net_device_ops ax88179_netdev_ops = {


(non-tab-mangled patch file attached)

Your feedback is duly appreciated. Please CC me, as I am not
subscribed to these mailing lists.

--
Ian Morgan

--001a113fb70842e8860505766710
Content-Type: text/x-patch; charset=US-ASCII; name="ax88719_setmacaddr_rc.patch"
Content-Disposition: attachment; filename="ax88719_setmacaddr_rc.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i1apg2mh0

LS0tIGxpbnV4LTMuMTcvZHJpdmVycy9uZXQvdXNiL2F4ODgxNzlfMTc4YS5jfgkyMDE0LTEwLTA1
IDE1OjIzOjA0LjAwMDAwMDAwMCAtMDQwMAorKysgbGludXgtMy4xNy9kcml2ZXJzL25ldC91c2Iv
YXg4ODE3OV8xNzhhLmMJMjAxNC0xMC0xNSAwOTowNzozMS4yMTc4MTAyMTcgLTA0MDAKQEAgLTkz
Nyw2ICs5MzcsNyBAQCBzdGF0aWMgaW50IGF4ODgxNzlfc2V0X21hY19hZGRyKHN0cnVjdCBuCiB7
CiAJc3RydWN0IHVzYm5ldCAqZGV2ID0gbmV0ZGV2X3ByaXYobmV0KTsKIAlzdHJ1Y3Qgc29ja2Fk
ZHIgKmFkZHIgPSBwOworCWludCByZXQ7CiAKIAlpZiAobmV0aWZfcnVubmluZyhuZXQpKQogCQly
ZXR1cm4gLUVCVVNZOwpAQCAtOTQ2LDggKzk0NywxMiBAQCBzdGF0aWMgaW50IGF4ODgxNzlfc2V0
X21hY19hZGRyKHN0cnVjdCBuCiAJbWVtY3B5KG5ldC0+ZGV2X2FkZHIsIGFkZHItPnNhX2RhdGEs
IEVUSF9BTEVOKTsKIAogCS8qIFNldCB0aGUgTUFDIGFkZHJlc3MgKi8KLQlyZXR1cm4gYXg4ODE3
OV93cml0ZV9jbWQoZGV2LCBBWF9BQ0NFU1NfTUFDLCBBWF9OT0RFX0lELCBFVEhfQUxFTiwKKwly
ZXQgPSBheDg4MTc5X3dyaXRlX2NtZChkZXYsIEFYX0FDQ0VTU19NQUMsIEFYX05PREVfSUQsIEVU
SF9BTEVOLAogCQkJCSBFVEhfQUxFTiwgbmV0LT5kZXZfYWRkcik7CisJaWYgKHJldCA8IDApCisJ
CXJldHVybiByZXQ7CisKKwlyZXR1cm4gMDsKIH0KIAogc3RhdGljIGNvbnN0IHN0cnVjdCBuZXRf
ZGV2aWNlX29wcyBheDg4MTc5X25ldGRldl9vcHMgPSB7Cg==
--001a113fb70842e8860505766710--
