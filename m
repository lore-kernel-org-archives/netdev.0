From: Richard Hartmann <richih.mailinglist@gmail.com>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP
	multi-link
Date: Wed, 31 Mar 2010 11:01:07 +0200
Message-ID: <l2o2d460de71003310201vcfabeaa2i6d4e32ed3995aad2@mail.gmail.com>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=00c09ffb51079accec048314fcd8
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--00c09ffb51079accec048314fcd8
Content-Type: text/plain; charset=UTF-8

Hi all,

this is our attempt at a cleaner version. It is still far from being
perfect and packets seem to gain one to two bytes in size sometimes
which means that you will run into "normal" fragmentation if you set
your MTU to the possible maximum (as you are then over said max) but it
does what it should, can be changed at run-time and is not panicking the
kernel.

Feedback appreciated, code even more so.


Thanks,
Richard

PS: The main patch is inline, both the main and the debug patch are
attached.


--- drivers/net/ppp_generic.c.orig      2010-03-25 16:56:05.000000000 +0100
+++ drivers/net/ppp_generic.c   2010-03-30 19:56:15.000000000 +0200
@@ -129,6 +129,7 @@
        u32             nextseq;        /* MP: seq no of next packet */
        u32             minseq;         /* MP: min of most recent seqnos */
        struct sk_buff_head mrq;        /* MP: receive reconstruction queue */
+       int     rrsched;    /* round robin scheduler for packet distribution */
 #endif /* CONFIG_PPP_MULTILINK */
 #ifdef CONFIG_PPP_FILTER
        struct sock_filter *pass_filter;        /* filter for packets to pass */
@@ -227,6 +228,17 @@
 #define B      0x80            /* this fragment begins a packet */
 #define E      0x40            /* this fragment ends a packet */

+#ifdef CONFIG_PPP_MULTILINK
+/* alternate fragmentation algorithm and multilink behaviour options
added by uli.staerk@globalways.net */
+static int ppp_ml_noexplode = 0;
+module_param(ppp_ml_noexplode, int, 0600);
+MODULE_PARM_DESC(ppp_ml_noexplode, "Set this to any other values than
zero to avoid fragmentation over connected channels");
+
+static int ppp_ml_noheader = 0;
+module_param(ppp_ml_noheader, int, 0600);
+MODULE_PARM_DESC(ppp_ml_noheader, "Set this to any other value than
zero to remove the ppp-multilink protocol header (pppoes.protocol not
0x003d) which enables fragmentation and reordering");
+#endif /* CONFIG_PPP_MULTILINK */
+
 /* Compare multilink sequence numbers (assumed to be 32 bits wide) */
 #define seq_before(a, b)	((s32)((a) - (b)) < 0)
 #define seq_after(a, b)		((s32)((a) - (b)) > 0)
@@ -250,6 +262,7 @@
 static void ppp_mp_insert(struct ppp *ppp, struct sk_buff *skb);
 static struct sk_buff *ppp_mp_reconstruct(struct ppp *ppp);
 static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb);
+static void ppp_mp_roundrobin(struct ppp *ppp, struct sk_buff *skb);
 #endif /* CONFIG_PPP_MULTILINK */
 static int ppp_set_compress(struct ppp *ppp, unsigned long arg);
 static void ppp_ccp_peek(struct ppp *ppp, struct sk_buff *skb, int inbound);
@@ -1292,10 +1305,18 @@
 	}

 #ifdef CONFIG_PPP_MULTILINK
-	/* Multilink: fragment the packet over as many links
-	   as can take the packet at the moment. */
-	if (!ppp_mp_explode(ppp, skb))
+	/* send packet without multilink header */
+	if(ppp_ml_noheader) {
+		ppp_mp_roundrobin(ppp, skb);
 		return;
+	}
+	else {
+		/* Multilink: fragment the packet over as many links
+		   as can take the packet at the moment. */
+		if (!ppp_mp_explode(ppp, skb)) {
+			return;
+		}
+	}
 #endif /* CONFIG_PPP_MULTILINK */

 	ppp->xmit_pending = NULL;
@@ -1304,6 +1325,38 @@

 #ifdef CONFIG_PPP_MULTILINK
 /*
+ * Send packet through the next channel (round robin)
+ */
+static void ppp_mp_roundrobin(struct ppp *ppp, struct sk_buff *skb)
+{
+	int i;
+	struct channel *pch;
+
+	ppp->rrsched++;
+	i = 0;
+	list_for_each_entry(pch, &ppp->channels, clist)      {
+		if(pch->chan == NULL) continue;
+
+		if (ppp->rrsched % ppp->n_channels == i) {
+			spin_lock_bh(&pch->downl);
+			if (pch->chan) {
+				if (pch->chan->ops->start_xmit(pch->chan, skb)) {
+					ppp->xmit_pending = NULL;
+				}
+			} else {
+				/* channel got unregistered */
+				kfree_skb(skb);
+				ppp->xmit_pending = NULL;
+			}
+			spin_unlock_bh(&pch->downl);
+			return;
+		}
+		i++;
+	}
+	return;
+}
+
+/*
  * Divide a packet to be transmitted into fragments and
  * send them out the individual links.
  */
@@ -1352,13 +1405,21 @@
 		}
 		++i;
 	}
-	/*
-	 * Don't start sending this	packet unless at least half	of
-	 * the channels	are	free.  This	gives much better TCP
-	 * performance if we have a	lot	of channels.
-	 */
-	if (nfree == 0 || nfree	< navail / 2)
-		return 0; /* can't take now, leave it in xmit_pending	*/
+
+
+	if(ppp_ml_noexplode) {
+	}
+	else {
+		/*
+		 * Don't start sending this	packet unless at least half	of
+		 * the channels	are	free.  This	gives much better TCP
+		 * performance if we have a	lot	of channels.
+		 */
+		if (nfree == 0 || nfree	< navail / 2) {
+			return 0; /* can't take now, leave it in xmit_pending	*/
+
+		}
+	}

 	/* Do protocol field compression (XXX this should be optional) */
 	p =	skb->data;
@@ -1371,6 +1432,7 @@
 	totlen = len;
 	nbigger	= len %	nfree;

+
 	/* skip	to the channel after the one we	last used
 	   and start at	that one */
 	list = &ppp->channels;
@@ -1432,33 +1494,40 @@
 		*of the channel we are going to transmit on
 		*/
 		flen = len;
-		if (nfree > 0) {
-			if (pch->speed == 0) {
-				flen = totlen/nfree	;
-				if (nbigger > 0) {
-					flen++;
-					nbigger--;
-				}
-			} else {
-				flen = (((totfree - nzero)*(totlen + hdrlen*totfree)) /
-					((totspeed*totfree)/pch->speed)) - hdrlen;
-				if (nbigger > 0) {
-					flen += ((totfree - nzero)*pch->speed)/totspeed;
-					nbigger -= ((totfree - nzero)*pch->speed)/
-							totspeed;
+
+		if(ppp_ml_noexplode) {
+			nfree--;
+		}
+		else {
+			if (nfree > 0) {
+				if (pch->speed == 0) {
+					flen = totlen/nfree	;
+					if (nbigger > 0) {
+						flen++;
+						nbigger--;
+					}
+				} else {
+					flen = (((totfree - nzero)*(totlen + hdrlen*totfree)) /
+						((totspeed*totfree)/pch->speed)) - hdrlen;
+					if (nbigger > 0) {
+						flen += ((totfree - nzero)*pch->speed)/totspeed;
+						nbigger -= ((totfree - nzero)*pch->speed)/
+								totspeed;
+					}
 				}
+				nfree--;
 			}
-			nfree--;
+			/*
+			 *check	if we are on the last channel or
+			 *we exceded the lenght	of the data	to
+			 *fragment
+			 */
+			if ((nfree <= 0) || (flen > len))
+				flen = len;
+
 		}

 		/*
-		 *check	if we are on the last channel or
-		 *we exceded the lenght	of the data	to
-		 *fragment
-		 */
-		if ((nfree <= 0) || (flen > len))
-			flen = len;
-		/*
 		 *it is not worth to tx on slow channels:
 		 *in that case from the resulting flen according to the
 		 *above formula will be equal or less than zero.

--00c09ffb51079accec048314fcd8
Content-Type: text/x-diff; charset=US-ASCII; name="ppp_ml_noexplode.patch"
Content-Disposition: attachment; filename="ppp_ml_noexplode.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g7fwpn6r0

LS0tIGRyaXZlcnMvbmV0L3BwcF9nZW5lcmljLmMub3JpZwkyMDEwLTAzLTI1IDE2OjU2OjA1LjAw
MDAwMDAwMCArMDEwMAorKysgZHJpdmVycy9uZXQvcHBwX2dlbmVyaWMuYwkyMDEwLTAzLTMwIDE5
OjU2OjE1LjAwMDAwMDAwMCArMDIwMApAQCAtMTI5LDYgKzEyOSw3IEBACiAJdTMyCQluZXh0c2Vx
OwkvKiBNUDogc2VxIG5vIG9mIG5leHQgcGFja2V0ICovCiAJdTMyCQltaW5zZXE7CQkvKiBNUDog
bWluIG9mIG1vc3QgcmVjZW50IHNlcW5vcyAqLwogCXN0cnVjdCBza19idWZmX2hlYWQgbXJxOwkv
KiBNUDogcmVjZWl2ZSByZWNvbnN0cnVjdGlvbiBxdWV1ZSAqLworCWludCAgICAgcnJzY2hlZDsg
ICAgLyogcm91bmQgcm9iaW4gc2NoZWR1bGVyIGZvciBwYWNrZXQgZGlzdHJpYnV0aW9uICovCiAj
ZW5kaWYgLyogQ09ORklHX1BQUF9NVUxUSUxJTksgKi8KICNpZmRlZiBDT05GSUdfUFBQX0ZJTFRF
UgogCXN0cnVjdCBzb2NrX2ZpbHRlciAqcGFzc19maWx0ZXI7CS8qIGZpbHRlciBmb3IgcGFja2V0
cyB0byBwYXNzICovCkBAIC0yMjcsNiArMjI4LDE3IEBACiAjZGVmaW5lIEIJMHg4MAkJLyogdGhp
cyBmcmFnbWVudCBiZWdpbnMgYSBwYWNrZXQgKi8KICNkZWZpbmUgRQkweDQwCQkvKiB0aGlzIGZy
YWdtZW50IGVuZHMgYSBwYWNrZXQgKi8KIAorI2lmZGVmIENPTkZJR19QUFBfTVVMVElMSU5LCisv
KiBhbHRlcm5hdGUgZnJhZ21lbnRhdGlvbiBhbGdvcml0aG0gYW5kIG11bHRpbGluayBiZWhhdmlv
dXIgb3B0aW9ucyBhZGRlZCBieSB1bGkuc3RhZXJrQGdsb2JhbHdheXMubmV0ICovCitzdGF0aWMg
aW50IHBwcF9tbF9ub2V4cGxvZGUgPSAwOworbW9kdWxlX3BhcmFtKHBwcF9tbF9ub2V4cGxvZGUs
IGludCwgMDYwMCk7CitNT0RVTEVfUEFSTV9ERVNDKHBwcF9tbF9ub2V4cGxvZGUsICJTZXQgdGhp
cyB0byBhbnkgb3RoZXIgdmFsdWVzIHRoYW4gemVybyB0byBhdm9pZCBmcmFnbWVudGF0aW9uIG92
ZXIgY29ubmVjdGVkIGNoYW5uZWxzIik7CisKK3N0YXRpYyBpbnQgcHBwX21sX25vaGVhZGVyID0g
MDsKK21vZHVsZV9wYXJhbShwcHBfbWxfbm9oZWFkZXIsIGludCwgMDYwMCk7CitNT0RVTEVfUEFS
TV9ERVNDKHBwcF9tbF9ub2hlYWRlciwgIlNldCB0aGlzIHRvIGFueSBvdGhlciB2YWx1ZSB0aGFu
IHplcm8gdG8gcmVtb3ZlIHRoZSBwcHAtbXVsdGlsaW5rIHByb3RvY29sIGhlYWRlciAocHBwb2Vz
LnByb3RvY29sIG5vdCAweDAwM2QpIHdoaWNoIGVuYWJsZXMgZnJhZ21lbnRhdGlvbiBhbmQgcmVv
cmRlcmluZyIpOworI2VuZGlmIC8qIENPTkZJR19QUFBfTVVMVElMSU5LICovCisKIC8qIENvbXBh
cmUgbXVsdGlsaW5rIHNlcXVlbmNlIG51bWJlcnMgKGFzc3VtZWQgdG8gYmUgMzIgYml0cyB3aWRl
KSAqLwogI2RlZmluZSBzZXFfYmVmb3JlKGEsIGIpCSgoczMyKSgoYSkgLSAoYikpIDwgMCkKICNk
ZWZpbmUgc2VxX2FmdGVyKGEsIGIpCQkoKHMzMikoKGEpIC0gKGIpKSA+IDApCkBAIC0yNTAsNiAr
MjYyLDcgQEAKIHN0YXRpYyB2b2lkIHBwcF9tcF9pbnNlcnQoc3RydWN0IHBwcCAqcHBwLCBzdHJ1
Y3Qgc2tfYnVmZiAqc2tiKTsKIHN0YXRpYyBzdHJ1Y3Qgc2tfYnVmZiAqcHBwX21wX3JlY29uc3Ry
dWN0KHN0cnVjdCBwcHAgKnBwcCk7CiBzdGF0aWMgaW50IHBwcF9tcF9leHBsb2RlKHN0cnVjdCBw
cHAgKnBwcCwgc3RydWN0IHNrX2J1ZmYgKnNrYik7CitzdGF0aWMgdm9pZCBwcHBfbXBfcm91bmRy
b2JpbihzdHJ1Y3QgcHBwICpwcHAsIHN0cnVjdCBza19idWZmICpza2IpOwogI2VuZGlmIC8qIENP
TkZJR19QUFBfTVVMVElMSU5LICovCiBzdGF0aWMgaW50IHBwcF9zZXRfY29tcHJlc3Moc3RydWN0
IHBwcCAqcHBwLCB1bnNpZ25lZCBsb25nIGFyZyk7CiBzdGF0aWMgdm9pZCBwcHBfY2NwX3BlZWso
c3RydWN0IHBwcCAqcHBwLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBpbnQgaW5ib3VuZCk7CkBAIC0x
MjkyLDEwICsxMzA1LDE4IEBACiAJfQogCiAjaWZkZWYgQ09ORklHX1BQUF9NVUxUSUxJTksKLQkv
KiBNdWx0aWxpbms6IGZyYWdtZW50IHRoZSBwYWNrZXQgb3ZlciBhcyBtYW55IGxpbmtzCi0JICAg
YXMgY2FuIHRha2UgdGhlIHBhY2tldCBhdCB0aGUgbW9tZW50LiAqLwotCWlmICghcHBwX21wX2V4
cGxvZGUocHBwLCBza2IpKQorCS8qIHNlbmQgcGFja2V0IHdpdGhvdXQgbXVsdGlsaW5rIGhlYWRl
ciAqLworCWlmKHBwcF9tbF9ub2hlYWRlcikgeworCQlwcHBfbXBfcm91bmRyb2JpbihwcHAsIHNr
Yik7CiAJCXJldHVybjsKKwl9CisJZWxzZSB7CisJCS8qIE11bHRpbGluazogZnJhZ21lbnQgdGhl
IHBhY2tldCBvdmVyIGFzIG1hbnkgbGlua3MKKwkJICAgYXMgY2FuIHRha2UgdGhlIHBhY2tldCBh
dCB0aGUgbW9tZW50LiAqLworCQlpZiAoIXBwcF9tcF9leHBsb2RlKHBwcCwgc2tiKSkgeworCQkJ
cmV0dXJuOworCQl9CisJfQogI2VuZGlmIC8qIENPTkZJR19QUFBfTVVMVElMSU5LICovCiAKIAlw
cHAtPnhtaXRfcGVuZGluZyA9IE5VTEw7CkBAIC0xMzA0LDYgKzEzMjUsMzggQEAKIAogI2lmZGVm
IENPTkZJR19QUFBfTVVMVElMSU5LCiAvKgorICogU2VuZCBwYWNrZXQgdGhyb3VnaCB0aGUgbmV4
dCBjaGFubmVsIChyb3VuZCByb2JpbikKKyAqLworc3RhdGljIHZvaWQgcHBwX21wX3JvdW5kcm9i
aW4oc3RydWN0IHBwcCAqcHBwLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQoreworCWludCBpOworCXN0
cnVjdCBjaGFubmVsICpwY2g7CisKKwlwcHAtPnJyc2NoZWQrKzsKKwlpID0gMDsKKwlsaXN0X2Zv
cl9lYWNoX2VudHJ5KHBjaCwgJnBwcC0+Y2hhbm5lbHMsIGNsaXN0KSAgICAgIHsKKwkJaWYocGNo
LT5jaGFuID09IE5VTEwpIGNvbnRpbnVlOworCisJCWlmIChwcHAtPnJyc2NoZWQgJSBwcHAtPm5f
Y2hhbm5lbHMgPT0gaSkgeworCQkJc3Bpbl9sb2NrX2JoKCZwY2gtPmRvd25sKTsKKwkJCWlmIChw
Y2gtPmNoYW4pIHsKKwkJCQlpZiAocGNoLT5jaGFuLT5vcHMtPnN0YXJ0X3htaXQocGNoLT5jaGFu
LCBza2IpKSB7CisJCQkJCXBwcC0+eG1pdF9wZW5kaW5nID0gTlVMTDsKKwkJCQl9CisJCQl9IGVs
c2UgeworCQkJCS8qIGNoYW5uZWwgZ290IHVucmVnaXN0ZXJlZCAqLworCQkJCWtmcmVlX3NrYihz
a2IpOworCQkJCXBwcC0+eG1pdF9wZW5kaW5nID0gTlVMTDsKKwkJCX0KKwkJCXNwaW5fdW5sb2Nr
X2JoKCZwY2gtPmRvd25sKTsKKwkJCXJldHVybjsKKwkJfQorCQlpKys7CisJfQorCXJldHVybjsK
K30KKworLyoKICAqIERpdmlkZSBhIHBhY2tldCB0byBiZSB0cmFuc21pdHRlZCBpbnRvIGZyYWdt
ZW50cyBhbmQKICAqIHNlbmQgdGhlbSBvdXQgdGhlIGluZGl2aWR1YWwgbGlua3MuCiAgKi8KQEAg
LTEzNTIsMTMgKzE0MDUsMjEgQEAKIAkJfQogCQkrK2k7CiAJfQotCS8qCi0JICogRG9uJ3Qgc3Rh
cnQgc2VuZGluZyB0aGlzCXBhY2tldCB1bmxlc3MgYXQgbGVhc3QgaGFsZglvZgotCSAqIHRoZSBj
aGFubmVscwlhcmUJZnJlZS4gIFRoaXMJZ2l2ZXMgbXVjaCBiZXR0ZXIgVENQCi0JICogcGVyZm9y
bWFuY2UgaWYgd2UgaGF2ZSBhCWxvdAlvZiBjaGFubmVscy4KLQkgKi8KLQlpZiAobmZyZWUgPT0g
MCB8fCBuZnJlZQk8IG5hdmFpbCAvIDIpCi0JCXJldHVybiAwOyAvKiBjYW4ndCB0YWtlIG5vdywg
bGVhdmUgaXQgaW4geG1pdF9wZW5kaW5nCSovCisKKworCWlmKHBwcF9tbF9ub2V4cGxvZGUpIHsK
Kwl9CisJZWxzZSB7CisJCS8qCisJCSAqIERvbid0IHN0YXJ0IHNlbmRpbmcgdGhpcwlwYWNrZXQg
dW5sZXNzIGF0IGxlYXN0IGhhbGYJb2YKKwkJICogdGhlIGNoYW5uZWxzCWFyZQlmcmVlLiAgVGhp
cwlnaXZlcyBtdWNoIGJldHRlciBUQ1AKKwkJICogcGVyZm9ybWFuY2UgaWYgd2UgaGF2ZSBhCWxv
dAlvZiBjaGFubmVscy4KKwkJICovCisJCWlmIChuZnJlZSA9PSAwIHx8IG5mcmVlCTwgbmF2YWls
IC8gMikgeworCQkJcmV0dXJuIDA7IC8qIGNhbid0IHRha2Ugbm93LCBsZWF2ZSBpdCBpbiB4bWl0
X3BlbmRpbmcJKi8KKworCQl9CisJfQogCiAJLyogRG8gcHJvdG9jb2wgZmllbGQgY29tcHJlc3Np
b24gKFhYWCB0aGlzIHNob3VsZCBiZSBvcHRpb25hbCkgKi8KIAlwID0Jc2tiLT5kYXRhOwpAQCAt
MTM3MSw2ICsxNDMyLDcgQEAKIAl0b3RsZW4gPSBsZW47CiAJbmJpZ2dlcgk9IGxlbiAlCW5mcmVl
OwogCisKIAkvKiBza2lwCXRvIHRoZSBjaGFubmVsIGFmdGVyIHRoZSBvbmUgd2UJbGFzdCB1c2Vk
CiAJICAgYW5kIHN0YXJ0IGF0CXRoYXQgb25lICovCiAJbGlzdCA9ICZwcHAtPmNoYW5uZWxzOwpA
QCAtMTQzMiwzMyArMTQ5NCw0MCBAQAogCQkqb2YgdGhlIGNoYW5uZWwgd2UgYXJlIGdvaW5nIHRv
IHRyYW5zbWl0IG9uCiAJCSovCiAJCWZsZW4gPSBsZW47Ci0JCWlmIChuZnJlZSA+IDApIHsKLQkJ
CWlmIChwY2gtPnNwZWVkID09IDApIHsKLQkJCQlmbGVuID0gdG90bGVuL25mcmVlCTsKLQkJCQlp
ZiAobmJpZ2dlciA+IDApIHsKLQkJCQkJZmxlbisrOwotCQkJCQluYmlnZ2VyLS07Ci0JCQkJfQot
CQkJfSBlbHNlIHsKLQkJCQlmbGVuID0gKCgodG90ZnJlZSAtIG56ZXJvKSoodG90bGVuICsgaGRy
bGVuKnRvdGZyZWUpKSAvCi0JCQkJCSgodG90c3BlZWQqdG90ZnJlZSkvcGNoLT5zcGVlZCkpIC0g
aGRybGVuOwotCQkJCWlmIChuYmlnZ2VyID4gMCkgewotCQkJCQlmbGVuICs9ICgodG90ZnJlZSAt
IG56ZXJvKSpwY2gtPnNwZWVkKS90b3RzcGVlZDsKLQkJCQkJbmJpZ2dlciAtPSAoKHRvdGZyZWUg
LSBuemVybykqcGNoLT5zcGVlZCkvCi0JCQkJCQkJdG90c3BlZWQ7CisKKwkJaWYocHBwX21sX25v
ZXhwbG9kZSkgeworCQkJbmZyZWUtLTsKKwkJfQorCQllbHNlIHsKKwkJCWlmIChuZnJlZSA+IDAp
IHsKKwkJCQlpZiAocGNoLT5zcGVlZCA9PSAwKSB7CisJCQkJCWZsZW4gPSB0b3RsZW4vbmZyZWUJ
OworCQkJCQlpZiAobmJpZ2dlciA+IDApIHsKKwkJCQkJCWZsZW4rKzsKKwkJCQkJCW5iaWdnZXIt
LTsKKwkJCQkJfQorCQkJCX0gZWxzZSB7CisJCQkJCWZsZW4gPSAoKCh0b3RmcmVlIC0gbnplcm8p
Kih0b3RsZW4gKyBoZHJsZW4qdG90ZnJlZSkpIC8KKwkJCQkJCSgodG90c3BlZWQqdG90ZnJlZSkv
cGNoLT5zcGVlZCkpIC0gaGRybGVuOworCQkJCQlpZiAobmJpZ2dlciA+IDApIHsKKwkJCQkJCWZs
ZW4gKz0gKCh0b3RmcmVlIC0gbnplcm8pKnBjaC0+c3BlZWQpL3RvdHNwZWVkOworCQkJCQkJbmJp
Z2dlciAtPSAoKHRvdGZyZWUgLSBuemVybykqcGNoLT5zcGVlZCkvCisJCQkJCQkJCXRvdHNwZWVk
OworCQkJCQl9CiAJCQkJfQorCQkJCW5mcmVlLS07CiAJCQl9Ci0JCQluZnJlZS0tOworCQkJLyoK
KwkJCSAqY2hlY2sJaWYgd2UgYXJlIG9uIHRoZSBsYXN0IGNoYW5uZWwgb3IKKwkJCSAqd2UgZXhj
ZWRlZCB0aGUgbGVuZ2h0CW9mIHRoZSBkYXRhCXRvCisJCQkgKmZyYWdtZW50CisJCQkgKi8KKwkJ
CWlmICgobmZyZWUgPD0gMCkgfHwgKGZsZW4gPiBsZW4pKQorCQkJCWZsZW4gPSBsZW47CisKIAkJ
fQogCiAJCS8qCi0JCSAqY2hlY2sJaWYgd2UgYXJlIG9uIHRoZSBsYXN0IGNoYW5uZWwgb3IKLQkJ
ICp3ZSBleGNlZGVkIHRoZSBsZW5naHQJb2YgdGhlIGRhdGEJdG8KLQkJICpmcmFnbWVudAotCQkg
Ki8KLQkJaWYgKChuZnJlZSA8PSAwKSB8fCAoZmxlbiA+IGxlbikpCi0JCQlmbGVuID0gbGVuOwot
CQkvKgogCQkgKml0IGlzIG5vdCB3b3J0aCB0byB0eCBvbiBzbG93IGNoYW5uZWxzOgogCQkgKmlu
IHRoYXQgY2FzZSBmcm9tIHRoZSByZXN1bHRpbmcgZmxlbiBhY2NvcmRpbmcgdG8gdGhlCiAJCSAq
YWJvdmUgZm9ybXVsYSB3aWxsIGJlIGVxdWFsIG9yIGxlc3MgdGhhbiB6ZXJvLgo=
--00c09ffb51079accec048314fcd8
Content-Type: text/x-diff; charset=US-ASCII; name="ppp_ml_noexplode-with_debug.patch"
Content-Disposition: attachment;
	filename="ppp_ml_noexplode-with_debug.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g7fwq1831

LS0tIGRyaXZlcnMvbmV0L3BwcF9nZW5lcmljLmMub3JpZwkyMDEwLTAzLTI1IDE2OjU2OjA1LjAw
MDAwMDAwMCArMDEwMAorKysgZHJpdmVycy9uZXQvcHBwX2dlbmVyaWMuYy5wYXRjaGVkX3dpdGhf
ZGVidWcJMjAxMC0wMy0zMCAyMDowMzozMS4wMDAwMDAwMDAgKzAyMDAKQEAgLTEyOSw2ICsxMjks
NyBAQAogCXUzMgkJbmV4dHNlcTsJLyogTVA6IHNlcSBubyBvZiBuZXh0IHBhY2tldCAqLwogCXUz
MgkJbWluc2VxOwkJLyogTVA6IG1pbiBvZiBtb3N0IHJlY2VudCBzZXFub3MgKi8KIAlzdHJ1Y3Qg
c2tfYnVmZl9oZWFkIG1ycTsJLyogTVA6IHJlY2VpdmUgcmVjb25zdHJ1Y3Rpb24gcXVldWUgKi8K
KwlpbnQgICAgIHJyc2NoZWQ7ICAgIC8qIHJvdW5kIHJvYmluIHNjaGVkdWxlciBmb3IgcGFja2V0
IGRpc3RyaWJ1dGlvbiAqLwogI2VuZGlmIC8qIENPTkZJR19QUFBfTVVMVElMSU5LICovCiAjaWZk
ZWYgQ09ORklHX1BQUF9GSUxURVIKIAlzdHJ1Y3Qgc29ja19maWx0ZXIgKnBhc3NfZmlsdGVyOwkv
KiBmaWx0ZXIgZm9yIHBhY2tldHMgdG8gcGFzcyAqLwpAQCAtMjI3LDYgKzIyOCwxNyBAQAogI2Rl
ZmluZSBCCTB4ODAJCS8qIHRoaXMgZnJhZ21lbnQgYmVnaW5zIGEgcGFja2V0ICovCiAjZGVmaW5l
IEUJMHg0MAkJLyogdGhpcyBmcmFnbWVudCBlbmRzIGEgcGFja2V0ICovCiAKKyNpZmRlZiBDT05G
SUdfUFBQX01VTFRJTElOSworLyogYWx0ZXJuYXRlIGZyYWdtZW50YXRpb24gYWxnb3JpdGhtIGFu
ZCBtdWx0aWxpbmsgYmVoYXZpb3VyIG9wdGlvbnMgYWRkZWQgYnkgdWxpLnN0YWVya0BnbG9iYWx3
YXlzLm5ldCAqLworc3RhdGljIGludCBwcHBfbWxfbm9leHBsb2RlID0gMDsKK21vZHVsZV9wYXJh
bShwcHBfbWxfbm9leHBsb2RlLCBpbnQsIDA2MDApOworTU9EVUxFX1BBUk1fREVTQyhwcHBfbWxf
bm9leHBsb2RlLCAiU2V0IHRoaXMgdG8gYW55IG90aGVyIHZhbHVlcyB0aGFuIHplcm8gdG8gYXZv
aWQgZnJhZ21lbnRhdGlvbiBvdmVyIGNvbm5lY3RlZCBjaGFubmVscyIpOworCitzdGF0aWMgaW50
IHBwcF9tbF9ub2hlYWRlciA9IDA7Cittb2R1bGVfcGFyYW0ocHBwX21sX25vaGVhZGVyLCBpbnQs
IDA2MDApOworTU9EVUxFX1BBUk1fREVTQyhwcHBfbWxfbm9oZWFkZXIsICJTZXQgdGhpcyB0byBh
bnkgb3RoZXIgdmFsdWUgdGhhbiB6ZXJvIHRvIHJlbW92ZSB0aGUgcHBwLW11bHRpbGluayBwcm90
b2NvbCBoZWFkZXIgKHBwcG9lcy5wcm90b2NvbCBub3QgMHgwMDNkKSB3aGljaCBlbmFibGVzIGZy
YWdtZW50YXRpb24gYW5kIHJlb3JkZXJpbmciKTsKKyNlbmRpZiAvKiBDT05GSUdfUFBQX01VTFRJ
TElOSyAqLworCiAvKiBDb21wYXJlIG11bHRpbGluayBzZXF1ZW5jZSBudW1iZXJzIChhc3N1bWVk
IHRvIGJlIDMyIGJpdHMgd2lkZSkgKi8KICNkZWZpbmUgc2VxX2JlZm9yZShhLCBiKQkoKHMzMiko
KGEpIC0gKGIpKSA8IDApCiAjZGVmaW5lIHNlcV9hZnRlcihhLCBiKQkJKChzMzIpKChhKSAtIChi
KSkgPiAwKQpAQCAtMjUwLDYgKzI2Miw3IEBACiBzdGF0aWMgdm9pZCBwcHBfbXBfaW5zZXJ0KHN0
cnVjdCBwcHAgKnBwcCwgc3RydWN0IHNrX2J1ZmYgKnNrYik7CiBzdGF0aWMgc3RydWN0IHNrX2J1
ZmYgKnBwcF9tcF9yZWNvbnN0cnVjdChzdHJ1Y3QgcHBwICpwcHApOwogc3RhdGljIGludCBwcHBf
bXBfZXhwbG9kZShzdHJ1Y3QgcHBwICpwcHAsIHN0cnVjdCBza19idWZmICpza2IpOworc3RhdGlj
IHZvaWQgcHBwX21wX3JvdW5kcm9iaW4oc3RydWN0IHBwcCAqcHBwLCBzdHJ1Y3Qgc2tfYnVmZiAq
c2tiKTsKICNlbmRpZiAvKiBDT05GSUdfUFBQX01VTFRJTElOSyAqLwogc3RhdGljIGludCBwcHBf
c2V0X2NvbXByZXNzKHN0cnVjdCBwcHAgKnBwcCwgdW5zaWduZWQgbG9uZyBhcmcpOwogc3RhdGlj
IHZvaWQgcHBwX2NjcF9wZWVrKHN0cnVjdCBwcHAgKnBwcCwgc3RydWN0IHNrX2J1ZmYgKnNrYiwg
aW50IGluYm91bmQpOwpAQCAtMTI3Myw2ICsxMjg2LDcgQEAKIAkJcmV0dXJuOwogCX0KIAorcHJp
bnRrKEtFUk5fRVJSICJzZW5kIHBhY2tldFxuIik7CiAJaWYgKChwcHAtPmZsYWdzICYgU0NfTVVM
VElMSU5LKSA9PSAwKSB7CiAJCS8qIG5vdCBkb2luZyBtdWx0aWxpbms6IHNlbmQgaXQgZG93biB0
aGUgZmlyc3QgY2hhbm5lbCAqLwogCQlsaXN0ID0gbGlzdC0+bmV4dDsKQEAgLTEyOTIsMTEgKzEz
MDYsMjQgQEAKIAl9CiAKICNpZmRlZiBDT05GSUdfUFBQX01VTFRJTElOSwotCS8qIE11bHRpbGlu
azogZnJhZ21lbnQgdGhlIHBhY2tldCBvdmVyIGFzIG1hbnkgbGlua3MKLQkgICBhcyBjYW4gdGFr
ZSB0aGUgcGFja2V0IGF0IHRoZSBtb21lbnQuICovCi0JaWYgKCFwcHBfbXBfZXhwbG9kZShwcHAs
IHNrYikpCisJLyogc2VuZCBwYWNrZXQgd2l0aG91dCBtdWx0aWxpbmsgaGVhZGVyICovCisJaWYo
cHBwX21sX25vaGVhZGVyKSB7CitwcmludGsoS0VSTl9FUlIgIkJFR0lOIFNFTkQgUlJcbiIpOwor
CQlwcHBfbXBfcm91bmRyb2JpbihwcHAsIHNrYik7CiAJCXJldHVybjsKK3ByaW50ayhLRVJOX0VS
UiAiRU5EIFNFTkQgUlJcbiIpOworCX0KKwllbHNlIHsKK3ByaW50ayhLRVJOX0VSUiAiQkVHSU4g
U0VORCBNVUxUSUxJTktcbiIpOworCQkvKiBNdWx0aWxpbms6IGZyYWdtZW50IHRoZSBwYWNrZXQg
b3ZlciBhcyBtYW55IGxpbmtzCisJCSAgIGFzIGNhbiB0YWtlIHRoZSBwYWNrZXQgYXQgdGhlIG1v
bWVudC4gKi8KKwkJaWYgKCFwcHBfbXBfZXhwbG9kZShwcHAsIHNrYikpIHsKK3ByaW50ayhLRVJO
X0VSUiAiRU5EIFNFTkQgTVVMVElMSU5LXG4iKTsKKwkJCXJldHVybjsKKwkJfQorCX0KICNlbmRp
ZiAvKiBDT05GSUdfUFBQX01VTFRJTElOSyAqLworcHJpbnRrKEtFUk5fRVJSICJFTkQgU0VORCBE
Uk9QIFBBQ0tFVFxuIik7CiAKIAlwcHAtPnhtaXRfcGVuZGluZyA9IE5VTEw7CiAJa2ZyZWVfc2ti
KHNrYik7CkBAIC0xMzA0LDYgKzEzMzEsNDEgQEAKIAogI2lmZGVmIENPTkZJR19QUFBfTVVMVElM
SU5LCiAvKgorICogU2VuZCBwYWNrZXQgdGhyb3VnaCB0aGUgbmV4dCBjaGFubmVsIChyb3VuZCBy
b2JpbikKKyAqLworc3RhdGljIHZvaWQgcHBwX21wX3JvdW5kcm9iaW4oc3RydWN0IHBwcCAqcHBw
LCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQoreworCWludCBpOworCXN0cnVjdCBjaGFubmVsICpwY2g7
CisKKwlwcHAtPnJyc2NoZWQrKzsKK3ByaW50ayhLRVJOX0VSUiAiICBSUiBjb3VudGVyPSVkLCBs
ZW49JWQsIGRldm10dT0lZFxuIiwgcHBwLT5ycnNjaGVkLCBza2ItPmxlbiwgcHBwLT5kZXYtPm10
dSk7CisJaSA9IDA7CisJbGlzdF9mb3JfZWFjaF9lbnRyeShwY2gsICZwcHAtPmNoYW5uZWxzLCBj
bGlzdCkgICAgICB7CisJCWlmKHBjaC0+Y2hhbiA9PSBOVUxMKSBjb250aW51ZTsKKworCQlpZiAo
cHBwLT5ycnNjaGVkICUgcHBwLT5uX2NoYW5uZWxzID09IGkpIHsKK3ByaW50ayhLRVJOX0VSUiAi
ICBSUiBzZW5kIHZpYSAlZCwgY2htdHU9JWRcbiIsIGksIHBjaC0+Y2hhbi0+bXR1KTsKKwkJCXNw
aW5fbG9ja19iaCgmcGNoLT5kb3dubCk7CisJCQlpZiAocGNoLT5jaGFuKSB7CisJCQkJaWYgKHBj
aC0+Y2hhbi0+b3BzLT5zdGFydF94bWl0KHBjaC0+Y2hhbiwgc2tiKSkgeworCQkJCQlwcHAtPnht
aXRfcGVuZGluZyA9IE5VTEw7CisJCQkJfQorCQkJfSBlbHNlIHsKK3ByaW50ayhLRVJOX0VSUiAi
ICBSUiBkcm9wcGVkIGF0ICVkXG4iLCBpKTsKKwkJCQkvKiBjaGFubmVsIGdvdCB1bnJlZ2lzdGVy
ZWQgKi8KKwkJCQlrZnJlZV9za2Ioc2tiKTsKKwkJCQlwcHAtPnhtaXRfcGVuZGluZyA9IE5VTEw7
CisJCQl9CisJCQlzcGluX3VubG9ja19iaCgmcGNoLT5kb3dubCk7CisJCQlyZXR1cm47CisJCX0K
KwkJaSsrOworCX0KKwlyZXR1cm47Cit9CisKKy8qCiAgKiBEaXZpZGUgYSBwYWNrZXQgdG8gYmUg
dHJhbnNtaXR0ZWQgaW50byBmcmFnbWVudHMgYW5kCiAgKiBzZW5kIHRoZW0gb3V0IHRoZSBpbmRp
dmlkdWFsIGxpbmtzLgogICovCkBAIC0xMzUyLDEzICsxNDE0LDI1IEBACiAJCX0KIAkJKytpOwog
CX0KLQkvKgotCSAqIERvbid0IHN0YXJ0IHNlbmRpbmcgdGhpcwlwYWNrZXQgdW5sZXNzIGF0IGxl
YXN0IGhhbGYJb2YKLQkgKiB0aGUgY2hhbm5lbHMJYXJlCWZyZWUuICBUaGlzCWdpdmVzIG11Y2gg
YmV0dGVyIFRDUAotCSAqIHBlcmZvcm1hbmNlIGlmIHdlIGhhdmUgYQlsb3QJb2YgY2hhbm5lbHMu
Ci0JICovCi0JaWYgKG5mcmVlID09IDAgfHwgbmZyZWUJPCBuYXZhaWwgLyAyKQotCQlyZXR1cm4g
MDsgLyogY2FuJ3QgdGFrZSBub3csIGxlYXZlIGl0IGluIHhtaXRfcGVuZGluZwkqLworCitwcmlu
dGsoS0VSTl9FUlIgIiAgTUwgbmZyZWU9JWQsIG5hdmFpbD0lZCwgbnplcm89JWQsIHRvdGZyZWU9
JWQsIHRvdHNwZWVkPSVkXG4iLCBuZnJlZSxuYXZhaWwsbnplcm8sdG90ZnJlZSx0b3RzcGVlZCk7
CisKKwlpZihwcHBfbWxfbm9leHBsb2RlKSB7CitwcmludGsoS0VSTl9FUlIgIiAgTUwgbm8gZXhw
bG9kZSBBXG4iKTsKKwl9CisJZWxzZSB7CitwcmludGsoS0VSTl9FUlIgIiAgTUwgZXhwbG9kZSBB
XG4iKTsKKwkJLyoKKwkJICogRG9uJ3Qgc3RhcnQgc2VuZGluZyB0aGlzCXBhY2tldCB1bmxlc3Mg
YXQgbGVhc3QgaGFsZglvZgorCQkgKiB0aGUgY2hhbm5lbHMJYXJlCWZyZWUuICBUaGlzCWdpdmVz
IG11Y2ggYmV0dGVyIFRDUAorCQkgKiBwZXJmb3JtYW5jZSBpZiB3ZSBoYXZlIGEJbG90CW9mIGNo
YW5uZWxzLgorCQkgKi8KKwkJaWYgKG5mcmVlID09IDAgfHwgbmZyZWUJPCBuYXZhaWwgLyAyKSB7
CitwcmludGsoS0VSTl9FUlIgIiAgTUwgd2FpdCBBXG4iKTsKKwkJCXJldHVybiAwOyAvKiBjYW4n
dCB0YWtlIG5vdywgbGVhdmUgaXQgaW4geG1pdF9wZW5kaW5nCSovCisKKwkJfQorCX0KIAogCS8q
IERvIHByb3RvY29sIGZpZWxkIGNvbXByZXNzaW9uIChYWFggdGhpcyBzaG91bGQgYmUgb3B0aW9u
YWwpICovCiAJcCA9CXNrYi0+ZGF0YTsKQEAgLTEzNzEsNiArMTQ0NSw4IEBACiAJdG90bGVuID0g
bGVuOwogCW5iaWdnZXIJPSBsZW4gJQluZnJlZTsKIAorcHJpbnRrKEtFUk5fRVJSICIgIE1MIGxl
bj0lZCwgdG90bGVuPSVkLCBuYmlnZ2VyPSVkXG4iLCBsZW4sIHRvdGxlbiwgbmJpZ2dlcik7CisK
IAkvKiBza2lwCXRvIHRoZSBjaGFubmVsIGFmdGVyIHRoZSBvbmUgd2UJbGFzdCB1c2VkCiAJICAg
YW5kIHN0YXJ0IGF0CXRoYXQgb25lICovCiAJbGlzdCA9ICZwcHAtPmNoYW5uZWxzOwpAQCAtMTM4
MSwxMCArMTQ1NywxMiBAQAogCQkJYnJlYWs7CiAJCX0KIAl9CitwcmludGsoS0VSTl9FUlIgIiAg
TUwgc2tpcCB0byBjaGFubmVsPSVkXG4iLCBpKTsKIAogCS8qIGNyZWF0ZSBhCWZyYWdtZW50IGZv
ciBlYWNoIGNoYW5uZWwgKi8KIAliaXRzID0gQjsKIAl3aGlsZSAobGVuCT4gMCkgeworcHJpbnRr
KEtFUk5fRVJSICIgIE1MIHdoaWxlIGxlbj0lZCwgaT0lZFxuIiwgbGVuLCBpKTsKIAkJbGlzdCA9
IGxpc3QtPm5leHQ7CiAJCWlmIChsaXN0ID09CSZwcHAtPmNoYW5uZWxzKQl7CiAJCQlpID0JMDsK
QEAgLTE0MzIsNDUgKzE1MTAsNTggQEAKIAkJKm9mIHRoZSBjaGFubmVsIHdlIGFyZSBnb2luZyB0
byB0cmFuc21pdCBvbgogCQkqLwogCQlmbGVuID0gbGVuOwotCQlpZiAobmZyZWUgPiAwKSB7Ci0J
CQlpZiAocGNoLT5zcGVlZCA9PSAwKSB7Ci0JCQkJZmxlbiA9IHRvdGxlbi9uZnJlZQk7Ci0JCQkJ
aWYgKG5iaWdnZXIgPiAwKSB7Ci0JCQkJCWZsZW4rKzsKLQkJCQkJbmJpZ2dlci0tOwotCQkJCX0K
LQkJCX0gZWxzZSB7Ci0JCQkJZmxlbiA9ICgoKHRvdGZyZWUgLSBuemVybykqKHRvdGxlbiArIGhk
cmxlbip0b3RmcmVlKSkgLwotCQkJCQkoKHRvdHNwZWVkKnRvdGZyZWUpL3BjaC0+c3BlZWQpKSAt
IGhkcmxlbjsKLQkJCQlpZiAobmJpZ2dlciA+IDApIHsKLQkJCQkJZmxlbiArPSAoKHRvdGZyZWUg
LSBuemVybykqcGNoLT5zcGVlZCkvdG90c3BlZWQ7Ci0JCQkJCW5iaWdnZXIgLT0gKCh0b3RmcmVl
IC0gbnplcm8pKnBjaC0+c3BlZWQpLwotCQkJCQkJCXRvdHNwZWVkOworcHJpbnRrKEtFUk5fRVJS
ICIgIE1MIGZyYWdtZW50bGVuPSVkXG4iLCBmbGVuKTsKKworCQlpZihwcHBfbWxfbm9leHBsb2Rl
KSB7CitwcmludGsoS0VSTl9FUlIgIiAgTUwgbm8gZXhwbG9kZSBCIFxuIik7CisJCQluZnJlZS0t
OworCQl9CisJCWVsc2UgeworcHJpbnRrKEtFUk5fRVJSICIgIE1MIGV4cGxvZGUgQiBcbiIpOwor
CQkJaWYgKG5mcmVlID4gMCkgeworCQkJCWlmIChwY2gtPnNwZWVkID09IDApIHsKKwkJCQkJZmxl
biA9IHRvdGxlbi9uZnJlZQk7CisJCQkJCWlmIChuYmlnZ2VyID4gMCkgeworCQkJCQkJZmxlbisr
OworCQkJCQkJbmJpZ2dlci0tOworCQkJCQl9CisJCQkJfSBlbHNlIHsKKwkJCQkJZmxlbiA9ICgo
KHRvdGZyZWUgLSBuemVybykqKHRvdGxlbiArIGhkcmxlbip0b3RmcmVlKSkgLworCQkJCQkJKCh0
b3RzcGVlZCp0b3RmcmVlKS9wY2gtPnNwZWVkKSkgLSBoZHJsZW47CisJCQkJCWlmIChuYmlnZ2Vy
ID4gMCkgeworCQkJCQkJZmxlbiArPSAoKHRvdGZyZWUgLSBuemVybykqcGNoLT5zcGVlZCkvdG90
c3BlZWQ7CisJCQkJCQluYmlnZ2VyIC09ICgodG90ZnJlZSAtIG56ZXJvKSpwY2gtPnNwZWVkKS8K
KwkJCQkJCQkJdG90c3BlZWQ7CisJCQkJCX0KIAkJCQl9CisJCQkJbmZyZWUtLTsKIAkJCX0KLQkJ
CW5mcmVlLS07CisJCQkvKgorCQkJICpjaGVjawlpZiB3ZSBhcmUgb24gdGhlIGxhc3QgY2hhbm5l
bCBvcgorCQkJICp3ZSBleGNlZGVkIHRoZSBsZW5naHQJb2YgdGhlIGRhdGEJdG8KKwkJCSAqZnJh
Z21lbnQKKwkJCSAqLworCQkJaWYgKChuZnJlZSA8PSAwKSB8fCAoZmxlbiA+IGxlbikpCisJCQkJ
ZmxlbiA9IGxlbjsKKworcHJpbnRrKEtFUk5fRVJSICIgIE1MIG5ldyBmcmFnbWVudGxlbj0lZFxu
IiwgZmxlbik7CiAJCX0KIAogCQkvKgotCQkgKmNoZWNrCWlmIHdlIGFyZSBvbiB0aGUgbGFzdCBj
aGFubmVsIG9yCi0JCSAqd2UgZXhjZWRlZCB0aGUgbGVuZ2h0CW9mIHRoZSBkYXRhCXRvCi0JCSAq
ZnJhZ21lbnQKLQkJICovCi0JCWlmICgobmZyZWUgPD0gMCkgfHwgKGZsZW4gPiBsZW4pKQotCQkJ
ZmxlbiA9IGxlbjsKLQkJLyoKIAkJICppdCBpcyBub3Qgd29ydGggdG8gdHggb24gc2xvdyBjaGFu
bmVsczoKIAkJICppbiB0aGF0IGNhc2UgZnJvbSB0aGUgcmVzdWx0aW5nIGZsZW4gYWNjb3JkaW5n
IHRvIHRoZQogCQkgKmFib3ZlIGZvcm11bGEgd2lsbCBiZSBlcXVhbCBvciBsZXNzIHRoYW4gemVy
by4KIAkJICpTa2lwIHRoZSBjaGFubmVsIGluIHRoaXMgY2FzZQogCQkgKi8KIAkJaWYgKGZsZW4g
PD0JMCkgeworcHJpbnRrKEtFUk5fRVJSICIgIE1MIGZyYWdtZW50bGVuIGlzIHplcm9cbiIpOwog
CQkJcGNoLT5hdmFpbCA9IDI7CiAJCQlzcGluX3VubG9ja19iaCgmcGNoLT5kb3dubCk7CiAJCQlj
b250aW51ZTsKIAkJfQogCiAJCW10dQk9IHBjaC0+Y2hhbi0+bXR1IC0gaGRybGVuOworcHJpbnRr
KEtFUk5fRVJSICIgIE1MIG10dT0lZCAoY2hhbi1tdHU9JWQpXG4iLCBtdHUsIHBjaC0+Y2hhbi0+
bXR1KTsKIAkJaWYgKG10dQk8IDQpCiAJCQltdHUJPSA0OwogCQlpZiAoZmxlbiA+IG10dSkKQEAg
LTE1MDIsNiArMTU5Myw3IEBACiAJCWlmICghc2tiX3F1ZXVlX2VtcHR5KCZwY2gtPmZpbGUueHEp
CXx8CiAJCQkhY2hhbi0+b3BzLT5zdGFydF94bWl0KGNoYW4sIGZyYWcpKQogCQkJc2tiX3F1ZXVl
X3RhaWwoJnBjaC0+ZmlsZS54cSwgZnJhZyk7CitwcmludGsoS0VSTl9FUlIgIiAgTUwgc2VudCBw
YWNrZXQgd2l0aCBzZXE6ICVkXG4iLCBwcHAtPm54c2VxKTsKIAkJcGNoLT5oYWRfZnJhZyA9CTE7
CiAJCXAgKz0gZmxlbjsKIAkJbGVuCS09IGZsZW47CkBAIC0xNTEwLDYgKzE2MDIsNyBAQAogCQlz
cGluX3VubG9ja19iaCgmcGNoLT5kb3dubCk7CiAJfQogCXBwcC0+bnhjaGFuCT0gaTsKK3ByaW50
ayhLRVJOX0VSUiAiICBNTCBFTkQgU0VORFxuIik7CiAKIAlyZXR1cm4gMTsKIAo=
--00c09ffb51079accec048314fcd8--
