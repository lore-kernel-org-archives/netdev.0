From: Chen Gang F T <chen.gang.flying.transformer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] drivers/net/wireless/ipw2x00: use strlcpy instead of
 strncpy
Date: Mon, 07 Jan 2013 10:57:55 +0800
Message-ID: <50EA39B3.1050008@gmail.com>
References: <50E82D7D.4090107@asianux.com> <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020805020104070605060406"
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50EA37CE.1090901-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020805020104070605060406
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

于 2013年01月07日 10:49, Chen Gang 写道:
> 于 2013年01月05日 22:42, Joe Perches 写道:
>> This happens because escaped is declared the wrong size.
>>
>> It'd be better to change
>> 	char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
>> to
>> 	DECLARE_SSID_BUF(escaped);
>> and use
>> 	print_ssid(escaped, network->ssid, network->ssid_len)
>> in the debug.
>>
> 
>   if what you said is true:
>     it is better to delete escaped variable
>     use ssid instead of escaped, directly.
> 
   oh, sorry, it is my fault.
   we need use duplicate buffer to print different contents, at the same time.

   :-)

   but I still suggest to keep original author using
      maybe he intend to keep the print size for output format
      so I think it is better to only fix bug, not touch the features. 

   Regards

 gchen.



>   but I think the original author intended to use escaped instead of ssid
>     DECLARE_SSID_BUF(ssid)  (line 5525, 5737)
>     use ssid to print debug information directly
>       (such as: line 5530..5535, 5545..5549, 5745..5749, ...)
>     when need print additional information, use escaped
>       (line 5559..5569, 5773..5782, 5791..5799)
> 
>   so, I still suggest:
>     only fix the bug (use strlcpy instead of strncpy)
>     and not touch original features which orignal author intended using.
> 
>   Regards
> 
> gchen.
> 
> in drivers/net/wireless/ipw2x00/ipw2200.c:
> 
>  5519 static int ipw_find_adhoc_network(struct ipw_priv *priv,
>  5520                                   struct ipw_network_match *match,
>  5521                                   struct libipw_network *network,
>  5522                                   int roaming)
>  5523 {
>  5524         struct ipw_supported_rates rates;
>  5525         DECLARE_SSID_BUF(ssid);
>  5526 
>  5527         /* Verify that this network's capability is compatible with the
>  5528          * current mode (AdHoc or Infrastructure) */
>  5529         if ((priv->ieee->iw_mode == IW_MODE_ADHOC &&
>  5530              !(network->capability & WLAN_CAPABILITY_IBSS))) {
>  5531                 IPW_DEBUG_MERGE("Network '%s (%pM)' excluded due to "
>  5532                                 "capability mismatch.\n",
>  5533                                 print_ssid(ssid, network->ssid,
>  5534                                            network->ssid_len),
>  5535                                 network->bssid);
>  5536                 return 0;
>  5537         }
>  5538 
>  5539         if (unlikely(roaming)) {
>  5540                 /* If we are roaming, then ensure check if this is a valid
>  5541                  * network to try and roam to */
>  5542                 if ((network->ssid_len != match->network->ssid_len) ||
>  5543                     memcmp(network->ssid, match->network->ssid,
>  5544                            network->ssid_len)) {
>  5545                         IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
>  5546                                         "because of non-network ESSID.\n",
>  5547                                         print_ssid(ssid, network->ssid,
>  5548                                                    network->ssid_len),
>  5549                                         network->bssid);
>  5550                         return 0;
>  5551                 }
>  5552         } else {
>  5553                 /* If an ESSID has been configured then compare the broadcast
>  5554                  * ESSID to ours */
>  5555                 if ((priv->config & CFG_STATIC_ESSID) &&
>  5556                     ((network->ssid_len != priv->essid_len) ||
>  5557                      memcmp(network->ssid, priv->essid,
>  5558                             min(network->ssid_len, priv->essid_len)))) {
>  5559                         char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
>  5560 
>  5561                         strncpy(escaped,
>  5562                                 print_ssid(ssid, network->ssid,
>  5563                                            network->ssid_len),
>  5564                                 sizeof(escaped));
>  5565                         IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
>  5566                                         "because of ESSID mismatch: '%s'.\n",
>  5567                                         escaped, network->bssid,
>  5568                                         print_ssid(ssid, priv->essid,
>  5569                                                    priv->essid_len));
>  5570                         return 0;
>  5571                 }
>  5572         }
>  ...
>  
>  5732 static int ipw_best_network(struct ipw_priv *priv,
>  5733                             struct ipw_network_match *match,
>  5734                             struct libipw_network *network, int roaming)
>  5735 {
>  5736         struct ipw_supported_rates rates;
>  5737         DECLARE_SSID_BUF(ssid);
>  5738 
>  5739         /* Verify that this network's capability is compatible with the
>  5740          * current mode (AdHoc or Infrastructure) */
>  5741         if ((priv->ieee->iw_mode == IW_MODE_INFRA &&
>  5742              !(network->capability & WLAN_CAPABILITY_ESS)) ||
>  5743             (priv->ieee->iw_mode == IW_MODE_ADHOC &&
>  5744              !(network->capability & WLAN_CAPABILITY_IBSS))) {
>  5745                 IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded due to "
>  5746                                 "capability mismatch.\n",
>  5747                                 print_ssid(ssid, network->ssid,
>  5748                                            network->ssid_len),
>  5749                                 network->bssid);
>  5750                 return 0;
>  5751         }
>  5752 
>  5753         if (unlikely(roaming)) {
>  5754                 /* If we are roaming, then ensure check if this is a valid
>  5755                  * network to try and roam to */
>  5756                 if ((network->ssid_len != match->network->ssid_len) ||
>  5757                     memcmp(network->ssid, match->network->ssid,
>  5758                            network->ssid_len)) {
>  5759                         IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
>  5760                                         "because of non-network ESSID.\n",
>  5761                                         print_ssid(ssid, network->ssid,
>  5762                                                    network->ssid_len),
>  5763                                         network->bssid);
>  5764                         return 0;
>  5765                 }
>  5766         } else {
>  5767                 /* If an ESSID has been configured then compare the broadcast
>  5768                  * ESSID to ours */
>  5769                 if ((priv->config & CFG_STATIC_ESSID) &&
>  5770                     ((network->ssid_len != priv->essid_len) ||
>  5771                      memcmp(network->ssid, priv->essid,
>  5772                             min(network->ssid_len, priv->essid_len)))) {
>  5773                         char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
>  5774                         strncpy(escaped,
>  5775                                 print_ssid(ssid, network->ssid,
>  5776                                            network->ssid_len),
>  5777                                 sizeof(escaped));
>  5778                         IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
>  5779                                         "because of ESSID mismatch: '%s'.\n",
>  5780                                         escaped, network->bssid,
>  5781                                         print_ssid(ssid, priv->essid,
>  5782                                                    priv->essid_len));
>  5783                         return 0;
>  5784                 }
>  5785         }
>  5786 
>  5787         /* If the old network rate is better than this one, don't bother
>  5788          * testing everything else. */
>  5789         if (match->network && match->network->stats.rssi > network->stats.rssi) {
>  5790                 char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
>  5791                 strncpy(escaped,
>  5792                         print_ssid(ssid, network->ssid, network->ssid_len),
>  5793                         sizeof(escaped));
>  5794                 IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded because "
>  5795                                 "'%s (%pM)' has a stronger signal.\n",
>  5796                                 escaped, network->bssid,
>  5797                                 print_ssid(ssid, match->network->ssid,
>  5798                                            match->network->ssid_len),
>  5799                                 match->network->bssid);
>  5800                 return 0;
>  5801         }
> 


-- 
Chen Gang

Flying Transformer

--------------020805020104070605060406
Content-Type: text/x-vcard; charset=utf-8;
 name="chen_gang_flying_transformer.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chen_gang_flying_transformer.vcf"

YmVnaW46dmNhcmQNCmZuOkNoZW4gR2FuZw0Kbjo7Q2hlbiBHYW5nDQp2ZXJzaW9uOjIuMQ0K
ZW5kOnZjYXJkDQoNCg==
--------------020805020104070605060406--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
