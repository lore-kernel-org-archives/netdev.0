From: James Cameron <quozl-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>
Subject: Re: question about potential integer truncation in
 mwifiex_set_wapi_ie and mwifiex_set_wps_ie
Date: Wed, 30 Sep 2015 09:10:38 +1000
Message-ID: <20150929231038.GG8613@us.netrek.org>
References: <560AAC78.14106.6193CAA9@pageexec.freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Avinash Patil <patila-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	re.emese-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, spender-JNS0hek0TMl4qEwOxq4T+Q@public.gmane.org
To: PaX Team <pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <560AAC78.14106.6193CAA9-tVCe0bXVy/VhMnff8nq0I0CAg8bcNmFB@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 29, 2015 at 05:21:28PM +0200, PaX Team wrote:
> hi all,
> 
> in drivers/net/wireless/mwifiex/sta_ioctl.c the following functions
> 
> 	mwifiex_set_wpa_ie_helper
> 	mwifiex_set_wapi_ie
> 	mwifiex_set_wps_ie
> 
> can truncate the incoming ie_len argument from u16 to u8 when it gets
> stored in mwifiex_private.wpa_ie_len, mwifiex_private.wapi_ie_len and
> mwifiex_private.wps_ie_len, respectively. based on some light code
> reading it seems a length value of 256 is valid (IEEE_MAX_IE_SIZE and
> MWIFIEX_MAX_VSIE_LEN seem to limit it) and thus would get truncated
> to 0 when stored in those u8 fields. the question is whether this is
> intentional or a bug somewhere.

i agree, while there is a test to ensure ie_len is not greater than
256, there is a possibility that it will be exactly 256, which means
256 bytes will be given to memcpy but
mwifiex_private.{wpa,wapi,wps}_ie_len will be zero.

i suggest changing the lengths to u16.  not tested.

diff --git a/drivers/net/wireless/mwifiex/main.h b/drivers/net/wireless/mwifiex/main.h
index fe12560..b66e9a7 100644
--- a/drivers/net/wireless/mwifiex/main.h
+++ b/drivers/net/wireless/mwifiex/main.h
@@ -512,14 +512,14 @@ struct mwifiex_private {
 	struct mwifiex_wep_key wep_key[NUM_WEP_KEYS];
 	u16 wep_key_curr_index;
 	u8 wpa_ie[256];
-	u8 wpa_ie_len;
+	u16 wpa_ie_len;
 	u8 wpa_is_gtk_set;
 	struct host_cmd_ds_802_11_key_material aes_key;
 	struct host_cmd_ds_802_11_key_material_v2 aes_key_v2;
 	u8 wapi_ie[256];
-	u8 wapi_ie_len;
+	u16 wapi_ie_len;
 	u8 *wps_ie;
-	u8 wps_ie_len;
+	u16 wps_ie_len;
 	u8 wmm_required;
 	u8 wmm_enabled;
 	u8 wmm_qosinfo;

-- 
James Cameron
http://quozl.linux.org.au/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
