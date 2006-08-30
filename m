From: Mohamed Abbas <mabbas@linux.intel.com>
Subject: Re: [PATCH 2/7] d80211: add support for SIOCSIWRATE and SIOCGIWRATE
Date: Wed, 30 Aug 2006 11:23:49 -0700
Message-ID: <44F5D7B5.6070808@linux.intel.com>
References: <44F355EE.3090607@linux.intel.com> <20060830171919.GC18041@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:41081 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751288AbWH3SdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 14:33:00 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060830171919.GC18041@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:

>On Mon, Aug 28, 2006 at 01:45:34PM -0700, mabbas wrote:
>
> =20
>
>>This patch modify d80211 to add SIOCSIWRATE and SIOCGIWRATE
>>commands. this patch almost does the same thing as in=20
>>PRISM2_HOSTAPD_SET_RATE_SETS.
>>   =20
>>
>
>I don't think I would like to get this applied since this seems to be
>changing the design on how the per-STA TX rate limiting is done in a
>way that does not match the original design and no justification has
>been given for that change so far. Some comments below.
> =20
>
per-STA rate limiting is enforced by what the AP beacon supported rates=
=20
values . this code is to enforce rate limiting for this interface=20
regarding to any AP we join. looking at the code the overall rate=20
restriction will be a combination of these two restrictions. this code=20
is to implement for the below description in iwconfig man page.

rate/bit[rate]
=46or cards supporting multiple bit rates, set the bit-rate in b/s. The=
=20
bit-rate is the speed at
which bits are transmitted over the medium, the user speed of the link=20
is lower due to medium
sharing and various overhead.
You may append the suffix k, M or G to the value (decimal multiplier :=20
10^3, 10^6 and 10^9 b/s),
or add enough =D9=820=D9=82. Values below 1000 are card specific, usual=
ly an index=20
in the bit-rate list. Use
auto to select automatic bit-rate mode (fallback to lower rate on noisy=
=20
channels), which is the
default for most cards, and fixed to revert back to fixed setting. If=20
you specify a bit-rate value
and append auto, the driver will use all bit-rates lower and equal than=
=20
this value.
Examples :
iwconfig eth0 rate 11M
iwconfig eth0 rate auto
iwconfig eth0 rate 5.5M auto

>
> =20
>
>>--- a/net/d80211/ieee80211_i.h
>>@@ -280,6 +280,9 @@ #define IEEE80211_AUTH_ALG_LEAP BIT(2)
>>    struct sk_buff *probe_resp; /* ProbeResp template for IBSS */
>>    u32 supp_rates_bits;
>>=20
>>+	u32 last_rate; /* last tx data rate value. management and multi cas=
t frame
>>+			* wont be used. */
>>   =20
>>
>
>Is this information valuable enough to collect with all the extra code
>in ieee80211_tx_h_rate_ctrl()? The last rate can be fetched from the S=
TA
>entry. It won't be the exact same value as this one here, but then
>again, I don't really see much point in reporting the last used TX rat=
e
>since it can be changing a lot. Some sort of average over the last N
>frames could be more useful information to collect, if that level of
>detail is needed.
> =20
>
The idea here is to report the last rate performed with this link once=20
requested by iwconfig so the user
can know the performance of the link. I can add some averaging but=20
really the user want to see last value. I thought of using STA entry
but in case IBSS mode there maybe many of them which once to report=20
adding this entry will report last rate used by all of the station.

>
> =20
>
>>--- a/net/d80211/ieee80211_ioctl.c
>>+++ b/net/d80211/ieee80211_ioctl.c
>>@@ -2138,6 +2138,103 @@ static int ieee80211_ioctl_giwretry(stru
>> 	return 0;
>> }
>>=20
>>+static int ieee80211_ioctl_siwrate(struct net_device *dev,
>>+                                struct iw_request_info *info,
>>+                                union iwreq_data *wrqu, char *extra)
>>+{
>>+	struct ieee80211_local *local =3D dev->ieee80211_ptr;
>>+	int i, j;
>>+	u32 target_rate =3D wrqu->bitrate.value /100000;
>>+	u32 fixed;
>>+	int *old_supp =3D local->supp_rates[local->conf.phymode];
>>+	int *supp =3D NULL;
>>+
>>+	/* value =3D -1, fixed =3D 0 means auto only, so we should use
>>+	 * all rates offered by AP
>>+	 * value =3D X, fixed =3D 1 means only rate X
>>+	* value =3D X, fixed =3D 0 means all rates lower equal X */
>>   =20
>>
>
>Please keep in mind that this function can also be called in AP mode.
> =20
>
I can check for STA and IBSS only

> =20
>
>>+	fixed =3D wrqu->bitrate.fixed;
>>+	supp =3D (int *) kmalloc((local->num_curr_rates + 1) *
>>+					sizeof(int), GFP_KERNEL);
>>+	if (!supp)
>>+		return 0;
>>   =20
>>
>
>return -ENOMEM
> =20
>
I will change it to return -ENOMEM

> =20
>
>>+	j =3D 0;
>>+	for (i=3D0; i< local->num_curr_rates; i++) {
>>+		struct ieee80211_rate *rate =3D &local->curr_rates[i];
>>+
>>+		if (target_rate =3D=3D rate->rate) {
>>+			supp[j++] =3D rate->rate;
>>+			break;
>>+		} else if (!fixed)
>>+			supp[j++] =3D rate->rate;
>>+	}
>>   =20
>>
>
>This can allow number of invalid configurations; especially so, since
>there is no synchronization with basic reate sets here. In addition, I
>would not really want to change the supported/basic rate sets this way=
=2E
>If there is desire to limit what rates the TX rate control algorithm i=
s
>using, this should be done by modifying per-STA entry data
>(sta->supp_rates), not the per-radio rate table.
> =20
>
I am calling ieee80211_prepare_rates which will sync basic rate for us.=
=20
again per-STA will be a problem for IBSS since I need to go to each=20
station and apply this, and what about new added station I need to=20
remember to apply this again, I think here is where it belong.

> =20
>
>>+	/* number of supported rate equal to all current supported rate
>>+	 * this equal like supp_rates =3D NULL so save process time and set
>>+	* supp to NULL
>>+	*/
>>+	if ((j >=3D local->num_curr_rates) || (j =3D=3D 0)) {
>>+		kfree(supp);
>>+		supp =3D NULL;
>>   =20
>>
>
>Shouldn't these return an error and not replace the current rate
>configuration?
> =20
>
if we reach here then we support all rates available at this point it i=
s=20
the same as setting supp_rates =3D null, this will be faster so we
dont need to search supp _rates. if supp_rates is null then all rate=20
supported. as this code in ieee80211_prepare_rates show

if (local->supp_rates[local->conf.phymode]) {
if (!rate_list_match(local->supp_rates
[local->conf.phymode],
rate->rate))
continue;
}

> =20
>
>>+	if (old_supp)
>>+		kfree(old_supp);
>>   =20
>>
>
> =20
>
this pointer could be NULL

>No need for 'if (old_supp)' before calling kfree(old_supp).
>
> =20
>
