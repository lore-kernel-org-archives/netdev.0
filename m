From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC 3/3] cfg80211 thoughts on configuration
Date: Wed, 20 Sep 2006 08:33:06 +0200
Message-ID: <20060920063306.GH18349@postel.suug.ch>
References: <1158230812.2936.46.camel@ux156> <1158231183.2936.55.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	Jiri Benc <jbenc@suse.cz>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:13244 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751217AbWITGcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 02:32:45 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1158231183.2936.55.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2006-09-14 12:53
> This is some preliminary code how I'm currently thinking (and that might
> change radically :) ) configuration might look like.
> 
> It uses the patch I previously posted to make genetlink attributes
> custom-definable.
> 
> --- wireless-dev.orig/include/linux/nl80211.h	2006-09-13 22:06:10.539647141 +0200
> +++ wireless-dev/include/linux/nl80211.h	2006-09-13 22:06:11.919647141 +0200
> @@ -45,6 +45,47 @@ enum {
>  	/* get list of all interfaces belonging to a wiphy */
>  	NL80211_CMD_NEW_INTERFACES,
>  
> +	/* configure device */
> +	NL80211_CMD_CONFIGURE,
> +
> +	/* request configuration */
> +	NL80211_CMD_GET_CONFIG,
> +
> +	/* configuration sent from kernel */
> +	NL80211_CMD_CONFIGURATION,

I think I brought this up already, it's a lot easier to understand
things if you keep it symmetric, i.e. NL80211_CMD_GET_CONFIG triggers
sending a NL80211_CMD_NEW_CONFIG.

> +static int check_information_element(struct nlattr *nla)
> +{
> +	int len = nla_len(nla);
> +	u8 *data = nla_data(nla);
> +	int elementlen;
> +
> +	while (len >= 2) {
> +		/* 1 byte ID, 1 byte len, `len' bytes data */
> +		elementlen = *(data+1) + 2;
> +		data += elementlen;
> +		len -= elementlen;
> +	}
> +	return len ? -EINVAL : 0;
> +}
> +
>  static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
>  	[NL80211_ATTR_IFINDEX] = { .type = NLA_U32 },
>  	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
> @@ -33,6 +49,17 @@ static struct nla_policy nl80211_policy[
>  				 .len = NL80211_MAX_FRAME_LEN },
>  	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ-1 },
>  	[NL80211_ATTR_IFTYPE] = { .type = NLA_U32 },
> +	[NL80211_ATTR_NETWORK_ID] = { .type = NLA_U16 },
> +	[NL80211_ATTR_CHANNEL] = { .type = NLA_U32 },
> +	[NL80211_ATTR_RX_SENSITIVITY] = { .type = NLA_U32 },
> +	[NL80211_ATTR_BSSID] = { .len = 6 },
> +	[NL80211_ATTR_SSID] = { .type = NLA_STRING, .len = 32 },
> +	[NL80211_ATTR_TRANSMIT_POWER] = { .type = NLA_U32 },
> +	[NL80211_ATTR_FRAG_THRESHOLD] = { .type = NLA_U32 },
> +	[NL80211_ATTR_INFORMATION_ELEMENT] = { .type = NLA_CUSTOM_CHECK,
> +					       .check = check_information_element },

Just use a nested attribute here, this new array format you introduce
having 1 byte ID, 1 byte len is equivalent to using a set of nested
attributes with nla_type=id, nla_len=len.
