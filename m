From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH] d80211: Reset assoc and auth retry counters
Date: Wed, 29 Nov 2006 15:27:06 +0100
Message-ID: <a32f33a40611290627q5fb9f905ued49bbae6f5670b3@mail.gmail.com>
References: <200611282056.05641.IvDoorn@gmail.com>
	 <20061129150928.63bf9f02@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.231]:8418 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S967194AbWK2O1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 09:27:09 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1104355nze
        for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 06:27:08 -0800 (PST)
To: "Jiri Benc" <jbenc@suse.cz>
In-Reply-To: <20061129150928.63bf9f02@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/29/06, Jiri Benc <jbenc@suse.cz> wrote:
> On Tue, 28 Nov 2006 20:56:05 +0100, Ivo van Doorn wrote:
> > After a succesfull authentication and association the matching retry
> counter
> > must be reset to 0.
> > Failure to do so will result in failure to authenticate after the
> interface
> > has been deauthenticated. This does not always happen after the first
> > deauthentication, but after the interface has been several times been
> > deauthenticated it will refuse to authenticate.
>
> Thanks for spotting this, but your fix makes statistics about
> authentication/association exported via sysfs useless. The counters
> should be reset before a new authentication/association attempt (as is
> done in ieee80211_sta_new_auth).

Sounds good to me, I was unsure where those counters should be reset anyway. :)

> I think this is a more correct fix:
> @@ -2858,7 +2866,7 @@ int ieee80211_sta_deauthenticate(struct
>  		return -EINVAL;
>
>  	ieee80211_send_deauth(dev, ifsta, reason);
> -	ieee80211_set_associated(dev, ifsta, 0);
> +	ieee80211_set_disassoc(dev, ifsta, 1);
>  	return 0;
>  }
>
> @@ -2878,6 +2886,6 @@ int ieee80211_sta_disassociate(struct ne
>  		return -1;
>
>  	ieee80211_send_disassoc(dev, ifsta, reason);
> -	ieee80211_set_associated(dev, ifsta, 0);
> +	ieee80211_set_disassoc(dev, ifsta, 1);
>  	return 0;
>  }
>

Shouldn't this last one be:
ieee80211_set_disassoc(dev, ifsta, 0)

This one is called from the IOCTL request to dissassociate,
so the interface should still be authenticated (with a valid
auth retry counter).

Ivo
