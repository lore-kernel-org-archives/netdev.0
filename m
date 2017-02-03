From: "Malinen, Jouni" <jouni@qca.qualcomm.com>
Subject: Re: [RFC PATCH 0/2] mac80211: use crypto shash for AES cmac
Date: Fri, 3 Feb 2017 21:47:15 +0000
Message-ID: <20170203214707.GA14147@jouni.qca.qualcomm.com>
References: <1486149955-11825-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:26093 "EHLO
        wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752268AbdBCVrT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:47:19 -0500
In-Reply-To: <1486149955-11825-1-git-send-email-ard.biesheuvel@linaro.org>
Content-Language: en-US
Content-ID: <327B6F0662368142A9432E3F5656218F@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2017 at 07:25:53PM +0000, Ard Biesheuvel wrote:
> The mac80211 aes_cmac code reimplements the CMAC algorithm based on the
> core AES cipher, which is rather restrictive in how platforms can satisfy
> the dependency on this algorithm. For instance, SIMD implementations may
> have a considerable setup time, which cannot be amortized over the entire
> input when calling into the crypto API one block at a time. Also, it prev=
ents
> the use of more secure fixed time implementations, since not all AES driv=
ers
> expose the cipher interface.
>=20
> So switch aes_cmac to use a cmac(aes) shash. This requires a preparatory
> patch so that we can remove the open coded implementation, which it share=
s
> with the fils aead driver. That driver could receive the same treatment, =
in
> which case we could replace patch #1 with one that carries it over first.
>=20
> Note that this is an RFC. I have no idea how I would go about testing thi=
s
> code, but I am on a mission to remove as many dependencies on the generic
> AES cipher as I can.

Neither the BIP nor FILS cases have any real speed requirements taken
into account how rarely they end up being used in practice (there is
really no use case for BIP today and FILS is used only once per
association). That said, there should be no issues with moving these to
a more generic mechanism assuming one is available now (I don't think
that was the case when I was working on BIP and I was too lazy to figure
out how to convert it or the newer FILS implementation)..

mac80211_hwsim show allow some of the testing to be done with wlantest
confirming the results in user space (*). I think that would cover all
of BIP (net/mac80211/aes_cmac.c), but not FILS. For FILS, we do not
currently have a convenient mechanism for running two different
instances of kernel or even just mac80211 in the setup, so that would
likely need testing with real WLAN hardware. I don't currently have a
good setup for testing this (was using Backports-based solution in the
past instead of full kernel build and Backports is a bit behind the
current state..), but I guess I'll need to build something functional
for this eventually.. Once that's in working condition on two devices,
it would be straightforward to run a test (snapshot of hostap.git build
to enable FILS functionality and go through one FILS authentication
round)..

Another alternative would be to extend wlantest to decrypt/validate FIPS
AEAD use case based on keys exposed from hostapd or wpa_supplicant.
There has not been sufficient use case for that so far and I have not
bothered working on it yet.


By the way, FILS AEAD uses SIV mode and I'm not sure it is supported in
the current crypto code, so that would be one additional piece to take
care of when considering net/mac80211/fils_aead.c conversion.


(*)
http://buildbot.w1.fi/hwsim/
http://w1.fi/cgit/hostap/tree/tests/hwsim/vm/example-vm-setup.txt

--=20
Jouni Malinen                                            PGP id EFC895FA=
