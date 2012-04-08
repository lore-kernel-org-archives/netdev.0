From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] pppoatm: Fix excessive queue bloat
Date: Sun, 08 Apr 2012 21:53:57 +0200
Message-ID: <1333914837.31812.57.camel@shinybook.infradead.org>
References: <1332450218.32446.79.camel@shinybook.infradead.org>
	 <20120322.230331.1623101647193498167.davem@davemloft.net>
	 <1332672230.32446.160.camel@shinybook.infradead.org>
	 <20120325.173635.1909319488008466320.davem@davemloft.net>
	 <1332875447.2058.48.camel@shinybook.infradead.org>
	 <1332878138.3547.41.camel@edumazet-glaptop>
	 <1332880522.2058.67.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-n8a0lYU37xRG5HplkUCW"
Cc: David Miller <davem@davemloft.net>, paulus@samba.org,
	chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:57136 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742Ab2DHTyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2012 15:54:06 -0400
In-Reply-To: <1332880522.2058.67.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-n8a0lYU37xRG5HplkUCW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

We discovered that PPPoATM has an excessively deep transmit queue. A
queue the size of the default socket send buffer (wmem_default) is
maintained between the PPP generic core and the ATM device.

Fix it to queue a maximum of *two* packets. The one the ATM device is
currently working on, and one more for the ATM driver to process
immediately in its TX done interrupt handler. The PPP core is designed
to feed packets to the channel with minimal latency, so that really
ought to be enough to keep the ATM device busy.

While we're at it, fix the fact that we were triggering the wakeup
tasklet on *every* pppoatm_pop() call. The comment saying "this is
inefficient, but doing it right is too hard" turns out to be overly
pessimistic... I think :)

On machines like the Traverse Geos, with a slow Geode CPU and two
high-speed ADSL2+ interfaces, there were reports of extremely high CPU
usage which could partly be attributed to the extra wakeups.

(The wakeup handling could actually be made a whole lot easier if we
 stop checking sk->sk_sndbuf altogether. Given that we now only queue
 *two* packets ever, one wonders what the point is. As it is, you could
 already deadlock the thing by setting the sk_sndbuf to a value lower
 than the MTU of the device, and it'd just block for ever.)

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

---

Seriously, this gets *much* easier if we just ditch the checks against
sk_sndbuf. We just wake up whenever decrementing ->inflight from zero.
Can I?

 net/atm/pppoatm.c |   95 +++++++++++++++++++++++++++++++++++++++++++++++--=
---
 1 files changed, 85 insertions(+), 10 deletions(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 614d3fc..68a02a9 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -62,12 +62,25 @@ struct pppoatm_vcc {
 	void (*old_pop)(struct atm_vcc *, struct sk_buff *);
 					/* keep old push/pop for detaching */
 	enum pppoatm_encaps encaps;
+	atomic_t inflight;
+	unsigned long blocked;
 	int flags;			/* SC_COMP_PROT - compress protocol */
 	struct ppp_channel chan;	/* interface to generic ppp layer */
 	struct tasklet_struct wakeup_tasklet;
 };
=20
 /*
+ * We want to allow two packets in the queue. The one that's currently in
+ * flight, and *one* queued up ready for the ATM device to send immediatel=
y
+ * from its TX done IRQ. We want to be able to use atomic_inc_not_zero(), =
so
+ * inflight =3D=3D -2 represents an empty queue, -1 one packet, and zero m=
eans
+ * there are two packets in the queue.
+ */
+#define NONE_INFLIGHT -2
+
+#define BLOCKED 0
+
+/*
  * Header used for LLC Encapsulated PPP (4 bytes) followed by the LCP prot=
ocol
  * ID (0xC021) used in autodetection
  */
@@ -102,16 +115,30 @@ static void pppoatm_wakeup_sender(unsigned long arg)
 static void pppoatm_pop(struct atm_vcc *atmvcc, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc =3D atmvcc_to_pvcc(atmvcc);
+
 	pvcc->old_pop(atmvcc, skb);
+	atomic_dec(&pvcc->inflight);
+
 	/*
-	 * We don't really always want to do this since it's
-	 * really inefficient - it would be much better if we could
-	 * test if we had actually throttled the generic layer.
-	 * Unfortunately then there would be a nasty SMP race where
-	 * we could clear that flag just as we refuse another packet.
-	 * For now we do the safe thing.
+	 * We always used to run the wakeup tasklet unconditionally here, for
+	 * fear of race conditions where we clear the BLOCKED flag just as we
+	 * refuse another packet in pppoatm_send(). This was quite inefficient.
+	 *
+	 * In fact it's OK. The PPP core will only ever call pppoatm_send()
+	 * while holding the channel->downl lock. And ppp_output_wakeup() as
+	 * called by the tasklet will *also* grab that lock. So even if another
+	 * CPU is in pppoatm_send() right now, the tasklet isn't going to race
+	 * with it. The wakeup *will* happen after the other CPU is safely out
+	 * of pppoatm_send() again.
+	 *
+	 * So if the CPU in pppoatm_send() has already set the BLOCKED bit and
+	 * it about to return, that's fine. We trigger a wakeup which will
+	 * happen later. And if the CPU in pppoatm_send() *hasn't* set the
+	 * BLOCKED bit yet, that's fine too because of the double check in
+	 * pppoatm_may_send() which is commented there.
 	 */
-	tasklet_schedule(&pvcc->wakeup_tasklet);
+	if (test_and_clear_bit(BLOCKED, &pvcc->blocked))
+		tasklet_schedule(&pvcc->wakeup_tasklet);
 }
=20
 /*
@@ -184,6 +211,51 @@ error:
 	ppp_input_error(&pvcc->chan, 0);
 }
=20
+static inline int pppoatm_may_send(struct pppoatm_vcc *pvcc, int size)
+{
+	/*
+	 * It's not clear that we need to bother with using atm_may_send()
+	 * to check we don't exceed sk->sk_sndbuf. If userspace sets a
+	 * value of sk_sndbuf which is lower than the MTU, we're going to
+	 * block for ever. But the code always did that before we introduced
+	 * the packet count limit, so...=20
+	 */
+	if (atm_may_send(pvcc->atmvcc, size) &&
+	    atomic_inc_not_zero_hint(&pvcc->inflight, NONE_INFLIGHT))
+		return 1;
+
+	/*
+	 * We use test_and_set_bit() rather than set_bit() here because
+	 * we need to ensure there's a memory barrier after it. The bit
+	 * *must* be set before we do the atomic_inc() on pvcc->inflight.
+	 * There's no smp_mb__after_set_bit(), so it's this or abuse
+	 * smp_mb__after_clear_bit().
+	 */
+	test_and_set_bit(BLOCKED, &pvcc->blocked);
+
+	/*
+	 * We may have raced with pppoatm_pop(). If it ran for the
+	 * last packet in the queue, *just* before we set the BLOCKED
+	 * bit, then it might never run again and the channel could
+	 * remain permanently blocked. Cope with that race by checking
+	 * *again*. If it did run in that window, we'll have space on
+	 * the queue now and can return success. It's harmless to leave
+	 * the BLOCKED flag set, since it's only used as a trigger to
+	 * run the wakeup tasklet. Another wakeup will never hurt.=20
+	 * If pppoatm_pop() is running but hasn't got as far as making
+	 * space on the queue yet, then it hasn't checked the BLOCKED
+	 * flag yet either, so we're safe in that case too. It'll issue
+	 * an "immediate" wakeup... where "immediate" actually involves
+	 * taking the PPP channel's ->downl lock, which is held by the
+	 * code path that calls pppoatm_send(), and is thus going to
+	 * wait for us to finish.
+	 */
+	if (atm_may_send(pvcc->atmvcc, size) &&
+	    atomic_inc_not_zero(&pvcc->inflight))
+		return 1;
+
+	return 0;
+}
 /*
  * Called by the ppp_generic.c to send a packet - returns true if packet
  * was accepted.  If we return false, then it's our job to call
@@ -207,7 +279,7 @@ static int pppoatm_send(struct ppp_channel *chan, struc=
t sk_buff *skb)
 			struct sk_buff *n;
 			n =3D skb_realloc_headroom(skb, LLC_LEN);
 			if (n !=3D NULL &&
-			    !atm_may_send(pvcc->atmvcc, n->truesize)) {
+			    !pppoatm_may_send(pvcc, n->truesize)) {
 				kfree_skb(n);
 				goto nospace;
 			}
@@ -215,12 +287,12 @@ static int pppoatm_send(struct ppp_channel *chan, str=
uct sk_buff *skb)
 			skb =3D n;
 			if (skb =3D=3D NULL)
 				return DROP_PACKET;
-		} else if (!atm_may_send(pvcc->atmvcc, skb->truesize))
+		} else if (!pppoatm_may_send(pvcc, skb->truesize))
 			goto nospace;
 		memcpy(skb_push(skb, LLC_LEN), pppllc, LLC_LEN);
 		break;
 	case e_vc:
-		if (!atm_may_send(pvcc->atmvcc, skb->truesize))
+		if (!pppoatm_may_send(pvcc, skb->truesize))
 			goto nospace;
 		break;
 	case e_autodetect:
@@ -285,6 +357,9 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, v=
oid __user *arg)
 	if (pvcc =3D=3D NULL)
 		return -ENOMEM;
 	pvcc->atmvcc =3D atmvcc;
+
+	/* Maximum is zero, so that we can use atomic_inc_not_zero() */
+	atomic_set(&pvcc->inflight, NONE_INFLIGHT);
 	pvcc->old_push =3D atmvcc->push;
 	pvcc->old_pop =3D atmvcc->pop;
 	pvcc->encaps =3D (enum pppoatm_encaps) be.encaps;
--=20
1.7.7.6



--=20
dwmw2

--=-n8a0lYU37xRG5HplkUCW
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIITvzCCBi0w
ggQVoAMCAQICAwCtOTANBgkqhkiG9w0BAQUFADBUMRQwEgYDVQQKEwtDQWNlcnQgSW5jLjEeMBwG
A1UECxMVaHR0cDovL3d3dy5DQWNlcnQub3JnMRwwGgYDVQQDExNDQWNlcnQgQ2xhc3MgMyBSb290
MB4XDTEwMDYxMjEwMDMwMFoXDTEyMDYxMTEwMDMwMFowgegxGDAWBgNVBAMTD0RhdmlkIFdvb2Ro
b3VzZTEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFkLm9yZzEfMB0GCSqGSIb3DQEJARYQ
ZGF2aWRAd29vZGhvdS5zZTEoMCYGCSqGSIb3DQEJARYZZGF2aWQud29vZGhvdXNlQGludGVsLmNv
bTEkMCIGCSqGSIb3DQEJARYVZHdtdzJAbGludXguaW50ZWwuY29tMTcwNQYJKoZIhvcNAQkBFigx
MDg3MmEwN2Y2ZDdlMWUwN2Y1NWZmMTcyYTAzYjMwMGVlYWFkMjAzMIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA29OPhNvMxBMW83psWdVhZDtmJvgN+tBEp1r6MZamONsR0k81a6fDFwJz
M0fEzEbV/bDG102QyX/xXC/0IpKV4acnqESC+sTHUmRwxfRKGNmR6t2iwEs2Y5kQDF31JxbCt49w
AlhLMAa+e1MBZ7vO0uDmRuJpS7+ZdHboq7cdk6dyoeumGv5sl6U/SPK9rL4KzULtqQaw6Wucd6MJ
irIggEHfCNqeT5a+TyuH4zKCwv9nblIGXq9wt+yqu5t/RicGaKPnXSqo/WpJAGggaO8g92mnYlVl
Wu/b9bYVISwQ8LI0sEtjN1WnP5AQO2f59bdPAVk4Rn25HceOO4NvlG47LwIDAQABo4IBcTCCAW0w
DAYDVR0TAQH/BAIwADBWBglghkgBhvhCAQ0ESRZHVG8gZ2V0IHlvdXIgb3duIGNlcnRpZmljYXRl
IGZvciBGUkVFIGhlYWQgb3ZlciB0byBodHRwOi8vd3d3LkNBY2VydC5vcmcwQAYDVR0lBDkwNwYI
KwYBBQUHAwQGCCsGAQUFBwMCBgorBgEEAYI3CgMEBgorBgEEAYI3CgMDBglghkgBhvhCBAEwMgYI
KwYBBQUHAQEEJjAkMCIGCCsGAQUFBzABhhZodHRwOi8vb2NzcC5jYWNlcnQub3JnMIGOBgNVHREE
gYYwgYOBE2R3bXcyQGluZnJhZGVhZC5vcmeBEGRhdmlkQHdvb2Rob3Uuc2WBGWRhdmlkLndvb2Ro
b3VzZUBpbnRlbC5jb22BFWR3bXcyQGxpbnV4LmludGVsLmNvbYEoMTA4NzJhMDdmNmQ3ZTFlMDdm
NTVmZjE3MmEwM2IzMDBlZWFhZDIwMzANBgkqhkiG9w0BAQUFAAOCAgEAXm+SUO1/TSeGJK0D9pAm
E9LTFkdlgbaD6HXGbS0TNUDyfLFkacc2F1JLoWcoFwcL6Rup5o/Rt4QYDBPWgF9EXFvqsc9SLrSe
X6VwRj7vI40x19ThE2A1Y8DzBJ9+2MzIR6hd5n9axATCOIRhmZVjX1cRkwshEGvAn8mTYGhWttkx
WhBcaAuCd9OOQqUwfxTUXiSfVumPUNrrbuvaH6MjrNjDrXdvicL26Y+AzFSJn3o8DShjjMhkUx9l
qV46BpjSGIuvkHhcLkGJ3Y1YmtOX1hwT+Z+d/10WJh8ZG2FqIlJtPtqvHK5ol/KvdzMwmMBd4qFj
YAO32vf7zde+jdTHNp2Mb15bJHhNdGOsZicpGue42fg3deZQFe1E2KBl9VO09fjncjt9YdhCUtxO
buDnoOixY6YSJgSmGJB2Xs+TE5gps4UiiOYen+NeJkuwg5x9vmyraU061Uc0csfc/E5IoxhTX/Pc
H+zXiER8aSjA/9MXQfrJM2xkY6UNKlDbCYSLKnH/O02eu7Hma6lB4wtcY8ECu7LJuFY2448Quolv
SQfQLRvKauGFGUAhbPClOxObuv/fNzA+lfg8DX2y5jXDutnpvBGgsplKxoah01SZfR9zNqxodPx2
srKhujBNB+WiAZntMf0xp4e0JPMlTFxm3tbY9wuBSyTJyueO9hUkbN4wggYtMIIEFaADAgECAgMA
rTkwDQYJKoZIhvcNAQEFBQAwVDEUMBIGA1UEChMLQ0FjZXJ0IEluYy4xHjAcBgNVBAsTFWh0dHA6
Ly93d3cuQ0FjZXJ0Lm9yZzEcMBoGA1UEAxMTQ0FjZXJ0IENsYXNzIDMgUm9vdDAeFw0xMDA2MTIx
MDAzMDBaFw0xMjA2MTExMDAzMDBaMIHoMRgwFgYDVQQDEw9EYXZpZCBXb29kaG91c2UxIjAgBgkq
hkiG9w0BCQEWE2R3bXcyQGluZnJhZGVhZC5vcmcxHzAdBgkqhkiG9w0BCQEWEGRhdmlkQHdvb2Ro
b3Uuc2UxKDAmBgkqhkiG9w0BCQEWGWRhdmlkLndvb2Rob3VzZUBpbnRlbC5jb20xJDAiBgkqhkiG
9w0BCQEWFWR3bXcyQGxpbnV4LmludGVsLmNvbTE3MDUGCSqGSIb3DQEJARYoMTA4NzJhMDdmNmQ3
ZTFlMDdmNTVmZjE3MmEwM2IzMDBlZWFhZDIwMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
ggEBANvTj4TbzMQTFvN6bFnVYWQ7Zib4DfrQRKda+jGWpjjbEdJPNWunwxcCczNHxMxG1f2wxtdN
kMl/8Vwv9CKSleGnJ6hEgvrEx1JkcMX0ShjZkerdosBLNmOZEAxd9ScWwrePcAJYSzAGvntTAWe7
ztLg5kbiaUu/mXR26Ku3HZOncqHrphr+bJelP0jyvay+Cs1C7akGsOlrnHejCYqyIIBB3wjank+W
vk8rh+MygsL/Z25SBl6vcLfsqrubf0YnBmij510qqP1qSQBoIGjvIPdpp2JVZVrv2/W2FSEsEPCy
NLBLYzdVpz+QEDtn+fW3TwFZOEZ9uR3HjjuDb5RuOy8CAwEAAaOCAXEwggFtMAwGA1UdEwEB/wQC
MAAwVgYJYIZIAYb4QgENBEkWR1RvIGdldCB5b3VyIG93biBjZXJ0aWZpY2F0ZSBmb3IgRlJFRSBo
ZWFkIG92ZXIgdG8gaHR0cDovL3d3dy5DQWNlcnQub3JnMEAGA1UdJQQ5MDcGCCsGAQUFBwMEBggr
BgEFBQcDAgYKKwYBBAGCNwoDBAYKKwYBBAGCNwoDAwYJYIZIAYb4QgQBMDIGCCsGAQUFBwEBBCYw
JDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuY2FjZXJ0Lm9yZzCBjgYDVR0RBIGGMIGDgRNkd213
MkBpbmZyYWRlYWQub3JngRBkYXZpZEB3b29kaG91LnNlgRlkYXZpZC53b29kaG91c2VAaW50ZWwu
Y29tgRVkd213MkBsaW51eC5pbnRlbC5jb22BKDEwODcyYTA3ZjZkN2UxZTA3ZjU1ZmYxNzJhMDNi
MzAwZWVhYWQyMDMwDQYJKoZIhvcNAQEFBQADggIBAF5vklDtf00nhiStA/aQJhPS0xZHZYG2g+h1
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
AAAAAA==


--=-n8a0lYU37xRG5HplkUCW--
