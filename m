From: Sven Eckelmann <sven.eckelmann@openmesh.com>
Subject: [REGRESSION] mac80211: IBSS vif queue stopped when started after 11s vif
Date: Wed, 22 Mar 2017 10:15:11 +0100
Message-ID: <1978424.XTv2Qph05K@bentobox>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart12317554.V7rrdmb2pt"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:36218 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758957AbdCVJPU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 05:15:20 -0400
Received: by mail-wr0-f182.google.com with SMTP id u108so126204620wrb.3
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 02:15:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart12317554.V7rrdmb2pt
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi,

I had following "simple" setup with LEDE with a single ath9k phy and multiple 
vif:

 * encrypted AP
 * encrypted 802.11s meshpoint
 * encrypted IBSS

Everything was started in the order by hostapd/wpa_supplicant (but immediately 
after each other).

The problem which I've experienced was that IBSS was not able to communicate 
with its link partner. The reason for that problem was that the IBSS 
interface's queue was stopped (QUEUE_STATE_DRV_XOFF). This problem disappeared 
when either the IBSS or meshpoint interface was changed to unencrypted (which 
disables wpa_supplicant in LEDE).

It looks like ieee80211_do_open didn't start the queues via 
netif_start_subqueue because local->queue_stop_reasons was for all queues set 
to IEEE80211_QUEUE_STOP_REASON_OFFCHANNEL. This happened because 
ieee80211_offchannel_stop_vifs was called from somewhere in the scan code at 
that time and ieee80211_offchannel_return was not yet called.


This behavior seems to be introduced by 2b730daacee6 ("mac80211: don't start 
new netdev queues if driver stopped"). I have therefore chosen to call it for 
now a regression by this change. Especially because it is rather odd that the 
commit talked about not starting the queues for AP_VLAN and 2b436312f091 
("mac80211: fix queue handling crash") introduced extra code to use the old 
behavior again for AP_VLAN.

But I could be completely wrong about it. It would therefore be interesting 
for me to know who would be responsible to start the queues when 
ieee80211_do_open rejected it for IBSS.

I am now simply using this setup with a revert of 
2b436312f0919c05804fed5aa4b7f255db196e7a and 
2b730daacee6c318bce7b6373c19909e36a74590.

Kind regards,
	Sven
--nextPart12317554.V7rrdmb2pt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAljSQJ8ACgkQXYcKB8Em
e0a0UxAAok1EvYmt7CdriRQOxdOGq6Ib7X/xoVcrW1ACDDwhjF1s6ke1hARJHT1E
ASP5IEMsKXyrVWsZNE5Mx9wpp1b0G/QRxs/pZepUyrKMEUngHH2Vo4oZfV1lhOa5
6/tM/Pm54ARd9Sv7ZdelCUI2LVKftLMDXbPeyXD7sPaQVE+v8y6Td0gystIyuvND
wcbmYLLZ/Nv+YDB068XghjNLb9SnPDQNjvQFlIHxqOjraHjZ4vjKGcw6nEmjT6Ru
Uge7vjnUa2EMQ/8xq2Qr1ICRqJurYR/h+LR6T2TfgGOWvSKN2Sk/Bi0qzHu5tP6T
HD32VD4eSyziUuKDwr9k0BWzOTdPWw9ruf9/y54q/gQyT8XzRPyXqSAMsD8hi5oI
Hjv6eY5sCa4aBV68rhHCzzvpvdsEC7G0ijt/dUxgD6ozLoh0ll9zymrp6mzb/PNA
o40xMAiidZuzz0vcNTrIeGxiwdcgoMeNH0ES7UcxMAlsl3UPzkhEjtM7UOf6YaV4
sHGfUmSsyd5sz/Rsm1G8j+4Cn1P0K3GpAfM75lsPMJfNkOVX1sz8XCE89VhhZ4Rb
1SujUm3GPKXzehmPO5bk27LMHwdkcTs6+zO4b1Z/R1nG33QhaxbE4H84SAQv0vwG
TMS8sbIoRMfUHUAikTb9rMJhOUkCPQL4J96J3xcXcMrSD1F5yQw=
=JpAT
-----END PGP SIGNATURE-----

--nextPart12317554.V7rrdmb2pt--
