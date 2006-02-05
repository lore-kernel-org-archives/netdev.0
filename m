From: Carlos =?utf-8?q?Mart=C3=ADn?= <carlos@cmartin.tk>
Subject: [PATCH] acx: Transform semaphore to mutex
Date: Sun, 5 Feb 2006 16:56:52 +0100
Message-ID: <200602051656.57214.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2392052.1ZO7SrviUA";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

--nextPart2392052.1ZO7SrviUA
Content-Type: multipart/mixed;
  boundary="Boundary-01=_EBi5DiAyOXKbDoM"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_EBi5DiAyOXKbDoM
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

 The attached patch transform the semaphore to a mutex. That's how we use i=
t,=20
it's faster and makes the binary smaller. It also deletes the semaphore deb=
ug=20
functions because I the kernel takes care of that now. Just yell if I've=20
misunderstood.

   text    data     bss     dec     hex filename
 113475    1520      20  115015   1c147 acx.ko-sem
 111033    1520      20  112573   1b7bd acx.ko

This only works for newer kernels, so I suppose it could be kept as an=20
into-mainline patch. People with newer kernels probably want this patch.

   cmn
=2D-=20
Carlos Mart=C3=ADn       http://www.cmartin.tk

"Erdbeben? Sicherlich etwas, das mit Erdberen zu tun hat." -- me, paraphras=
ed

--Boundary-01=_EBi5DiAyOXKbDoM
Content-Type: text/x-diff;
  charset="utf-8";
  name="acx-sem-to-mutex.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="acx-sem-to-mutex.patch"

diff --git a/acx_func.h b/acx_func.h
index a8e2482..239698b 100644
=2D-- a/acx_func.h
+++ b/acx_func.h
@@ -307,27 +307,18 @@ acx_unlock_helper(acx_device_t *adev, un
 	acx_unlock_debug(adev, where);
 	spin_unlock_irqrestore(&adev->lock, *fp);
 }
=2Dstatic inline void
=2Dacx_down_helper(acx_device_t *adev, const char* where)
=2D{
=2D	acx_down_debug(adev, where);
=2D}
=2Dstatic inline void
=2Dacx_up_helper(acx_device_t *adev, const char* where)
=2D{
=2D	acx_up_debug(adev, where);
=2D}
+
 #define acx_lock(adev, flags)	acx_lock_helper(adev, &(flags), __FILE__ ":"=
 STRING(__LINE__))
 #define acx_unlock(adev, flags)	acx_unlock_helper(adev, &(flags), __FILE__=
 ":" STRING(__LINE__))
=2D#define acx_sem_lock(adev)	acx_down_helper(adev, __FILE__ ":" STRING(__L=
INE__))
=2D#define acx_sem_unlock(adev)	acx_up_helper(adev, __FILE__ ":" STRING(__L=
INE__))
+#define acx_sem_lock(adev)	mutex_lock(&(adev)->mutex)
+#define acx_sem_unlock(adev)    mutex_unlock(&(adev)->mutex)
=20
 #elif defined(DO_LOCKING)
=20
 #define acx_lock(adev, flags)	spin_lock_irqsave(&adev->lock, flags)
 #define acx_unlock(adev, flags)	spin_unlock_irqrestore(&adev->lock, flags)
=2D#define acx_sem_lock(adev)	down(&adev->sem)
=2D#define acx_sem_unlock(adev)	up(&adev->sem)
+#define acx_sem_lock(adev)	mutex_lock(&(adev)->mutex)
+#define acx_sem_unlock(adev)	mutex_unlock(&(adev)->mutex)
 #define acx_lock_unhold()	((void)0)
 #define acx_sem_unhold()	((void)0)
=20
diff --git a/acx_struct.h b/acx_struct.h
index 0bd18c4..65d6cf5 100644
=2D-- a/acx_struct.h
+++ b/acx_struct.h
@@ -1142,7 +1142,7 @@ struct acx_device {
 	/* FIXME: try to convert semaphore to more efficient mutex according
 	   to Ingo Molnar's docs (but not before driver is in mainline or
 		 pre-mutex Linux 2.6.10 is very outdated). */
=2D	struct semaphore	sem;
+	struct mutex	mutex;
 	spinlock_t		lock;
 #if defined(PARANOID_LOCKING) /* Lock debugging */
 	const char		*last_sem;
diff --git a/common.c b/common.c
index 70e8afc..c019cef 100644
=2D-- a/common.c
+++ b/common.c
@@ -189,59 +189,7 @@ acx_unlock_debug(acx_device_t *adev, con
 		}
 	}
 }
=2Dvoid
=2Dacx_down_debug(acx_device_t *adev, const char* where)
=2D{
=2D	int sem_count;
=2D	unsigned long timeout =3D jiffies + 5*HZ;
=2D
=2D	where =3D sanitize_str(where);
=20
=2D	for (;;) {
=2D		sem_count =3D atomic_read(&adev->sem.count);
=2D		if (sem_count) break;
=2D		if (time_after(jiffies, timeout))
=2D			break;
=2D		msleep(5);
=2D	}
=2D	if (!sem_count) {
=2D		printk(KERN_EMERG "D STATE at %s! last sem at %s\n",
=2D			where, adev->last_sem);
=2D		dump_stack();
=2D	}
=2D	adev->last_sem =3D where;
=2D	adev->sem_time =3D jiffies;
=2D	down(&adev->sem);
=2D	if (acx_debug & L_LOCK) {
=2D		printk("%s: sem_down %d -> %d\n",
=2D			where, sem_count, atomic_read(&adev->sem.count));
=2D	}
=2D}
=2Dvoid
=2Dacx_up_debug(acx_device_t *adev, const char* where)
=2D{
=2D	int sem_count =3D atomic_read(&adev->sem.count);
=2D	if (sem_count) {
=2D		where =3D sanitize_str(where);
=2D		printk(KERN_EMERG "STRAY UP at %s! sem.count=3D%d\n", where, sem_count=
);
=2D		dump_stack();
=2D	}
=2D	if (acx_debug & L_LOCK) {
=2D		unsigned long diff =3D jiffies - adev->sem_time;
=2D		if (diff > max_sem_time) {
=2D			where =3D sanitize_str(where);
=2D			printk("max sem hold time %ld jiffies from %s "
=2D				"to %s\n", diff, adev->last_sem, where);
=2D			max_sem_time =3D diff;
=2D		}
=2D	}
=2D	up(&adev->sem);
=2D	if (acx_debug & L_LOCK) {
=2D		where =3D sanitize_str(where);
=2D		printk("%s: sem_up %d -> %d\n",
=2D			where, sem_count, atomic_read(&adev->sem.count));
=2D	}
=2D}
 #endif /* PARANOID_LOCKING */
=20
=20
diff --git a/pci.c b/pci.c
index 910155f..a390606 100644
=2D-- a/pci.c
+++ b/pci.c
@@ -1617,7 +1617,7 @@ acxpci_e_probe(struct pci_dev *pdev, con
 	adev =3D ndev2adev(ndev);
 	spin_lock_init(&adev->lock);	/* initial state: unlocked */
 	/* We do not start with downed sem: we want PARANOID_LOCKING to work */
=2D	sema_init(&adev->sem, 1);	/* initial state: 1 (upped) */
+	mutex_init(&adev->mutex);	/* initial state: 1 (upped) */
 	/* since nobody can see new netdev yet, we can as well
 	** just _presume_ that we're under sem (instead of actually taking it): */
 	/* acx_sem_lock(adev); */
diff --git a/usb.c b/usb.c
index 3183743..cd610e4 100644
=2D-- a/usb.c
+++ b/usb.c
@@ -869,7 +869,7 @@ acxusb_e_probe(struct usb_interface *int
=20
 	adev->usbdev =3D usbdev;
 	spin_lock_init(&adev->lock);    /* initial state: unlocked */
=2D	sema_init(&adev->sem, 1);       /* initial state: 1 (upped) */
+	mutex_init(&adev->mutex);       /* initial state: 1 (upped) */
=20
 	/* Check that this is really the hardware we know about.
 	** If not sure, at least notify the user that he

--Boundary-01=_EBi5DiAyOXKbDoM--

--nextPart2392052.1ZO7SrviUA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBD5iBJEVXxXOiy6a4RAkEhAJ930fzUfm/ECM+Aa5v69tyuxc6VbgCfTva/
Em85LM7co/XbZJO4m6kgtBw=
=srXn
-----END PGP SIGNATURE-----

--nextPart2392052.1ZO7SrviUA--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
