From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [PATCH 4/10] d80211: reduce mdev usage, fix ieee80211_rx_mgmt
Date: Sun, 19 Nov 2006 08:35:45 -0800
Message-ID: <20061119163545.GA25557@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:11472 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1756765AbWKSQfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 11:35:47 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reply-To: 
In-Reply-To: <1163802439.3392.47.camel@johannes.berg>


> 
> --- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-17 20:01:54.999703408 +0100
> +++ wireless-dev/net/d80211/ieee80211.c	2006-11-17 20:01:55.659703408 +0100
> @@ -210,9 +210,16 @@ static void ieee80211_key_threshold_noti
>  					   struct ieee80211_key *key,
>  					   struct sta_info *sta)
>  {
> +	struct ieee80211_local *local = dev->ieee80211_ptr;
>  	struct sk_buff *skb;
>  	struct ieee80211_msg_key_notification *msg;
>  
> +	/* if no one will get it anyway, don't even allocate it.
> +	 * unlikely because this is only relevant for APs
> +	 * where the device must be open... */
> +	if (unlikely(!local->apdev))
> +		return;

Why not just let it Oops and show the bug?  In what cases is it ok
for apdev to not be set?

>  	skb = dev_alloc_skb(sizeof(struct ieee80211_frame_info) +
>  			    sizeof(struct ieee80211_msg_key_notification));
>  	if (!skb)


Can we get whitespace changes like this in a separate patch?

>  
> -                jiffies_to_timespec(status->hosttime, &ts);
> +		jiffies_to_timespec(status->hosttime, &ts);
>  		fi->hosttime = cpu_to_be64((u64) ts.tv_sec * 1000000 +
>  					   ts.tv_nsec / 1000);
>  		fi->mactime = cpu_to_be64(status->mactime);
>  		switch (status->phymode) {
> -                case MODE_IEEE80211A:
> -                        fi->phytype = htonl(ieee80211_phytype_ofdm_dot11_a);
> -                        break;
> -                case MODE_IEEE80211B:
> -                        fi->phytype = htonl(ieee80211_phytype_dsss_dot11_b);
> -                        break;
> -                case MODE_IEEE80211G:
> -                        fi->phytype = htonl(ieee80211_phytype_pbcc_dot11_g);
> -                        break;
> -                case MODE_ATHEROS_TURBO:
> +		case MODE_IEEE80211A:
> +			fi->phytype = htonl(ieee80211_phytype_ofdm_dot11_a);
> +			break;
> +		case MODE_IEEE80211B:
> +			fi->phytype = htonl(ieee80211_phytype_dsss_dot11_b);
> +			break;
> +		case MODE_IEEE80211G:
> +			fi->phytype = htonl(ieee80211_phytype_pbcc_dot11_g);
> +			break;
> +		case MODE_ATHEROS_TURBO:
>  			fi->phytype =
>  				htonl(ieee80211_phytype_dsss_dot11_turbo);
>                          break;
>                  default:
> -                        fi->phytype = 0xAAAAAAAA;
> +			fi->phytype = 0xAAAAAAAA;
>  			break;
> -                }
> -                fi->channel = htonl(status->channel);
> +		}
> +		fi->channel = htonl(status->channel);


. . . 


>  int ieee80211_set_aid_for_sta(struct net_device *dev, u8 *peer_address,
>  			      u16 aid)
>  {
> +	struct ieee80211_local *local = dev->ieee80211_ptr;
>  	struct sk_buff *skb;
>  	struct ieee80211_msg_set_aid_for_sta *msg;
>  
> +	/* unlikely because if this event only happens for APs,
> +	 * which require an open ap device. */
> +	if (unlikely(!local->apdev))
> +		return 0;

again, so should we just let the Oops happen?

-David
