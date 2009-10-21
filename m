From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Wed, 21 Oct 2009 17:40:07 +0200
Message-ID: <4ADF2B57.4030708@gmail.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36298 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbZJUPkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 11:40:09 -0400
In-Reply-To: <200910211539.01824.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Sunday 18 October 2009 21:21:44 you wrote:
>>> The msleep(250) should be tuned first. Then if this is really neces=
sary
>>> to dismantle 100.000 netdevices per second, we might have to think =
a bit
>>> more.=20
>>> Just try msleep(1 or 2), it should work quite well.
>> My goal is tearing down 100,000 interfaces in a few seconds, which r=
eally
>>  is  necessary.  Right now we're running about 40,000 interfaces on =
a not
>>  yet saturated 10Gbps link.  Going to dual 10Gbps links means pushin=
g more
>>  than 100,000 subscriber interfaces, and it looks like a modern dual=
 socket
>>  system can handle that.
>>
>=20
> I would also like to see this patch in, we are running into scalabili=
ty issues=20
> with creating/deleting lots of interfaces as well.

Ben patch only address interface deletion, and one part of the problem,
maybe the more visible one for the current kernel.

Adding lots of interfaces only needs several threads to run concurently=
=2E

Before applying/examining his patch I suggest identifying all dev_put()=
 spots than
can be deleted and replaced by something more scalable. I began this jo=
b
but others can help me.

RTNL and rcu grace periods are going to hurt anyway, so you probably ne=
ed
to use many tasks to be able to delete lots of interfaces in parallel.

netdev_run_todo() should also use a better algorithm to allow paralleli=
sm.

=46ollowing patch doesnt slow down dev_put() users and real scalability
problems will surface and might be addressed.

[PATCH] net: allow netdev_wait_allrefs() to run faster

netdev_wait_allrefs() waits that all references to a device vanishes.

It currently uses a _very_ pessimistic 250 ms delay between each probe.
Some users report that no more than 4 devices can be dismantled per sec=
ond,
this is a pretty serious problem for extreme setups.

Most likely, references only wait for a rcu grace period that should co=
me
fast, so use a schedule_timeout_uninterruptible(1) to allow faster reco=
very.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 28b0b9e..fca2e4a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4983,7 +4983,7 @@ static void netdev_wait_allrefs(struct net_device=
 *dev)
 			rebroadcast_time =3D jiffies;
 		}
=20
-		msleep(250);
+		schedule_timeout_uninterruptible(1);
=20
 		if (time_after(jiffies, warning_time + 10 * HZ)) {
 			printk(KERN_EMERG "unregister_netdevice: "
