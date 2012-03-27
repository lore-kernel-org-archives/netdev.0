From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [STRAW MAN PATCH] sch_teql doesn't load-balance ppp(oatm) slaves
Date: Tue, 27 Mar 2012 20:10:47 +0100
Message-ID: <1332875447.2058.48.camel@shinybook.infradead.org>
References: <1332450218.32446.79.camel@shinybook.infradead.org>
	 <20120322.230331.1623101647193498167.davem@davemloft.net>
	 <1332672230.32446.160.camel@shinybook.infradead.org>
	 <20120325.173635.1909319488008466320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-h4mmETvgJ4SGEMeWsmS5"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56203 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942Ab2C0TKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 15:10:54 -0400
In-Reply-To: <20120325.173635.1909319488008466320.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-h4mmETvgJ4SGEMeWsmS5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-03-25 at 17:36 -0400, David Miller wrote:
> Yes, the ATM devices deep transmit queue is quite undesirable.

This should fix that, and while I'm at it should fix the gratuitous
running of ppp_output_wakeup() from a tasklet on *every* packet, when
it's almost never necessary. Some careful eyes over the locking issues
on that would be much appreciated. I've documented how I *think* it
works...

I'm tempted to rip out the atm_may_send() bit; there's not a lot of
point in checking against sk_sndbuf when we're limiting to two packets
anyway, is there? There's always been a problem here if sk_sndbuf was
set lower than the MTU of the interface; it would block for ever.

I'm running this now on my ADSL router. I can watch it working, keeping
precisely two packets in the queue at a time (one really in-flight and
one ready for the ATM driver). My leftover debugging in sch_teql is
triggering when the xmit returns NETDEV_TX_BUSY, and all seems to be
well.

--- net/atm/pppoatm.c~	2012-03-27 19:59:54.379565896 +0100
+++ net/atm/pppoatm.c	2012-03-27 20:03:02.676561017 +0100
@@ -62,10 +62,13 @@ struct pppoatm_vcc {
 	void (*old_pop)(struct atm_vcc *, struct sk_buff *);
 					/* keep old push/pop for detaching */
 	enum pppoatm_encaps encaps;
+	atomic_t inflight;
+	unsigned long blocked;
 	int flags;			/* SC_COMP_PROT - compress protocol */
 	struct ppp_channel chan;	/* interface to generic ppp layer */
 	struct tasklet_struct wakeup_tasklet;
 };
+#define BLOCKED 0
=20
 /*
  * Header used for LLC Encapsulated PPP (4 bytes) followed by the LCP prot=
ocol
@@ -102,16 +105,31 @@ static void pppoatm_wakeup_sender(unsign
 static void pppoatm_pop(struct atm_vcc *atmvcc, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc =3D atmvcc_to_pvcc(atmvcc);
+
 	pvcc->old_pop(atmvcc, skb);
+	smp_mb__before_atomic_dec();
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
@@ -184,6 +202,54 @@ error:
 	ppp_input_error(&pvcc->chan, 0);
 }
=20
+static inline int pppoatm_may_send(struct pppoatm_vcc *pvcc, int size)
+{
+	/*
+	 * We allow two packets in the queue. The one that's currently
+	 * in flight, and *one* queued up ready for the ATM device to
+	 * send immediately from its TX done IRQ. More than that is
+	 * unnecessary, since the PPP core is designed to feed us packets
+	 * with extremely low latency anyway.
+	 *
+	 * It's not clear that we need to bother with using atm_may_send()
+	 * to check we don't exceed sk->sk_sndbuf. If userspace sets a
+	 * value of sk_sndbuf which is lower than the MTU, we're going to
+	 * block for ever. But the code always did that before we introduced
+	 * the packet count limit, so...=20
+	 */
+	if (atm_may_send(pvcc->atmvcc, size) &&
+	    atomic_inc_not_zero_hint(&pvcc->inflight, -2)) {
+		smp_mb__after_atomic_inc();
+		return 1;
+	}
+
+	smp_mb__before_clear_bit();
+	set_bit(BLOCKED, &pvcc->blocked);
+	smp_mb__after_clear_bit();
+	/*
+	 * We may have raced with pppoatm_pop(). If it ran for the
+	 * last packet in the queue, *just* before we set the BLOCKED
+	 * bit, then it might never run again and the channel could
+	 * remain permanently blocked. Cope with that race by checking
+	 * *again*. If it did run in that window, we'll have space on
+	 * the queue now and can return success. It's harmless to leave
+	 * the BLOCKED flag set, since it's only used as a trigger to
+	 * run the wakeup tasklet.=20
+	 * If pppoatm_pop() is running but hasn't got as far as making
+	 * space on the queue yet, then it hasn't checked the BLOCKED
+	 * flag yet either, so we're safe in that case too. It'll issue
+	 * an "immediate" wakeup... where "immediate" actually involves
+	 * taking the PPP channel's ->downl lock, which is held by the
+	 * code path that calls pppoatm_send(), and is thus going to
+	 * wait for us to finish.
+	 */
+	if (atm_may_send(pvcc->atmvcc, size) &&
+	    atomic_inc_not_zero(&pvcc->inflight)) {
+		smp_mb__after_atomic_inc();
+		return 1;
+	}
+	return 0;
+}
 /*
  * Called by the ppp_generic.c to send a packet - returns true if packet
  * was accepted.  If we return false, then it's our job to call
@@ -207,7 +273,7 @@ static int pppoatm_send(struct ppp_chann
 			struct sk_buff *n;
 			n =3D skb_realloc_headroom(skb, LLC_LEN);
 			if (n !=3D NULL &&
-			    !atm_may_send(pvcc->atmvcc, n->truesize)) {
+			    !pppoatm_may_send(pvcc, n->truesize)) {
 				kfree_skb(n);
 				goto nospace;
 			}
@@ -215,12 +281,12 @@ static int pppoatm_send(struct ppp_chann
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
@@ -285,6 +351,9 @@ static int pppoatm_assign_vcc(struct atm
 	if (pvcc =3D=3D NULL)
 		return -ENOMEM;
 	pvcc->atmvcc =3D atmvcc;
+
+	/* Maximum is zero, so that we can use atomic_inc_not_zero() */
+	atomic_set(&pvcc->inflight, -2);
 	pvcc->old_push =3D atmvcc->push;
 	pvcc->old_pop =3D atmvcc->pop;
 	pvcc->encaps =3D (enum pppoatm_encaps) be.encaps;


--=20
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



--=-h4mmETvgJ4SGEMeWsmS5
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


--=-h4mmETvgJ4SGEMeWsmS5--
