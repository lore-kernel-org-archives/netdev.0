From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 17:54:44 +0200
Message-ID: <1304783684.9216.2.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
	 <1304770926.2821.1157.camel@edumazet-laptop>
	 <0F4A638C2A523577CDBC295E@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57863 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748Ab1EGPyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 11:54:49 -0400
Received: by wya21 with SMTP id 21so3020083wya.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 08:54:48 -0700 (PDT)
In-Reply-To: <0F4A638C2A523577CDBC295E@Ximines.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 16:26 +0100, Alex Bligh a =C3=A9crit :
> Well, I patched it (patch attached for what it's worth) and it made
> no difference in this case. I would suggest however that it might
> be the right think to do anyway.
>=20

As I said, this code should not be entered in normal situations.

You are not the first to suggest a change, but it wont help you at all.




> On the current 8 core box I am testing, I see 280ms per interface
> delete **even with only 10 interfaces**. I see 260ms with one
> interface. I know doing lots of rcu sync stuff can be slow, but
> 260ms to remove one veth pair sounds like more than rcu sync going
> on. It sounds like a sleep (though I may not have found the
> right one). I see no CPU load.
>=20
> Equally, with one interface (remember I'm doing this in unshare -n
> so there is only a loopback interface there), this bit surely
> can't be sysfs.
>=20

synchronize_rcu() calls are not consuming cpu, they just _wait_
rcu grace period.

I suggest you read Documentation/RCU files if you really want to :)

If you want to check how expensive it is, its quite easy:
add a trace in synchronize_net()=20

diff --git a/net/core/dev.c b/net/core/dev.c
index 856b6ee..70f3c46 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5915,8 +5915,10 @@ EXPORT_SYMBOL(free_netdev);
  */
 void synchronize_net(void)
 {
+	pr_err("begin synchronize_net()\n");
 	might_sleep();
 	synchronize_rcu();
+	pr_err("end synchronize_net()\n");
 }
 EXPORT_SYMBOL(synchronize_net);
=20





