From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] ieee80211: Move IV/ICV stripping into ieee80211_rx
Date: Tue, 26 Sep 2006 23:02:16 -0500
Message-ID: <4519F7C8.2040503@lwfinger.net>
References: <20060927025031.90F567B40A0@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net, mb@bu3sch.de,
	ipw2100-admin@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:16516 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932394AbWI0ECY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 00:02:24 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060927025031.90F567B40A0@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> This patch adds a host_strip_iv_icv flag to ieee80211 which indicates that
> ieee80211_rx should strip the IV/ICV/other security features from the payload.
> This saves on some memmove() calls in the driver and seems like something that
> belongs in the stack as it can be used by bcm43xx, ipw2200, and zd1211rw
> 
> I will submit the ipw2200 patch separately as it needs testing.
> 
> This patch also adds some sensible variable reuse (idx vs keyidx) in
> ieee80211_rx
> 
> Signed-off-by: Daniel Drake <dsd@gentoo.org>
> Acked-by: Johannes Berg <johannes@sipsolutions.net>
> 
> Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
> ===================================================================
> --- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
> +++ linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
> @@ -543,25 +543,6 @@ int bcm43xx_rx(struct bcm43xx_private *b
>  		break;
>  	}
>  
> -	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
> -	if ((frame_ctl & IEEE80211_FCTL_PROTECTED) && !bcm->ieee->host_decrypt) {
> -		frame_ctl &= ~IEEE80211_FCTL_PROTECTED;
> -		wlhdr->frame_ctl = cpu_to_le16(frame_ctl);		
> -		/* trim IV and ICV */
> -		/* FIXME: this must be done only for WEP encrypted packets */
> -		if (skb->len < 32) {
> -			dprintkl(KERN_ERR PFX "RX packet dropped (PROTECTED flag "
> -					      "set and length < 32)\n");
> -			return -EINVAL;
> -		} else {		
> -			memmove(skb->data + 4, skb->data, 24);
> -			skb_pull(skb, 4);
> -			skb_trim(skb, skb->len - 4);
> -			stats.len -= 8;
> -		}
> -		wlhdr = (struct ieee80211_hdr_4addr *)(skb->data);
> -	}
> -	
>  	switch (WLAN_FC_GET_TYPE(frame_ctl)) {

At this point, gcc warns that frame_ctl has been used uninitialized. Did you mean to remove the 
extraction of frame_ctl from wlhdr just before the previous 'if'?

Larry

