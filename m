From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 5/7] via-velocity: Re-enable transmit scatter-gather
 support
Date: Wed, 25 Nov 2009 15:37:35 -0800 (PST)
Message-ID: <20091125.153735.28806618.davem@davemloft.net>
References: <20091123152724.2871cf4d@marrow.netinsight.se>
	<20091123153133.2237b04c@marrow.netinsight.se>
	<20091125092213.423d0dd7@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55897
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935197AbZKYXhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 18:37:17 -0500
In-Reply-To: <20091125092213.423d0dd7@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Wed, 25 Nov 2009 09:22:13 +0100

> The velocity hardware can handle up to 7 memory segments. This can be
> turned on and off via ethtool. The support was removed in commit
> 
>   83c98a8cd04dd0f848574370594886ba3bf56750
> 
> but is re-enabled and cleaned up here. It's off by default.
> 
> Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
> ---
> ChangeLog:
> 
>   * (David Miller) return NETDEV_TX_OK from the velocity_xmit
>     function. I'm still a bit unsure on what to actually return in
>     these cases (they are error cases), but other drivers seem to
>     return NETDEV_TX_OK, so that's what I went with.

This still isn't right, sorry.

If you return NETDEV_TX_OK you must free the packet up, either
immediately or in response to the TX interrupt which finishes the
sending of the TX packet.

The case where you aren't getting this right:

+	/* If it's still above 6 we can't do anything */
+	if (skb_shinfo(skb)->nr_frags > 6) {
+		dev_err(&vptr->pdev->dev,
+				"via-velocity: more than 6 frags, can't send.\n");
+		return NETDEV_TX_OK;
+	}

is bogus because you just did __skb_linearize() and it returned zero, therefore
it would be illegal to see ->nr_frags with a > 6 value here.

Just remove this check and block of code entirely.
