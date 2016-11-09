From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] wireless: fix bogus maybe-uninitialized warning
Date: Wed, 09 Nov 2016 03:21:13 +0200
Message-ID: <87mvh9qwhi.fsf@purkki.adurom.net>
References: <20161024153918.2810634-1-arnd@arndb.de>
        <20161024153918.2810634-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
        Jouni Malinen <j@w1.fi>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:54560 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751646AbcKIBVS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 20:21:18 -0500
In-Reply-To: <20161024153918.2810634-2-arnd@arndb.de> (Arnd Bergmann's message
        of "Mon, 24 Oct 2016 17:38:35 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:

> The hostap_80211_rx() function is supposed to set up the mac addresses
> for four possible cases, based on two bits of input data. For
> some reason, gcc decides that it's possible that none of the these
> four cases apply and the addresses remain uninitialized:
>
> drivers/net/wireless/intersil/hostap/hostap_80211_rx.c: In function =E2=
=80=98hostap_80211_rx=E2=80=99:
> arch/x86/include/asm/string_32.h:77:14: warning: =E2=80=98src=E2=80=99 ma=
y be used uninitialized in this function [-Wmaybe-uninitialized]
> drivers/net/wireless/intel/ipw2x00/libipw_rx.c: In function =E2=80=98libi=
pw_rx=E2=80=99:
> arch/x86/include/asm/string_32.h:77:14: error: =E2=80=98dst=E2=80=99 may =
be used uninitialized in this function [-Werror=3Dmaybe-uninitialized]
> arch/x86/include/asm/string_32.h:78:22: error: =E2=80=98*((void *)&dst+4)=
=E2=80=99 may be used uninitialized in this function [-Werror=3Dmaybe-unini=
tialized]
>
> This warning is clearly nonsense, but changing the last case into
> 'default' makes it obvious to the compiler too, which avoids the
> warning and probably leads to better object code too.
>
> The same code is duplicated several times in the kernel, so this
> patch uses the same workaround for all copies. The exact configuration
> was hit only very rarely in randconfig builds and I only saw it
> in three drivers, but I assume that all of them are potentially
> affected, and it's better to keep the code consistent.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/wireless/ath/ath6kl/wmi.c                  | 8 ++++----
>  drivers/net/wireless/intel/ipw2x00/libipw_rx.c         | 2 +-
>  drivers/net/wireless/intersil/hostap/hostap_80211_rx.c | 2 +-
>  net/wireless/lib80211_crypt_tkip.c                     | 2 +-
>  4 files changed, 7 insertions(+), 7 deletions(-)

[...]

> --- a/net/wireless/lib80211_crypt_tkip.c
> +++ b/net/wireless/lib80211_crypt_tkip.c
> @@ -556,7 +556,7 @@ static void michael_mic_hdr(struct sk_buff *skb, u8 *=
 hdr)
>  		memcpy(hdr, hdr11->addr3, ETH_ALEN);	/* DA */
>  		memcpy(hdr + ETH_ALEN, hdr11->addr4, ETH_ALEN);	/* SA */
>  		break;
> -	case 0:
> +	default:
>  		memcpy(hdr, hdr11->addr1, ETH_ALEN);	/* DA */
>  		memcpy(hdr + ETH_ALEN, hdr11->addr2, ETH_ALEN);	/* SA */
>  		break;

Ideally we prefer that drivers/net/wireless and net/wireless changes are
split into different patches as they get applied to different trees.
Johannes, is it ok if I take this change through my tree this time?

--=20
Kalle Valo
