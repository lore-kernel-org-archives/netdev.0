From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vhost_dev_cleanup() crash: BUG: unable to handle kernel NULL
 pointer dereference
Date: Tue, 31 Aug 2010 14:05:57 +0200
Message-ID: <1283256357.2550.61.camel@edumazet-laptop>
References: <20100831075705.GA4710@elte.hu>
	 <1283251801.2550.53.camel@edumazet-laptop> <20100831111413.GB12853@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100831111413.GB12853@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 31 ao=C3=BBt 2010 =C3=A0 13:14 +0200, Ingo Molnar a =C3=A9crit=
 :
> * Eric Dumazet <eric.dumazet@gmail.com> wrote:

> >=20
> > Seems to be commit c23f3445e68e1
> > (vhost: replace vhost_workqueue with per-vhost kthread)
> >=20
> > following patch should cure it ?
> >=20
> > Thanks
> >=20
> > [PATCH] vhost: stop worker only if created
> >=20
> > Its illegal to call kthread_stop(NULL)
> >=20
> > Reported-by: Ingo Molnar <mingo@elte.hu>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > index e05557d..0a00121 100644
> > --- a/drivers/vhost/vhost.c
> > +++ b/drivers/vhost/vhost.c
> > @@ -323,7 +323,8 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
> >  	dev->mm =3D NULL;
> > =20
> >  	WARN_ON(!list_empty(&dev->work_list));
> > -	kthread_stop(dev->worker);
> > +	if (dev->worker)
> > +		kthread_stop(dev->worker);
>=20
> Btw., i think this check should be pushed into kthread_stop() instead=
 -=20
> just like kfree(NULL) is possible as well - it simplifies cleanup=20
> sequences.
>=20

Sure !

Just in case, I resubmit the patch, clearing dev->worker, because I am
not sure if vhost_dev_cleanup() can be run several times on same struct
vhost_dev. Patch is needed even if you add this check in kthread_stop()

[PATCH v2] vhost: stop worker only if created

Its currently illegal to call kthread_stop(NULL)

Reported-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/vhost/vhost.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index e05557d..4b99117 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -323,7 +323,10 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 	dev->mm =3D NULL;
=20
 	WARN_ON(!list_empty(&dev->work_list));
-	kthread_stop(dev->worker);
+	if (dev->worker) {
+		kthread_stop(dev->worker);
+		dev->worker =3D NULL;
+	}
 }
=20
 static int log_access_ok(void __user *log_base, u64 addr, unsigned lon=
g sz)
