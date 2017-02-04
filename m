From: "Malinen, Jouni" <jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [RFC PATCH 0/2] mac80211: use crypto shash for AES cmac
Date: Sat, 4 Feb 2017 11:35:22 +0000
Message-ID: <20170204113514.GA4350@jouni.qca.qualcomm.com>
References: <1486149955-11825-1-git-send-email-ard.biesheuvel@linaro.org>
 <20170203214707.GA14147@jouni.qca.qualcomm.com>
 <CAKv+Gu9zp+vptF2mHP5MW=x_K5m7WQgMxNNSD5hn93aT_-99xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKv+Gu9zp+vptF2mHP5MW=x_K5m7WQgMxNNSD5hn93aT_-99xA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Content-ID: <AD38CE1C2336A340847A963E8260F1FD-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 03, 2017 at 09:55:36PM +0000, Ard Biesheuvel wrote:
> OK, that looks like something I could figure out how to use. But are
> you saying the CMAC code is never called in practice?

It will get called if there is a frame that were to need to use BIP.
There are some APs that do send broadcast addressed Deauthentication and
Disassociation frames when terminating the network and those would get
here. In theory, someone could come up with a new Action frame use case
as well with a group addressed Robust Action frame, but no such thing is
defined today. Anyway, this will be needed for certification purposes
and to block DoS with broadcast addressed Deauthentication and
Disassociation frames even if there is not really a common use case
using BIP frames today.

> I did spot something peculiar when looking at the code: if I am
> reading the following sequence correctly (from
> fils_encrypt_assoc_req())

> addr[0] =3D mgmt->sa;
...
> addr[4] =3D capab;
> len[4] =3D encr - capab;
>=20
> crypt_len =3D skb->data + skb->len - encr;
> skb_put(skb, AES_BLOCK_SIZE);
> return aes_siv_encrypt(assoc_data->fils_kek, assoc_data->fils_kek_len,
>       encr, crypt_len, 1, addr, len, encr);
>=20
> the addr[]/len[] arrays are populated with 5 (addr, len) pairs, but
> only one is actually passed into aes_siv_encrypt()? This is actually
> the main reason I stopped looking into whether I could convert it to
> CMAC, because I couldn't figure it out.

Argh.. Thanks for finding this!

That is indeed supposed to have num_elems =3D=3D 5. This "works" since the
other end of the exchange is actually in user space (hostapd) and a
similar error is there..

This comes from the development history of FILS support.. The draft
standard changed this AES-SIV AAD design from P802.11ai/D7.0 to D8.0
from a single AAD vector with concatenated fields to separate vectors.
Clearly I added the vectors here in addr[] and len[] arrays, but forgot
to update the num_elems parameter in this direction (STA->AP); the other
direction for Association Response frame is actually using correct
number of AAD vectors.

I'll fix this in hostapd and mac80211.


I did not actually remember that the AP side was still in hostapd for
FILS AEAD in case of mac80211, but with that in mind, the answer to your
earlier question about testing these becomes much simpler.. All you need
to do is this with hostap.git hwsim tests:

hostap/tests/hwsim/vm$ ./vm-run.sh ap_cipher_bip fils_sk_erp
Starting test run in a virtual machine
./run-all.sh: passing the following args to run-tests.py: ap_cipher_bip fil=
s_sk_erp=20
START ap_cipher_bip 1/2
PASS ap_cipher_bip 0.703048 2017-02-04 11:21:35.341174
START fils_sk_erp 2/2
PASS fils_sk_erp 0.667927 2017-02-04 11:21:36.029205
passed all 2 test case(s)
ALL-PASSED


ap_cipher_bip uses wlantest to verify the BIP (AES-128-CMAC) protection
in the frames and fils_sk_erp goes through FILS AEAD exchange with one
side of the operation in mac80211 and the other one in hostapd. This
should be able to discover if something is broken in the AES related
changes in crypto.

And this particular example run here was with your two patches applied,
to the proposed net/mac80211/aes_cmac.c change seems to work fine.

--=20
Jouni Malinen                                            PGP id EFC895FA=
