From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] Fix caif BUG() with network namespaces
Date: Tue, 25 Oct 2011 09:25:21 +0200
Message-ID: <1319527522.24797.10.camel@shinybook.infradead.org>
References: <CAJK669a0cX73J0pEr3EtCkbxsaHRfxnS-56Q3Q5ANdKd47mnrg@mail.gmail.com>
	 <1319405079.13738.72.camel@shinybook.infradead.org>
	 <CAJK669ar5ASsX+wEv2EwwaeBoHYtr3Uq+sG1RWroViYGOVgytw@mail.gmail.com>
	 <20111024.182831.489446218871753789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34199 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009Ab1JYHZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 03:25:25 -0400
In-Reply-To: <20111024.182831.489446218871753789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The caif code will register its own pernet_operations, and then registe=
r
a netdevice_notifier. Each time the netdevice_notifier is triggered,
it'll do some stuff... including a lookup of its own pernet stuff with
net_generic().

If the net_generic() call ever returns NULL, the caif code will BUG().
That doesn't seem *so* unreasonable, I suppose =E2=80=94 it does seem l=
ike it
should never happen.

However, it *does* happen. When we clone a network namespace,
setup_net() runs through all the pernet_operations one at a time. It
gets to loopback before it gets to caif. And loopback_net_init()
registers a netdevice... while caif hasn't been initialised. So the cai=
f
netdevice notifier triggers, and immediately goes BUG().

We could imagine a complex and overengineered solution to this generic
class of problems, but this patch takes the simple approach. It just
makes caif_device_notify() *not* go looking for its pernet data
structures if the device it's being notified about isn't a caif device
in the first place.

Cc: stable@kernel.org
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Acked-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

---
On Mon, 2011-10-24 at 18:28 -0400, David Miller wrote:
> David W., the copy that ended up in patchwork was using DOS newlines:
> http://patchwork.ozlabs.org/patch/121250/
> Click on Download "mbox" to see what I mean.
> Can you get your email configuration straightened out before
> resubmitting this patch a third time?

Sorry about that. It's not a configuration thing; just me being stupid
and using the wrong account to send. I *know* Exchange is not an email
server, and that signing emails causes QP encoding. This one should be
fine.

Having said that... in fact, email is *supposed* to have DOS newlines.
The SMTP protocol requires it. When receiving on *nix boxes, we tend to
convert CRLF to LF.

I played a little with applying the emails I sent with 'git am', and it
actually copes fine with the original Quoted-Printable email, as it
should. It *almost* copes with the base64 email, but it forgets to do
the CRLF to LF conversion. I'll look at fixing it (in the spirit of 'be
liberal in what you accept)... but of course we should also be
conservative in what we *send*, so here is (hopefully) an unencoded
version. Apologies again for the inconvenience.

/me double-checks that the signature is turned off, and the sending
account is not the Exchange one... <send>



 net/caif/caif_dev.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 7f9ac07..47fc8f3 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -212,8 +212,7 @@ static int caif_device_notify(struct notifier_block=
 *me, unsigned long what,
 	enum cfcnfg_phy_preference pref;
 	enum cfcnfg_phy_type phy_type;
 	struct cfcnfg *cfg;
-	struct caif_device_entry_list *caifdevs =3D
-	    caif_device_list(dev_net(dev));
+	struct caif_device_entry_list *caifdevs;
=20
 	if (dev->type !=3D ARPHRD_CAIF)
 		return 0;
@@ -222,6 +221,8 @@ static int caif_device_notify(struct notifier_block=
 *me, unsigned long what,
 	if (cfg =3D=3D NULL)
 		return 0;
=20
+	caifdevs =3D caif_device_list(dev_net(dev));
+
 	switch (what) {
 	case NETDEV_REGISTER:
 		caifd =3D caif_device_alloc(dev);
--=20
1.7.6.4



--=20
David Woodhouse                            Open Source Technology Centr=
e
David.Woodhouse@intel.com                              Intel Corporatio=
n
