From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: oops during unregister_netdevice interface enslaved to
 bond - regression
Date: Tue, 10 May 2011 15:36:59 +0200
Message-ID: <1305034619.2614.37.camel@edumazet-laptop>
References: <OF0F4919C3.B9CFCAE8-ONC125788C.002D5EB1-C125788C.002D83B7@de.ibm.com>
	 <1305017672.2614.9.camel@edumazet-laptop>
	 <20110510131438.GA41522@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ELELUECK@de.ibm.com,
	Octavian Purdila <opurdila@ixiacom.com>
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49605 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006Ab1EJNhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 09:37:06 -0400
Received: by fxm17 with SMTP id 17so4306606fxm.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 06:37:05 -0700 (PDT)
In-Reply-To: <20110510131438.GA41522@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 mai 2011 =C3=A0 15:14 +0200, Frank Blaschka a =C3=A9crit :

> I just checked todays net-next tree, problem is still there.
> I don't have an x86 box, but I was able to reproduce the problem
> with the dummy device (on s/390)
>=20
> # modprobe bonding
> # modprobe dummy
> # ifconfig bond0 up
> # ifenslave bond0 dummy0
> # rmmod dummy

Here is the patch to fix this problem

Thanks again for your help.

[PATCH net-2.6] net: dev_close() should check IFF_UP

Commit 443457242beb (factorize sync-rcu call in
unregister_netdevice_many) mistakenly removed one test from dev_close()

=46ollowing actions trigger a BUG :

modprobe bonding
modprobe dummy
ifconfig bond0 up
ifenslave bond0 dummy0
rmmod dummy

dev_close() must not close a non IFF_UP device.

With help from Frank Blaschka and Einar EL Lueck

Reported-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Reported-by: Einar EL Lueck <ELELUECK@de.ibm.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Octavian Purdila <opurdila@ixiacom.com>
---
 net/core/dev.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 856b6ee..9200944 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1284,11 +1284,13 @@ static int dev_close_many(struct list_head *hea=
d)
  */
 int dev_close(struct net_device *dev)
 {
-	LIST_HEAD(single);
+	if (dev->flags & IFF_UP) {
+		LIST_HEAD(single);
=20
-	list_add(&dev->unreg_list, &single);
-	dev_close_many(&single);
-	list_del(&single);
+		list_add(&dev->unreg_list, &single);
+		dev_close_many(&single);
+		list_del(&single);
+	}
 	return 0;
 }
 EXPORT_SYMBOL(dev_close);


