From: Amitkumar Karwar <akarwar@marvell.com>
Subject: RE: question about potential integer truncation in
 mwifiex_set_wapi_ie and mwifiex_set_wps_ie
Date: Fri, 9 Oct 2015 12:05:01 +0000
Message-ID: <464d9553bace4971add4c3b448a1255f@SC-EXCH04.marvell.com>
References: <560AAC78.14106.6193CAA9@pageexec.freemail.hu>
 <20150929231038.GG8613@us.netrek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Avinash Patil <patila@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"re.emese@gmail.com" <re.emese@gmail.com>,
	"spender@grsecurity.net" <spender@grsecurity.net>
To: "quozl@laptop.org" <quozl@laptop.org>,
	PaX Team <pageexec@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:22427 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750702AbbJIMFf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2015 08:05:35 -0400
In-Reply-To: <20150929231038.GG8613@us.netrek.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi James/PaX Team,

> -----Original Message-----
> From: quozl@laptop.org [mailto:quozl@laptop.org]
> Sent: Wednesday, September 30, 2015 4:41 AM
> To: PaX Team
> Cc: Amitkumar Karwar; Avinash Patil; Kalle Valo; linux-
> wireless@vger.kernel.org; netdev@vger.kernel.org; re.emese@gmail.com;
> spender@grsecurity.net
> Subject: Re: question about potential integer truncation in
> mwifiex_set_wapi_ie and mwifiex_set_wps_ie
> 
> On Tue, Sep 29, 2015 at 05:21:28PM +0200, PaX Team wrote:
> > hi all,
> >
> > in drivers/net/wireless/mwifiex/sta_ioctl.c the following functions
> >
> > 	mwifiex_set_wpa_ie_helper
> > 	mwifiex_set_wapi_ie
> > 	mwifiex_set_wps_ie
> >
> > can truncate the incoming ie_len argument from u16 to u8 when it gets
> > stored in mwifiex_private.wpa_ie_len, mwifiex_private.wapi_ie_len and
> > mwifiex_private.wps_ie_len, respectively. based on some light code
> > reading it seems a length value of 256 is valid (IEEE_MAX_IE_SIZE and
> > MWIFIEX_MAX_VSIE_LEN seem to limit it) and thus would get truncated to
> > 0 when stored in those u8 fields. the question is whether this is
> > intentional or a bug somewhere.
> 
> i agree, while there is a test to ensure ie_len is not greater than 256,
> there is a possibility that it will be exactly 256, which means
> 256 bytes will be given to memcpy but
> mwifiex_private.{wpa,wapi,wps}_ie_len will be zero.
> 
> i suggest changing the lengths to u16.  not tested.
> 
> diff --git a/drivers/net/wireless/mwifiex/main.h
> b/drivers/net/wireless/mwifiex/main.h
> index fe12560..b66e9a7 100644
> --- a/drivers/net/wireless/mwifiex/main.h
> +++ b/drivers/net/wireless/mwifiex/main.h
> @@ -512,14 +512,14 @@ struct mwifiex_private {
>  	struct mwifiex_wep_key wep_key[NUM_WEP_KEYS];
>  	u16 wep_key_curr_index;
>  	u8 wpa_ie[256];
> -	u8 wpa_ie_len;
> +	u16 wpa_ie_len;
>  	u8 wpa_is_gtk_set;
>  	struct host_cmd_ds_802_11_key_material aes_key;
>  	struct host_cmd_ds_802_11_key_material_v2 aes_key_v2;
>  	u8 wapi_ie[256];
> -	u8 wapi_ie_len;
> +	u16 wapi_ie_len;
>  	u8 *wps_ie;
> -	u8 wps_ie_len;
> +	u16 wps_ie_len;
>  	u8 wmm_required;
>  	u8 wmm_enabled;
>  	u8 wmm_qosinfo;
> 

This change makes sense. Also, we should not typecast the length to v8 while copying to mwifiex_private variable.

./sta_ioctl.c:761:		priv->wpa_ie_len = (u8) ie_len;

Eventually the length stored in 'wapi_ie_len' is copied to a u16 variable.

/join.c:304:		ie_header.len = cpu_to_le16(priv->wapi_ie_len);

I will submit a patch to fix this.

Regards,
Amitkumar
