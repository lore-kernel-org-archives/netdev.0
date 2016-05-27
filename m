From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] wl3501_cs: avoid bogus gcc-6 warning
Date: Fri, 27 May 2016 17:08:33 +0200
Message-ID: <4731273.LDpWBaOjNT@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes.berg@intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@kernel.org>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-6 on x86 started warning about wl3501_get_encode when building
with -O2:

drivers/net/wireless/wl3501_cs.c: In function =E2=80=98wl3501_get_encod=
e=E2=80=99:
drivers/net/wireless/wl3501_cs.c:1769:5: warning: =E2=80=98implemented=E2=
=80=99 may be used uninitialized in this function
drivers/net/wireless/wl3501_cs.c:1686:19: warning: =E2=80=98threshold=E2=
=80=99 may be used uninitialized in this function
drivers/net/wireless/wl3501_cs.c:1702:20: warning: =E2=80=98threshold=E2=
=80=99 may be used uninitialized in this function
drivers/net/wireless/wl3501_cs.c:1719:23: warning: =E2=80=98txpow=E2=80=
=99 may be used uninitialized in this function
drivers/net/wireless/wl3501_cs.c:1752:20: warning: =E2=80=98retry=E2=80=
=99 may be used uninitialized in this function
drivers/net/wireless/wl3501_cs.c:1806:25: warning: =E2=80=98pwr_state=E2=
=80=99 may be used uninitialized in this function
drivers/net/wireless/wl3501_cs.c:1383:24: warning: =E2=80=98value=E2=80=
=99 may be used uninitialized in this function

I could not figure out what exactly confuses gcc here, but splitting th=
e
wl3501_get_mib_value function into two helps the compiler to figure out
that the variables are not actually used uninitialized, and makes it
slightly clearer to a human reader what the function actually does and
which parts of it are under the spinlock.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl=
3501_cs.c
index 13fd734b61ec..82d94f83b6b4 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -378,8 +378,7 @@ static int wl3501_esbq_exec(struct wl3501_card *thi=
s, void *sig, int sig_size)
 	return rc;
 }
=20
-static int wl3501_get_mib_value(struct wl3501_card *this, u8 index,
-				void *bf, int size)
+static int wl3501_request_mib(struct wl3501_card *this, u8 index, void=
 *bf)
 {
 	struct wl3501_get_req sig =3D {
 		.sig_id	    =3D WL3501_SIG_GET_REQ,
@@ -395,20 +394,32 @@ static int wl3501_get_mib_value(struct wl3501_car=
d *this, u8 index,
 			wl3501_set_to_wla(this, ptr, &sig, sizeof(sig));
 			wl3501_esbq_req(this, &ptr);
 			this->sig_get_confirm.mib_status =3D 255;
-			spin_unlock_irqrestore(&this->lock, flags);
-			rc =3D wait_event_interruptible(this->wait,
-				this->sig_get_confirm.mib_status !=3D 255);
-			if (!rc)
-				memcpy(bf, this->sig_get_confirm.mib_value,
-				       size);
-			goto out;
+			rc =3D 0;
 		}
 	}
 	spin_unlock_irqrestore(&this->lock, flags);
-out:
+
 	return rc;
 }
=20
+static int wl3501_get_mib_value(struct wl3501_card *this, u8 index,
+				void *bf, int size)
+{
+	int rc;
+
+	rc =3D wl3501_request_mib(this, index, bf);
+	if (rc)
+		return rc;
+
+	rc =3D wait_event_interruptible(this->wait,
+		this->sig_get_confirm.mib_status !=3D 255);
+	if (rc)
+		return rc;
+
+	memcpy(bf, this->sig_get_confirm.mib_value, size);
+	return 0;
+}
+
 static int wl3501_pwr_mgmt(struct wl3501_card *this, int suspend)
 {
 	struct wl3501_pwr_mgmt_req sig =3D {
