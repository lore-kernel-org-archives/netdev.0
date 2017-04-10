From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] mac80211: Fix clang warning about constant operand in
 logical operation
Date: Mon, 10 Apr 2017 14:12:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFCA9CE@AcuExch.aculab.com>
References: <20170406185633.91065-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Grant Grundler <grundler@chromium.org>,
        Michael Davidson <md@google.com>,
        Greg Hackmann <ghackmann@google.com>
To: 'Matthias Kaehlcke' <mka@chromium.org>,
        Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170406185633.91065-1-mka@chromium.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Kaehlcke
> Sent: 06 April 2017 19:57
> Clang raises a warning about the expression 'strlen(CONFIG_XXX)' being
> used in a logical operation. Clangs' builtin strlen function resolves the
> expression to a constant at compile time, which causes clang to generate
> a 'constant-logical-operand' warning.
> 
> Split the if statement in two to avoid using the const expression in a
> logical operation.
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> ---
>  net/mac80211/rate.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
> index 206698bc93f4..68ff202d6380 100644
> --- a/net/mac80211/rate.c
> +++ b/net/mac80211/rate.c
> @@ -173,9 +173,14 @@ ieee80211_rate_control_ops_get(const char *name)
>  		/* try default if specific alg requested but not found */
>  		ops = ieee80211_try_rate_control_ops_get(ieee80211_default_rc_algo);
> 
> +	if (ops)
> +		goto unlock;
> +
>  	/* try built-in one if specific alg requested but not found */
> -	if (!ops && strlen(CONFIG_MAC80211_RC_DEFAULT))
> +	if (strlen(CONFIG_MAC80211_RC_DEFAULT))
>  		ops = ieee80211_try_rate_control_ops_get(CONFIG_MAC80211_RC_DEFAULT);
> +
> +unlock:

Using the result of strlen() as a boolean should itself be a compilation error.
You could change to code to the equivalent:

	if (!ops && CONFIG_MAC80211_RC_DEFAULT[0])
		ops = ...

	David
